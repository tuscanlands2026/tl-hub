-- =====================================================================
-- 0045 · DIMORA GHIRLANDAIO VIRA FICHA, COM AS SEIS ACOMODAÇÕES
--
-- Pedido dela, outubro/26: pôr no hub um grupo de hotéis com a essência
-- da casa, a localização, os tipos de quarto e as fotos, para ela lançar
-- o preço à mão e puxar na proposta do cliente.
--
-- POR QUE FICHA DE FORNECEDOR, E NÃO LINHA DE CATÁLOGO. Ela disse
-- "catálogo", e catálogo é uma linha por item vendável: o texto do hotel
-- se repetiria em cada quarto, e corrigir uma frase viraria corrigir seis
-- linhas. A ficha guarda o hotel UMA vez e pendura os quartos nela, que é
-- exatamente o desenho de ops_room_types — com metragem em m² e sq ft,
-- ocupação, camas e vista. Da ficha ela puxa direto na proposta, pela
-- mesma caixa de busca, e manda para o catálogo o quarto que quiser, por
-- botão. Nada do catálogo que já existe é tocado.
--
-- A LINHA DO CATÁLOGO DA VILLA GHIRLANDAIO CONTINUA ONDE ESTÁ. Ela é de
-- agosto/26 e pode já ter ido em proposta; esta migração não a altera e
-- não a apaga. Por isso a busca vai mostrar a Villa Ghirlandaio duas
-- vezes por enquanto — uma do catálogo, uma da ficha. Aposentar a linha
-- antiga é decisão dela, e vai em migração própria se ela mandar.
--
-- "Dimora Ghirlandaio (esta como Villa Ghirlandaio)" ficou resolvido
-- lendo o site: Villa Ghirlandaio NÃO é outro nome da propriedade, é uma
-- das seis acomodações dela — a villa renascentista principal. Então não
-- há nada para renomear: a ficha é a Dimora, e a Villa é um quarto dela.
--
-- TUDO ESCRITO DO QUE O SITE PUBLICA, em dimoraghirlandaio.it, uma página
-- por acomodação. Nada de memória.
--
-- O QUE O SITE NÃO PUBLICA, e por isso fica em branco: metragem e
-- ocupação máxima de cada villa. Os números estão nas planimetrias, que o
-- site oferece para download por acomodação. A única metragem preenchida
-- é a da Villa Ghirlandaio — 288 m², que veio da planimetria que ela
-- mandou em agosto/26 e já estava no catálogo. Metragem de villa a doze
-- mil euros não se estima: fica em branco e em "pontos em aberto".
--
-- Só cria e preenche objetos ops_. Nenhum update ou delete em linha que
-- já existia.
-- =====================================================================


insert into ops_suppliers
  (id, name, legal_name, category, subcategories, business_suite, status, region, city,
   address, website, languages, name_rule, vat_status, vat_number,
   accommodation_summary, accommodation_notes, highlights, tags, summary,
   open_points, internal_notes)
values ('d0000000-0000-0000-0000-000000000000',
  'Dimora Ghirlandaio',
  'Società Agricola Indaco S.r.l. a socio unico',
  'Hotel / Accommodation',
  array['Villa','Estate for exclusive use'],
  array['TL Selected Stays'],
  'To test',
  'Tuscany',
  'Impruneta (Firenze)',
  'Via Colleramole, 59 – 50023 Impruneta, Firenze',
  E'https://dimoraghirlandaio.it/en/',
  array['Italian','English'],
  'Show supplier name',
  'not stated',
  '06632920481',
  E'Six private accommodations on one estate: five villas and one suite, let individually or as the whole hamlet for exclusive use.',
  E'Walk-in closet · minibar · marble bathrooms with shower or tub · hairdryer and luxury amenities · safe · Wi-Fi · USB charger outlets · Tuscan dispensa · free parking on the estate. Kitchen arrangements vary by villa: fully equipped in Villa Ghirlandaio, La Fattoria, La Bottega and Lo Studio, kitchenette in Il Frantoio, none in Suite La Limonaia.',
  array[
    'Historic home of the Renaissance painter Domenico Ghirlandaio and his son Ridolfo',
    'The whole hamlet of Colle Ramole can be reserved for exclusive use',
    '150 sqm pool in the estate park',
    'Spa on the lower level of the Renaissance villa: treatment room, massage room and a small gym',
    'Private Chapel of the Visitation, reserved for guests during their stay',
    'Organic extra virgin olive oil produced on the estate',
    'Florence 20 minutes by car; Siena, Pisa, Arezzo and Lucca about an hour'],
  array['villa','exclusive use','Florence hills','weddings','Impruneta'],
  E'Estate in the hills of Impruneta, twenty minutes from Florence, built around the country home of the Ghirlandaio family. Six accommodations — five villas and one suite — let on their own or together, with a pool, a spa, a park and a private chapel. Views reach across the Florentine countryside to Brunelleschi''s dome.',
  array[
    'Floor area and maximum occupancy of each villa are not published: they are in the planimetry PDFs offered on each accommodation page. Only Villa Ghirlandaio has a confirmed figure (288 sqm, from the planimetry she sent in August 2026).',
    'Net rates, cancellation policy and payment terms to the supplier not yet collected.',
    'Photo usage not yet cleared with the property: usage_cleared is false on every photo.'],
  E'Contatos: info@dimoraghirlandaio.it · (+39) 055 23 74 507 · (+39) 324 895 26 89.\nFicha montada do site oficial, outubro/26, uma página por acomodação.\nAs planimetrias de cada villa estão para download no site — baixando, dá para preencher metragem e ocupação, que são justamente o que falta.\nStatus ''To test'' porque não há tarifa net lançada nem histórico de venda registrado aqui.' )
