-- =====================================================================
-- 0048 · ORIENT EXPRESS VENEZIA, NO PALAZZO DONÀ GIOVANNELLI
--
-- Ela respondeu "Orient Express Venezia" à pergunta de qual era: são três
-- coisas com esse nome — o hotel La Minerva em Roma, este em Veneza, e o
-- trem La Dolce Vita. Este é o hotel de Veneza.
--
-- Palazzo de 1436 em Cannaregio, que virou hotel pela primeira vez na
-- história dele: abriu em 30 de março de 2026, com restauro de Aline
-- Asmar d'Amman. São 47 quartos e suítes, de 30 a 148 m².
--
-- DEZ CATEGORIAS, que é o que o site publica, com metragem, cama e
-- ocupação tiradas do bloco "About your room" de cada página. As seis
-- Signature Suites têm nome próprio e história própria — Minerva, Teatro,
-- Colori Persi, Cherubini, Del Conte e a Orient Express Suite —, cada uma
-- com o afresco e o ano dele, que é material de proposta que não se
-- inventa.
--
-- O QUE FALTA, e está nos pontos em aberto: os 2 Orient Express
-- Apartments, no prédio ao lado, que o site anuncia no texto institucional
-- mas não lista na página de quartos.
--
-- A REGIÃO FICOU 'Other'. A lista de regiões do hub é Tuscany, Umbria,
-- Lazio e Other — Veneto não existe nela, e inventar valor fora da lista
-- quebraria a trava. Acrescentar Veneto é migração à parte, que só amplia
-- a lista e não mexe em ficha nenhuma; fica à espera da palavra dela.
--
-- FOTO: as galerias de cada categoria são carregadas por JavaScript e não
-- deram para ler. Cada página mostra o carrossel DAS OUTRAS categorias, e
-- é de lá que saíram as cinco fotos que trazem nome de categoria no
-- arquivo. As outras entraram como foto DO HOTEL, sem quarto — e foto de
-- hotel já acompanha qualquer quarto que ela puxe.
--
-- Só cria e preenche objetos ops_. Nenhum update ou delete em linha antiga.
-- =====================================================================


insert into ops_suppliers
  (id, name, category, subcategories, business_suite, status, region, city, address,
   website, languages, name_rule, vat_status, vat_number,
   accommodation_summary, accommodation_notes, highlights, tags, summary,
   open_points, internal_notes)
