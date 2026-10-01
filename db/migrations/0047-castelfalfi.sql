-- =====================================================================
-- 0047 · CASTELFALFI VIRA FICHA, COM AS 24 CATEGORIAS DO FACT SHEET
--
-- Pedido dela, outubro/26. Castelfalfi é o maior dos hotéis desta leva:
-- 146 quartos e suítes, mais um penthouse de duas suítes e as villas da
-- propriedade, numa fazenda de 2.700 acres em Montaione.
--
-- A FONTE É O FACT SHEET OFICIAL DE 2025, em PDF no próprio site. É a
-- melhor fonte que este hotel tem: traz metragem em m² E em sq ft,
-- quantas unidades de cada categoria, os restaurantes com nome, as
-- distâncias e os serviços. Nada veio de memória nem de site de terceiro.
--
-- SEM FOTO, E O MOTIVO FICA REGISTRADO: castelfalfi.com derruba a conexão
-- de leitura automatizada, então nenhuma URL de foto pôde ser lida do
-- site. É o mesmo caso do Palazzo Ripetta. As oito fotos que o próprio
-- fact sheet carrega foram extraídas do PDF e entregues a ela em arquivo,
-- para subir pela tela da ficha. Link de foto que eu não consegui ler não
-- se inventa.
--
-- UMA INCOERÊNCIA DO PRÓPRIO FACT SHEET, registrada e não resolvida por
-- mim: o texto de abertura fala em "3 villas" e a tabela das villas lista
-- cinco. Ficaram as cinco da tabela, que é a parte mais específica do
-- documento, e a dúvida foi para os pontos em aberto da ficha.
--
-- Só cria e preenche objetos ops_. Nenhum update ou delete em linha antiga.
-- =====================================================================


insert into ops_suppliers
  (id, name, category, subcategories, business_suite, status, region, city, address,
   website, languages, name_rule, vat_status,
   accommodation_summary, accommodation_notes, capacities, highlights, tags, summary,
   open_points, internal_notes)
values ('c1000000-0000-0000-0000-000000000000',
  'Castelfalfi', 'Hotel / Accommodation',
  array['Resort','Estate','Golf'],
  array['TL Selected Stays','MICE e Exclusive Events'],
  'To test', 'Tuscany', 'Montaione (Firenze)',
  'Località Castelfalfi, Montaione (Firenze)',
  E'https://www.castelfalfi.com/',
  array['Italian','English'],
  'Show supplier name', 'not stated',
  E'146 rooms and suites, including 20 suites and 4 signature suites, plus a two-suite penthouse and the estate villas. Accommodation ranges from 21 to 550 sqm, split between a contemporary building and a 1900s tobacco warehouse.',
  E'Welcome amenities · 55" or larger TV with national and international channels · Wi-Fi and high-speed internet · individual climate control · Dyson hair dryer · in-room bar · coffee and tea station · safe · iron and ironing board · 24-hour in-room dining. Connected rooms available on request in selected categories.',
  E'21 venues for events and weddings. Largest: Aria - The Great Pavilion, 650 sqm, up to 700 for a cocktail and 650 theatre-style. La Rocca, 1,277 sqm in and outdoors, up to 200. Olivina, 860 sqm indoors, up to 200. Meeting rooms from 59 to 190 sqm (Collodi, Dante, Leonardo, and the combinations Divina, Pinocchio and Sala d''autore).',
  array[
    'Five-star estate of 2,700 acres with a medieval borgo, its castle, the Medicean garden and the church of San Floriano',
    '25 hectares of vineyards and over 40 hectares of olive groves, in organic production',
    'RAKxa Wellness Spa: heated indoor and outdoor pool, two saunas, Turkish bath, sensory showers, vitality pool and seven treatment rooms',
    'Five restaurants and bars, including La Rocca in the medieval castle with tasting menus by chef Davide De Simone',
    'Golf course on the estate',
    'Over 40 experiences: cooking classes, wine and oil tastings, trekking, bike tours, adventure park',
    'Exclusive beach club access at Forte dei Marmi',
    'Montessori-inspired kids club · pet friendly',
    'Pisa airport 52 km (40 min); Florence airport 67 km (60 min); San Gimignano 23 km; Volterra 32 km; Siena 56 km; Lucca 57 km'],
  array['Montaione','estate','golf','spa','wedding venue','MICE'],
  E'Five-star estate across 2,700 acres of Tuscan countryside at Montaione, built around a medieval borgo with its castle, the Medicean garden and the church of San Floriano. The hotel sits within walking distance of the village, split between a contemporary building and a tobacco warehouse of the early 1900s restored into 31 rooms. The working farm produces organic wine and olive oil that feed the restaurants, and the estate carries a golf course, the RAKxa spa, and more than forty experiences.',
  array[
    'The fact sheet says 3 villas in the text and lists 5 in the table: confirm with the hotel which are bookable.',
    'No photo URL could be read: castelfalfi.com refuses automated reading. The eight photos from the fact sheet PDF were handed over as files, to be uploaded from the ficha screen.',
    'Net rates, cancellation policy and payment terms to the supplier not yet collected.',
    'Bed configuration and maximum occupancy are not in the fact sheet, only the bedroom count.'],
  E'Ficha montada do FACT SHEET OFICIAL de 2025, que o próprio hotel publica em PDF: castelfalfi.com/assets/docs/Castelfalfi_Fact-Sheet_ENG_2025.pdf. Metragem, contagem de unidades, restaurantes, distâncias e serviços são os números dele, palavra por palavra.\nO SITE DO CASTELFALFI RECUSA LEITURA AUTOMATIZADA — a conexão é derrubada. Por isso não há foto nesta ficha: nenhuma URL pública pôde ser lida. As oito fotos do próprio fact sheet foram extraídas do PDF e entregues a ela em arquivo, para subir pela ficha (Fornecedores → Fotos → escolher arquivos). Mesmo caso do Palazzo Ripetta, que também recusa leitura.\nUMA INCOERÊNCIA DO PRÓPRIO FACT SHEET: o texto diz ''3 villas'' e a tabela lista cinco (Casa Medici, Il Fienile, Golf Villa I Bianchi, Casale La Pergola, Casale I Bianchi). Ficaram as cinco da tabela, que é a fonte mais específica — conferir com o hotel.\nAs categorias marcadas com * no fact sheet aceitam quarto comunicante sob pedido: Junior Suite, Suite Terrace, Deluxe, Deluxe Belvedere, Prestige, Castelfalfi Suite e Castelfalfi Grand Suite.' )
