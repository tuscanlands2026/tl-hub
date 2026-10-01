-- =====================================================================
-- 0050 · BELMOND VILLA SAN MICHELE, EM FIESOLE
--
-- Pedido dela, outubro/26. Antigo mosteiro do século XV nas colinas de
-- Fiesole, com fachada atribuída à escola de Michelangelo, 39 quartos e
-- suítes, jardins em terraço e piscina panorâmica sobre Florença.
--
-- QUATRO CATEGORIAS, E O MOTIVO É O QUE A BELMOND PUBLICA. O site dá
-- Rooms, Junior Suites, Suites e Signature Suites, cada um com metragem
-- "a partir de" e ocupação máxima. Quarto a quarto só existe dentro do
-- motor de reservas. Então as categorias aqui são as quatro famílias, com
-- o número do hotel — e não nomes de quarto inventados para parecer mais
-- detalhado.
--
-- A PÁGINA SÓ SE LÊ EM NAVEGADOR: sem JavaScript ela não traz metragem
-- nenhuma. Foi lida com o Chromium.
--
-- UM INDÍCIO QUE FICA REGISTRADO E NÃO VIRA DADO: os arquivos de foto do
-- próprio site nomeiam três suítes — botanica, gran-tour e limonaia —, e o
-- hotel diz ter exatamente três Signature Suites. É forte, mas é nome de
-- arquivo, não texto publicado. Ficou nos pontos em aberto, para ela
-- confirmar com o hotel.
--
-- Só cria e preenche objetos ops_. Nenhum update ou delete em linha antiga.
-- =====================================================================


insert into ops_suppliers
  (id, name, category, subcategories, business_suite, status, region, city,
   website, languages, name_rule, vat_status,
   accommodation_summary, capacities, highlights, tags, summary,
   open_points, internal_notes)
values ('f0000000-0000-0000-0000-000000000000',
  'Belmond Villa San Michele', 'Hotel / Accommodation',
  array['Historic building','Hillside'],
  array['TL Selected Stays','MICE e Exclusive Events'],
  'To test', 'Tuscany', 'Fiesole (Firenze)',
  E'https://www.belmond.com/en/hotels/europe/italy/villa-san-michele-florence',
  array['Italian','English'],
  'Show supplier name', 'not stated',
  E'39 rooms and suites: 36 rooms and suites plus 3 signature suites, from 29 to over 109 sqm.',
  E'Hotel takeovers and banqueting for up to 90 guests.',
  array[
    'A 15th-century monastery, with a façade attributed to the School of Michelangelo',
    'Terraced 15th-century gardens, first tended by the monks',
    'Panoramic heated outdoor pool overlooking Florence',
    'Villa San Michele Spa by Guerlain, newly opened',
    'Three restaurants, with fine dining at Antesi',
    'The surrounding hills were the testing ground for Leonardo da Vinci''s flying machines'],
  array['Fiesole','Florence','Belmond','monastery','spa','panoramic pool'],
  E'A monastery of the 15th century in the hills of Fiesole, above Florence, whose façade is attributed to the School of Michelangelo. The terraced gardens were laid out by the monks and are still there. Thirty-nine rooms and suites, a heated pool looking over the city, the Guerlain spa and three restaurants, with fine dining at Antesi.',
  array[
    'Belmond publishes size and occupancy by family, not by room: ask the hotel for the room-by-room fact sheet.',
    'The photo filenames on the site name three suites — botanica, gran tour and limonaia — which match the three Signature Suites. Confirm the names with the hotel before using them in a proposal.',
    'Bed configuration is not published for any family.',
    'Net rates, cancellation policy and payment terms to the supplier not yet collected.',
    'Photo usage not yet cleared with the property: usage_cleared is false on every photo.'],
  E'Ficha montada do site da Belmond, outubro/26, lido em navegador — a página é montada por JavaScript e sem ele não traz metragem nenhuma.\nA BELMOND PUBLICA POR FAMÍLIA, NÃO POR QUARTO. O site dá quatro blocos — Rooms, Junior Suites, Suites e Signature Suites — cada um com metragem ''a partir de'' e ocupação. Quarto a quarto só existe dentro do motor de reservas. Por isso as categorias aqui são as quatro famílias, com o número que o hotel publica, e não nomes de quarto que eu teria de adivinhar.\nOS NOMES DAS TRÊS SIGNATURE SUITES aparecem nos arquivos de foto do próprio site: botanica, gran-tour e limonaia. É indício forte — o hotel diz que são três —, mas é nome de arquivo e não texto publicado, então não virou categoria. Confirmar com o hotel e desdobrar depois.\nAs fotos vêm de img.belmond.com, no corte t_1080 que o próprio site usa.' )
