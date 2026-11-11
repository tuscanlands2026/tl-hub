-- =====================================================================
-- 0083 · EMILY (TL-053-26): A PROPOSTA COMERCIAL NASCE COMO VERSÃO 2
--
-- Pedido dela, nov/26: o estudo de viabilidade da Emily fica SALVO como
-- está — vai ser a referência do modelo "Primeiro estudo · Luxo" — e a
-- proposta comercial é montada em cima dele. O briefing aprovado pela
-- Danielle (8/11) fechou Castelfalfi e Bulgari Roma; Cortona não entra
-- na proposta, só é mencionada.
--
-- O estudo:  ops_proposals.id = b59090ad-14dc-45d3-87f5-9f7206834668 (v1)
-- A nova:    ops_proposals.id = e0530000-0000-0000-0000-000000000002 (v2)
--
-- SÓ INSERE. A v1 e as linhas dela não são tocadas: é o mesmo caminho do
-- botão "Nova versão" — copia a proposta inteira, menos o que é da outra
-- (id, versão, link, link do net, datas, resposta e "aceita").
--
-- Na v2:
--   · ficam os cards do Castelfalfi e do Bulgari exatamente como no
--     estudo (texto, fotos, site), e saem Borgo Vescine e La Minerva;
--   · as categorias trocam pelas que ela escolheu, com o VALOR EM BRANCO
--     (ela manda os valores no fim). No indicativo, zero sai só com o nome;
--   · tarifa flexível com café da manhã; city tax e extras não inclusos;
--   · Castelfalfi leva os dois tours virtuais (Matterport) que ela mandou;
--   · a seção da Toscana menciona as cinco noites em Cortona.
--
-- De onde veio cada número:
--   Castelfalfi · Suite Terrace — castelfalfi.com/rooms-suites/suite-terrace:
--     61 sqm, até 4 hóspedes, 1 king + 1 sofá-cama, vista panorâmica.
--   Castelfalfi · Junior Suite Terrace — a página própria pediu CAPTCHA e
--     não foi lida. 40 sqm e vista panorâmica vêm da página da Junior Suite
--     Garden, que lista a Terrace como "outra expressão da mesma
--     categoria". A CAMA NÃO ESTÁ ESCRITA: a Garden publica king, a Terrace
--     não foi lida. Fica sem "king bed" até ela confirmar.
--   Bulgari · Premium Room e Junior Suite — bulgarihotels.com recusa
--     leitura automatizada (403). Cama e vista são as que ela passou
--     ("1 King, City view"); 49 m² e 51 m² são os que o site oficial
--     publica, conforme índice de busca das páginas dele.
--
-- O conjunto de fotos do Bulgari no estudo tinha a do Deluxe, que saiu da
-- proposta. Na v2 fica só a do Premium. Junior Suite segue sem foto: o site
-- não foi lido e foto não se inventa.
--
-- Seção 7: ops_proposals (insert), ops_proposal_items (insert),
-- ops_migrations (insert). Sem update, sem delete. Nenhuma tabela do CRM.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1 · A PROPOSTA (cópia campo a campo da v1, versão 2, links novos)
-- ---------------------------------------------------------------------
insert into ops_proposals
  (id, opportunity_id, version, title, summary, lang, pax_summary,
   travel_window, intro, payment_note, terms_url, show_prices, sections,
   internal_notes, conditions, conditions_pt, conditions_en, excluded_pt,
   excluded_en, layout, cover_img, cover_tag_pt, cover_tag_en, welcome_pt,
   welcome_en, itinerary, about_pt, about_en, credentials_pt,
   credentials_en, backcover_pt, backcover_en, payment_options, about_img,
   labels, backcover_img, token_expires_at, white_label, agency_logo,
   agency_logo_bg, assurance_pt, assurance_en, confirm_mode, cover_title,
   assurance_img, curations, rate_type, route, duration, from_price,
   from_price_show, show_conditions, rate_mode, rate_label, rate_label_en,
   rate_note, rate_note_en, show_summary)
select E'e0530000-0000-0000-0000-000000000002', p.opportunity_id, 2, p.title,
   p.summary, p.lang, p.pax_summary, p.travel_window, p.intro,
   p.payment_note, p.terms_url, p.show_prices,
   -- a seção da Toscana menciona Cortona; Roma fica como estava
   (select jsonb_agg(
             case when s->>'key' = 'stays'
                  then s || jsonb_build_object(
                         'title', 'Tuscany countryside',
                         'note',  'After five nights in Cortona, June 20 to 25, four nights in the Tuscan countryside. Select your stay for June 25 to 29.')
                  else s end
             order by o)
      from jsonb_array_elements(p.sections) with ordinality as t(s, o)),
   p.internal_notes, p.conditions, p.conditions_pt, p.conditions_en,
   p.excluded_pt, p.excluded_en, p.layout, p.cover_img, p.cover_tag_pt,
   p.cover_tag_en, p.welcome_pt, p.welcome_en, p.itinerary, p.about_pt,
   p.about_en, p.credentials_pt, p.credentials_en, p.backcover_pt,
   p.backcover_en, p.payment_options, p.about_img, p.labels,
   p.backcover_img, p.token_expires_at, p.white_label, p.agency_logo,
   p.agency_logo_bg, p.assurance_pt, p.assurance_en, p.confirm_mode,
   p.cover_title, p.assurance_img, p.curations, p.rate_type, p.route,
   p.duration, p.from_price, p.from_price_show, p.show_conditions,
   p.rate_mode, p.rate_label, p.rate_label_en, p.rate_note, p.rate_note_en,
   p.show_summary
  from ops_proposals p
 where p.id = 'b59090ad-14dc-45d3-87f5-9f7206834668'
   and not exists (select 1 from ops_proposals x
                    where x.opportunity_id = p.opportunity_id and x.version = 2)
