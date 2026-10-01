-- =====================================================================
-- 0049 · COLLEGIO ALLA QUERCE, AUBERGE RESORTS COLLECTION
--
-- Pedido dela, outubro/26. Antigo colégio numa encosta a 15 minutos do
-- centro de Florença, reaberto pela Auberge: 83 quartos e suítes, em
-- 17 categorias com nome próprio.
--
-- A PÁGINA É MONTADA POR JAVASCRIPT e não se lê sem navegador. Foi lida
-- com o Chromium, nas quatro páginas de categoria — guestrooms, suites,
-- grandsuites e two-bedroom-suites —, que é de onde saíram os 17 nomes,
-- o texto de cada família e as vistas.
--
-- A AUBERGE NÃO PUBLICA METRAGEM. Não é descuido meu: não há metro
-- quadrado nem square foot em nenhuma das páginas. A única medida que
-- existe é a do release de abertura, que dá a Residenza la Quercia em
-- 2.292 sq ft. Metragem não se estima, então as 17 ficam sem — e a
-- pergunta foi para os pontos em aberto da ficha, onde ela vê e pede ao
-- hotel. O resto está completo: nome, família, vista e foto.
--
-- Só cria e preenche objetos ops_. Nenhum update ou delete em linha antiga.
-- =====================================================================


insert into ops_suppliers
  (id, name, category, subcategories, business_suite, status, region, city, address,
   website, languages, name_rule, vat_status,
   accommodation_summary, accommodation_notes, highlights, tags, summary,
   open_points, internal_notes)
values ('a0000000-0000-0000-0000-000000000000',
  'Collegio alla Querce, Auberge Resorts Collection', 'Hotel / Accommodation',
  array['City hotel','Historic building'],
  array['TL Selected Stays'],
  'To test', 'Tuscany', 'Firenze',
  'Via delle Forbici 21B, 50133 Firenze',
  E'https://auberge.com/collegio-alla-querce/',
  array['Italian','English'],
  'Show supplier name', 'not stated',
  E'83 rooms and suites in 17 named categories: 5 guest rooms, 3 suites, 6 grand suites and 3 two-bedroom suites.',
  E'Each accommodation is individually designed, so layouts and furnishings vary between rooms of the same category. Inlaid hardwood floors and tall windows in the guest rooms; linen-upholstered lounge seating and walk-through dressing rooms in the suites. The Grand Suites include a complimentary minibar with espresso machine and locally curated bites, a signature cocktail on arrival, a round-trip transfer from Florence airport or station, one in-house experience for two, and packing and unpacking service.',
  array[
    'A former college on a hillside about 15 minutes north of the historic centre of Florence',
    'Baroque gardens and a terrazza, with views over Firenze and the Duomo',
    'Aelia Spa, open year round',
    'Outdoor pool, seasonal from 15 April to 30 September',
    'Four dining venues: La Gamella, Bar Bertelli, Il Bosco and The Conservatorio',
    'Complimentary shuttle to the centre, 9:30 to 21:30',
    'On-site parking at EUR 60 per night'],
  array['Florence','hillside','Auberge','Baroque gardens','spa'],
  E'A nineteenth-century college on the hillside above Florence, reopened by Auberge with 83 rooms and suites. Rich colours and local materials sit beside hand-picked antiques and curated artwork, and the tall windows look over the Baroque gardens to the city and the Duomo. Each room is individually designed, so two rooms of the same category are not the same room.',
  array[
    'No floor area is published for any of the 17 categories: ask the hotel for the fact sheet.',
    'Maximum occupancy and bed configuration are not published either, beyond the bedroom count.',
    'Penthouse La Quercia is likely the Residenza la Quercia of the opening release (2,292 sq ft / 213 sqm): confirm the name and the figure.',
    'Collegio Double and Balcone Premium King have no photo of their own on the site.',
    'Net rates, cancellation policy and payment terms to the supplier not yet collected.',
    'Photo usage not yet cleared with the property: usage_cleared is false on every photo.'],
  E'Ficha montada do site da Auberge, outubro/26, com as quatro páginas de categoria (guestrooms, suites, grandsuites, two-bedroom-suites) lidas em navegador — a página é montada por JavaScript e não dá para ler sem ele.\nA AUBERGE NÃO PUBLICA METRAGEM de nenhuma categoria, em lugar nenhum do site. A única medida que existe é a do release de abertura, que dá a Residenza la Quercia em 2.292 sq ft (213 m²) — é o que aqui está como Penthouse La Quercia, e mesmo essa ficou nos pontos em aberto porque o nome não bate exatamente. Pedir a ficha técnica ao hotel resolve as 17 de uma vez.\nAs fotos vêm do CDN da Auberge, na versão original (sem o corte -768x511 da listagem), e esse servidor responde CORS ''*'' — então elas encolhem normalmente no PDF.\nDois quartos sem foto própria no site: Collegio Double e Balcone Premium King.' )