values ('e0000000-0000-0000-0000-000000000000',
  'Orient Express Venezia', 'Hotel / Accommodation',
  array['Palazzo','City hotel'],
  array['TL Selected Stays'],
  'To test', 'Other', 'Venezia (Cannaregio)',
  'Strada Nova 2292 – 30121 Venezia',
  E'https://www.orient-express.com/en/hotel/europe/italy/venice/orient-express-venezia',
  array['Italian','English','French'],
  'Show supplier name', 'not stated', 'IT17193471004',
  E'47 rooms and suites from 30 to 148 sqm: 29 rooms, 16 suites of which 6 are Signature Suites, and 2 Orient Express Apartments in an adjoining building.',
  E'Venetian sliding doors framing hand-painted scenes · Art Deco fixtures and Murano glass accents · marble bathrooms with bathtub or walk-in shower · luxurious linens · bespoke bathroom amenities · minibar with complimentary soft drinks · coffee and tea selection. Butler service in the Signature Suites.',
  array[
    'A palazzo of 1436 in Cannaregio, turned into a hotel for the first time in its history',
    'Opened 30 March 2026; restoration by architect and interior designer Aline Asmar d''Amman',
    'Original frescoes from 1790, 1860 and the 19th century, restored in the Signature Suites',
    'Fine dining restaurant with private boat access',
    'All-day dining onto the courtyard and the garden',
    'The Wagon Bar, a tribute to the golden age of rail travel',
    'Spa',
    'Canal views over the Rio di Santa Fosca and the Strada Nova'],
  array['Venice','Cannaregio','palazzo','Orient Express','new opening'],
  E'A Venetian palazzo of 1436 in Cannaregio, home of the Donà and then the Giovannelli families, which became a hotel for the first time in 2026. Aline Asmar d''Amman''s restoration left the frescoed ceilings, the carved beams and the marble fireplaces where they were and built the rooms around them, so that each of the six Signature Suites carries a different piece of the house''s history. The fine dining restaurant has its own boat landing.',
  array[
    'The 2 Orient Express Apartments are announced in the hotel text but not listed on the rooms page: ask the hotel for size, layout and rate.',
    'Region recorded as Other: the hub list has no Veneto. Adding it is a separate migration.',
    'Net rates, cancellation policy and payment terms to the supplier not yet collected.',
    'Each category gallery is JavaScript-loaded and could not be read: six property photos were filed at hotel level instead.',
    'Photo usage not yet cleared with the property: usage_cleared is false on every photo.'],
  E'Contatos: reservations.venezia@orient-express.com · +39 041 885 8004.\nStrada Nova 2292, 30121 Venezia (Cannaregio). VAT IT17193471004 · CIN IT027042A19T6QRB9D.\nFicha montada do site oficial, outubro/26: a página do hotel e as dez páginas de categoria. Metragem, cama e ocupação são o bloco ''About your room/suite'' de cada página.\nREGIÃO FICOU COMO ''Other'' porque a lista do hub só tem Tuscany, Umbria, Lazio e Other — Veneto não existe nela. Se ela quiser, acrescentar Veneto é uma migração que só amplia a lista e não mexe em ficha nenhuma.\nAs fotos vêm de medias.orient-express.com no estilo w1600, que é o tamanho certo para proposta (115 a 180 KB cada). Esse servidor NÃO manda CORS, então elas não encolhem no PDF — só que já nascem pequenas, então aqui isso quase não pesa.\nAs galerias próprias de cada categoria são carregadas por JavaScript e não puderam ser lidas. Cada página mostra o carrossel DAS OUTRAS categorias, e é daí que saíram as cinco fotos com nome de categoria no arquivo. As demais ficaram como foto do HOTEL, sem quarto — e foto de hotel entra junto em qualquer quarto que ela puxar, que é o comportamento que já existia.' )
on conflict (id) do update set
  name = excluded.name, category = excluded.category, subcategories = excluded.subcategories,
  business_suite = excluded.business_suite, region = excluded.region, city = excluded.city,
  address = excluded.address, website = excluded.website, languages = excluded.languages,
  name_rule = excluded.name_rule, vat_number = excluded.vat_number,
  accommodation_summary = excluded.accommodation_summary,
  accommodation_notes = excluded.accommodation_notes,
  highlights = excluded.highlights, tags = excluded.tags, summary = excluded.summary,
  open_points = excluded.open_points, updated_at = now();

insert into ops_supplier_contacts (id, supplier_id, name, role, email, phone, sort_order)
values ('e0000000-0000-0000-0000-000000990001', 'e0000000-0000-0000-0000-000000000000', 'Reservations', 'Reservations',
        'reservations.venezia@orient-express.com', '+39 041 885 8004', 1)
on conflict (id) do update set email = excluded.email, phone = excluded.phone;