on conflict (id) do update set
  name = excluded.name, legal_name = excluded.legal_name, category = excluded.category,
  subcategories = excluded.subcategories, business_suite = excluded.business_suite,
  region = excluded.region, city = excluded.city, address = excluded.address,
  website = excluded.website, languages = excluded.languages, name_rule = excluded.name_rule,
  vat_number = excluded.vat_number,
  accommodation_summary = excluded.accommodation_summary,
  accommodation_notes = excluded.accommodation_notes,
  highlights = excluded.highlights, tags = excluded.tags, summary = excluded.summary,
  open_points = excluded.open_points, updated_at = now();

insert into ops_supplier_contacts (id, supplier_id, name, role, email, phone, sort_order)
values ('d0000000-0000-0000-0000-000000990001', 'd0000000-0000-0000-0000-000000000000', 'Reservations', 'Reservations',
        'info@dimoraghirlandaio.it', '+39 055 23 74 507', 1)
on conflict (id) do update set email = excluded.email, phone = excluded.phone;


-- 1. Villa Ghirlandaio ---------------------------------------------------
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('d0000000-0000-0000-0000-000000000000', 'd0000000-0000-0000-0000-000000010000', E'Villa Ghirlandaio', E'288 sqm (from the planimetry)', 288, 288, null, E'5 bedrooms: 1 king on the ground floor, 3 doubles on the upper floor, 1 in the former dovecote', E'Italian garden and the city of Florence, from the Certosa to Brunelleschi''s dome', E'1 villa', E'The Renaissance villa at the heart of the estate, on two floors plus the former dovecote. A pietra serena façade and a double staircase descend to the Italian garden, with the city of Florence open in front.\nOn the ground floor, a hall with fireplace and coffered ceiling, a dining room, a fully equipped kitchen with island and one king bedroom. On the floor above, three double bedrooms, each with its own marble bathroom. On the third level, the former dovecote is now the most private room in the house, with panoramic views.\nFive bathrooms and a guest toilet, two living rooms. The spa occupies the lower level of this villa.', array[E'Main building of the estate', E'Former dovecote as the top bedroom', E'Double staircase onto the Italian garden', E'Spa on the lower level'], E'A villa renascentista no coração da propriedade, em dois andares mais o antigo pombal. A fachada em pietra serena e a escadaria dupla descem para o jardim all''italiana, com Florença aberta à frente.\nNo térreo, salão com lareira e teto de caixotões, sala de jantar, cozinha equipada com ilha e um quarto king. No andar de cima, três quartos duplos, cada um com banheiro próprio em mármore. No terceiro nível, o antigo pombal é hoje o quarto mais reservado da casa, com vista panorâmica.\nCinco banheiros e um lavabo, duas salas de estar. A spa fica no nível inferior desta villa.', array[E'Construção principal da propriedade', E'O antigo pombal como quarto mais alto', E'Escadaria dupla para o jardim all''italiana', E'Spa no nível inferior'], 1)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('d0000000-0000-0000-0000-000000010001', 'd0000000-0000-0000-0000-000000000000', 'd0000000-0000-0000-0000-000000010000', E'https://dimoraghirlandaio.it/wp-content/uploads/2023/08/dimora_ghirlandaio-main_villa_cover.jpg', E'https://dimoraghirlandaio.it/en/accommodations/villa-ghirlandaio/', E'Villa Ghirlandaio', true, false, 1)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('d0000000-0000-0000-0000-000000010002', 'd0000000-0000-0000-0000-000000000000', 'd0000000-0000-0000-0000-000000010000', E'https://dimoraghirlandaio.it/wp-content/uploads/2023/08/dimora_ghirlandaio-Main_Living_Room_Main_Villa_3.jpg', E'https://dimoraghirlandaio.it/en/accommodations/villa-ghirlandaio/', E'Villa Ghirlandaio', true, false, 2)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('d0000000-0000-0000-0000-000000010003', 'd0000000-0000-0000-0000-000000000000', 'd0000000-0000-0000-0000-000000010000', E'https://dimoraghirlandaio.it/wp-content/uploads/2023/08/dimora_ghirlandaio-Dining_Room_Main_Villa.jpg', E'https://dimoraghirlandaio.it/en/accommodations/villa-ghirlandaio/', E'Villa Ghirlandaio', true, false, 3)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('d0000000-0000-0000-0000-000000010004', 'd0000000-0000-0000-0000-000000000000', 'd0000000-0000-0000-0000-000000010000', E'https://dimoraghirlandaio.it/wp-content/uploads/2023/08/dimora_ghirlandaio-_Ridolfo_Room_Main_Villa.jpg', E'https://dimoraghirlandaio.it/en/accommodations/villa-ghirlandaio/', E'Villa Ghirlandaio', true, false, 4)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;