on conflict (id) do update set
  name = excluded.name, category = excluded.category, subcategories = excluded.subcategories,
  business_suite = excluded.business_suite, region = excluded.region, city = excluded.city,
  address = excluded.address, website = excluded.website, languages = excluded.languages,
  name_rule = excluded.name_rule,
  accommodation_summary = excluded.accommodation_summary,
  accommodation_notes = excluded.accommodation_notes,
  highlights = excluded.highlights, tags = excluded.tags, summary = excluded.summary,
  open_points = excluded.open_points, updated_at = now();

insert into ops_supplier_contacts (id, supplier_id, name, role, sort_order)
values ('a0000000-0000-0000-0000-000000990001', 'a0000000-0000-0000-0000-000000000000', 'Reservations', 'Reservations', 1)
on conflict (id) do nothing;


-- Fotos do HOTEL, sem quarto: acompanham qualquer quarto que ela puxe --
insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('a0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000000', null, E'https://dreffui1gbt6t.cloudfront.net/images/caq/CAQ-stay-category-grandsuites-2.jpg', E'https://auberge.com/collegio-alla-querce/stay/', E'Collegio alla Querce', true, false, 1)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('a0000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-000000000000', null, E'https://dreffui1gbt6t.cloudfront.net/images/caq/CAQ-stay-suites-feature-category.jpg', E'https://auberge.com/collegio-alla-querce/stay/', E'Collegio alla Querce', true, false, 2)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;


-- 01. Arcata Classic King (Guest Rooms)
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('a0000000-0000-0000-0000-000000000000', 'a0000000-0000-0000-0000-000000010000', E'Arcata Classic King', null, null, null, null, E'1 bedroom', null, null, E'Each guest room has a layout of its own, where the new spaces meet the original architecture of the building. Neutral walls are warmed by inlaid hardwood floors; the residential furnishings are finished in rich woollen fabrics that nod to the city''s tailoring, and tall windows carry the Tuscan light inside.', array[E'Individually designed layout', E'Inlaid hardwood floors', E'Tall windows'], E'Cada quarto tem uma planta própria, em que os ambientes novos encontram a arquitetura original do edifício. As paredes neutras são aquecidas por pisos de madeira embutida; o mobiliário residencial é acabado em lãs que fazem referência à alfaiataria da cidade, e as janelas altas trazem a luz toscana para dentro.', array[E'Planta desenhada uma a uma', E'Pisos de madeira embutida', E'Janelas altas'], 1)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('a0000000-0000-0000-0000-000000010001', 'a0000000-0000-0000-0000-000000000000', 'a0000000-0000-0000-0000-000000010000', E'https://dreffui1gbt6t.cloudfront.net/images/caq/CAQ-stay-arcataking-feature.jpg', E'https://auberge.com/collegio-alla-querce/stay/guestrooms/', E'Arcata Classic King', true, false, 1)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;