on conflict (id) do update set
  name = excluded.name, category = excluded.category, subcategories = excluded.subcategories,
  business_suite = excluded.business_suite, region = excluded.region, city = excluded.city,
  address = excluded.address, website = excluded.website, languages = excluded.languages,
  name_rule = excluded.name_rule,
  accommodation_summary = excluded.accommodation_summary,
  accommodation_notes = excluded.accommodation_notes, capacities = excluded.capacities,
  highlights = excluded.highlights, tags = excluded.tags, summary = excluded.summary,
  open_points = excluded.open_points, updated_at = now();

insert into ops_supplier_contacts (id, supplier_id, name, role, sort_order)
values ('c1000000-0000-0000-0000-000000990001', 'c1000000-0000-0000-0000-000000000000', 'Reservations', 'Reservations', 1)
on conflict (id) do nothing;


-- 01. Tabaccaia Classic (TRADITION)
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('c1000000-0000-0000-0000-000000000000', 'c1000000-0000-0000-0000-000000010000', E'Tabaccaia Classic', E'21 sqm / 227 sq ft (fact sheet)', 21, 21, null, E'1 bedroom', null, E'23 rooms', E'The history of the medieval village is evident inside Castelfalfi''s historic tobacco warehouse, carefully renovated to hold 31 "Tabaccaia" rooms in a traditional Tuscan style.', array[E'In the 1900s tobacco warehouse', E'Traditional Tuscan style', E'31 Tabaccaia rooms in all'], E'A história da aldeia medieval está dentro do antigo armazém de tabaco do Castelfalfi, restaurado para abrigar 31 quartos "Tabaccaia" em estilo toscano tradicional.', array[E'No armazém de tabaco dos anos 1900', E'Estilo toscano tradicional', E'31 quartos Tabaccaia ao todo'], 1)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;


