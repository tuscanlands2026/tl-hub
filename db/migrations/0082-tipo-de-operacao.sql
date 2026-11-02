-- 0082-tipo-de-operacao.sql
-- Tipo de OPERAÇÃO em cada linha da order. Pedido dela, 02/11/26: o Checklist do CRM
-- adivinhava o tipo pela categoria de venda, e "TL Signature Programs" — que é o pacote — fez o
-- Palazzo Ripetta da TL-055 nascer como guia. "Cria um campo a mais, porque pode ser hotel, pode
-- ser transfer, pode ser tour, pode ser experiência… pode ser só uma degustação."
--
-- Dois campos com trabalhos diferentes, lado a lado na linha:
--   crm_type = categoria de VENDA (Stays, Ground, Experiences, Programs…) — IVA, CRM, exportação;
--   op_tipo  = o que a linha É na operação — a mesma lista de op_servicos.tipo no CRM, que
--              escolhe o modelo do voucher, a cor na agenda e as etapas do Checklist.
-- Lista nova seria um terceiro vocabulário. "Degustação" cabe em Tour guiado ou Full experience.
--
-- Interno: tl_get_order, tl_get_proforma e o e-mail montam o objeto campo a campo, e este não
-- entra. Order que já existe fica com o campo vazio — nada é reescrito.
--
-- A order que nasce da proposta já vem com o tipo quando a proposta sabe: hospedagem (e cada
-- quarto dela) → Hotel; transfer → Transfer. Experiência e extra ficam em branco: quem decide é ela.
--
-- Só cria: coluna e a nova versão de tl_order_from_quote.

alter table ops_order_items add column if not exists op_tipo text;
do $$ begin
  alter table ops_order_items add constraint ops_order_items_op_tipo_check
    check (op_tipo is null or op_tipo in ('hotel','transfer','self_drive','tour_guiado','full_experience','outro'));
exception when duplicate_object then null; end $$;
comment on column ops_order_items.op_tipo is
  'Tipo de operação da linha (hotel, transfer, self_drive, tour_guiado, full_experience, outro) — a lista de op_servicos.tipo do CRM. Não é crm_type, que é categoria de venda.';

create or replace function public.tl_order_from_quote(p_selection uuid)
 returns jsonb
 language plpgsql
 set search_path to 'public'
as $function$
declare
  sel    ops_proposal_selections%rowtype;
  pp     ops_proposals%rowtype;
  o      ops_opportunities%rowtype;
  it     ops_proposal_items%rowtype;
  ln     jsonb;
  ex     jsonb;
  novo   uuid;
  ref    text;
  n      int := 0;
  idioma text;
  ing    boolean;
  achou  boolean;
  tit    text;
  det    text;
  tipo   text;
  optp   text;
begin
  select * into sel from ops_proposal_selections where id = p_selection;
  if not found then return jsonb_build_object('ok', false, 'error', 'selection_not_found'); end if;
  if sel.order_id is not null then
    return jsonb_build_object('ok', false, 'error', 'already_generated', 'order_id', sel.order_id);
  end if;

  select * into pp from ops_proposals    where id = sel.proposal_id;
  select * into o  from ops_opportunities where id = pp.opportunity_id;
  idioma := coalesce(pp.lang, o.lang, 'pt');
  ing    := idioma = 'en';

  update ops_proposals
     set outcome = 'accepted', acceptance_mode = 'written',
         decided_at = coalesce(decided_at, now()), updated_at = now()
   where id = pp.id;

  select coalesce(o.crm_code, pp.title, 'TL') || '.' ||
         (1 + (select count(*) from ops_orders r where r.opportunity_id = o.id))
    into ref;

  insert into ops_orders
    (opportunity_id, opportunity_code, order_ref, lang, status, agency, agency_contact,
     final_client, pax_summary, travel_window, intro, terms_url, payment_note, proposal_ref)
  values (o.id, coalesce(o.crm_code,''), ref, idioma, 'draft', o.agency, o.agency_contact,
     coalesce(o.final_client, sel.lead_name), pp.pax_summary, pp.travel_window,
     pp.intro, pp.terms_url, pp.payment_note,
     case when coalesce(pp.title,'') <> '' then pp.title || ' · v' || pp.version
          else 'v' || pp.version end)
  returning id into novo;

  for ln in select * from jsonb_array_elements(sel.lines) loop
    if (ln->>'chosen')::boolean then
      achou := false;
      if nullif(ln->>'item_id','') is not null then
        select * into it from ops_proposal_items where id = (ln->>'item_id')::uuid;
        achou := found;
      end if;

      if achou then
        tit  := tl_txt(ing, it.title, it.title_en);
        tipo := coalesce(it.kind, ln->>'kind', 'stay');
        -- Hospedagem: o tipo de quarto, e não o texto de venda.
        det  := case when tipo = 'stay'
                     then tl_txt(ing, it.room_type, it.room_type_en)
                     else tl_txt(ing, it.details,   it.details_en) end;
      else
        tit  := nullif(ln->>'title','');
        det  := nullif(ln->>'details','');
        tipo := nullif(ln->>'kind','');
      end if;
      tit := coalesce(tit, '—');
      -- Tipo de operação: só quando a proposta sabe. Experiência e extra ficam para ela.
      optp := case tipo when 'stay' then 'hotel' when 'transfer' then 'transfer' else null end;

      insert into ops_order_items (order_id, sort, service_date, title, details, price, supplier, op_tipo)
      values (novo, n, ln->>'service_date', tit, det,
              coalesce((ln->>'price')::numeric, 0), ln->>'supplier', optp);
      n := n + 1;

      -- Do que o serviço é feito: cada unidade escolhida vira linha,
      -- com o valor dela, logo abaixo do serviço que a gerou. O quarto é do hotel.
      for ex in select * from jsonb_array_elements(coalesce(ln->'units','[]'::jsonb)) loop
        insert into ops_order_items (order_id, sort, service_date, title, details, price, supplier, op_tipo)
        values (novo, n, ln->>'service_date',
                coalesce(tl_txt(ing, ex->>'label', ex->>'label_en'), ex->>'key'),
                tit, coalesce((ex->>'price')::numeric, 0), ln->>'supplier', optp);
        n := n + 1;
      end loop;

      for ex in select * from jsonb_array_elements(coalesce(ln->'extras','[]'::jsonb)) loop
        insert into ops_order_items (order_id, sort, service_date, title, details, price, supplier)
        values (novo, n, ln->>'service_date',
                coalesce(tl_txt(ing, ex->>'label_pt', ex->>'label_en'), ex->>'key'),
                tit, coalesce((ex->>'price')::numeric, 0), ln->>'supplier');
        n := n + 1;
      end loop;
    end if;
  end loop;

  update ops_proposal_selections set order_id = novo where id = sel.id;
  return jsonb_build_object('ok', true, 'order_id', novo, 'order_ref', ref);
end $function$;

insert into ops_migrations (id) values ('0082-tipo-de-operacao') on conflict (id) do nothing;