-- 02. Campagna View King (Guest Rooms)
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('a0000000-0000-0000-0000-000000000000', 'a0000000-0000-0000-0000-000000020000', E'Campagna View King', null, null, null, null, E'1 bedroom', E'Hillside and Terrazza Gardens', null, E'Each guest room has a layout of its own, where the new spaces meet the original architecture of the building. Neutral walls are warmed by inlaid hardwood floors; the residential furnishings are finished in rich woollen fabrics that nod to the city''s tailoring, and tall windows carry the Tuscan light inside.', array[E'Individually designed layout', E'Inlaid hardwood floors', E'Tall windows', E'View: Hillside and Terrazza Gardens'], E'Cada quarto tem uma planta própria, em que os ambientes novos encontram a arquitetura original do edifício. As paredes neutras são aquecidas por pisos de madeira embutida; o mobiliário residencial é acabado em lãs que fazem referência à alfaiataria da cidade, e as janelas altas trazem a luz toscana para dentro.', array[E'Planta desenhada uma a uma', E'Pisos de madeira embutida', E'Janelas altas', E'Vista: Hillside and Terrazza Gardens'], 2)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('a0000000-0000-0000-0000-000000020001', 'a0000000-0000-0000-0000-000000000000', 'a0000000-0000-0000-0000-000000020000', E'https://dreffui1gbt6t.cloudfront.net/images/caq/CAQ-stay-campagnaking-featuredimage.jpg', E'https://auberge.com/collegio-alla-querce/stay/guestrooms/', E'Campagna View King', true, false, 1)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;


-- 03. Firenze View King (Guest Rooms)
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('a0000000-0000-0000-0000-000000000000', 'a0000000-0000-0000-0000-000000030000', E'Firenze View King', null, null, null, null, E'1 bedroom', E'City', null, E'Each guest room has a layout of its own, where the new spaces meet the original architecture of the building. Neutral walls are warmed by inlaid hardwood floors; the residential furnishings are finished in rich woollen fabrics that nod to the city''s tailoring, and tall windows carry the Tuscan light inside.', array[E'Individually designed layout', E'Inlaid hardwood floors', E'Tall windows', E'View: City'], E'Cada quarto tem uma planta própria, em que os ambientes novos encontram a arquitetura original do edifício. As paredes neutras são aquecidas por pisos de madeira embutida; o mobiliário residencial é acabado em lãs que fazem referência à alfaiataria da cidade, e as janelas altas trazem a luz toscana para dentro.', array[E'Planta desenhada uma a uma', E'Pisos de madeira embutida', E'Janelas altas', E'Vista: City'], 3)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('a0000000-0000-0000-0000-000000030001', 'a0000000-0000-0000-0000-000000000000', 'a0000000-0000-0000-0000-000000030000', E'https://dreffui1gbt6t.cloudfront.net/images/caq/CAQ-stay-firenzeking-featuredimage.jpg', E'https://auberge.com/collegio-alla-querce/stay/guestrooms/', E'Firenze View King', true, false, 1)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;


-- 04. Collegio Double (Guest Rooms)
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('a0000000-0000-0000-0000-000000000000', 'a0000000-0000-0000-0000-000000040000', E'Collegio Double', null, null, null, null, E'1 bedroom', E'Courtyard', null, E'Each guest room has a layout of its own, where the new spaces meet the original architecture of the building. Neutral walls are warmed by inlaid hardwood floors; the residential furnishings are finished in rich woollen fabrics that nod to the city''s tailoring, and tall windows carry the Tuscan light inside.', array[E'Individually designed layout', E'Inlaid hardwood floors', E'Tall windows', E'View: Courtyard'], E'Cada quarto tem uma planta própria, em que os ambientes novos encontram a arquitetura original do edifício. As paredes neutras são aquecidas por pisos de madeira embutida; o mobiliário residencial é acabado em lãs que fazem referência à alfaiataria da cidade, e as janelas altas trazem a luz toscana para dentro.', array[E'Planta desenhada uma a uma', E'Pisos de madeira embutida', E'Janelas altas', E'Vista: Courtyard'], 4)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;