-- 02. Tabaccaia Superior (TRADITION)
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('c1000000-0000-0000-0000-000000000000', 'c1000000-0000-0000-0000-000000020000', E'Tabaccaia Superior', E'29 sqm / 312 sq ft (fact sheet)', 29, 29, null, E'1 bedroom', null, E'4 rooms', E'The history of the medieval village is evident inside Castelfalfi''s historic tobacco warehouse, carefully renovated to hold 31 "Tabaccaia" rooms in a traditional Tuscan style.', array[E'In the 1900s tobacco warehouse', E'Traditional Tuscan style', E'31 Tabaccaia rooms in all'], E'A história da aldeia medieval está dentro do antigo armazém de tabaco do Castelfalfi, restaurado para abrigar 31 quartos "Tabaccaia" em estilo toscano tradicional.', array[E'No armazém de tabaco dos anos 1900', E'Estilo toscano tradicional', E'31 quartos Tabaccaia ao todo'], 2)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;


-- 03. Tabaccaia Premium (TRADITION)
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('c1000000-0000-0000-0000-000000000000', 'c1000000-0000-0000-0000-000000030000', E'Tabaccaia Premium', E'35 sqm / 377 sq ft (fact sheet)', 35, 35, null, E'1 bedroom', null, E'4 rooms', E'The history of the medieval village is evident inside Castelfalfi''s historic tobacco warehouse, carefully renovated to hold 31 "Tabaccaia" rooms in a traditional Tuscan style.', array[E'In the 1900s tobacco warehouse', E'Traditional Tuscan style', E'31 Tabaccaia rooms in all'], E'A história da aldeia medieval está dentro do antigo armazém de tabaco do Castelfalfi, restaurado para abrigar 31 quartos "Tabaccaia" em estilo toscano tradicional.', array[E'No armazém de tabaco dos anos 1900', E'Estilo toscano tradicional', E'31 quartos Tabaccaia ao todo'], 3)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;


-- 04. Deluxe (ELEGANCE)
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('c1000000-0000-0000-0000-000000000000', 'c1000000-0000-0000-0000-000000040000', E'Deluxe', E'29 sqm / 312 sq ft (fact sheet)', 29, 29, null, E'1 bedroom', null, E'40 rooms', E'Sophisticated rooms in the heart of the main building, where the warm colours typical of the Tuscan landscape meet contemporary design. Every hotel service is a short walk away.', array[E'In the main building', E'Contemporary design in the warm colours of the landscape', E'All hotel services within reach', E'Connecting room available on request'], E'Quartos sofisticados no coração do edifício principal, onde as cores quentes típicas da paisagem toscana encontram o design contemporâneo. Todos os serviços do hotel ficam a poucos passos.', array[E'No edifício principal', E'Design contemporâneo nas cores quentes da paisagem', E'Todos os serviços do hotel por perto', E'Quarto comunicante sob pedido'], 4)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;


-- 05. Deluxe Belvedere (ELEGANCE)
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('c1000000-0000-0000-0000-000000000000', 'c1000000-0000-0000-0000-000000050000', E'Deluxe Belvedere', E'29 sqm / 312 sq ft (fact sheet)', 29, 29, null, E'1 bedroom', E'Belvedere outlook over the estate', E'7 rooms', E'Sophisticated rooms in the heart of the main building, where the warm colours typical of the Tuscan landscape meet contemporary design. Every hotel service is a short walk away.', array[E'In the main building', E'Contemporary design in the warm colours of the landscape', E'All hotel services within reach', E'Belvedere outlook over the estate', E'Connecting room available on request'], E'Quartos sofisticados no coração do edifício principal, onde as cores quentes típicas da paisagem toscana encontram o design contemporâneo. Todos os serviços do hotel ficam a poucos passos.', array[E'No edifício principal', E'Design contemporâneo nas cores quentes da paisagem', E'Todos os serviços do hotel por perto', E'Vista Belvedere sobre a propriedade', E'Quarto comunicante sob pedido'], 5)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;


-- 06. Deluxe Dolcevita (ELEGANCE)
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('c1000000-0000-0000-0000-000000000000', 'c1000000-0000-0000-0000-000000060000', E'Deluxe Dolcevita', E'40 sqm / 431 sq ft (fact sheet)', 40, 40, null, E'1 bedroom', E'Dolcevita outlook', E'12 rooms', E'Sophisticated rooms in the heart of the main building, where the warm colours typical of the Tuscan landscape meet contemporary design. Every hotel service is a short walk away.', array[E'In the main building', E'Contemporary design in the warm colours of the landscape', E'All hotel services within reach', E'Dolcevita outlook'], E'Quartos sofisticados no coração do edifício principal, onde as cores quentes típicas da paisagem toscana encontram o design contemporâneo. Todos os serviços do hotel ficam a poucos passos.', array[E'No edifício principal', E'Design contemporâneo nas cores quentes da paisagem', E'Todos os serviços do hotel por perto', E'Vista Dolcevita'], 6)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;