-- Fotos do HOTEL, sem quarto: acompanham qualquer quarto que ela puxe --
insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('e0000000-0000-0000-0000-000000000001', 'e0000000-0000-0000-0000-000000000000', null, E'https://medias.orient-express.com/sites/default/files/styles/w1600/public/2025-07/orient-express-palazzo-dona-giovannelli.webp', E'https://www.orient-express.com/en/hotel/europe/italy/venice/orient-express-venezia', E'Orient Express Venezia', true, false, 1)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('e0000000-0000-0000-0000-000000000002', 'e0000000-0000-0000-0000-000000000000', null, E'https://medias.orient-express.com/sites/default/files/styles/w1600/public/2026-03/P3270004%201__T_1.webp', E'https://www.orient-express.com/en/hotel/europe/italy/venice/orient-express-venezia', E'Orient Express Venezia', true, false, 2)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('e0000000-0000-0000-0000-000000000003', 'e0000000-0000-0000-0000-000000000000', null, E'https://medias.orient-express.com/sites/default/files/styles/w1600/public/2026-04/02%20Detail%20Cherub%20OEV.webp', E'https://www.orient-express.com/en/hotel/europe/italy/venice/orient-express-venezia', E'Orient Express Venezia', true, false, 3)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('e0000000-0000-0000-0000-000000000004', 'e0000000-0000-0000-0000-000000000000', null, E'https://medias.orient-express.com/sites/default/files/styles/w1600/public/2026-04/OE_ALINE17611%20copia.webp', E'https://www.orient-express.com/en/hotel/europe/italy/venice/orient-express-venezia', E'Orient Express Venezia', true, false, 4)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('e0000000-0000-0000-0000-000000000005', 'e0000000-0000-0000-0000-000000000000', null, E'https://medias.orient-express.com/sites/default/files/styles/w1600/public/2026-04/OE_ALINE17636%201%20copia.webp', E'https://www.orient-express.com/en/hotel/europe/italy/venice/orient-express-venezia', E'Orient Express Venezia', true, false, 5)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('e0000000-0000-0000-0000-000000000006', 'e0000000-0000-0000-0000-000000000000', null, E'https://medias.orient-express.com/sites/default/files/styles/w1600/public/2026-04/OE_ALINE17651%20copia.webp', E'https://www.orient-express.com/en/hotel/europe/italy/venice/orient-express-venezia', E'Orient Express Venezia', true, false, 6)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;


-- 01. Superior Room ----------------------------------------------
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('e0000000-0000-0000-0000-000000000000', 'e0000000-0000-0000-0000-000000010000', E'Superior Room', E'average of 32 sqm', 32, 32, E'Max 2 guests: 2 adults, or 1 adult and 1 child', E'King size bed', null, null, E'Elegant superior rooms with a king-size bed and marble bathroom. Murano glass accents, embossed leathers and custom furnishings. Luxurious linens, bespoke bathroom amenities, minibar with complimentary soft drinks, coffee and tea selection.', array[E'Murano glass accents and embossed leathers', E'Marble bathroom with bathtub or walk-in shower', E'Custom furnishings'], E'Quartos superiores elegantes, com cama king e banheiro em mármore. Detalhes em vidro de Murano, couros gravados e mobiliário sob medida. Roupa de cama fina, amenidades exclusivas, frigobar com refrigerantes de cortesia e seleção de café e chá.', array[E'Detalhes em vidro de Murano e couros gravados', E'Banheiro em mármore com banheira ou chuveiro', E'Mobiliário sob medida'], 1)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;