-- 2. Villa La Fattoria ---------------------------------------------------
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('d0000000-0000-0000-0000-000000000000', 'd0000000-0000-0000-0000-000000020000', E'Villa La Fattoria', null, null, null, null, E'4 rooms: 3 double bedrooms and 1 single room', E'Florence and the surrounding countryside, with the silhouette of Brunelleschi''s dome', E'1 villa', E'Recorded in documents as early as the fifteenth century, La Fattoria stands at the heart of the estate and was originally part of the Ghirlandaio family''s own property. Whitewashed façades, a central courtyard and the plan of an old country house.\nIn every room the restoration brought back the original vaulted ceilings in Impruneta terracotta, made at the Ghirlandaio family kiln — the same craft that tiled the dome of the Florentine cathedral. Natural stone floors and a pietra serena banister.\nA spacious kitchen with an island, a bright living room, and a gravel terrace surrounded by flowers and aromatic herbs looking out over Florence.', array[E'One of the original buildings of the estate', E'Vaulted ceilings in Impruneta terracotta', E'Central courtyard', E'Gravel terrace facing Florence'], E'Citada em documentos já no século XV, La Fattoria fica no centro da propriedade e era parte do patrimônio da própria família Ghirlandaio. Fachadas caiadas, pátio central e a planta das antigas casas de campo.\nEm cada ambiente o restauro trouxe de volta as abóbadas originais em cotto de Impruneta, feitas no forno da família Ghirlandaio — o mesmo ofício que cobriu a cúpula da catedral de Florença. Pisos de pedra natural e corrimão em pietra serena.\nCozinha ampla com ilha, sala de estar clara, e um terraço de saibro cercado de flores e ervas aromáticas voltado para Florença.', array[E'Uma das construções originais da propriedade', E'Abóbadas em cotto de Impruneta', E'Pátio central', E'Terraço de saibro voltado para Florença'], 2)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('d0000000-0000-0000-0000-000000020001', 'd0000000-0000-0000-0000-000000000000', 'd0000000-0000-0000-0000-000000020000', E'https://dimoraghirlandaio.it/wp-content/uploads/2023/08/dimora_ghirlandaio-Dining_Room_Kitchen_Villa_Fattoria.jpg', E'https://dimoraghirlandaio.it/en/accommodations/la-fattoria/', E'Villa La Fattoria', true, false, 1)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('d0000000-0000-0000-0000-000000020002', 'd0000000-0000-0000-0000-000000000000', 'd0000000-0000-0000-0000-000000020000', E'https://dimoraghirlandaio.it/wp-content/uploads/2023/08/dimora_ghirlandaio-Cecchi_Room_Villa_Fattoria.jpg', E'https://dimoraghirlandaio.it/en/accommodations/la-fattoria/', E'Villa La Fattoria', true, false, 2)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('d0000000-0000-0000-0000-000000020003', 'd0000000-0000-0000-0000-000000000000', 'd0000000-0000-0000-0000-000000020000', E'https://dimoraghirlandaio.it/wp-content/uploads/2023/08/dimora_ghirlandaio-Agostini_Room_Villa_Fattoria.jpg', E'https://dimoraghirlandaio.it/en/accommodations/la-fattoria/', E'Villa La Fattoria', true, false, 3)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('d0000000-0000-0000-0000-000000020004', 'd0000000-0000-0000-0000-000000000000', 'd0000000-0000-0000-0000-000000020000', E'https://dimoraghirlandaio.it/wp-content/uploads/2023/08/dimora_ghirlandaio-DElci_Room_Villa_Fattoria.jpg', E'https://dimoraghirlandaio.it/en/accommodations/la-fattoria/', E'Villa La Fattoria', true, false, 4)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;