-- 05. Balcone Premium King (Guest Rooms)
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('a0000000-0000-0000-0000-000000000000', 'a0000000-0000-0000-0000-000000050000', E'Balcone Premium King', null, null, null, null, E'1 bedroom', E'City or Terrazza Gardens', null, E'Each guest room has a layout of its own, where the new spaces meet the original architecture of the building. Neutral walls are warmed by inlaid hardwood floors; the residential furnishings are finished in rich woollen fabrics that nod to the city''s tailoring, and tall windows carry the Tuscan light inside.', array[E'Individually designed layout', E'Inlaid hardwood floors', E'Tall windows', E'View: City or Terrazza Gardens'], E'Cada quarto tem uma planta própria, em que os ambientes novos encontram a arquitetura original do edifício. As paredes neutras são aquecidas por pisos de madeira embutida; o mobiliário residencial é acabado em lãs que fazem referência à alfaiataria da cidade, e as janelas altas trazem a luz toscana para dentro.', array[E'Planta desenhada uma a uma', E'Pisos de madeira embutida', E'Janelas altas', E'Vista: City or Terrazza Gardens'], 5)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;


-- 06. Principe Junior Suite (Suites)
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('a0000000-0000-0000-0000-000000000000', 'a0000000-0000-0000-0000-000000060000', E'Principe Junior Suite', null, null, null, null, E'1 bedroom', E'Firenze or the Tuscan hillside', null, E'Spacious, with linen-upholstered lounge seating, walk-through dressing rooms and a mix of contemporary furnishings and objets d''art.', array[E'Linen-upholstered lounge seating', E'Walk-through dressing room', E'Contemporary furnishings and objets d''art', E'View: Firenze or the Tuscan hillside'], E'Amplas, com assentos de estar estofados em linho, closets de passagem e uma mistura de mobiliário contemporâneo e objetos de arte.', array[E'Assentos de estar estofados em linho', E'Closet de passagem', E'Mobiliário contemporâneo e objetos de arte', E'Vista: Firenze or the Tuscan hillside'], 6)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('a0000000-0000-0000-0000-000000060001', 'a0000000-0000-0000-0000-000000000000', 'a0000000-0000-0000-0000-000000060000', E'https://dreffui1gbt6t.cloudfront.net/images/caq/CAQ-stay-principeking-feature.jpg', E'https://auberge.com/collegio-alla-querce/stay/suites/', E'Principe Junior Suite', true, false, 1)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;


-- 07. Fiore One Bedroom Suite (Suites)
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('a0000000-0000-0000-0000-000000000000', 'a0000000-0000-0000-0000-000000070000', E'Fiore One Bedroom Suite', null, null, null, null, E'1 bedroom', E'Firenze or the Terrazza Gardens', null, E'Spacious, with linen-upholstered lounge seating, walk-through dressing rooms and a mix of contemporary furnishings and objets d''art.', array[E'Linen-upholstered lounge seating', E'Walk-through dressing room', E'Contemporary furnishings and objets d''art', E'View: Firenze or the Terrazza Gardens'], E'Amplas, com assentos de estar estofados em linho, closets de passagem e uma mistura de mobiliário contemporâneo e objetos de arte.', array[E'Assentos de estar estofados em linho', E'Closet de passagem', E'Mobiliário contemporâneo e objetos de arte', E'Vista: Firenze or the Terrazza Gardens'], 7)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('a0000000-0000-0000-0000-000000070001', 'a0000000-0000-0000-0000-000000000000', 'a0000000-0000-0000-0000-000000070000', E'https://dreffui1gbt6t.cloudfront.net/images/caq/CAQ-stay-fiore-hero-featuredimage-1.jpg', E'https://auberge.com/collegio-alla-querce/stay/suites/', E'Fiore One Bedroom Suite', true, false, 1)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;