-- 02. Deluxe Room ----------------------------------------------
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('e0000000-0000-0000-0000-000000000000', 'e0000000-0000-0000-0000-000000020000', E'Deluxe Room', E'average of 40 sqm', 40, 40, E'Max 2 guests: 2 adults, or 1 adult and 1 child', E'King size bed', null, null, E'Generous deluxe rooms with a king-size bed and marble bathroom, where the intimacy of a Venetian salon meets a sense of space. Murano glass accents, embossed leathers and custom furnishings. Luxurious linens, bespoke bathroom amenities, minibar with complimentary soft drinks, coffee and tea selection.', array[E'The intimacy of a Venetian salon, with space', E'Murano glass accents and embossed leathers', E'Marble bathroom with bathtub or walk-in shower'], E'Quartos deluxe amplos, com cama king e banheiro em mármore, onde a intimidade de um salão veneziano encontra a sensação de espaço. Detalhes em vidro de Murano, couros gravados e mobiliário sob medida. Roupa de cama fina, amenidades exclusivas, frigobar com refrigerantes de cortesia e seleção de café e chá.', array[E'A intimidade de um salão veneziano, com espaço', E'Detalhes em vidro de Murano e couros gravados', E'Banheiro em mármore com banheira ou chuveiro'], 2)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('e0000000-0000-0000-0000-000000020001', 'e0000000-0000-0000-0000-000000000000', 'e0000000-0000-0000-0000-000000020000', E'https://medias.orient-express.com/sites/default/files/styles/w1600/public/2026-03/OEV_404_DeluxeRoom_Credits_GiulioGhirardi_2.webp', E'https://www.orient-express.com/en/hotel/europe/italy/venice/orient-express-venezia/rooms-suites/deluxe-room', E'Deluxe Room', true, false, 1)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('e0000000-0000-0000-0000-000000020002', 'e0000000-0000-0000-0000-000000000000', 'e0000000-0000-0000-0000-000000020000', E'https://medias.orient-express.com/sites/default/files/styles/w1600/public/desktop/1072x800/OEV_404_DeluxeRoom_Credits_GiulioGhirardi.webp', E'https://www.orient-express.com/en/hotel/europe/italy/venice/orient-express-venezia/rooms-suites/deluxe-room', E'Deluxe Room', true, false, 2)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('e0000000-0000-0000-0000-000000020003', 'e0000000-0000-0000-0000-000000000000', 'e0000000-0000-0000-0000-000000020000', E'https://medias.orient-express.com/sites/default/files/styles/w1600/public/desktop/2202x2202/OEV_404_DeluxeRoom_Credits_GiulioGhirardi.webp', E'https://www.orient-express.com/en/hotel/europe/italy/venice/orient-express-venezia/rooms-suites/deluxe-room', E'Deluxe Room', true, false, 3)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;


-- 03. Junior Suite ----------------------------------------------
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('e0000000-0000-0000-0000-000000000000', 'e0000000-0000-0000-0000-000000030000', E'Junior Suite', E'average of 46 sqm', 46, 46, E'Max 2 guests: 2 adults, or 1 adult and 1 child', E'King or twin beds', null, null, E'Intimate sanctuaries for the well-travelled: hand-painted panoramas of distant voyages intertwine with wood fretwork drawn from the Ca'' d''Oro. A walk-in dressing room inspired by the art of travel, and a marble-clad bathroom with bathtub and standing shower. Contemporary artwork, luxurious linens, bespoke amenities.', array[E'Hand-painted panoramas of distant voyages', E'Wood fretwork drawn from the Ca'' d''Oro', E'Walk-in dressing room inspired by the art of travel', E'Marble bathroom with bathtub and standing shower'], E'Refúgios para quem já viajou muito: panoramas pintados à mão de viagens distantes se entrelaçam com treliças de madeira inspiradas na Ca'' d''Oro. Closet inspirado na arte de viajar, e banheiro revestido de mármore com banheira e chuveiro. Arte contemporânea, roupa de cama fina, amenidades exclusivas.', array[E'Panoramas de viagens distantes pintados à mão', E'Treliças de madeira inspiradas na Ca'' d''Oro', E'Closet inspirado na arte de viajar', E'Banheiro em mármore com banheira e chuveiro'], 3)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('e0000000-0000-0000-0000-000000030001', 'e0000000-0000-0000-0000-000000000000', 'e0000000-0000-0000-0000-000000030000', E'https://medias.orient-express.com/sites/default/files/styles/w1600/public/desktop/1072x800/OEV_413_JuniorSuite_creditsGiulioGhirardi.webp', E'https://www.orient-express.com/en/hotel/europe/italy/venice/orient-express-venezia/rooms-suites/junior-suite', E'Junior Suite', true, false, 1)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('e0000000-0000-0000-0000-000000030002', 'e0000000-0000-0000-0000-000000000000', 'e0000000-0000-0000-0000-000000030000', E'https://medias.orient-express.com/sites/default/files/styles/w1600/public/desktop/2202x2202/OEV_413_JuniorSuite_creditsGiulioGhirardi.webp', E'https://www.orient-express.com/en/hotel/europe/italy/venice/orient-express-venezia/rooms-suites/junior-suite', E'Junior Suite', true, false, 2)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('e0000000-0000-0000-0000-000000030003', 'e0000000-0000-0000-0000-000000000000', 'e0000000-0000-0000-0000-000000030000', E'https://medias.orient-express.com/sites/default/files/styles/w1600/public/desktop/3840x1240/OEV_413_JuniorSuite_creditsGiulioGhirardi.webp', E'https://www.orient-express.com/en/hotel/europe/italy/venice/orient-express-venezia/rooms-suites/junior-suite', E'Junior Suite', true, false, 3)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('e0000000-0000-0000-0000-000000030004', 'e0000000-0000-0000-0000-000000000000', 'e0000000-0000-0000-0000-000000030000', E'https://medias.orient-express.com/sites/default/files/styles/w1600/public/desktop/3840x2160/OEV_413_JuniorSuite_creditsGiulioGhirardi.webp', E'https://www.orient-express.com/en/hotel/europe/italy/venice/orient-express-venezia/rooms-suites/junior-suite', E'Junior Suite', true, false, 4)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;