on conflict (id) do update set
  name = excluded.name, category = excluded.category, subcategories = excluded.subcategories,
  business_suite = excluded.business_suite, region = excluded.region, city = excluded.city,
  website = excluded.website, languages = excluded.languages, name_rule = excluded.name_rule,
  accommodation_summary = excluded.accommodation_summary, capacities = excluded.capacities,
  highlights = excluded.highlights, tags = excluded.tags, summary = excluded.summary,
  open_points = excluded.open_points, updated_at = now();

insert into ops_supplier_contacts (id, supplier_id, name, role, sort_order)
values ('f0000000-0000-0000-0000-000000990001', 'f0000000-0000-0000-0000-000000000000', 'Reservations', 'Reservations', 1)
on conflict (id) do nothing;


-- Fotos do HOTEL, sem quarto --
insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('f0000000-0000-0000-0000-000000000001', 'f0000000-0000-0000-0000-000000000000', null, E'https://img.belmond.com/f_auto/t_1080_ar_4_5/photos/vsm/vsm-ext-florence-view11.jpg', E'https://www.belmond.com/en/hotels/europe/italy/villa-san-michele-florence', E'Belmond Villa San Michele', true, false, 1)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('f0000000-0000-0000-0000-000000000002', 'f0000000-0000-0000-0000-000000000000', null, E'https://img.belmond.com/f_auto/t_1080_ar_4_5/photos/vsm/vsm-ext59.jpg', E'https://www.belmond.com/en/hotels/europe/italy/villa-san-michele-florence', E'Belmond Villa San Michele', true, false, 2)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('f0000000-0000-0000-0000-000000000003', 'f0000000-0000-0000-0000-000000000000', null, E'https://img.belmond.com/f_auto/t_1080_ar_4_5/photos/vsm/vsm-spa-entrance01.jpg', E'https://www.belmond.com/en/hotels/europe/italy/villa-san-michele-florence', E'Belmond Villa San Michele', true, false, 3)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('f0000000-0000-0000-0000-000000000004', 'f0000000-0000-0000-0000-000000000000', null, E'https://img.belmond.com/f_auto/t_1080_ar_5_4/photos/vsm/vsm-gst-garden15.jpg', E'https://www.belmond.com/en/hotels/europe/italy/villa-san-michele-florence', E'Belmond Villa San Michele', true, false, 4)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('f0000000-0000-0000-0000-000000000005', 'f0000000-0000-0000-0000-000000000000', null, E'https://img.belmond.com/f_auto/t_1280_ar_4_5/photos/vsm/vsm-ext-florence-view11.jpg', E'https://www.belmond.com/en/hotels/europe/italy/villa-san-michele-florence', E'Belmond Villa San Michele', true, false, 5)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;


-- 1. Rooms ------------------------------------------------
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('f0000000-0000-0000-0000-000000000000', 'f0000000-0000-0000-0000-000000010000', E'Rooms', E'29 to 37 sqm / 312 to 398 sq ft', 29, 37, E'Up to 2 guests', null, null, null, E'Contemporary comfort inside Renaissance walls. The rooms were reimagined honouring the heritage of the house, so that the new sits inside the old rather than over it.', array[E'Reimagined within the monastery''s original walls', E'29 to 37 sqm', E'Up to 2 guests'], E'Conforto contemporâneo dentro de paredes renascentistas. Os quartos foram redesenhados respeitando a herança da casa, de modo que o novo fique dentro do antigo e não por cima dele.', array[E'Redesenhados dentro das paredes originais do mosteiro', E'29 a 37 m²', E'Até 2 hóspedes'], 1)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('f0000000-0000-0000-0000-000000010001', 'f0000000-0000-0000-0000-000000000000', 'f0000000-0000-0000-0000-000000010000', E'https://img.belmond.com/f_auto/t_1080_ar_5_4/photos/vsm/vsm-acc-room-deluxe-room03.jpg', E'https://www.belmond.com/en/hotels/europe/italy/villa-san-michele-florence/accommodation', E'Rooms', true, false, 1)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('f0000000-0000-0000-0000-000000010002', 'f0000000-0000-0000-0000-000000000000', 'f0000000-0000-0000-0000-000000010000', E'https://img.belmond.com/f_auto/t_1080_ar_5_4/photos/vsm/vsm-acc-room-premium-room-09.jpg', E'https://www.belmond.com/en/hotels/europe/italy/villa-san-michele-florence/accommodation', E'Rooms', true, false, 2)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('f0000000-0000-0000-0000-000000010003', 'f0000000-0000-0000-0000-000000000000', 'f0000000-0000-0000-0000-000000010000', E'https://img.belmond.com/f_auto/t_1080_ar_5_4/photos/vsm/vsm-acc-room-premium-room-bathroom01.jpg', E'https://www.belmond.com/en/hotels/europe/italy/villa-san-michele-florence/accommodation', E'Rooms', true, false, 3)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('f0000000-0000-0000-0000-000000010004', 'f0000000-0000-0000-0000-000000000000', 'f0000000-0000-0000-0000-000000010000', E'https://img.belmond.com/f_auto/t_1280_ar_5_4/photos/vsm/vsm-acc-room-deluxe-room03.jpg', E'https://www.belmond.com/en/hotels/europe/italy/villa-san-michele-florence/accommodation', E'Rooms', true, false, 4)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;


