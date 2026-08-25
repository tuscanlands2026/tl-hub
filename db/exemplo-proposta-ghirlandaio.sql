-- =====================================================================
-- EXEMPLO · Villa Ghirlandaio · 13 a 17 de outubro de 2026
--
-- Proposta modelo montada com os dados que ela passou: três famílias,
-- dez pessoas, valor fechado para o período. A linha nasce do catálogo
-- e é COPIADA — mudar o valor aqui não mexe no cadastro da villa, e
-- corrigir o cadastro depois não reescreve esta proposta.
--
-- Roda depois de 0006-catalogo.sql e catalogo-villa-ghirlandaio.sql.
-- =====================================================================

insert into ops_opportunities (id, crm_code, title, lang, agency, final_client, internal_notes)
values ('9126ac00-0000-0000-0000-000000000001', 'TL-041-26',
  'Villa Ghirlandaio · Toscana · out 2026', 'pt', 'Agência', null,
  'Três famílias, dez pessoas. Villa fechada para o grupo.')
on conflict (id) do nothing;

insert into ops_briefings (opportunity_id, travel_window, pax_summary, scope)
values ('9126ac00-0000-0000-0000-000000000001', '13 – 17 out 2026', '10 pessoas · 3 famílias',
  'Três famílias em uma villa só: 1 casal, 1 casal com 2 crianças, 1 casal com 2 crianças.')
on conflict (opportunity_id) do nothing;

insert into ops_proposals
  (id, opportunity_id, version, title, lang, layout, pax_summary, travel_window, show_prices,
   cover_tag_pt, cover_tag_en, cover_img,
   welcome_pt, welcome_en, sections, conditions_pt, excluded_pt, internal_notes)
values ('9126ac00-0000-0000-0000-0000000000a1','9126ac00-0000-0000-0000-000000000001', 1,
  'Villa Ghirlandaio', 'pt', 'apresentada', '10 pessoas · 3 famílias', '13 – 17 out 2026', true,
  'Selected Stays · Toscana', 'Selected Stays · Tuscany',
  'https://dimoraghirlandaio.it/wp-content/uploads/2024/07/DG_Aerial_Villas-overview.jpg',
  E'A Tuscan Lands é um DMC boutique com base em Pontassieve, na Toscana.\nCada hospedagem desta proposta foi visitada por nós. O que segue é o que consideramos para o período de 13 a 17 de outubro de 2026.',
  E'Tuscan Lands is a boutique DMC based in Pontassieve, Tuscany.\nEvery stay in this proposal has been visited by us.',
  '[{"key":"stays","title":"Hospedagem","title_en":"Where you stay",
     "note":"A villa inteira, para as três famílias.",
     "note_en":"The entire villa, for all three families.",
     "photo":"https://dimoraghirlandaio.it/wp-content/uploads/2023/08/dimora_ghirlandaio-main_villa_cover.jpg"}]',
  (select pt from ops_text_defaults where key='conditions'),
  E'- Reservas de restaurantes\n- Transfers e serviços terrestres\n- Seguro viagem\n- Passeios e experiências\n- Despesas com refeições não mencionadas e impostos hoteleiros/city tax a serem pagos no momento do check-in',
  'Valor fechado para o período. Conferir margem e disponibilidade da villa principal antes de enviar.')
on conflict (id) do nothing;

-- A linha nasce do catálogo: nome, site, estrutura, descrição e fotos
-- vêm de lá; data, valor e o que é desta venda são escritos aqui.
insert into ops_proposal_items
  (proposal_id, sort, catalog_id, service_date, title, title_en,
   details, details_en, room_type, room_type_en, facilities, facilities_en,
   website, photos, price, optional, section)
select '9126ac00-0000-0000-0000-0000000000a1', 0, c.id,
  '13 – 17 out 2026', c.name, c.name,
  c.descr, c.descr_en, c.accommodation, c.accommodation_en, c.facilities, c.facilities_en,
  c.website, c.photos, 12000, false, 'stays'
from ops_catalog c where c.id = 'c0000000-0000-0000-0000-000000000001'
on conflict do nothing;
