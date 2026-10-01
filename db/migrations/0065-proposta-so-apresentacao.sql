-- =====================================================================
-- 0065 · A FOLHA DA PROPOSTA COMERCIAL VIRA ESCOLHA
--
-- Instrução dela, outubro/26, sobre a proposta da Emily: "tira aquela
-- parte da proposta comercial, porque aqui é só um levantamento para ela
-- ver opções, ver se ela gosta. Tira aquela parte escolha, aquela parte
-- do resumo."
--
-- É a última etapa da peça apresentada: o resumo do que o cliente marcou,
-- a tabela de serviços, a caixinha "Selecione para aprovar este serviço"
-- e o bloco de envio. Numa peça que é levantamento de opções ela não
-- cabe — é o resumo de uma escolha que ainda não existe.
--
-- O QUE ISSO IMPLICA, e está dito porque não é óbvio: as três coisas que
-- moram só nessa folha são a tabela, a aprovação e o envio. Desligando
-- ela, A PROPOSTA DEIXA DE TER COMO SER RESPONDIDA. Nesta fase é o certo:
-- quem pergunta "quais hotéis?" é o briefing da advisor, que já tem as
-- três perguntas. No dia em que a peça virar proposta de verdade, ela
-- religa a chave e o caminho de resposta volta inteiro — nada foi
-- apagado, e `tl_submit_quote` continua de pé.
--
-- NASCE LIGADA (default true): proposta que já existe não muda de cara.
--
-- VALE SÓ NA APRESENTADA. Na quote simples o resumo É o documento, e
-- esconder deixaria uma folha de rosto sem nada atrás — por isso a trava
-- está no desenho da apresentada, no index.html, e não na função.
--
-- ESTE ARQUIVO TAMBÉM DESLIGA A CHAVE NA PROPOSTA DA EMILY, que é um
-- update em linha que já existe e foi pedido por ela nesta conversa:
--   update ops_proposals set show_summary = false
--    where id = 'b59090ad-14dc-45d3-87f5-9f7206834668';
-- Nenhuma outra proposta é tocada, e o Supabase vai avisar "destrutivo"
-- por causa dele.
--
-- CONFERÊNCIA DA SEÇÃO 7, relida antes de entregar. Os objetos que este
-- arquivo toca, um a um: ops_proposals (add column, e um update em UMA
-- linha por id), tl_get_quote (create or replace) e ops_migrations
-- (insert). Nenhum drop, truncate ou delete. Nenhuma tabela do CRM é
-- lida, escrita ou citada. Nenhum comando percorre o schema. Nenhuma
-- service_role key aparece aqui.
-- =====================================================================

alter table ops_proposals
  add column if not exists show_summary boolean not null default true;

comment on column ops_proposals.show_summary is
  'Folha da proposta comercial (resumo da escolha, aprovação e envio). false = a peça sai só como apresentação e NÃO pode ser respondida. Vale no layout apresentada.';

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
           'modo', coalesce(nullif(s->>'modo',''), 'blocos'),
           -- As noites daquela base. Com elas e o valor por noite da
           -- categoria, a tela faz a estimativa da estadia.
           'nights', (s->>'nights')::int) order by ord), '[]'::jsonb)
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
      -- A folha da proposta comercial: resumo da escolha, caixinha de
      -- aprovar e bloco de envio. Desligada, a peça é só apresentação.
      'show_summary', coalesce(pp.show_summary, true),
      'rate_mode', coalesce(pp.rate_mode, 'total'),
      'rate_label', nullif(case when ing then pp.rate_label_en else pp.rate_label end, ''),
      'rate_note', nullif(case when ing then pp.rate_note_en else pp.rate_note end, ''),
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

-- A proposta da Emily passa a sair só como apresentação ------------------
update ops_proposals set show_summary = false, updated_at = now()
 where id = 'b59090ad-14dc-45d3-87f5-9f7206834668'
   and show_summary is distinct from false;

insert into ops_migrations (id) values ('0065-proposta-so-apresentacao') on conflict (id) do nothing;