-- 2. Junior Suites ------------------------------------------------
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('f0000000-0000-0000-0000-000000000000', 'f0000000-0000-0000-0000-000000020000', E'Junior Suites', E'from 38 sqm / 409 sq ft', 38, null, E'Up to 3 guests', null, null, null, E'Additional space, antique details and fine finishes, in the hills of Fiesole. Some open onto a garden terrace.', array[E'Antique details and fine finishes', E'From 38 sqm', E'Up to 3 guests', E'Garden terrace in some of them'], E'Mais espaço, detalhes de antiquário e acabamentos finos, nas colinas de Fiesole. Algumas se abrem para um terraço de jardim.', array[E'Detalhes de antiquário e acabamentos finos', E'A partir de 38 m²', E'Até 3 hóspedes', E'Terraço de jardim em algumas delas'], 2)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('f0000000-0000-0000-0000-000000020001', 'f0000000-0000-0000-0000-000000000000', 'f0000000-0000-0000-0000-000000020000', E'https://img.belmond.com/f_auto/t_1080_ar_5_4/photos/vsm/vsm-acc-suite-jrsuite-garden-terrace01.jpg', E'https://www.belmond.com/en/hotels/europe/italy/villa-san-michele-florence/accommodation', E'Junior Suites', true, false, 1)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('f0000000-0000-0000-0000-000000020002', 'f0000000-0000-0000-0000-000000000000', 'f0000000-0000-0000-0000-000000020000', E'https://img.belmond.com/f_auto/t_1080_ar_5_4/photos/vsm/vsm-acc-suite-junior-suite07.jpg', E'https://www.belmond.com/en/hotels/europe/italy/villa-san-michele-florence/accommodation', E'Junior Suites', true, false, 2)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('f0000000-0000-0000-0000-000000020003', 'f0000000-0000-0000-0000-000000000000', 'f0000000-0000-0000-0000-000000020000', E'https://img.belmond.com/f_auto/t_1080_ar_5_4/photos/vsm/vsm-acc-suite-junior-suite11.jpg', E'https://www.belmond.com/en/hotels/europe/italy/villa-san-michele-florence/accommodation', E'Junior Suites', true, false, 3)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('f0000000-0000-0000-0000-000000020004', 'f0000000-0000-0000-0000-000000000000', 'f0000000-0000-0000-0000-000000020000', E'https://img.belmond.com/f_auto/t_1280_ar_5_4/photos/vsm/vsm-acc-suite-jrsuite-garden-terrace01.jpg', E'https://www.belmond.com/en/hotels/europe/italy/villa-san-michele-florence/accommodation', E'Junior Suites', true, false, 4)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;


