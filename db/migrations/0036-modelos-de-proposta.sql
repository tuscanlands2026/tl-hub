-- =====================================================================
-- 0036-modelos-de-proposta.sql
--   A folha da Curadoria, o modo de exibição de cada seção, a tarifa
--   net com link separado de valores, e a volta do "selecione a opção
--   aprovada" — agora opcional e desmarcável.
-- =====================================================================
-- Desenho fechado com ela em setembro/26 e escrito em
-- docs/MODELOS-DE-PROPOSTA.md. Esta migração é só o banco: a tela vem
-- em seguida, lendo o que aqui já existe.
-- ---------------------------------------------------------------------

-- 1) A FOLHA DA CURADORIA -------------------------------------------
-- Uma proposta pode levar mais de uma: "Opção 1", "Opção 2". Por isso é
-- lista, e não um par de colunas de texto. Cada folha é livre — os dois
-- campos grandes são texto, não uma linha por data, porque foi assim
-- que ela pediu: "deixa livre para eu escrever".
alter table ops_proposals
  add column if not exists curations jsonb not null default '[]'::jsonb;
comment on column ops_proposals.curations is
  'Folhas de curadoria: [{"opcao","cor","title_pt","title_en","dest_pt","dest_en","dias_pt","dias_en"}]. '
  'cor: verde | terracota. Vazio = a proposta não tem essa folha.';

-- 2) TARIFA: COMISSIONADA OU NET -------------------------------------
-- Net: a proposta sai completa e SEM valores, e sem caixinha de
-- aprovação — ela é peça de apresentação para a agência mandar ao
-- cliente dela. Os valores vão num link separado, no formato tabela, e
-- é lá que a aprovação acontece.
alter table ops_proposals
  add column if not exists rate_type text not null default 'comissionado';
do $$ begin
  if not exists (select 1 from pg_constraint where conname = 'ops_proposals_rate_type_chk') then
    alter table ops_proposals add constraint ops_proposals_rate_type_chk
      check (rate_type in ('comissionado','net'));
  end if;
end $$;
comment on column ops_proposals.rate_type is
  'comissionado: preço na proposta, aprovação do cliente final. '
  'net: proposta sem valores; valores e aprovação no link do net_token.';

-- O link dos valores é OUTRO endereço, e não um parâmetro do primeiro:
-- quem tem o link bonito não descobre o dos valores mudando a URL.
alter table ops_proposals
  add column if not exists net_token text;
update ops_proposals set net_token = gen_random_uuid()::text where net_token is null;
alter table ops_proposals alter column net_token set default gen_random_uuid()::text;
create unique index if not exists ops_proposals_net_token_idx on ops_proposals(net_token);