-- 07. Prestige (ELEGANCE)
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('c1000000-0000-0000-0000-000000000000', 'c1000000-0000-0000-0000-000000070000', E'Prestige', E'40 sqm / 431 sq ft (fact sheet)', 40, 40, null, E'1 bedroom', null, E'7 rooms', E'Sophisticated rooms in the heart of the main building, where the warm colours typical of the Tuscan landscape meet contemporary design. Every hotel service is a short walk away.', array[E'In the main building', E'Contemporary design in the warm colours of the landscape', E'All hotel services within reach', E'Connecting room available on request'], E'Quartos sofisticados no coração do edifício principal, onde as cores quentes típicas da paisagem toscana encontram o design contemporâneo. Todos os serviços do hotel ficam a poucos passos.', array[E'No edifício principal', E'Design contemporâneo nas cores quentes da paisagem', E'Todos os serviços do hotel por perto', E'Quarto comunicante sob pedido'], 7)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;


-- 08. Prestige Belvedere (ELEGANCE)
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('c1000000-0000-0000-0000-000000000000', 'c1000000-0000-0000-0000-000000080000', E'Prestige Belvedere', E'40 sqm / 431 sq ft (fact sheet)', 40, 40, null, E'1 bedroom', E'Belvedere outlook over the estate', E'15 rooms', E'Sophisticated rooms in the heart of the main building, where the warm colours typical of the Tuscan landscape meet contemporary design. Every hotel service is a short walk away.', array[E'In the main building', E'Contemporary design in the warm colours of the landscape', E'All hotel services within reach', E'Belvedere outlook over the estate'], E'Quartos sofisticados no coração do edifício principal, onde as cores quentes típicas da paisagem toscana encontram o design contemporâneo. Todos os serviços do hotel ficam a poucos passos.', array[E'No edifício principal', E'Design contemporâneo nas cores quentes da paisagem', E'Todos os serviços do hotel por perto', E'Vista Belvedere sobre a propriedade'], 8)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;


-- 09. Prestige Dolcevita (ELEGANCE)
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('c1000000-0000-0000-0000-000000000000', 'c1000000-0000-0000-0000-000000090000', E'Prestige Dolcevita', E'40 sqm / 431 sq ft (fact sheet)', 40, 40, null, E'1 bedroom', E'Dolcevita outlook', E'9 rooms', E'Sophisticated rooms in the heart of the main building, where the warm colours typical of the Tuscan landscape meet contemporary design. Every hotel service is a short walk away.', array[E'In the main building', E'Contemporary design in the warm colours of the landscape', E'All hotel services within reach', E'Dolcevita outlook'], E'Quartos sofisticados no coração do edifício principal, onde as cores quentes típicas da paisagem toscana encontram o design contemporâneo. Todos os serviços do hotel ficam a poucos passos.', array[E'No edifício principal', E'Design contemporâneo nas cores quentes da paisagem', E'Todos os serviços do hotel por perto', E'Vista Dolcevita'], 9)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;


-- 10. Junior Suite (SUITES)
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('c1000000-0000-0000-0000-000000000000', 'c1000000-0000-0000-0000-000000100000', E'Junior Suite', E'41 sqm / 441 sq ft (fact sheet)', 41, 41, null, E'1 bedroom', null, E'5 rooms', E'Wide spaces with large windows or balconies onto the countryside, where the landscape changes with the season. The furnishings are chosen for elegance, comfort and quiet.', array[E'Large windows or balcony onto the countryside', E'Wide living space', E'Connecting room available on request'], E'Espaços amplos com grandes janelas ou varandas sobre o campo, onde a paisagem muda com a estação. O mobiliário é escolhido para elegância, conforto e sossego.', array[E'Grandes janelas ou varanda sobre o campo', E'Amplo espaço de estar', E'Quarto comunicante sob pedido'], 10)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;


