-- =====================================================================
-- 0010 · INCLUSO, FORMA DE PAGAMENTO E A FOTO DO "SOBRE NÓS"
--
-- Três coisas que a proposta precisa e não tinha:
--
-- 1. "Incluso" por linha. Diferente da descrição: a descrição vende a
--    propriedade, o incluso diz o que o valor cobre. Misturados, o
--    cliente lê a descrição inteira procurando se o café está incluso.
--
-- 2. Forma de pagamento como escolha do cliente. Ela lança as opções
--    por proposta, porque mudam conforme o caso, e o cliente marca uma.
--    Fica gravada no retrato da escolha.
--
-- 3. A foto do "sobre nós", que é sempre a mesma mas mora na proposta:
--    trocar a foto da casa não deve mudar proposta já enviada.
--
-- Só toca em objetos ops_. Nada fora desse prefixo.
-- =====================================================================

alter table ops_proposal_items add column if not exists included_pt text;
alter table ops_proposal_items add column if not exists included_en text;
comment on column ops_proposal_items.included_pt is
  'O que o valor cobre. Sai como bloco próprio no card, separado da descrição.';

alter table ops_proposals add column if not exists payment_options jsonb not null default '[]'::jsonb;
comment on column ops_proposals.payment_options is
  'Formas de pagamento oferecidas nesta proposta: [{"label","label_en"}]. O cliente marca uma.';

alter table ops_proposals add column if not exists about_img text;

alter table ops_proposal_selections add column if not exists payment_choice text;

-- Foto padrão do "sobre nós" e da capa do resumo, para não redigitar.
insert into ops_text_defaults (key, pt, en) values
  ('about_img', 'https://i.postimg.cc/DZWKjd7N/Tuscan-Lands-Founder-and-CEO-Maria-Fernanda-Batistella-(2).jpg', null),
  ('summary_img', 'https://i.postimg.cc/HsV7Z2fq/Tuscan-Lands-Travel-Luxury-DMC.png', null)
on conflict (key) do update
   set pt = coalesce(nullif(ops_text_defaults.pt,''), excluded.pt), updated_at = now();

update ops_proposals
   set about_img = (select pt from ops_text_defaults where key='about_img')
 where layout = 'apresentada' and coalesce(about_img,'') = '';