-- 04. Suite ----------------------------------------------
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('e0000000-0000-0000-0000-000000000000', 'e0000000-0000-0000-0000-000000040000', E'Suite', E'average of 58 sqm', 58, 58, E'Max 3 guests: 3 adults, or 2 adults and 1 child', E'King size bed', E'Canal and palazzo views', null, E'Luminous suites with a king-size bed and enchanting views. Separate living room, walk-in wardrobe, and marble bathroom with standing shower and spacious bathtub. Luxurious linens, bespoke bathroom amenities, minibar with complimentary soft drinks, coffee and tea selection.', array[E'Separate living room', E'Walk-in wardrobe', E'Marble bathroom with shower and bathtub', E'Sleeps a third guest'], E'Suítes luminosas, com cama king e vistas encantadoras. Sala de estar separada, closet e banheiro em mármore com chuveiro e banheira ampla. Roupa de cama fina, amenidades exclusivas, frigobar com refrigerantes de cortesia e seleção de café e chá.', array[E'Sala de estar separada', E'Closet', E'Banheiro em mármore com chuveiro e banheira', E'Acomoda um terceiro hóspede'], 4)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;


-- 05. La Minerva Suite · Signature ----------------------------------------------
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('e0000000-0000-0000-0000-000000000000', 'e0000000-0000-0000-0000-000000050000', E'La Minerva Suite · Signature', E'average of 64 sqm', 64, 64, E'Max 3 guests', E'King size bed', E'Over two canals', null, E'Named after Minerva, Roman goddess of wisdom and the arts, in one of the Palazzo''s most recognisable corners, looking over two canals. The suite is crowned by an original 1790 fresco by Costantino Cedini — one of the oldest works in the hotel — set in a curved, reeded ceiling framed by fine stucco. Pastel furnishings pick up the tones of the fresco, beside a Murano-accented drinks cabinet.', array[E'Original 1790 fresco by Costantino Cedini', E'One of the oldest works in the hotel', E'On a corner over two canals', E'Curved reeded ceiling with fine stucco'], E'Leva o nome de Minerva, deusa romana da sabedoria e das artes, e fica num dos cantos mais reconhecíveis do palazzo, voltada para dois canais. A suíte é coroada por um afresco original de 1790, de Costantino Cedini — uma das obras mais antigas do hotel —, num teto curvo e canelado emoldurado por estuques finos. O mobiliário em tons pastel retoma as cores do afresco, ao lado de um bar com detalhes de Murano.', array[E'Afresco original de 1790, de Costantino Cedini', E'Uma das obras mais antigas do hotel', E'Em esquina, sobre dois canais', E'Teto curvo e canelado com estuques finos'], 5)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;