-- 11. Junior Suite Garden (SUITES)
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('c1000000-0000-0000-0000-000000000000', 'c1000000-0000-0000-0000-000000110000', E'Junior Suite Garden', E'41 sqm / 441 sq ft (fact sheet)', 41, 41, null, E'1 bedroom', E'Onto the garden', E'2 rooms', E'Wide spaces with large windows or balconies onto the countryside, where the landscape changes with the season. The furnishings are chosen for elegance, comfort and quiet.', array[E'Large windows or balcony onto the countryside', E'Wide living space', E'Onto the garden'], E'Espaços amplos com grandes janelas ou varandas sobre o campo, onde a paisagem muda com a estação. O mobiliário é escolhido para elegância, conforto e sossego.', array[E'Grandes janelas ou varanda sobre o campo', E'Amplo espaço de estar', E'Voltado para o jardim'], 11)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;


-- 12. Junior Suite Terrace (SUITES)
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('c1000000-0000-0000-0000-000000000000', 'c1000000-0000-0000-0000-000000120000', E'Junior Suite Terrace', E'41 sqm / 441 sq ft (fact sheet)', 41, 41, null, E'1 bedroom', E'Private terrace', E'4 rooms', E'Wide spaces with large windows or balconies onto the countryside, where the landscape changes with the season. The furnishings are chosen for elegance, comfort and quiet.', array[E'Large windows or balcony onto the countryside', E'Wide living space', E'Private terrace'], E'Espaços amplos com grandes janelas ou varandas sobre o campo, onde a paisagem muda com a estação. O mobiliário é escolhido para elegância, conforto e sossego.', array[E'Grandes janelas ou varanda sobre o campo', E'Amplo espaço de estar', E'Terraço privativo'], 12)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;


-- 13. Suite (SUITES)
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('c1000000-0000-0000-0000-000000000000', 'c1000000-0000-0000-0000-000000130000', E'Suite', E'50 sqm / 538 sq ft (fact sheet)', 50, 50, null, E'1 bedroom', null, E'6 rooms', E'Wide spaces with large windows or balconies onto the countryside, where the landscape changes with the season. The furnishings are chosen for elegance, comfort and quiet.', array[E'Large windows or balcony onto the countryside', E'Wide living space'], E'Espaços amplos com grandes janelas ou varandas sobre o campo, onde a paisagem muda com a estação. O mobiliário é escolhido para elegância, conforto e sossego.', array[E'Grandes janelas ou varanda sobre o campo', E'Amplo espaço de estar'], 13)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;


-- 14. Suite Terrace (SUITES)
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('c1000000-0000-0000-0000-000000000000', 'c1000000-0000-0000-0000-000000140000', E'Suite Terrace', E'61 sqm / 657 sq ft (fact sheet)', 61, 61, null, E'1 bedroom', E'Private terrace', E'3 rooms', E'Wide spaces with large windows or balconies onto the countryside, where the landscape changes with the season. The furnishings are chosen for elegance, comfort and quiet.', array[E'Large windows or balcony onto the countryside', E'Wide living space', E'Private terrace', E'Connecting room available on request'], E'Espaços amplos com grandes janelas ou varandas sobre o campo, onde a paisagem muda com a estação. O mobiliário é escolhido para elegância, conforto e sossego.', array[E'Grandes janelas ou varanda sobre o campo', E'Amplo espaço de estar', E'Terraço privativo', E'Quarto comunicante sob pedido'], 14)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;


-- 15. Family Suite Terrace (SUITES)
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('c1000000-0000-0000-0000-000000000000', 'c1000000-0000-0000-0000-000000150000', E'Family Suite Terrace', E'120 sqm / 1,292 sq ft (fact sheet)', 120, 120, null, E'2 bedrooms', E'Private terrace', E'1', E'Wide spaces with large windows or balconies onto the countryside, where the landscape changes with the season. The furnishings are chosen for elegance, comfort and quiet.', array[E'Large windows or balcony onto the countryside', E'Wide living space', E'Private terrace'], E'Espaços amplos com grandes janelas ou varandas sobre o campo, onde a paisagem muda com a estação. O mobiliário é escolhido para elegância, conforto e sossego.', array[E'Grandes janelas ou varanda sobre o campo', E'Amplo espaço de estar', E'Terraço privativo'], 15)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;