-- 08. Florentina One Bedroom Suite (Suites)
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('a0000000-0000-0000-0000-000000000000', 'a0000000-0000-0000-0000-000000080000', E'Florentina One Bedroom Suite', null, null, null, null, E'1 bedroom', E'Duomo or the Tuscan hillside', null, E'Spacious, with linen-upholstered lounge seating, walk-through dressing rooms and a mix of contemporary furnishings and objets d''art.', array[E'Linen-upholstered lounge seating', E'Walk-through dressing room', E'Contemporary furnishings and objets d''art', E'View: Duomo or the Tuscan hillside'], E'Amplas, com assentos de estar estofados em linho, closets de passagem e uma mistura de mobiliário contemporâneo e objetos de arte.', array[E'Assentos de estar estofados em linho', E'Closet de passagem', E'Mobiliário contemporâneo e objetos de arte', E'Vista: Duomo or the Tuscan hillside'], 8)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('a0000000-0000-0000-0000-000000080001', 'a0000000-0000-0000-0000-000000000000', 'a0000000-0000-0000-0000-000000080000', E'https://dreffui1gbt6t.cloudfront.net/images/caq/CAQ-stay-fiorentina-featuredimage.jpg', E'https://auberge.com/collegio-alla-querce/stay/suites/', E'Florentina One Bedroom Suite', true, false, 1)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;


-- 09. Affreschi Suite (Grand Suites)
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('a0000000-0000-0000-0000-000000000000', 'a0000000-0000-0000-0000-000000090000', E'Affreschi Suite', null, null, null, null, E'1 bedroom', E'Firenze, Duomo and neighbourhood', null, E'Coffered wood ceilings, rich textiles, stand-alone bathtubs, hand-painted murals and generous balconies, over the terrazza and the Baroque gardens or over Firenze. The rate includes a complimentary minibar with espresso machine, a signature cocktail on arrival, a round-trip transfer from the airport or station, one in-house experience for two, and packing and unpacking service.', array[E'Coffered wood ceilings and hand-painted murals', E'Stand-alone bathtub', E'Generous balcony', E'Airport transfer, an in-house experience and packing service included', E'View: Firenze, Duomo and neighbourhood'], E'Tetos de caixotões de madeira, tecidos nobres, banheiras soltas, murais pintados à mão e varandas generosas, sobre a terrazza e os jardins barrocos ou sobre Florença. A diária inclui frigobar de cortesia com máquina de espresso, um coquetel de boas-vindas, transfer de ida e volta do aeroporto ou da estação, uma experiência da casa para duas pessoas, e serviço de arrumar e desfazer as malas.', array[E'Tetos de caixotões e murais pintados à mão', E'Banheira solta', E'Varanda generosa', E'Transfer, uma experiência da casa e serviço de malas inclusos', E'Vista: Firenze, Duomo and neighbourhood'], 9)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('a0000000-0000-0000-0000-000000090001', 'a0000000-0000-0000-0000-000000000000', 'a0000000-0000-0000-0000-000000090000', E'https://dreffui1gbt6t.cloudfront.net/images/caq/CAQ-stay-affreschi-hero-featuredimage-3.jpg', E'https://auberge.com/collegio-alla-querce/stay/grandsuites/', E'Affreschi Suite', true, false, 1)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;