-- 06. Teatro Suite · Signature ----------------------------------------------
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('e0000000-0000-0000-0000-000000000000', 'e0000000-0000-0000-0000-000000060000', E'Teatro Suite · Signature', E'81 sqm', 81, 81, E'Max 3 guests', E'King size bed', E'Over the Rio di Santa Fosca', null, E'Venice''s nineteenth-century revival read through a theatrical lens: Neo-Rococo flourishes meet historicist drama, and the city''s artistic heritage becomes a room that plays to its audience. Looking over the Rio di Santa Fosca, the suite is crowned by an original 1860 fresco by Giacomo Casa, where the Three Graces and playful cherubs drift across the ceiling.', array[E'Original 1860 fresco by Giacomo Casa', E'The Three Graces and cherubs across the ceiling', E'Over the Rio di Santa Fosca', E'Neo-Rococo interiors read through a theatrical lens'], E'O renascimento oitocentista de Veneza lido por uma lente teatral: ornamentos neorrococó encontram o drama historicista, e a herança artística da cidade vira um ambiente que se apresenta a quem entra. Voltada para o Rio di Santa Fosca, a suíte é coroada por um afresco original de 1860, de Giacomo Casa, onde as Três Graças e querubins atravessam o teto.', array[E'Afresco original de 1860, de Giacomo Casa', E'As Três Graças e querubins no teto', E'Voltada para o Rio di Santa Fosca', E'Interiores neorrococó lidos por uma lente teatral'], 6)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;


-- 07. Colori Persi Suite · Signature ----------------------------------------------
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('e0000000-0000-0000-0000-000000000000', 'e0000000-0000-0000-0000-000000070000', E'Colori Persi Suite · Signature', E'117 sqm', 117, 117, E'Max 3 guests', E'King size bed', E'The palazzo gardens and the Strada Nova', null, E'Colori Persi means lost colours — named for sixteenth-century pigment names and the lore around them. Not gone, but found again. A corner suite over the palazzo gardens and the Strada Nova, crowned by an original 1860 Neo-Rococo fresco by Eugenio Moretti Larese. The salon fills with daylight over Venetian terrazzo floors, framed by sculpted mouldings and soft marmorino finishes. A full marble bathroom.', array[E'Original 1860 Neo-Rococo fresco by Eugenio Moretti Larese', E'Venetian terrazzo floors and marmorino finishes', E'Corner suite over the gardens and the Strada Nova', E'Full marble bathroom'], E'Colori Persi quer dizer cores perdidas — o nome vem dos pigmentos do século XVI e do folclore em torno deles. Não desaparecidas: reencontradas. Suíte de esquina sobre os jardins do palazzo e a Strada Nova, coroada por um afresco neorrococó original de 1860, de Eugenio Moretti Larese. O salão se enche de luz sobre pisos de terrazzo veneziano, emoldurado por molduras esculpidas e acabamentos suaves em marmorino. Banheiro inteiro em mármore.', array[E'Afresco neorrococó original de 1860, de Eugenio Moretti Larese', E'Pisos de terrazzo veneziano e acabamentos em marmorino', E'Suíte de esquina sobre os jardins e a Strada Nova', E'Banheiro inteiro em mármore'], 7)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('e0000000-0000-0000-0000-000000070001', 'e0000000-0000-0000-0000-000000000000', 'e0000000-0000-0000-0000-000000070000', E'https://medias.orient-express.com/sites/default/files/styles/w1600/public/2026-04/OEV_204_ColoriPersi_Suite_02_Credits_GiulioGhirardi.webp', E'https://www.orient-express.com/en/hotel/europe/italy/venice/orient-express-venezia/rooms-suites/colori-persi-suite', E'Colori Persi Suite · Signature', true, false, 1)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('e0000000-0000-0000-0000-000000070002', 'e0000000-0000-0000-0000-000000000000', 'e0000000-0000-0000-0000-000000070000', E'https://medias.orient-express.com/sites/default/files/styles/w1600/public/2026-04/OEV_COLORIPERSI_204_Bathroom_CreditsGiulioGhirardi.webp', E'https://www.orient-express.com/en/hotel/europe/italy/venice/orient-express-venezia/rooms-suites/colori-persi-suite', E'Colori Persi Suite · Signature', true, false, 2)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('e0000000-0000-0000-0000-000000070003', 'e0000000-0000-0000-0000-000000000000', 'e0000000-0000-0000-0000-000000070000', E'https://medias.orient-express.com/sites/default/files/styles/w1600/public/desktop/1072x800/OEV_204_ColoriPersi_Suite_02_Credits_GiulioGhirardi.webp', E'https://www.orient-express.com/en/hotel/europe/italy/venice/orient-express-venezia/rooms-suites/colori-persi-suite', E'Colori Persi Suite · Signature', true, false, 3)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('e0000000-0000-0000-0000-000000070004', 'e0000000-0000-0000-0000-000000000000', 'e0000000-0000-0000-0000-000000070000', E'https://medias.orient-express.com/sites/default/files/styles/w1600/public/desktop/1092x1092/OEV_COLORIPERSI_204_Bathroom_CreditsGiulioGhirardi.webp', E'https://www.orient-express.com/en/hotel/europe/italy/venice/orient-express-venezia/rooms-suites/colori-persi-suite', E'Colori Persi Suite · Signature', true, false, 4)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;


