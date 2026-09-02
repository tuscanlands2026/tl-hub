-- =====================================================================
-- 0035 · O IDIOMA DA VENDA CHEGA INTEIRO NA ORDER E NO E-MAIL
--
-- Um defeito só, aparecendo em três lugares. A proposta escrita em
-- inglês tem o texto em title_en/details_en/room_type_en e o campo
-- português vazio. A página que o cliente vê resolve isso desde a 0005
-- (case when ing then coalesce(nullif(title_en,''), title) ...), mas
-- quem lê depois dela não resolvia: guardava e imprimia a coluna
-- portuguesa, crua.
--
--   · No e-mail de resposta, a linha saía SEM TÍTULO — só data,
--     "(opcional)" e valor. Foi o que ela viu na TL-042-26.
--   · Na order, o serviço nascia em português (ou vazio) mesmo com a
--     order em inglês. A "confirmation of services" saía bilíngue ao
--     contrário: rótulos em inglês, serviços em português.
--   · Os trens "não copiaram as informações": a descrição estava em
--     details_en, e o que era copiado é details.
--
-- Correção nas duas pontas que leem a resposta, sempre pelo item de
-- origem (a linha guarda item_id), com o mesmo desempate das outras
-- funções da casa — o idioma pedido primeiro, o outro como reserva.
-- Assim vale também para as respostas já gravadas, sem refazer nada.
--
-- Três decisões que vão junto, pedidas por ela em setembro/26:
--
-- 1. O E-MAIL SAI NO IDIOMA DA PROPOSTA. Ela encaminha esse e-mail
--    para a agência, e um aviso em português numa venda americana não
--    serve. A única linha que NÃO sai na versão inglesa é o lembrete
--    interno ("a order não foi criada") — é recado de casa, e quem
--    recebe encaminhado não tem o que fazer com ele.
--
-- 2. A LINHA DA HOSPEDAGEM NA ORDER PERDE O TEXTO DE VENDA. Na order
--    ela quer o tipo de quarto, não o parágrafo da proposta: "Deluxe
--    room (brighter Double Room that opens toward the main square)".
--    O texto de venda continua na proposta, que é onde ele convence.
--    Vale só para hospedagem (kind='stay'); no resto — trem, transfer,
--    experiência — a descrição é a informação operacional e continua.
--
-- 3. AS UNIDADES VIRAM LINHA. O que a hospedagem é feita (1 Prestige +
--    2 Luxury, os trechos do trem) tinha valor próprio na proposta e
--    sumia na order: só os extras viravam linha. Agora cada unidade
--    escolhida desce como linha, com o seu valor, abaixo do serviço a
--    que pertence — que é como ela pediu na 0014 e como o total da
--    quote já somava.
--
-- Só objetos ops_ e funções tl_.
-- =====================================================================

-- A referência da proposta que originou a order, para o documento dizer
-- de onde veio sem ter de caçar a seleção.
alter table ops_orders add column if not exists proposal_ref text;
comment on column ops_orders.proposal_ref is
  'Proposta que originou a order (título · versão). Só leitura, para o documento.';

-- ------------------------------------------------------- DESEMPATE ---
-- O idioma pedido primeiro; o outro como reserva, para nunca sair vazio.
-- É a mesma regra que tl_get_quote já usa desde a 0005, agora com nome.
create or replace function tl_txt(p_ing boolean, p_pt text, p_en text)
returns text
language sql
immutable
as $$
  select case when p_ing
              then coalesce(nullif(p_en,''), nullif(p_pt,''))
              else coalesce(nullif(p_pt,''), nullif(p_en,'')) end;
$$;
comment on function tl_txt(boolean,text,text) is
  'Texto no idioma pedido, com o outro idioma como reserva.';

-- =====================================================================
-- E-MAIL DA RESPOSTA — no idioma da proposta, com o título resolvido
-- =====================================================================
create or replace function tl_notify_quote()
returns trigger
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  c       ops_notify_config%rowtype;
  pp      ops_proposals%rowtype;
  o       ops_opportunities%rowtype;
  it      ops_proposal_items%rowtype;
  ln      jsonb;
  ex      jsonb;
  ing     boolean;
  tit     text;
  linhas  text := '';
  assunto text;
  corpo   text;
  req_id  bigint;