-- 3. Suites ------------------------------------------------
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('f0000000-0000-0000-0000-000000000000', 'f0000000-0000-0000-0000-000000030000', E'Suites', E'from 60 sqm / 646 sq ft', 60, null, E'Up to 3 guests', null, null, null, E'A sanctuary of its own, floating in the hills above Florence, where the reimagined interiors keep the proportions of the monastery.', array[E'Above Florence, in the Fiesole hills', E'From 60 sqm', E'Up to 3 guests'], E'Um refúgio próprio, suspenso nas colinas acima de Florença, onde os interiores redesenhados mantêm as proporções do mosteiro.', array[E'Acima de Florença, nas colinas de Fiesole', E'A partir de 60 m²', E'Até 3 hóspedes'], 3)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('f0000000-0000-0000-0000-000000030001', 'f0000000-0000-0000-0000-000000000000', 'f0000000-0000-0000-0000-000000030000', E'https://img.belmond.com/f_auto/t_1080_ar_5_4/photos/vsm/vsm-acc-suite-garden-suite04.jpg', E'https://www.belmond.com/en/hotels/europe/italy/villa-san-michele-florence/accommodation', E'Suites', true, false, 1)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('f0000000-0000-0000-0000-000000030002', 'f0000000-0000-0000-0000-000000000000', 'f0000000-0000-0000-0000-000000030000', E'https://img.belmond.com/f_auto/t_1080_ar_5_4/photos/vsm/vsm-acc-suite-garden-suite05.jpg', E'https://www.belmond.com/en/hotels/europe/italy/villa-san-michele-florence/accommodation', E'Suites', true, false, 2)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('f0000000-0000-0000-0000-000000030003', 'f0000000-0000-0000-0000-000000000000', 'f0000000-0000-0000-0000-000000030000', E'https://img.belmond.com/f_auto/t_1080_ar_5_4/photos/vsm/vsm-acc-suite-garden-suite06.jpg', E'https://www.belmond.com/en/hotels/europe/italy/villa-san-michele-florence/accommodation', E'Suites', true, false, 3)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('f0000000-0000-0000-0000-000000030004', 'f0000000-0000-0000-0000-000000000000', 'f0000000-0000-0000-0000-000000030000', E'https://img.belmond.com/f_auto/t_1280_ar_5_4/photos/vsm/vsm-acc-suite-garden-suite04.jpg', E'https://www.belmond.com/en/hotels/europe/italy/villa-san-michele-florence/accommodation', E'Suites', true, false, 4)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;


-- 4. Signature Suites ------------------------------------------------
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('f0000000-0000-0000-0000-000000000000', 'f0000000-0000-0000-0000-000000040000', E'Signature Suites', E'from 109 sqm / 1,173 sq ft', 109, null, E'Up to 4 guests', null, null, E'3 suites', E'The three Signature Suites answer to the heritage of the place and to the gardens around it, with expanded space, rare antiques and the views that come with the hill.', array[E'Only three in the hotel', E'Rare antiques', E'From 109 sqm', E'Up to 4 guests'], E'As três Signature Suites respondem à herança do lugar e aos jardins em volta, com espaço ampliado, antiguidades raras e a vista que a colina dá.', array[E'Apenas três no hotel', E'Antiguidades raras', E'A partir de 109 m²', E'Até 4 hóspedes'], 4)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('f0000000-0000-0000-0000-000000040001', 'f0000000-0000-0000-0000-000000000000', 'f0000000-0000-0000-0000-000000040000', E'https://img.belmond.com/f_auto/t_1080_ar_4_5/photos/vsm/vsm-acc-suite-botanica-suite15.jpg', E'https://www.belmond.com/en/hotels/europe/italy/villa-san-michele-florence/accommodation', E'Signature Suites', true, false, 1)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('f0000000-0000-0000-0000-000000040002', 'f0000000-0000-0000-0000-000000000000', 'f0000000-0000-0000-0000-000000040000', E'https://img.belmond.com/f_auto/t_1080_ar_4_5/photos/vsm/vsm-acc-suite-gran-tour-suite12.jpg', E'https://www.belmond.com/en/hotels/europe/italy/villa-san-michele-florence/accommodation', E'Signature Suites', true, false, 2)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('f0000000-0000-0000-0000-000000040003', 'f0000000-0000-0000-0000-000000000000', 'f0000000-0000-0000-0000-000000040000', E'https://img.belmond.com/f_auto/t_1080_ar_4_5/photos/vsm/vsm-acc-suite-limonaia-suite28.jpg', E'https://www.belmond.com/en/hotels/europe/italy/villa-san-michele-florence/accommodation', E'Signature Suites', true, false, 3)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('f0000000-0000-0000-0000-000000040004', 'f0000000-0000-0000-0000-000000000000', 'f0000000-0000-0000-0000-000000040000', E'https://img.belmond.com/f_auto/t_1080_ar_4_5/photos/vsm/vsm-acc-suite-limonaia-suite29.jpg', E'https://www.belmond.com/en/hotels/europe/italy/villa-san-michele-florence/accommodation', E'Signature Suites', true, false, 4)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;


insert into ops_migrations (id) values ('0050-villa-san-michele') on conflict (id) do nothing;