-- 3. Villa La Bottega ---------------------------------------------------
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('d0000000-0000-0000-0000-000000000000', 'd0000000-0000-0000-0000-000000030000', E'Villa La Bottega', null, null, null, null, E'2 double bedrooms: one with twin beds, one with a king bed', E'Florence and the surrounding countryside', E'1 villa', E'The most intimate of the villas, and the one that kept most of the architecture of a traditional Tuscan country house. Stone arches open onto a fountain with a pietra serena basin.\nGuests come into an open-plan living area under a wooden truss, with beamed ceiling, Impruneta brick floor, an ornamental stone fireplace and a well equipped kitchen.\nBoth bedrooms have walk-in closets and en-suite marble bathrooms. Like every accommodation on the estate, it has its own private garden.', array[E'Stone arches and a pietra serena fountain', E'Open-plan living area under a wooden truss', E'Ornamental stone fireplace', E'Private garden'], E'A mais íntima das villas, e a que mais preservou a arquitetura da casa de campo toscana. Arcos de pedra se abrem para uma fonte com tanque em pietra serena.\nEntra-se por uma sala de estar integrada sob um cavalete de madeira, com teto de vigas aparentes, piso de tijolo de Impruneta, lareira ornamental em pedra e cozinha bem equipada.\nOs dois quartos têm closet e banheiro privativo em mármore. Como toda acomodação da propriedade, tem jardim próprio.', array[E'Arcos de pedra e fonte em pietra serena', E'Sala integrada sob cavalete de madeira', E'Lareira ornamental em pedra', E'Jardim privativo'], 3)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('d0000000-0000-0000-0000-000000030001', 'd0000000-0000-0000-0000-000000000000', 'd0000000-0000-0000-0000-000000030000', E'https://dimoraghirlandaio.it/wp-content/uploads/2024/12/DG_La-Bottega_Exterior-2_June2024.jpg', E'https://dimoraghirlandaio.it/en/accommodations/la-bottega/', E'Villa La Bottega', true, false, 1)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('d0000000-0000-0000-0000-000000030002', 'd0000000-0000-0000-0000-000000000000', 'd0000000-0000-0000-0000-000000030000', E'https://dimoraghirlandaio.it/wp-content/uploads/2024/12/DG_Living_Room_Villa_Bottega-scaled.jpg', E'https://dimoraghirlandaio.it/en/accommodations/la-bottega/', E'Villa La Bottega', true, false, 2)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('d0000000-0000-0000-0000-000000030003', 'd0000000-0000-0000-0000-000000000000', 'd0000000-0000-0000-0000-000000030000', E'https://dimoraghirlandaio.it/wp-content/uploads/2023/08/dimora_ghirlandaio-Michelangelo_Bedroom_Villa_Bottega.jpg', E'https://dimoraghirlandaio.it/en/accommodations/la-bottega/', E'Villa La Bottega', true, false, 3)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('d0000000-0000-0000-0000-000000030004', 'd0000000-0000-0000-0000-000000000000', 'd0000000-0000-0000-0000-000000030000', E'https://dimoraghirlandaio.it/wp-content/uploads/2023/08/dimora_ghirlandaio-Raffaello_Bedroom_Villa_Bottega.jpg', E'https://dimoraghirlandaio.it/en/accommodations/la-bottega/', E'Villa La Bottega', true, false, 4)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;