-- 10. Suite Giardino (Grand Suites)
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('a0000000-0000-0000-0000-000000000000', 'a0000000-0000-0000-0000-000000100000', E'Suite Giardino', null, null, null, null, E'1 bedroom', E'Firenze and the Baroque Gardens', null, E'Coffered wood ceilings, rich textiles, stand-alone bathtubs, hand-painted murals and generous balconies, over the terrazza and the Baroque gardens or over Firenze. The rate includes a complimentary minibar with espresso machine, a signature cocktail on arrival, a round-trip transfer from the airport or station, one in-house experience for two, and packing and unpacking service.', array[E'Coffered wood ceilings and hand-painted murals', E'Stand-alone bathtub', E'Generous balcony', E'Airport transfer, an in-house experience and packing service included', E'View: Firenze and the Baroque Gardens'], E'Tetos de caixotões de madeira, tecidos nobres, banheiras soltas, murais pintados à mão e varandas generosas, sobre a terrazza e os jardins barrocos ou sobre Florença. A diária inclui frigobar de cortesia com máquina de espresso, um coquetel de boas-vindas, transfer de ida e volta do aeroporto ou da estação, uma experiência da casa para duas pessoas, e serviço de arrumar e desfazer as malas.', array[E'Tetos de caixotões e murais pintados à mão', E'Banheira solta', E'Varanda generosa', E'Transfer, uma experiência da casa e serviço de malas inclusos', E'Vista: Firenze and the Baroque Gardens'], 10)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('a0000000-0000-0000-0000-000000100001', 'a0000000-0000-0000-0000-000000000000', 'a0000000-0000-0000-0000-000000100000', E'https://dreffui1gbt6t.cloudfront.net/images/caq/CAQ-stay-suitegiardino-featuredimage-1.jpg', E'https://auberge.com/collegio-alla-querce/stay/grandsuites/', E'Suite Giardino', true, false, 1)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;


-- 11. Suite dei Gigli (Grand Suites)
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('a0000000-0000-0000-0000-000000000000', 'a0000000-0000-0000-0000-000000110000', E'Suite dei Gigli', null, null, null, null, E'1 bedroom', E'Duomo', null, E'Coffered wood ceilings, rich textiles, stand-alone bathtubs, hand-painted murals and generous balconies, over the terrazza and the Baroque gardens or over Firenze. The rate includes a complimentary minibar with espresso machine, a signature cocktail on arrival, a round-trip transfer from the airport or station, one in-house experience for two, and packing and unpacking service.', array[E'Coffered wood ceilings and hand-painted murals', E'Stand-alone bathtub', E'Generous balcony', E'Airport transfer, an in-house experience and packing service included', E'View: Duomo'], E'Tetos de caixotões de madeira, tecidos nobres, banheiras soltas, murais pintados à mão e varandas generosas, sobre a terrazza e os jardins barrocos ou sobre Florença. A diária inclui frigobar de cortesia com máquina de espresso, um coquetel de boas-vindas, transfer de ida e volta do aeroporto ou da estação, uma experiência da casa para duas pessoas, e serviço de arrumar e desfazer as malas.', array[E'Tetos de caixotões e murais pintados à mão', E'Banheira solta', E'Varanda generosa', E'Transfer, uma experiência da casa e serviço de malas inclusos', E'Vista: Duomo'], 11)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('a0000000-0000-0000-0000-000000110001', 'a0000000-0000-0000-0000-000000000000', 'a0000000-0000-0000-0000-000000110000', E'https://dreffui1gbt6t.cloudfront.net/images/caq/CAQ-stay-suitedeigigli-featuredimage.jpg', E'https://auberge.com/collegio-alla-querce/stay/grandsuites/', E'Suite dei Gigli', true, false, 1)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;


-- 12. Campanile Suite (Grand Suites)
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('a0000000-0000-0000-0000-000000000000', 'a0000000-0000-0000-0000-000000120000', E'Campanile Suite', null, null, null, null, E'1 bedroom', E'Duomo and the Tuscan hillside', null, E'Coffered wood ceilings, rich textiles, stand-alone bathtubs, hand-painted murals and generous balconies, over the terrazza and the Baroque gardens or over Firenze. The rate includes a complimentary minibar with espresso machine, a signature cocktail on arrival, a round-trip transfer from the airport or station, one in-house experience for two, and packing and unpacking service.', array[E'Coffered wood ceilings and hand-painted murals', E'Stand-alone bathtub', E'Generous balcony', E'Airport transfer, an in-house experience and packing service included', E'View: Duomo and the Tuscan hillside'], E'Tetos de caixotões de madeira, tecidos nobres, banheiras soltas, murais pintados à mão e varandas generosas, sobre a terrazza e os jardins barrocos ou sobre Florença. A diária inclui frigobar de cortesia com máquina de espresso, um coquetel de boas-vindas, transfer de ida e volta do aeroporto ou da estação, uma experiência da casa para duas pessoas, e serviço de arrumar e desfazer as malas.', array[E'Tetos de caixotões e murais pintados à mão', E'Banheira solta', E'Varanda generosa', E'Transfer, uma experiência da casa e serviço de malas inclusos', E'Vista: Duomo and the Tuscan hillside'], 12)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;