-- 3) tl_get_quote: modo da seção, curadoria e tarifa ------------------
create or replace function tl_get_quote(p_token text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  pp ops_proposals%rowtype; o ops_opportunities%rowtype;
  idioma text; ing boolean; secs jsonb; dias jsonb; rots jsonb; cur jsonb; result jsonb;
begin
  select * into pp from ops_proposals where token = p_token;
  if not found then return null; end if;
  if pp.token_expires_at is not null and pp.token_expires_at < now() then
    return jsonb_build_object('expired', true);
  end if;
  select * into o from ops_opportunities where id = pp.opportunity_id;
  idioma := coalesce(pp.lang, o.lang, 'pt');
  ing := idioma = 'en';

  -- modo: blocos (um bloco por serviço, numa aba só), dias (programa
  -- cronológico, uma foto por dia) ou abas (uma aba por serviço, em
  -- submenu). Nulo é blocos, que é como tudo nasceu.
  select coalesce(jsonb_agg(jsonb_build_object(
           'key', s->>'key',
           'title', case when ing then coalesce(nullif(s->>'title_en',''), s->>'title')
                         else coalesce(nullif(s->>'title',''), s->>'title_en') end,
           'note',  case when ing then coalesce(nullif(s->>'note_en',''), s->>'note')
                         else coalesce(nullif(s->>'note',''), s->>'note_en') end,
           'photo', s->>'photo',
           'modo', coalesce(nullif(s->>'modo',''), 'blocos')) order by ord), '[]'::jsonb)
    into secs from jsonb_array_elements(coalesce(pp.sections,'[]'::jsonb)) with ordinality as t(s, ord);

  select coalesce(jsonb_agg(jsonb_build_object(
           'date', case when ing then coalesce(nullif(d->>'date_en',''), d->>'date')
                        else coalesce(nullif(d->>'date',''), d->>'date_en') end,
           'lines', case when ing then coalesce(d->'lines_en', d->'lines')
                         else coalesce(d->'lines', d->'lines_en') end) order by ord), '[]'::jsonb)
    into dias from jsonb_array_elements(coalesce(pp.itinerary,'[]'::jsonb)) with ordinality as t(d, ord);

  -- Curadoria já resolvida no idioma: a tela não escolhe coluna.
  select coalesce(jsonb_agg(jsonb_build_object(
           'opcao', c->>'opcao',
           'cor',   coalesce(nullif(c->>'cor',''), 'verde'),
           'title', case when ing then coalesce(nullif(c->>'title_en',''), c->>'title_pt')
                         else coalesce(nullif(c->>'title_pt',''), c->>'title_en') end,
           'destinos', case when ing then coalesce(nullif(c->>'dest_en',''), c->>'dest_pt')
                            else coalesce(nullif(c->>'dest_pt',''), c->>'dest_en') end,
           'dias', case when ing then coalesce(nullif(c->>'dias_en',''), c->>'dias_pt')
                        else coalesce(nullif(c->>'dias_pt',''), c->>'dias_en') end) order by ord), '[]'::jsonb)
    into cur from jsonb_array_elements(coalesce(pp.curations,'[]'::jsonb)) with ordinality as t(c, ord);

  select coalesce(jsonb_object_agg(k, v), '{}'::jsonb) into rots from (
    select r.key as k,
           case when ing then coalesce(nullif(r.value->>'en',''), nullif(r.value->>'pt',''))
                else coalesce(nullif(r.value->>'pt',''), nullif(r.value->>'en','')) end as v
      from jsonb_each(coalesce(pp.labels,'{}'::jsonb)) r
  ) x where v is not null;

  select jsonb_build_object(
    'proposal', jsonb_build_object(
      'id', pp.id, 'version', pp.version, 'title', pp.title, 'summary', pp.summary,
      'lang', idioma, 'layout', coalesce(pp.layout,'tabela'), 'labels', rots,
      'pax_summary', pp.pax_summary, 'travel_window', pp.travel_window,
      'intro', pp.intro, 'payment_note', pp.payment_note, 'terms_url', pp.terms_url,
      'cover_img', pp.cover_img, 'about_img', pp.about_img,
      'white_label', coalesce(pp.white_label, false),
      'agency_logo', pp.agency_logo,
      'agency_logo_bg', coalesce(pp.agency_logo_bg, false),
      'assurance_img', pp.assurance_img,
      'cover_title', case when coalesce(pp.white_label,false)
                          then coalesce(pp.cover_title, o.final_client, '')
                          else coalesce(pp.cover_title, o.final_client, o.agency, '') end,
      'confirm_mode', coalesce(pp.confirm_mode, 'full'),
      'assurance', replace(
        case when ing then coalesce(nullif(pp.assurance_en,''), pp.assurance_pt)
             else coalesce(nullif(pp.assurance_pt,''), pp.assurance_en) end,
        '{agencia}', coalesce(o.agency, '')),
      'cover_tag', case when ing then coalesce(nullif(pp.cover_tag_en,''), pp.cover_tag_pt)
                        else coalesce(nullif(pp.cover_tag_pt,''), pp.cover_tag_en) end,
      'about', case when ing then coalesce(nullif(pp.about_en,''), pp.about_pt)
                    else coalesce(nullif(pp.about_pt,''), pp.about_en) end,
      'credentials', case when ing then coalesce(nullif(pp.credentials_en,''), pp.credentials_pt)
                          else coalesce(nullif(pp.credentials_pt,''), pp.credentials_en) end,
      'backcover', case when ing then coalesce(nullif(pp.backcover_en,''), pp.backcover_pt)
                        else coalesce(nullif(pp.backcover_pt,''), pp.backcover_en) end,
      'backcover_img', pp.backcover_img,
      'itinerary', dias,
      -- novos
      'curations', cur,
      'rate_type', coalesce(pp.rate_type,'comissionado'),
      'conditions', case when ing then coalesce(nullif(pp.conditions_en,''), pp.conditions_pt, pp.conditions)
                         else coalesce(nullif(pp.conditions_pt,''), pp.conditions) end,
      'excluded', case when ing then coalesce(nullif(pp.excluded_en,''), pp.excluded_pt)
                       else coalesce(nullif(pp.excluded_pt,''), pp.excluded_en) end,
      'sections', secs,
      -- Net esconde valor na peça bonita, mesmo que o campo de preços
      -- esteja em "sim": a regra da tarifa manda, para ninguém mandar
      -- valor net ao cliente final por esquecer de virar uma chave.
      'show_prices', case when coalesce(pp.rate_type,'comissionado') = 'net'
                          then false else pp.show_prices end,
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
        'kind', coalesce(i.kind,'stay'),
        'units', coalesce((select jsonb_agg(jsonb_build_object(
            'key', u->>'key',
            'label', case when ing then coalesce(nullif(u->>'label_en',''), u->>'label')
                          else coalesce(nullif(u->>'label',''), u->>'label_en') end,
            'price', (u->>'price')::numeric,
            'optional', coalesce((u->>'optional')::boolean, false)) order by ord)
          from jsonb_array_elements(coalesce(i.units,'[]'::jsonb)) with ordinality as w(u, ord)),
          '[]'::jsonb),
        'website', i.website, 'photos', i.photos, 'attachments', i.attachments,
        'qty', coalesce(i.qty, 1), 'unit_price', i.unit_price,
        'price', i.price, 'section', i.section,
        'optional', i.optional, 'choice_group', i.choice_group,
        'extras', i.extras) order by i.sort)
      from ops_proposal_items i where i.proposal_id = pp.id), '[]'::jsonb)
  ) into result;
  return result;