-- 16. Castelfalfi Suite (SIGNATURE)
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('c1000000-0000-0000-0000-000000000000', 'c1000000-0000-0000-0000-000000160000', E'Castelfalfi Suite', E'63 sqm / 678 sq ft (fact sheet)', 63, 63, null, E'1 bedroom', null, E'2 rooms', E'The largest and most luxurious suites of the estate. Fine materials, elegant fabrics and bright colours, chosen to carry the character of Castelfalfi.', array[E'The largest suites of the estate', E'Fine materials and elegant fabrics', E'Connecting room available on request'], E'As suítes maiores e mais luxuosas da propriedade. Materiais nobres, tecidos elegantes e cores vivas, escolhidos para carregar o caráter do Castelfalfi.', array[E'As maiores suítes da propriedade', E'Materiais nobres e tecidos elegantes', E'Quarto comunicante sob pedido'], 16)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;


-- 17. Castelfalfi Grand Suite (SIGNATURE)
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('c1000000-0000-0000-0000-000000000000', 'c1000000-0000-0000-0000-000000170000', E'Castelfalfi Grand Suite', E'106 sqm / 1,141 sq ft (fact sheet)', 106, 106, null, E'1 bedroom', null, E'2 rooms', E'The largest and most luxurious suites of the estate. Fine materials, elegant fabrics and bright colours, chosen to carry the character of Castelfalfi.', array[E'The largest suites of the estate', E'Fine materials and elegant fabrics', E'Connecting room available on request'], E'As suítes maiores e mais luxuosas da propriedade. Materiais nobres, tecidos elegantes e cores vivas, escolhidos para carregar o caráter do Castelfalfi.', array[E'As maiores suítes da propriedade', E'Materiais nobres e tecidos elegantes', E'Quarto comunicante sob pedido'], 17)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;


-- 18. Stefano Ricci La Rocca · Aquila (ROCCA)
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('c1000000-0000-0000-0000-000000000000', 'c1000000-0000-0000-0000-000000180000', E'Stefano Ricci La Rocca · Aquila', E'133 sqm / 1,432 sq ft (fact sheet)', 133, 133, null, E'1 bedroom', null, E'3 rooms', E'A two-suite penthouse of 307 sqm over two levels, blending Tuscany with Stefano Ricci''s craftsmanship: bespoke interiors, a rooftop terrace and a private jacuzzi. Guests have access to tailored fittings and tours of the Antico Setificio Fiorentino.', array[E'Part of the 307 sqm Stefano Ricci penthouse', E'Rooftop terrace and private jacuzzi', E'Bespoke interiors'], E'Um penthouse de duas suítes, 307 m² em dois níveis, que junta a Toscana ao artesanato da Stefano Ricci: interiores sob medida, terraço na cobertura e jacuzzi privativa. O hóspede tem acesso a provas de alfaiataria e à visita do Antico Setificio Fiorentino.', array[E'Parte do penthouse Stefano Ricci, de 307 m²', E'Terraço na cobertura e jacuzzi privativa', E'Interiores sob medida'], 18)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;


-- 19. Stefano Ricci La Rocca · Pegasus (ROCCA)
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('c1000000-0000-0000-0000-000000000000', 'c1000000-0000-0000-0000-000000190000', E'Stefano Ricci La Rocca · Pegasus', E'78 sqm / 840 sq ft (fact sheet)', 78, 78, null, E'1 bedroom', null, E'2 rooms', E'A two-suite penthouse of 307 sqm over two levels, blending Tuscany with Stefano Ricci''s craftsmanship: bespoke interiors, a rooftop terrace and a private jacuzzi. Guests have access to tailored fittings and tours of the Antico Setificio Fiorentino.', array[E'Part of the 307 sqm Stefano Ricci penthouse', E'Rooftop terrace and private jacuzzi', E'Bespoke interiors'], E'Um penthouse de duas suítes, 307 m² em dois níveis, que junta a Toscana ao artesanato da Stefano Ricci: interiores sob medida, terraço na cobertura e jacuzzi privativa. O hóspede tem acesso a provas de alfaiataria e à visita do Antico Setificio Fiorentino.', array[E'Parte do penthouse Stefano Ricci, de 307 m²', E'Terraço na cobertura e jacuzzi privativa', E'Interiores sob medida'], 19)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;