-- 13. Santa Maria del Fiore Suite (Grand Suites)
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('a0000000-0000-0000-0000-000000000000', 'a0000000-0000-0000-0000-000000130000', E'Santa Maria del Fiore Suite', null, null, null, null, E'1 bedroom', E'Firenze, Duomo and the Tuscan hillside', null, E'Coffered wood ceilings, rich textiles, stand-alone bathtubs, hand-painted murals and generous balconies, over the terrazza and the Baroque gardens or over Firenze. The rate includes a complimentary minibar with espresso machine, a signature cocktail on arrival, a round-trip transfer from the airport or station, one in-house experience for two, and packing and unpacking service.', array[E'Coffered wood ceilings and hand-painted murals', E'Stand-alone bathtub', E'Generous balcony', E'Airport transfer, an in-house experience and packing service included', E'View: Firenze, Duomo and the Tuscan hillside'], E'Tetos de caixotões de madeira, tecidos nobres, banheiras soltas, murais pintados à mão e varandas generosas, sobre a terrazza e os jardins barrocos ou sobre Florença. A diária inclui frigobar de cortesia com máquina de espresso, um coquetel de boas-vindas, transfer de ida e volta do aeroporto ou da estação, uma experiência da casa para duas pessoas, e serviço de arrumar e desfazer as malas.', array[E'Tetos de caixotões e murais pintados à mão', E'Banheira solta', E'Varanda generosa', E'Transfer, uma experiência da casa e serviço de malas inclusos', E'Vista: Firenze, Duomo and the Tuscan hillside'], 13)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;


-- 14. Penthouse La Quercia (Grand Suites)
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('a0000000-0000-0000-0000-000000000000', 'a0000000-0000-0000-0000-000000140000', E'Penthouse La Quercia', null, null, null, null, E'1 bedroom', E'Firenze, Duomo and the Tuscan hillside', null, E'Coffered wood ceilings, rich textiles, stand-alone bathtubs, hand-painted murals and generous balconies, over the terrazza and the Baroque gardens or over Firenze. The rate includes a complimentary minibar with espresso machine, a signature cocktail on arrival, a round-trip transfer from the airport or station, one in-house experience for two, and packing and unpacking service.', array[E'Coffered wood ceilings and hand-painted murals', E'Stand-alone bathtub', E'Generous balcony', E'Airport transfer, an in-house experience and packing service included', E'View: Firenze, Duomo and the Tuscan hillside'], E'Tetos de caixotões de madeira, tecidos nobres, banheiras soltas, murais pintados à mão e varandas generosas, sobre a terrazza e os jardins barrocos ou sobre Florença. A diária inclui frigobar de cortesia com máquina de espresso, um coquetel de boas-vindas, transfer de ida e volta do aeroporto ou da estação, uma experiência da casa para duas pessoas, e serviço de arrumar e desfazer as malas.', array[E'Tetos de caixotões e murais pintados à mão', E'Banheira solta', E'Varanda generosa', E'Transfer, uma experiência da casa e serviço de malas inclusos', E'Vista: Firenze, Duomo and the Tuscan hillside'], 14)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;