on conflict (id) do nothing;

-- ---------------------------------------------------------------------
-- 2 · CASTELFALFI — o card do estudo, com as duas categorias dela
-- ---------------------------------------------------------------------
insert into ops_proposal_items
  (proposal_id, sort, service_date, title, details, price, optional, extras,
   choice_group, section, supplier, title_en, details_en, website,
   room_type, room_type_en, photos, attachments, catalog_id, facilities,
   facilities_en, included_pt, included_en, units, kind, qty, unit_price,
   supplier_id, supplier_service_id, supplier_room_type_id)
select E'e0530000-0000-0000-0000-000000000002', i.sort, i.service_date,
   i.title, i.details, 0, i.optional, i.extras, i.choice_group, i.section,
   i.supplier, i.title_en, i.details_en, i.website, null, null, i.photos,
   E'[{"name":"Virtual tour · Junior Suite Terrace","url":"https://my.matterport.com/show/?m=mxG1WKJSv7K"},
      {"name":"Virtual tour · Suite Terrace","url":"https://my.matterport.com/show/?m=Wp1a1rBzXp6"}]'::jsonb,
   i.catalog_id, i.facilities, i.facilities_en, null,
   E'Flexible rate, breakfast included. City tax and extras are not included.',
   E'[{"key":"u1","label":"Junior Suite Terrace · 40 m² / 431 sq ft · private terrace, panoramic view","label_en":"Junior Suite Terrace · 40 m² / 431 sq ft · private terrace, panoramic view","price":0,"optional":true},
      {"key":"u2","label":"Suite Terrace · 61 m² / 657 sq ft · king bed and sofa bed · private terrace, panoramic view","label_en":"Suite Terrace · 61 m² / 657 sq ft · king bed and sofa bed · private terrace, panoramic view","price":0,"optional":true}]'::jsonb,
   i.kind, i.qty, i.unit_price, i.supplier_id, i.supplier_service_id, null
  from ops_proposal_items i
 where i.proposal_id = 'b59090ad-14dc-45d3-87f5-9f7206834668'
   and 'Castelfalfi' in (coalesce(i.title,''), coalesce(i.title_en,''))
   and exists (select 1 from ops_proposals x where x.id = 'e0530000-0000-0000-0000-000000000002')
   and not exists (select 1 from ops_proposal_items y
                    where y.proposal_id = 'e0530000-0000-0000-0000-000000000002'
                      and 'Castelfalfi' in (coalesce(y.title,''), coalesce(y.title_en,'')));

-- ---------------------------------------------------------------------
-- 3 · BULGARI HOTEL ROMA — o card do estudo, com as duas categorias dela
-- ---------------------------------------------------------------------
insert into ops_proposal_items
  (proposal_id, sort, service_date, title, details, price, optional, extras,
   choice_group, section, supplier, title_en, details_en, website,
   room_type, room_type_en, photos, attachments, catalog_id, facilities,
   facilities_en, included_pt, included_en, units, kind, qty, unit_price,
   supplier_id, supplier_service_id, supplier_room_type_id)
select E'e0530000-0000-0000-0000-000000000002', i.sort, i.service_date,
   i.title, i.details, 0, i.optional, i.extras, i.choice_group, i.section,
   i.supplier, i.title_en, i.details_en, i.website, null, null,
   -- sai a foto do Deluxe, que não está mais na proposta
   coalesce((select jsonb_agg(f) from jsonb_array_elements(i.photos) f
              where f::text not ilike '%deluxe-room%'), '[]'::jsonb),
   i.attachments, i.catalog_id, i.facilities, i.facilities_en, null,
   E'Flexible rate, breakfast included. City tax and extras are not included.',
   E'[{"key":"u1","label":"Premium Room · 49 m² / 527 sq ft · king bed · city view","label_en":"Premium Room · 49 m² / 527 sq ft · king bed · city view","price":0,"optional":true},
      {"key":"u2","label":"Junior Suite · 51 m² / 549 sq ft · king bed · city view","label_en":"Junior Suite · 51 m² / 549 sq ft · king bed · city view","price":0,"optional":true}]'::jsonb,
   i.kind, i.qty, i.unit_price, i.supplier_id, i.supplier_service_id, null
  from ops_proposal_items i
 where i.proposal_id = 'b59090ad-14dc-45d3-87f5-9f7206834668'
   and 'Bulgari Hotel Roma' in (coalesce(i.title,''), coalesce(i.title_en,''))
   and exists (select 1 from ops_proposals x where x.id = 'e0530000-0000-0000-0000-000000000002')
   and not exists (select 1 from ops_proposal_items y
                    where y.proposal_id = 'e0530000-0000-0000-0000-000000000002'
                      and 'Bulgari Hotel Roma' in (coalesce(y.title,''), coalesce(y.title_en,'')));

insert into ops_migrations (id) values ('0083-emily-proposta-comercial-v2') on conflict (id) do nothing;