-- 08. Cherubini Suite · Signature ----------------------------------------------
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('e0000000-0000-0000-0000-000000000000', 'e0000000-0000-0000-0000-000000080000', E'Cherubini Suite · Signature', E'127 sqm', 127, 127, E'Max 3 guests', E'King size bed', E'The palazzo gardens and the Strada Nova', null, E'Named for the cherubs that run across its walls, over the palazzo gardens and the Strada Nova. The salon is framed by a rediscovered frieze by Sebastiano Santi and crowned by a finely worked coffered wooden ceiling. Daylight fills the living space, with contemporary seating beside a Murano-accented drinks cabinet. The master bedroom is anchored by a king bed under a blue-and-gold dome.', array[E'Rediscovered frieze by Sebastiano Santi', E'Finely worked coffered wooden ceiling', E'King bed under a blue-and-gold dome', E'Over the gardens and the Strada Nova'], E'Leva o nome dos querubins que correm pelas paredes, e dá para os jardins do palazzo e a Strada Nova. O salão é emoldurado por um friso redescoberto de Sebastiano Santi e coroado por um teto de caixotões de madeira finamente trabalhado. A luz do dia enche a sala, com assentos contemporâneos ao lado de um bar com detalhes de Murano. No quarto principal, a cama king fica sob uma cúpula azul e dourada.', array[E'Friso redescoberto de Sebastiano Santi', E'Teto de caixotões de madeira finamente trabalhado', E'Cama king sob cúpula azul e dourada', E'Sobre os jardins e a Strada Nova'], 8)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('e0000000-0000-0000-0000-000000080001', 'e0000000-0000-0000-0000-000000000000', 'e0000000-0000-0000-0000-000000080000', E'https://medias.orient-express.com/sites/default/files/styles/w1600/public/desktop/1072x800/OEV_CherubiniSuite_creditsGiulioGhirardi.webp', E'https://www.orient-express.com/en/hotel/europe/italy/venice/orient-express-venezia/rooms-suites/cherubini-suite', E'Cherubini Suite · Signature', true, false, 1)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('e0000000-0000-0000-0000-000000080002', 'e0000000-0000-0000-0000-000000000000', 'e0000000-0000-0000-0000-000000080000', E'https://medias.orient-express.com/sites/default/files/styles/w1600/public/desktop/2202x2202/OEV_CherubiniSuite_creditsGiulioGhirardi.webp', E'https://www.orient-express.com/en/hotel/europe/italy/venice/orient-express-venezia/rooms-suites/cherubini-suite', E'Cherubini Suite · Signature', true, false, 2)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;