-- 15. Hillside Two Bedroom Suite (Two Bedroom Suites)
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('a0000000-0000-0000-0000-000000000000', 'a0000000-0000-0000-0000-000000150000', E'Hillside Two Bedroom Suite', null, null, null, null, E'2 bedrooms', E'Tuscan hillside, resort entryway and gardens, Fiesole', null, E'Combinations that make a two-bedroom accommodation around a generous living space, with views over the Tuscan countryside and Firenze.', array[E'Two bedrooms around a shared living space', E'Views over the countryside and Firenze', E'View: Tuscan hillside, resort entryway and gardens, Fiesole'], E'Combinações que formam uma acomodação de dois quartos em torno de uma sala ampla, com vista para o campo toscano e para Florença.', array[E'Dois quartos em torno de uma sala comum', E'Vista para o campo e para Florença', E'Vista: Tuscan hillside, resort entryway and gardens, Fiesole'], 15)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('a0000000-0000-0000-0000-000000150001', 'a0000000-0000-0000-0000-000000000000', 'a0000000-0000-0000-0000-000000150000', E'https://dreffui1gbt6t.cloudfront.net/images/caq/CAQ-stay-hillsidetwobed-featuredimage-1.jpg', E'https://auberge.com/collegio-alla-querce/stay/two-bedroom-suites/', E'Hillside Two Bedroom Suite', true, false, 1)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;


-- 16. Duomo Two Bedroom Suite (Two Bedroom Suites)
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('a0000000-0000-0000-0000-000000000000', 'a0000000-0000-0000-0000-000000160000', E'Duomo Two Bedroom Suite', null, null, null, null, E'2 bedrooms', E'Duomo and the Tuscan hillside', null, E'Combinations that make a two-bedroom accommodation around a generous living space, with views over the Tuscan countryside and Firenze.', array[E'Two bedrooms around a shared living space', E'Views over the countryside and Firenze', E'View: Duomo and the Tuscan hillside'], E'Combinações que formam uma acomodação de dois quartos em torno de uma sala ampla, com vista para o campo toscano e para Florença.', array[E'Dois quartos em torno de uma sala comum', E'Vista para o campo e para Florença', E'Vista: Duomo and the Tuscan hillside'], 16)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('a0000000-0000-0000-0000-000000160001', 'a0000000-0000-0000-0000-000000000000', 'a0000000-0000-0000-0000-000000160000', E'https://dreffui1gbt6t.cloudfront.net/images/caq/caq-stay-fioretwobed-listing-1.jpg', E'https://auberge.com/collegio-alla-querce/stay/two-bedroom-suites/', E'Duomo Two Bedroom Suite', true, false, 1)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;


-- 17. Firenze Two Bedroom Suite (Two Bedroom Suites)
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('a0000000-0000-0000-0000-000000000000', 'a0000000-0000-0000-0000-000000170000', E'Firenze Two Bedroom Suite', null, null, null, null, E'2 bedrooms', E'Florence rooftop, Baroque gardens', null, E'Combinations that make a two-bedroom accommodation around a generous living space, with views over the Tuscan countryside and Firenze.', array[E'Two bedrooms around a shared living space', E'Views over the countryside and Firenze', E'View: Florence rooftop, Baroque gardens'], E'Combinações que formam uma acomodação de dois quartos em torno de uma sala ampla, com vista para o campo toscano e para Florença.', array[E'Dois quartos em torno de uma sala comum', E'Vista para o campo e para Florença', E'Vista: Florence rooftop, Baroque gardens'], 17)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('a0000000-0000-0000-0000-000000170001', 'a0000000-0000-0000-0000-000000000000', 'a0000000-0000-0000-0000-000000170000', E'https://dreffui1gbt6t.cloudfront.net/images/caq/CAQ-stay-firenze2bedroom-featureimage.jpg', E'https://auberge.com/collegio-alla-querce/stay/two-bedroom-suites/', E'Firenze Two Bedroom Suite', true, false, 1)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;


insert into ops_migrations (id) values ('0049-collegio-alla-querce') on conflict (id) do nothing;