-- 20. Villa Casa Medici (VILLAS)
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('c1000000-0000-0000-0000-000000000000', 'c1000000-0000-0000-0000-000000200000', E'Villa Casa Medici', E'180 sqm / 1,938 sq ft (fact sheet)', 180, 180, null, E'3 bedrooms', null, E'1', E'Farmhouses surrounded by cypress rows and wheat fields, where guests have the privacy of their own house with the full five-star service brought to the door on request.', array[E'Private farmhouse on the estate', E'Five-star service on request at the accommodation', E'Cypress rows and wheat fields'], E'Casas de campo cercadas por fileiras de ciprestes e campos de trigo, onde o hóspede tem a privacidade da casa dele com o serviço cinco estrelas inteiro levado à porta, sob pedido.', array[E'Casa de campo privativa na propriedade', E'Serviço cinco estrelas sob pedido na acomodação', E'Fileiras de ciprestes e campos de trigo'], 20)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;


-- 21. Villa Il Fienile (VILLAS)
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('c1000000-0000-0000-0000-000000000000', 'c1000000-0000-0000-0000-000000210000', E'Villa Il Fienile', E'230 sqm / 2,476 sq ft (fact sheet)', 230, 230, null, E'3 bedrooms', null, E'1', E'Farmhouses surrounded by cypress rows and wheat fields, where guests have the privacy of their own house with the full five-star service brought to the door on request.', array[E'Private farmhouse on the estate', E'Five-star service on request at the accommodation', E'Cypress rows and wheat fields'], E'Casas de campo cercadas por fileiras de ciprestes e campos de trigo, onde o hóspede tem a privacidade da casa dele com o serviço cinco estrelas inteiro levado à porta, sob pedido.', array[E'Casa de campo privativa na propriedade', E'Serviço cinco estrelas sob pedido na acomodação', E'Fileiras de ciprestes e campos de trigo'], 21)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;


-- 22. Golf Villa I Bianchi (VILLAS)
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('c1000000-0000-0000-0000-000000000000', 'c1000000-0000-0000-0000-000000220000', E'Golf Villa I Bianchi', E'323 sqm / 3,477 sq ft (fact sheet)', 323, 323, null, E'4 bedrooms', null, E'1', E'Farmhouses surrounded by cypress rows and wheat fields, where guests have the privacy of their own house with the full five-star service brought to the door on request.', array[E'Private farmhouse on the estate', E'Five-star service on request at the accommodation', E'Cypress rows and wheat fields'], E'Casas de campo cercadas por fileiras de ciprestes e campos de trigo, onde o hóspede tem a privacidade da casa dele com o serviço cinco estrelas inteiro levado à porta, sob pedido.', array[E'Casa de campo privativa na propriedade', E'Serviço cinco estrelas sob pedido na acomodação', E'Fileiras de ciprestes e campos de trigo'], 22)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;


-- 23. Casale La Pergola (VILLAS)
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('c1000000-0000-0000-0000-000000000000', 'c1000000-0000-0000-0000-000000230000', E'Casale La Pergola', E'224 sqm / 2,411 sq ft (fact sheet)', 224, 224, null, E'4 bedrooms', null, E'1', E'Farmhouses surrounded by cypress rows and wheat fields, where guests have the privacy of their own house with the full five-star service brought to the door on request.', array[E'Private farmhouse on the estate', E'Five-star service on request at the accommodation', E'Cypress rows and wheat fields'], E'Casas de campo cercadas por fileiras de ciprestes e campos de trigo, onde o hóspede tem a privacidade da casa dele com o serviço cinco estrelas inteiro levado à porta, sob pedido.', array[E'Casa de campo privativa na propriedade', E'Serviço cinco estrelas sob pedido na acomodação', E'Fileiras de ciprestes e campos de trigo'], 23)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;


-- 24. Casale I Bianchi (VILLAS)
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('c1000000-0000-0000-0000-000000000000', 'c1000000-0000-0000-0000-000000240000', E'Casale I Bianchi', E'550 sqm / 5,920 sq ft (fact sheet)', 550, 550, null, E'5 bedrooms', null, E'1', E'Farmhouses surrounded by cypress rows and wheat fields, where guests have the privacy of their own house with the full five-star service brought to the door on request.', array[E'Private farmhouse on the estate', E'Five-star service on request at the accommodation', E'Cypress rows and wheat fields'], E'Casas de campo cercadas por fileiras de ciprestes e campos de trigo, onde o hóspede tem a privacidade da casa dele com o serviço cinco estrelas inteiro levado à porta, sob pedido.', array[E'Casa de campo privativa na propriedade', E'Serviço cinco estrelas sob pedido na acomodação', E'Fileiras de ciprestes e campos de trigo'], 24)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;


insert into ops_migrations (id) values ('0047-castelfalfi') on conflict (id) do nothing;