-- 4. Villa Il Frantoio ---------------------------------------------------
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('d0000000-0000-0000-0000-000000000000', 'd0000000-0000-0000-0000-000000040000', E'Villa Il Frantoio', null, null, null, null, E'4 rooms: 3 double bedrooms and 1 single room, plus a separate dependance with a double bedroom', E'Inner courtyard and the villa''s garden', E'1 villa', E'An outer loggia with graceful arches looks over the garden; the dining room gives onto an inner courtyard, which is what makes the house feel private.\nIn the entrance hall the floor is laid with boards cut from old wooden beams, left with their natural imperfections. Whitewashed walls with pietra serena finishes meet a stone wall and an ornamental fireplace in pietra forte.\nThe lintel between hall and dining room carries the coats of arms of the Bigordi family, whose nickname was Ghirlandaio: one shows a knight at the gallop holding the bigordo, an old jousting pole; the other shows three garlands.', array[E'Outer loggia with arches over the garden', E'Inner courtyard off the dining room', E'Bigordi family coats of arms carved on the lintel', E'Separate dependance with a double bedroom'], E'Uma loggia externa de arcos se debruça sobre o jardim; a sala de jantar dá para um pátio interno, e é o que dá privacidade à casa.\nNo hall de entrada o piso é de tábuas cortadas de vigas antigas, mantidas com as imperfeições naturais. Paredes caiadas com acabamento em pietra serena encontram um muro de pedra e uma lareira ornamental em pietra forte.\nA verga entre o hall e a sala de jantar leva os brasões da família Bigordi, cujo apelido era Ghirlandaio: um mostra um cavaleiro a galope com o bigordo, antiga lança de torneio; o outro, três guirlandas.', array[E'Loggia externa de arcos sobre o jardim', E'Pátio interno junto à sala de jantar', E'Brasões dos Bigordi esculpidos na verga', E'Dependência separada com quarto de casal'], 4)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('d0000000-0000-0000-0000-000000040001', 'd0000000-0000-0000-0000-000000000000', 'd0000000-0000-0000-0000-000000040000', E'https://dimoraghirlandaio.it/wp-content/uploads/2024/08/DG_Il-Frantoio_exterior_detail3_horizontal_June2024.jpg', E'https://dimoraghirlandaio.it/en/accommodations/il-frantoio/', E'Villa Il Frantoio', true, false, 1)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('d0000000-0000-0000-0000-000000040002', 'd0000000-0000-0000-0000-000000000000', 'd0000000-0000-0000-0000-000000040000', E'https://dimoraghirlandaio.it/wp-content/uploads/2023/08/dimora_ghirlandaio-Main_Living_Room_Villa_Frantoio.jpg', E'https://dimoraghirlandaio.it/en/accommodations/il-frantoio/', E'Villa Il Frantoio', true, false, 2)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('d0000000-0000-0000-0000-000000040003', 'd0000000-0000-0000-0000-000000000000', 'd0000000-0000-0000-0000-000000040000', E'https://dimoraghirlandaio.it/wp-content/uploads/2023/08/dimora_ghirlandaio-Leccino_Room_Villa_Frantoio.jpg', E'https://dimoraghirlandaio.it/en/accommodations/il-frantoio/', E'Villa Il Frantoio', true, false, 3)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('d0000000-0000-0000-0000-000000040004', 'd0000000-0000-0000-0000-000000000000', 'd0000000-0000-0000-0000-000000040000', E'https://dimoraghirlandaio.it/wp-content/uploads/2023/08/dimora_ghirlandaio-Moraiolo_Room_Villa_Frantoio.jpg', E'https://dimoraghirlandaio.it/en/accommodations/il-frantoio/', E'Villa Il Frantoio', true, false, 4)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;