begin
  select * into c from ops_notify_config where id = 1;
  if not found or c.enabled is not true or coalesce(c.resend_key,'') = '' then
    return new;
  end if;

  select * into pp from ops_proposals     where id = new.proposal_id;
  select * into o  from ops_opportunities where id = pp.opportunity_id;
  ing := coalesce(pp.lang, o.lang, 'pt') = 'en';

  for ln in select * from jsonb_array_elements(new.lines) loop
    tit := null;
    if nullif(ln->>'item_id','') is not null then
      select * into it from ops_proposal_items where id = (ln->>'item_id')::uuid;
      if found then tit := tl_txt(ing, it.title, it.title_en); end if;
    end if;
    tit := coalesce(tit, nullif(ln->>'title',''), '—');

    linhas := linhas
      || '<tr><td style="padding:5px 12px 5px 0;color:#595e49;white-space:nowrap;">'
      || tl_html(coalesce(ln->>'service_date','')) || '</td>'
      || '<td style="padding:5px 12px 5px 0;">'
      || case when (ln->>'chosen')::boolean then '' else '<span style="color:#a2564c;">✕ </span>' end
      || tl_html(tit)
      || case when (ln->>'optional')::boolean
              then ' <span style="color:#6b6860;font-size:11px;">'
                   || case when ing then '(optional)' else '(opcional)' end || '</span>'
              else '' end;
    for ex in select * from jsonb_array_elements(coalesce(ln->'units','[]'::jsonb)) loop
      linhas := linhas || '<br><span style="color:#595e49;font-size:12px;">· '
        || tl_html(coalesce(tl_txt(ing, ex->>'label', ex->>'label_en'), ex->>'key'))
        || case when pp.show_prices then ' · ' || tl_eur((ex->>'price')::numeric) else '' end
        || '</span>';
    end loop;
    for ex in select * from jsonb_array_elements(coalesce(ln->'extras','[]'::jsonb)) loop
      linhas := linhas || '<br><span style="color:#a56850;font-size:12px;">+ '
        || tl_html(coalesce(tl_txt(ing, ex->>'label_pt', ex->>'label_en'), ex->>'key'))
        || case when pp.show_prices then ' · ' || tl_eur((ex->>'price')::numeric) else '' end
        || '</span>';
    end loop;
    linhas := linhas || '</td><td style="padding:5px 0;text-align:right;white-space:nowrap;">'
      || case when not (ln->>'chosen')::boolean then '—'
              when pp.show_prices then tl_eur(coalesce((ln->>'price')::numeric,0)
                   + coalesce((select sum((u->>'price')::numeric)
                                 from jsonb_array_elements(coalesce(ln->'units','[]'::jsonb)) u),0)
                   + coalesce((select sum((e2->>'price')::numeric)
                                 from jsonb_array_elements(coalesce(ln->'extras','[]'::jsonb)) e2),0))
              else '' end
      || '</td></tr>';
  end loop;

  assunto := case
      when new.confirm_mode = 'simple' and ing then 'Interest confirmed · '
      when new.confirm_mode = 'simple'         then 'Interesse confirmado · '
      when ing                                 then 'Quote answered · '
      else 'Quote respondida · ' end
    || coalesce(o.crm_code, pp.title, '')
    || ' · ' || coalesce(new.lead_name, o.agency, '');

  corpo :=
    '<div style="font-family:''Libre Franklin'',Helvetica,Arial,sans-serif;font-size:14px;line-height:1.6;color:#2a2a28;max-width:640px;">'
    || '<p style="font-size:11px;letter-spacing:.2em;text-transform:uppercase;color:#595e49;margin:0 0 4px;">'
    || case when ing then 'Tuscan Lands · quote answered' else 'Tuscan Lands · quote respondida' end || '</p>'
    || '<div style="width:30px;height:1px;background:#a56850;margin:0 0 18px;"></div>'
    || '<p style="margin:0 0 18px;"><strong style="font-size:17px;">'
    || tl_html(coalesce(o.final_client, o.agency, '')) || '</strong><br>'
    || tl_html(coalesce(pp.title,'')) || case when ing then ' · version ' else ' · versão ' end || pp.version || '<br>'
    || case when ing then 'Opportunity ' else 'Oportunidade ' end || tl_html(coalesce(o.crm_code,'—')) || '<br>'
    || case when ing then 'Travel dates: ' else 'Período: ' end || tl_html(coalesce(pp.travel_window,'—')) || '</p>'
    || case when new.confirm_mode = 'simple'
            then '<p>' || case when ing then 'Interest confirmed by <strong>' else 'Interesse confirmado por <strong>' end
                 || tl_html(coalesce(new.lead_name, o.agency, '—')) || '</strong>'
                 || case when ing then ''
                         else '<br><span style="color:#6b6860;font-size:12px;">'
                              || 'Proposta enviada com o bloco simples: só a confirmação de interesse.</span>' end
                 || '</p>'
            else '<p>' || case when ing then 'Answered by <strong>' else 'Respondida por <strong>' end
                 || tl_html(coalesce(new.lead_name,'—')) || '</strong><br>'
                 || case when coalesce(new.agency_name,'') <> ''
                         then case when ing then 'Agency: ' else 'Agência: ' end
                              || tl_html(new.agency_name) || '<br>' else '' end
                 || case when coalesce(new.designer_name,'') <> ''
                         then 'Travel designer: ' || tl_html(new.designer_name) || '<br>' else '' end
                 || case when ing then 'Contact: ' else 'Contato: ' end
                 || tl_html(coalesce(new.lead_email,'—')) || ' · '
                 || tl_html(coalesce(new.lead_phone,'—')) || '</p>' end
    || case when coalesce(new.remarks,'') <> ''
            then '<p>' || case when ing then 'Remarks:<br><em>' else 'Observações:<br><em>' end
                 || replace(tl_html(new.remarks), E'\n','<br>') || '</em></p>'
            else '' end
    || '<p style="font-size:11px;letter-spacing:.16em;text-transform:uppercase;color:#595e49;margin:22px 0 6px;">'
    || case when ing then 'What was selected' else 'O que ele escolheu' end || '</p>'
    || '<table style="border-collapse:collapse;font-size:14px;width:100%;">' || linhas || '</table>'
    || case when pp.show_prices
            then '<p style="margin:10px 0 0;text-align:right;"><strong>Total ' || tl_eur(new.total) || '</strong></p>'
            when ing
            then '<p style="margin:10px 0 0;color:#6b6860;font-size:12px;">Proposal sent without prices.</p>'
            else '<p style="margin:10px 0 0;color:#6b6860;font-size:12px;">Proposta enviada sem preços.</p>' end
    -- O lembrete interno fica fora da versão inglesa: esse e-mail é
    -- encaminhado para a agência, e recado de casa não se encaminha.
    || case when ing then ''
            else '<p style="font-size:12px;color:#6b6860;margin-top:26px;border-top:1px solid #eae4db;padding-top:12px;">'
                 || 'A order <strong>não</strong> foi criada. Reconfirme os serviços e gere a order pelo hub.</p>' end
    || '</div>';

  begin
    select net.http_post(
      url     := 'https://api.resend.com/emails',
      headers := jsonb_build_object('Content-Type','application/json',
                                    'Authorization','Bearer ' || c.resend_key),
      body    := jsonb_build_object('from', c.mail_from,
                                    'to', string_to_array(c.mail_to, ','),
                                    'subject', assunto, 'html', corpo),
      timeout_milliseconds := 8000
    ) into req_id;
    insert into ops_notifications (order_id, kind, mail_to, subject, net_request_id)
    values (null, 'quote_answered', c.mail_to, assunto, req_id);
  exception when others then
    insert into ops_notifications (order_id, kind, mail_to, subject, error)
    values (null, 'quote_answered', c.mail_to, assunto, sqlerrm);
  end;

  return new;