end $$;

revoke all on function tl_get_quote(text) from public;
grant execute on function tl_get_quote(text) to anon, authenticated;

-- 4) O LINK DOS VALORES ----------------------------------------------
-- Mesma proposta, outra leitura: formato tabela, com valores, e um
-- aviso de que aquilo é o net. Reaproveita tl_get_quote de propósito —
-- duas montagens do mesmo payload divergiriam na primeira mudança.
create or replace function tl_get_net_quote(p_token text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare pp ops_proposals%rowtype; base jsonb;
begin
  select * into pp from ops_proposals where net_token = p_token;
  if not found then return null; end if;
  if coalesce(pp.rate_type,'comissionado') <> 'net' then
    -- Proposta comissionada não tem link de valores: o valor está nela.
    return jsonb_build_object('not_net', true);
  end if;
  if pp.token_expires_at is not null and pp.token_expires_at < now() then
    return jsonb_build_object('expired', true);
  end if;
  base := tl_get_quote(pp.token);
  if base is null then return null; end if;
  return jsonb_set(
           jsonb_set(
             jsonb_set(base, '{proposal,layout}', '"tabela"'::jsonb),
             '{proposal,show_prices}', 'true'::jsonb),
           '{proposal,net_view}', 'true'::jsonb);
end $$;

revoke all on function tl_get_net_quote(text) from public;
grant execute on function tl_get_net_quote(text) to anon, authenticated;

-- 5) tl_submit_quote: aceita o link dos valores e devolve o grupo -----
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
  un       jsonb;
  unsel    jsonb;
  unmarc   jsonb;
  temun    boolean;
  marcados jsonb;
  exmarc   jsonb;
  escol    boolean;
  exsel    jsonb;
  linhas   jsonb := '[]'::jsonb;
  soma     numeric := 0;
  quantos  int := 0;
  simples  boolean;
  dupg     text;