create or replace function tl_get_quote(p_token text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  pp ops_proposals%rowtype; o ops_opportunities%rowtype;
  idioma text; ing boolean; secs jsonb; dias jsonb; result jsonb;
begin
  select * into pp from ops_proposals where token = p_token;
  if not found then return null; end if;
  select * into o from ops_opportunities where id = pp.opportunity_id;
  idioma := coalesce(pp.lang, o.lang, 'pt');
  ing := idioma = 'en';

  select coalesce(jsonb_agg(jsonb_build_object(
           'key', s->>'key',
           'title', case when ing then coalesce(nullif(s->>'title_en',''), s->>'title')
                         else coalesce(nullif(s->>'title',''), s->>'title_en') end,
           'note',  case when ing then coalesce(nullif(s->>'note_en',''), s->>'note')
                         else coalesce(nullif(s->>'note',''), s->>'note_en') end,
           'photo', s->>'photo') order by ord), '[]'::jsonb)
    into secs from jsonb_array_elements(coalesce(pp.sections,'[]'::jsonb)) with ordinality as t(s, ord);

  select coalesce(jsonb_agg(jsonb_build_object(
           'date', case when ing then coalesce(nullif(d->>'date_en',''), d->>'date')
                        else coalesce(nullif(d->>'date',''), d->>'date_en') end,
           'lines', case when ing then coalesce(d->'lines_en', d->'lines')
                         else coalesce(d->'lines', d->'lines_en') end) order by ord), '[]'::jsonb)
    into dias from jsonb_array_elements(coalesce(pp.itinerary,'[]'::jsonb)) with ordinality as t(d, ord);

  select jsonb_build_object(
    'proposal', jsonb_build_object(
      'id', pp.id, 'version', pp.version, 'title', pp.title, 'summary', pp.summary,
      'lang', idioma, 'layout', coalesce(pp.layout,'tabela'),
      'pax_summary', pp.pax_summary, 'travel_window', pp.travel_window,
      'intro', pp.intro, 'payment_note', pp.payment_note, 'terms_url', pp.terms_url,
      'cover_img', pp.cover_img,
      'cover_tag', case when ing then coalesce(nullif(pp.cover_tag_en,''), pp.cover_tag_pt)
                        else coalesce(nullif(pp.cover_tag_pt,''), pp.cover_tag_en) end,
      'about', case when ing then coalesce(nullif(pp.about_en,''), pp.about_pt)
                    else coalesce(nullif(pp.about_pt,''), pp.about_en) end,
      'credentials', case when ing then coalesce(nullif(pp.credentials_en,''), pp.credentials_pt)
                          else coalesce(nullif(pp.credentials_pt,''), pp.credentials_en) end,
      'backcover', case when ing then coalesce(nullif(pp.backcover_en,''), pp.backcover_pt)
                        else coalesce(nullif(pp.backcover_pt,''), pp.backcover_en) end,
      'itinerary', dias,
      'conditions', case when ing then coalesce(nullif(pp.conditions_en,''), pp.conditions_pt, pp.conditions)
                         else coalesce(nullif(pp.conditions_pt,''), pp.conditions) end,
      'excluded', case when ing then coalesce(nullif(pp.excluded_en,''), pp.excluded_pt)
                       else coalesce(nullif(pp.excluded_pt,''), pp.excluded_en) end,
      'sections', secs, 'show_prices', pp.show_prices,
      'about_img', pp.about_img,
      'payment_options', coalesce((select jsonb_agg(jsonb_build_object(
          'key', po->>'key',
          'label', case when ing then coalesce(nullif(po->>'label_en',''), po->>'label')
                        else coalesce(nullif(po->>'label',''), po->>'label_en') end) order by ord)
        from jsonb_array_elements(coalesce(pp.payment_options,'[]'::jsonb)) with ordinality as q(po, ord)),
        '[]'::jsonb),
      'crm_code', o.crm_code, 'agency', o.agency, 'final_client', o.final_client,
      'agency_contact', o.agency_contact,
      'outcome', pp.outcome, 'responded_at', pp.responded_at),
    'items', coalesce((select jsonb_agg(jsonb_build_object(
        'id', i.id, 'service_date', i.service_date,
        'title', case when ing then coalesce(nullif(i.title_en,''), i.title)
                      else coalesce(nullif(i.title,''), i.title_en) end,
        'details', case when ing then coalesce(nullif(i.details_en,''), i.details)
                        else coalesce(nullif(i.details,''), i.details_en) end,
        'room_type', case when ing then coalesce(nullif(i.room_type_en,''), i.room_type)
                          else coalesce(nullif(i.room_type,''), i.room_type_en) end,
        'facilities', case when ing then coalesce(nullif(i.facilities_en,''), i.facilities)
                           else coalesce(nullif(i.facilities,''), i.facilities_en) end,
        'included', case when ing then coalesce(nullif(i.included_en,''), i.included_pt)
                         else coalesce(nullif(i.included_pt,''), i.included_en) end,
        'website', i.website, 'photos', i.photos, 'attachments', i.attachments,
        'price', i.price, 'section', i.section,
        'optional', i.optional, 'choice_group', i.choice_group,
        'extras', i.extras) order by i.sort)
      from ops_proposal_items i where i.proposal_id = pp.id), '[]'::jsonb)
  ) into result;
  return result;
end $$;

revoke all on function tl_get_quote(text) from public;
grant execute on function tl_get_quote(text) to anon, authenticated;


create or replace function tl_submit_quote(p_token text, p_payload jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  pp       ops_proposals%rowtype;
  it       ops_proposal_items%rowtype;
  ex       jsonb;
  g        text;
  faltando text[] := '{}';
  marcados jsonb;
  exmarc   jsonb;
  escol    boolean;
  exsel    jsonb;
  linhas   jsonb := '[]'::jsonb;
  soma     numeric := 0;
  quantos  int := 0;
begin
  select * into pp from ops_proposals where token = p_token;
  if not found then return jsonb_build_object('ok', false, 'error', 'not_found'); end if;
  if pp.responded_at is not null then
    return jsonb_build_object('ok', false, 'error', 'already_answered');
  end if;
  if coalesce(btrim(p_payload->>'lead_name'),'') = '' then
    return jsonb_build_object('ok', false, 'error', 'missing_fields', 'missing', to_jsonb(array['lead_name']));
  end if;
  if coalesce((p_payload->>'ack_conditions')::boolean, false) is not true then
    return jsonb_build_object('ok', false, 'error', 'missing_ack');
  end if;

  marcados := coalesce(p_payload->'items','[]'::jsonb);
  exmarc   := coalesce(p_payload->'extras','{}'::jsonb);

  for g in select distinct choice_group from ops_proposal_items
            where proposal_id = pp.id and choice_group is not null loop
    if not exists (select 1 from ops_proposal_items i
                    where i.proposal_id = pp.id and i.choice_group = g
                      and marcados @> to_jsonb(i.id::text)) then
      faltando := array_append(faltando, g);
    end if;
  end loop;
  if array_length(faltando,1) > 0 then
    return jsonb_build_object('ok', false, 'error', 'missing_choice', 'missing', to_jsonb(faltando));
  end if;

  for it in select * from ops_proposal_items where proposal_id = pp.id order by sort loop
    -- Marcada ou não entra. Não existe mais linha que entra sozinha.
    escol := marcados @> to_jsonb(it.id::text);
    exsel := '[]'::jsonb;
    if escol then
      quantos := quantos + 1;
      soma := soma + coalesce(it.price,0);
      for ex in select * from jsonb_array_elements(coalesce(it.extras,'[]'::jsonb)) loop
        if coalesce(exmarc->(it.id::text), '[]'::jsonb) @> to_jsonb(ex->>'key') then
          soma  := soma + coalesce((ex->>'price')::numeric, 0);
          exsel := exsel || jsonb_build_object('key', ex->>'key', 'label_pt', ex->>'label_pt',
            'label_en', ex->>'label_en', 'price', ex->>'price');
        end if;
      end loop;
    end if;
    linhas := linhas || jsonb_build_object(
      'item_id', it.id, 'service_date', it.service_date, 'title', it.title,
      'details', it.details, 'price', it.price, 'optional', it.optional,
      'section', it.section, 'choice_group', it.choice_group,
      'supplier', it.supplier,
      'included', it.included_pt,
      'chosen', escol, 'extras', exsel);
  end loop;

  -- Resposta sem nenhum serviço marcado não é resposta: é formulário
  -- enviado por engano, e viraria uma order vazia lá na frente.
  if quantos = 0 then
    return jsonb_build_object('ok', false, 'error', 'missing_items');
  end if;

  insert into ops_proposal_selections
    (proposal_id, lead_name, lead_email, lead_phone, remarks, lines, total, ack_conditions,
     payment_choice)
  values (pp.id, p_payload->>'lead_name', p_payload->>'lead_email',
          p_payload->>'lead_phone', p_payload->>'remarks', linhas, soma, true,
          p_payload->>'payment_choice');

  update ops_proposals set responded_at = now(), updated_at = now() where id = pp.id;
  return jsonb_build_object('ok', true);
end $$;


revoke all on function tl_submit_quote(text, jsonb) from public;
grant execute on function tl_submit_quote(text, jsonb) to anon, authenticated;

insert into ops_migrations (id) values ('0010-ajustes-da-proposta') on conflict (id) do nothing;