end $$;

-- =====================================================================
-- ORDER A PARTIR DA QUOTE — no idioma da order, e com as unidades
-- =====================================================================
create or replace function tl_order_from_quote(p_selection uuid)
returns jsonb
language plpgsql
set search_path = public
as $$
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
      end if;
      tit := coalesce(tit, '—');

      insert into ops_order_items (order_id, sort, service_date, title, details, price, supplier)
      values (novo, n, ln->>'service_date', tit, det,
              coalesce((ln->>'price')::numeric, 0), ln->>'supplier');
      n := n + 1;

      -- Do que o serviço é feito: cada unidade escolhida vira linha,
      -- com o valor dela, logo abaixo do serviço que a gerou.
      for ex in select * from jsonb_array_elements(coalesce(ln->'units','[]'::jsonb)) loop
        insert into ops_order_items (order_id, sort, service_date, title, details, price, supplier)
        values (novo, n, ln->>'service_date',
                coalesce(tl_txt(ing, ex->>'label', ex->>'label_en'), ex->>'key'),
                tit, coalesce((ex->>'price')::numeric, 0), ln->>'supplier');
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
end $$;

revoke all on function tl_order_from_quote(uuid) from public, anon;
grant execute on function tl_order_from_quote(uuid) to authenticated;

insert into ops_migrations (id) values ('0035-idioma-da-venda') on conflict (id) do nothing;