-- 09. Del Conte Suite · Signature ----------------------------------------------
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('e0000000-0000-0000-0000-000000000000', 'e0000000-0000-0000-0000-000000090000', E'Del Conte Suite · Signature', E'140 sqm', 140, 140, E'Max 3 guests', E'King size bed', E'Palazzo and canal', null, E'Named for Count Giovannelli, humanist and patron of the arts, and once his private residence. Layers of the building''s history open up here: neo-Gothic stained glass, arched corridors, and partitions in wood or brick that show the Venetian trades, while Pompeian-inspired ornament and 1930s finishes carry the memory of patrician villas.', array[E'Once the private residence of Count Giovannelli', E'Neo-Gothic stained glass and arched corridors', E'Pompeian-inspired ornament and 1930s finishes', E'Among the largest suites of the hotel'], E'Leva o nome do conde Giovannelli, humanista e mecenas, e foi a residência particular dele. As camadas da história do edifício se abrem aqui: vitrais neogóticos, corredores em arco e divisórias de madeira ou tijolo que mostram os ofícios venezianos, enquanto a ornamentação de inspiração pompeiana e os acabamentos dos anos 1930 guardam a memória das villas patrícias.', array[E'Antiga residência particular do conde Giovannelli', E'Vitrais neogóticos e corredores em arco', E'Ornamentação pompeiana e acabamentos dos anos 1930', E'Entre as maiores suítes do hotel'], 9)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;


-- 10. Orient Express Suite · Signature ----------------------------------------------
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('e0000000-0000-0000-0000-000000000000', 'e0000000-0000-0000-0000-000000100000', E'Orient Express Suite · Signature', E'145 sqm', 145, 145, E'Max 3 guests', E'King size bed', E'Over the canal, through a restored corner window', null, E'The largest of the suites, and the one that reads Venice as a city of intellect, art and spectacle. Paintings by Antonio Zona and Giovanni Busato hang in the salon, among carved beams, sculptural fireplaces and gilded detail. In the master bedroom, a couture canopy over the king bed, Murano chandeliers, and a restored corner window that brings the canal close. Marble bathroom with freestanding tub and walk-in shower.', array[E'The largest suite of the hotel', E'Paintings by Antonio Zona and Giovanni Busato', E'Couture canopy over the bed and Murano chandeliers', E'Restored corner window onto the canal'], E'A maior das suítes, e a que lê Veneza como cidade de intelecto, arte e espetáculo. Quadros de Antonio Zona e Giovanni Busato ocupam o salão, entre vigas entalhadas, lareiras esculturais e detalhes dourados. No quarto principal, um dossel de alta-costura sobre a cama king, lustres de Murano, e uma janela de esquina restaurada que traz o canal para perto. Banheiro em mármore com banheira solta e chuveiro.', array[E'A maior suíte do hotel', E'Quadros de Antonio Zona e Giovanni Busato', E'Dossel de alta-costura sobre a cama e lustres de Murano', E'Janela de esquina restaurada sobre o canal'], 10)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('e0000000-0000-0000-0000-000000100001', 'e0000000-0000-0000-0000-000000000000', 'e0000000-0000-0000-0000-000000100000', E'https://medias.orient-express.com/sites/default/files/styles/w1600/public/2026-03/OEV_201_OrientExpressSuite_Credits_GiulioGhirardi_2.webp', E'https://www.orient-express.com/en/hotel/europe/italy/venice/orient-express-venezia/rooms-suites/orient-express-suite', E'Orient Express Suite · Signature', true, false, 1)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;


insert into ops_migrations (id) values ('0048-orient-express-venezia') on conflict (id) do nothing;
