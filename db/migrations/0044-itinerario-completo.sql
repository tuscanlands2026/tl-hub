-- =====================================================================
-- 0044 · ITINERÁRIO COMPLETO: O CABEÇALHO DE FATOS DA PROPOSTA
--
-- Pedido dela, setembro/26, com a página de itinerário do La Dolce Vita
-- como referência de ARQUITETURA, não de texto: antes de qualquer
-- parágrafo, um bloco de fatos — título, rota, duração, datas, número de
-- viajantes e um "a partir de" que ela esconde quando não quiser.
--
-- O QUE ESTE ARQUIVO **NÃO** FAZ, e é o mais importante: não cria um
-- terceiro tipo de proposta. Ela pediu "um novo tipo de proposta" e a
-- resposta honesta, depois de reler `docs/MODELOS-DE-PROPOSTA.md`, é que
-- o tipo já existe: é o **Completo** (`layout='apresentada'`) com a seção
-- em `modo='dias'` — "programa cronológico, uma foto por dia" —, desenho
-- fechado com ela em setembro e já em pé na 0036. Criar um `layout` novo
-- seria manter dois desenhos que desembocam na mesma folha, e o segundo
-- nasceria sem a curadoria, sem o net e sem a escolha de opção.
--
-- O dia de cada linha também já existe: é `ops_proposal_items.service_date`,
-- que é o que `blocoDias` lê hoje. Coluna `day` seria um segundo campo
-- dizendo a mesma coisa, livre para divergir dele.
--
-- E "proposta só de experiências, sem hotel" não se constrói: é ela não
-- criar a seção de hospedagem. Campo para desligar hotel seria campo para
-- ela lembrar de virar.
--
-- ENTÃO O QUE FALTA SÃO QUATRO CAMPOS, e só isso:
--   route            "Roma · Val d'Orcia · Florença" — texto dela, com o
--                    separador que ela escolher; o hub não monta a rota a
--                    partir das seções porque a ordem de apresentação não
--                    é necessariamente a ordem do trajeto;
--   duration         "5 dias · 4 noites" — também texto. Contar dias a
--                    partir das datas erraria em toda viagem que começa à
--                    noite ou termina de manhã;
--   from_price       o "a partir de";
--   from_price_show  se ele aparece. **Nasce desligado**: proposta que já
--                    existe não muda de cara por causa de coluna nova, e
--                    o valor sem o "a partir de" ligado é rascunho dela.
--
-- Passageiros e datas NÃO entram: são `pax_summary` e `travel_window`,
-- que já existem e já saem em `tl_get_quote`.
--
-- O PASSADO: este arquivo só CRIA coluna e REDEFINE função. Nenhum
-- update, nenhum delete, nenhuma linha existente tocada. As quatro
-- colunas nascem nulas e a chave nasce desligada, então nenhuma proposta
-- já enviada muda de aparência ao ser reaberta.
--
-- Só toca em objetos `ops_` e `tl_`. Conferido linha a linha.
-- =====================================================================

alter table ops_proposals add column if not exists route           text;
alter table ops_proposals add column if not exists duration        text;
alter table ops_proposals add column if not exists from_price      numeric(12,2);
alter table ops_proposals add column if not exists from_price_show boolean not null default false;

comment on column ops_proposals.route is
  'A rota como ela escreve: "Roma · Val d''Orcia · Florença". Texto, e não '
  'montagem a partir das seções: a ordem de apresentação não é a do trajeto.';
comment on column ops_proposals.duration is
  'Duração como ela escreve: "5 dias · 4 noites". Contar a partir das datas '
  'erraria em viagem que começa à noite ou termina de manhã.';
comment on column ops_proposals.from_price is
  'O "a partir de" do cabeçalho de fatos. Não soma nada e não substitui o '
  'total: é a chamada comercial do programa.';
comment on column ops_proposals.from_price_show is
  'Se o "a partir de" aparece ao cliente. Nasce desligado, para proposta que '
  'já existe não mudar de cara, e para o valor em rascunho não vazar.';

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
      -- Cabeçalho de fatos (0044). Rota e duração são texto dela. O "a
      -- partir de" só sai com a chave ligada: nulo aqui é o mesmo que
      -- "não mostre", e a tela não precisa conhecer a chave para acertar.
      'route', pp.route, 'duration', pp.duration,
      -- O net segue a mesma regra do show_prices: peça sem valor nenhum,
      -- e o "a partir de" é valor. Ele aparece no link dos valores.
      'from_price', case when coalesce(pp.from_price_show, false)
                          and coalesce(pp.rate_type,'comissionado') <> 'net'
                         then pp.from_price else null end,
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


-- O LINK DOS VALORES DEVOLVE O "A PARTIR DE" --------------------------
-- tl_get_quote esconde o from_price no net pelo mesmo motivo que esconde
-- todo o resto: a peça bonita do net vai ao cliente final. Mas o link dos
-- valores é a leitura da agência, e lá o valor é justamente o assunto.
-- Como tl_get_net_quote reaproveita tl_get_quote — de propósito, para as
-- duas leituras não divergirem —, é aqui que ele volta.
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
  base := jsonb_set(
            jsonb_set(
              jsonb_set(base, '{proposal,layout}', '"tabela"'::jsonb),
              '{proposal,show_prices}', 'true'::jsonb),
            '{proposal,net_view}', 'true'::jsonb);
  if coalesce(pp.from_price_show, false) and pp.from_price is not null then
    base := jsonb_set(base, '{proposal,from_price}', to_jsonb(pp.from_price));
  end if;
  return base;
end $$;

revoke all on function tl_get_net_quote(text) from public;
grant execute on function tl_get_net_quote(text) to anon, authenticated;

insert into ops_migrations (id) values ('0044-itinerario-completo') on conflict (id) do nothing;
