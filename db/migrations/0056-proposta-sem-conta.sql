-- =====================================================================
-- 0056 · PROPOSTA DE APRESENTAÇÃO SEM A CONTA: VALOR INDICATIVO E A
--        PÁGINA DE CONDIÇÕES COMO ESCOLHA
--
-- Pedido dela, outubro/26, montando a proposta da Emily: "nessa fase aqui
-- a gente não vai colocar aquela página de termos e condições, queria que
-- você me deixasse como opção"; e "eu não vou colocar preço não, eu vou
-- colocar média por noite nesta categoria — talvez duas categorias".
--
-- DUAS CHAVES, e cada uma resolve uma coisa só.
--
-- 1) show_conditions — a página de forma de pagamento e condições gerais
--    passa a ser escolha por proposta. NASCE LIGADA: proposta que já
--    existe não muda de cara. Desligar não apaga o texto, só não imprime
--    a folha; religar devolve tudo.
--
-- 2) rate_mode — como o valor aparece.
--      'total'      o de sempre: o valor da linha é o total daquela linha,
--                   as linhas somam, e a proposta fecha com o total.
--      'indicativo' o valor NÃO é total e NÃO soma: é referência por
--                   noite, por categoria de quarto. Some o valor grande
--                   da linha, somem os totais, e o que fica é a lista de
--                   categorias com o valor de cada uma e o rótulo dela.
--
--    POR QUE UMA CHAVE E NÃO UM CAMPO NOVO NA LINHA: a lista de
--    categorias com valor já existe e é `units` — no Palazzo Ripetta são
--    1 Prestige e 2 Luxury. O que faltava não era onde escrever o número,
--    era dizer que naquela proposta o número não é uma conta. Campo novo
--    na linha seria um segundo lugar para escrever preço, e aí a proposta
--    e a order divergem no dia em que alguém preenche o errado.
--
--    E POR QUE NÃO BASTA O show_prices QUE JÁ EXISTE: ele esconde valor
--    nenhum ou todos. Ela quer MOSTRAR valor, e que ele não seja somado.
--
-- 3) rate_label / rate_label_en — o rótulo do valor indicativo, texto
--    dela: "média por noite", "average per night", "por noite, 2 pax".
--    Em branco cai no padrão do hub, que é o caminho de todo rótulo aqui.
--    Fica vazio de propósito: "média por noite" é afirmação comercial, e
--    quem assina é ela.
--
-- O PASSADO: só cria coluna e redefine função. Nenhum update, nenhum
-- delete. `show_conditions` nasce ligada e `rate_mode` nasce em 'total',
-- que é exatamente o que as propostas já enviadas fazem hoje — reabrir
-- qualquer uma devolve o mesmo documento.
--
-- Só toca em objetos ops_ e tl_. Conferido linha a linha.
-- =====================================================================

alter table ops_proposals add column if not exists show_conditions boolean not null default true;
alter table ops_proposals add column if not exists rate_mode       text not null default 'total';
alter table ops_proposals add column if not exists rate_label      text;
alter table ops_proposals add column if not exists rate_label_en   text;

do $$
begin
  if not exists (select 1 from pg_constraint where conname = 'ops_proposals_rate_mode_ck') then
    alter table ops_proposals add constraint ops_proposals_rate_mode_ck
      check (rate_mode in ('total','indicativo'));
  end if;
end $$;

comment on column ops_proposals.show_conditions is
  'Se a folha de forma de pagamento e condições gerais sai na proposta. '
  'Desligada, o texto continua gravado — só não imprime.';
comment on column ops_proposals.rate_mode is
  'total: o valor da linha é o total dela e as linhas somam. indicativo: o '
  'valor é referência por noite/categoria, não soma, e a proposta não fecha '
  'com total nenhum.';
comment on column ops_proposals.rate_label is
  'Rótulo do valor indicativo, texto dela: "média por noite". Vazio cai no '
  'padrão do hub — afirmação comercial é dela, não minha.';

-- tl_get_quote redefinida inteira, como manda a casa: a função monta o
-- objeto CAMPO A CAMPO, justamente para coluna nova não vazar sozinha, e
-- por isso os três campos novos precisam ser escritos nela à mão.
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
      -- Dois campos de 0056. show_conditions decide se a folha de forma de
      -- pagamento e condições gerais sai; rate_mode decide se o valor da
      -- linha é um total que soma ou uma referência por noite que não soma.
      -- O rótulo do indicativo já sai no idioma da proposta.
      'show_conditions', coalesce(pp.show_conditions, true),
      'rate_mode', coalesce(pp.rate_mode, 'total'),
      'rate_label', nullif(case when ing then pp.rate_label_en else pp.rate_label end, ''),
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

insert into ops_migrations (id) values ('0056-proposta-sem-conta') on conflict (id) do nothing;