begin
  -- Net: a aprovação chega pelo link dos valores, que é outro token da
  -- mesma proposta. Sem isto, a agência não teria por onde aprovar.
  select * into pp from ops_proposals where token = p_token or net_token = p_token;
  if not found then return jsonb_build_object('ok', false, 'error', 'not_found'); end if;
  if pp.token_expires_at is not null and pp.token_expires_at < now() then
    return jsonb_build_object('ok', false, 'error', 'expired');
  end if;
  if pp.responded_at is not null then
    return jsonb_build_object('ok', false, 'error', 'already_answered');
  end if;
  simples := coalesce(pp.confirm_mode, 'full') = 'simple';
  if not simples and coalesce(btrim(p_payload->>'lead_name'),'') = '' then
    return jsonb_build_object('ok', false, 'error', 'missing_fields', 'missing', to_jsonb(array['lead_name']));
  end if;
  if coalesce((p_payload->>'ack_conditions')::boolean, false) is not true then
    return jsonb_build_object('ok', false, 'error', 'missing_ack');
  end if;

  marcados := coalesce(p_payload->'items','[]'::jsonb);
  exmarc   := coalesce(p_payload->'extras','{}'::jsonb);
  unmarc   := coalesce(p_payload->'units','{}'::jsonb);

  -- Grupo de escolha, de volta e ao contrário do de antes: ele NÃO
  -- obriga a escolher, só impede escolher duas. Conjunto sem nada
  -- marcado simplesmente não entra na order.
  select g into dupg from (
    select coalesce(i.choice_group,'') as g, count(*) as n
      from ops_proposal_items i
     where i.proposal_id = pp.id
       and coalesce(i.choice_group,'') <> ''
       and marcados @> to_jsonb(i.id::text)
     group by 1 having count(*) > 1
     limit 1) d;
  if dupg is not null then
    return jsonb_build_object('ok', false, 'error', 'choice_conflict',
                              'missing', to_jsonb(array[dupg]));
  end if;

  for it in select * from ops_proposal_items where proposal_id = pp.id order by sort loop
    escol := marcados @> to_jsonb(it.id::text);
    exsel := '[]'::jsonb;
    unsel := '[]'::jsonb;
    if escol then
      quantos := quantos + 1;
      soma := soma + coalesce(it.price,0);
      temun := false;
      for un in select * from jsonb_array_elements(coalesce(it.units,'[]'::jsonb)) loop
        if coalesce((un->>'optional')::boolean, false) is not true
           or coalesce(unmarc->(it.id::text), '[]'::jsonb) @> to_jsonb(un->>'key') then
          soma  := soma + coalesce((un->>'price')::numeric, 0);
          unsel := unsel || jsonb_build_object('key', un->>'key', 'label', un->>'label',
            'label_en', un->>'label_en', 'price', un->>'price',
            'optional', coalesce((un->>'optional')::boolean, false));
          temun := true;
        end if;
      end loop;
      if not temun and jsonb_array_length(coalesce(it.units,'[]'::jsonb)) > 0 then
        return jsonb_build_object('ok', false, 'error', 'missing_units',
                                  'missing', to_jsonb(array[it.title]));
      end if;
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
      'qty', coalesce(it.qty,1), 'unit_price', it.unit_price,
      'section', it.section, 'choice_group', it.choice_group,
      'supplier', it.supplier,
      'included', it.included_pt,
      'kind', coalesce(it.kind,'stay'),
      'chosen', escol, 'units', unsel, 'extras', exsel);
  end loop;

  if quantos = 0 then
    return jsonb_build_object('ok', false, 'error', 'missing_items');
  end if;

  insert into ops_proposal_selections
    (proposal_id, lead_name, agency_name, designer_name, lead_email, lead_phone, remarks,
     lines, total, ack_conditions, payment_choice, confirm_mode)
  values (pp.id, nullif(btrim(coalesce(p_payload->>'lead_name','')),''),
          nullif(btrim(coalesce(p_payload->>'agency_name','')),''),
          nullif(btrim(coalesce(p_payload->>'designer_name','')),''),
          p_payload->>'lead_email',
          p_payload->>'lead_phone', p_payload->>'remarks', linhas, soma, true,
          case when simples then null else p_payload->>'payment_choice' end,
          case when simples then 'simple' else 'full' end);

  update ops_proposals set responded_at = now(), updated_at = now() where id = pp.id;
  return jsonb_build_object('ok', true, 'total', soma);
end $$;

revoke all on function tl_submit_quote(text, jsonb) from public;
grant execute on function tl_submit_quote(text, jsonb) to anon, authenticated;

insert into ops_migrations (id) values ('0036-modelos-de-proposta') on conflict (id) do nothing;