-- 5. Villa Lo Studio ---------------------------------------------------
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('d0000000-0000-0000-0000-000000000000', 'd0000000-0000-0000-0000-000000050000', E'Villa Lo Studio', null, null, null, null, E'4 rooms: 3 double bedrooms and 1 single room, the master on the mezzanine', E'South-facing private garden', E'1 villa', E'South-facing, arranged over three levels, with a mezzanine reached directly from the garden — which is what gives the outdoor space its privacy, closed in by hedges, fragrant herbs, bougainvillea and fruit trees.\nOn the ground floor a bright living room with Tuscan furnishings and an old decorative stone fireplace, a dining area and the kitchen.\nOn the upper floors three double bedrooms and a single, each with its own closet and an en-suite bathroom in marble and stone. The master, on the mezzanine, is reached by a small staircase with pietra serena steps and a wrought-iron rail. In the garden, an arbour with table and chairs.', array[E'Three levels with a mezzanine master', E'Mezzanine reached directly from the garden', E'Private garden with arbour for alfresco dining', E'South-facing'], E'Voltada para o sul, distribuída em três níveis, com um mezanino que se alcança direto do jardim — é o que dá privacidade à área externa, fechada por sebes, ervas aromáticas, buganvílias e árvores frutíferas.\nNo térreo, uma sala de estar clara com mobiliário toscano e lareira decorativa antiga em pedra, área de jantar e a cozinha.\nNos andares de cima, três quartos de casal e um solteiro, cada um com closet próprio e banheiro privativo em mármore e pedra. O quarto principal, no mezanino, se alcança por uma escadinha de degraus em pietra serena e corrimão de ferro batido. No jardim, um caramanchão com mesa e cadeiras.', array[E'Três níveis, com o quarto principal no mezanino', E'Mezanino com acesso direto pelo jardim', E'Jardim privativo com caramanchão para refeições ao ar livre', E'Face sul'], 5)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('d0000000-0000-0000-0000-000000050001', 'd0000000-0000-0000-0000-000000000000', 'd0000000-0000-0000-0000-000000050000', E'https://dimoraghirlandaio.it/wp-content/uploads/2024/08/DG_Lo-Studio_Living-Room_June2024.jpg', E'https://dimoraghirlandaio.it/en/accommodations/lo-studio/', E'Villa Lo Studio', true, false, 1)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('d0000000-0000-0000-0000-000000050002', 'd0000000-0000-0000-0000-000000000000', 'd0000000-0000-0000-0000-000000050000', E'https://dimoraghirlandaio.it/wp-content/uploads/2023/08/dimora_ghirlandaio-Vermiglio_Room_Villa_Studio.jpg', E'https://dimoraghirlandaio.it/en/accommodations/lo-studio/', E'Villa Lo Studio', true, false, 2)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('d0000000-0000-0000-0000-000000050003', 'd0000000-0000-0000-0000-000000000000', 'd0000000-0000-0000-0000-000000050000', E'https://dimoraghirlandaio.it/wp-content/uploads/2023/08/dimora_ghirlandaio-Indaco_Room_Villa_Studio.jpg', E'https://dimoraghirlandaio.it/en/accommodations/lo-studio/', E'Villa Lo Studio', true, false, 3)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('d0000000-0000-0000-0000-000000050004', 'd0000000-0000-0000-0000-000000000000', 'd0000000-0000-0000-0000-000000050000', E'https://dimoraghirlandaio.it/wp-content/uploads/2023/08/dimora_ghirlandaio-Outdoor_Dining_Villa_Studio.jpg', E'https://dimoraghirlandaio.it/en/accommodations/lo-studio/', E'Villa Lo Studio', true, false, 4)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;


-- 6. Suite La Limonaia ---------------------------------------------------
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('d0000000-0000-0000-0000-000000000000', 'd0000000-0000-0000-0000-000000060000', E'Suite La Limonaia', null, null, null, null, E'1 double room', E'The Renaissance garden', E'1 suite', E'A one-bedroom suite in the estate''s old lemon house, restored and looking onto the Renaissance garden. Walk-in closet, minibar and a marble bathroom with shower. The smallest of the accommodations, and the only one without a kitchen.', array[E'In the estate''s restored lemon house', E'Onto the Renaissance garden', E'Marble bathroom with shower'], E'Suíte de um quarto na antiga limonaia da propriedade, restaurada e voltada para o jardim renascentista. Closet, frigobar e banheiro em mármore com chuveiro. É a menor das acomodações, e a única sem cozinha.', array[E'Na limonaia restaurada da propriedade', E'Voltada para o jardim renascentista', E'Banheiro em mármore com chuveiro'], 6)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('d0000000-0000-0000-0000-000000060001', 'd0000000-0000-0000-0000-000000000000', 'd0000000-0000-0000-0000-000000060000', E'https://dimoraghirlandaio.it/wp-content/uploads/2024/10/dimora_ghirlandaio-La_Limonaia-bedroom-1024x683.jpg', E'https://dimoraghirlandaio.it/en/accommodations/la-limonaia/', E'Suite La Limonaia', true, false, 1)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('d0000000-0000-0000-0000-000000060002', 'd0000000-0000-0000-0000-000000000000', 'd0000000-0000-0000-0000-000000060000', E'https://dimoraghirlandaio.it/wp-content/uploads/2024/10/dimora_ghirlandaio-La_Limonaia-bedroom_detail-1024x683.jpg', E'https://dimoraghirlandaio.it/en/accommodations/la-limonaia/', E'Suite La Limonaia', true, false, 2)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;


insert into ops_migrations (id) values ('0045-dimora-ghirlandaio') on conflict (id) do nothing;
