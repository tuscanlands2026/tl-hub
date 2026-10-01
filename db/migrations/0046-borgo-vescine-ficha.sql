-- =====================================================================
-- 0046 · BORGO VESCINE VIRA FICHA, COM AS SETE CATEGORIAS DE QUARTO
--
-- Pedido dela, outubro/26: "complemente com os demais quartos". Em
-- agosto/26 entrou só a Camera Deluxe, como linha de catálogo, porque era
-- a acomodação daquela venda. Agora entram as sete categorias que o hotel
-- publica, na ficha do fornecedor — que é onde quarto tem lugar próprio,
-- com metragem, cama, ocupação e foto de cada um.
--
-- A LINHA DO CATÁLOGO DE AGOSTO CONTINUA ONDE ESTÁ. Pode já ter ido em
-- proposta; não se altera e não se apaga. A Deluxe vai aparecer duas
-- vezes na busca por enquanto — uma do catálogo, uma da ficha.
--
-- O SITE AGORA PUBLICA EM INGLÊS. Em agosto a observação registrada foi
-- "o site só publica em italiano", e o texto da Deluxe teve de ser
-- traduzido. As páginas em inglês existem hoje (vescine.it/deluxe-room), e
-- é delas que saiu o texto desta ficha. O português é tradução do inglês
-- publicado.
--
-- DUAS CONVERSÕES ERRADAS NO PRÓPRIO SITE, e por isso elas não foram
-- copiadas:
--   · Deluxe: "Around 22 to 24 Sq. Metres (90 Sq. Foot)" — 22–24 m² são
--     237–258 sq ft, e não 90;
--   · Superior: "Around 35 Sq. Feet", onde a Superior com Patio diz
--     "Around 35 mq - 375 Sq. Feet". São 35 m², e o "Feet" ali é engano.
-- Gravou-se o metro quadrado, que é o número certo. A conversão para sq ft
-- quem faz é o hub, a partir de size_m2_min e size_m2_max — era para isso
-- que esses dois campos existiam.
--
-- O que o site NÃO publica e por isso não está aqui: spa. A observação de
-- agosto vale igual — a palavra que aparece na home é "Vespa", do passeio.
--
-- Só cria e preenche objetos ops_. Nenhum update ou delete em linha antiga.
-- =====================================================================


insert into ops_suppliers
  (id, name, category, subcategories, business_suite, status, region, city,
   website, languages, name_rule, vat_status,
   accommodation_summary, accommodation_notes, highlights, tags, summary,
   open_points, internal_notes)
values ('b0000000-0000-0000-0000-000000000000',
  'Borgo Vescine', 'Hotel / Accommodation',
  array['Relais','Historic hamlet'],
  array['TL Selected Stays'],
  'To test', 'Tuscany', 'Radda in Chianti (Siena)',
  E'https://www.vescine.it/',
  array['Italian','English'],
  'Show supplier name', 'not stated',
  E'Seven room categories across a 13th-century hamlet, from 15 sqm Classic rooms to a 55 sqm Suite Superior with private patio.',
  E'Hand-fired terracotta floors and exposed beams kept from the original hamlet · furnishings designed for Borgo Vescine and handmade by local artisans · original window and wall proportions preserved · fully renovated bathrooms with cotton towels, bathrobe, slippers and courtesy set · all bath products locally made, with no single-use plastic · minibar restocked daily · goose feather or memory foam pillows.',
  array[
    'Five-star relais in a 13th-century hamlet at Radda in Chianti, in the heart of Chianti Classico',
    '42 hectares of vineyards, centuries-old olive groves and woodland, with trails inside the estate',
    'Centuries-old cellar with tastings of the estate wines',
    'Pool set in an Italian garden',
    'Dinner in the hamlet square, dinner in the olive grove, picnics',
    'Trekking, yoga, horse riding and vintage car outings',
    '20 km from Siena and 42 km from Florence'],
  array['Chianti Classico','borgo','Radda in Chianti','wine'],
  E'Five-star relais set in a 13th-century hamlet at Radda in Chianti. Each room category occupies a part of the hamlet that once had a working purpose — the granary, the olive store, the artisans'' workshops, the wine press, the hall where the community ate together — and the restoration kept the proportions and the materials of each. The estate covers 42 hectares of vineyards, olive groves and woodland.',
  array[
    'Net rates, cancellation policy and payment terms to the supplier not yet collected.',
    'Number of rooms in each category is not published: only the categories are.',
    'Photo usage not yet cleared with the property: usage_cleared is false on every photo.'],
  E'Contatos: reservations@vescine.it · +39 0577 741144.\nFicha montada das páginas de quarto em vescine.it, outubro/26 — o site agora publica em inglês, o que não acontecia quando a entrada do catálogo foi feita em agosto/26.\nATENÇÃO ÀS CONVERSÕES DO SITE, que estão erradas em dois lugares: a Deluxe diz "22 to 24 Sq. Metres (90 Sq. Foot)" e 22–24 m² dão 237–258 sq ft, não 90; a Superior diz "Around 35 Sq. Feet" onde a Superior com Patio diz "35 mq - 375 Sq. Feet", ou seja são 35 m². Aqui ficou gravado o METRO QUADRADO, que é o número certo, e quem converte para sq ft é o hub — não se copiou a conta errada do site.\nO site não publica spa. Não oferecer: a palavra que aparece na home é Vespa, do passeio.\nA entrada do catálogo de agosto/26 (Camera Deluxe) continua onde está e não foi tocada.' )
on conflict (id) do update set
  name = excluded.name, category = excluded.category, subcategories = excluded.subcategories,
  business_suite = excluded.business_suite, region = excluded.region, city = excluded.city,
  website = excluded.website, languages = excluded.languages, name_rule = excluded.name_rule,
  accommodation_summary = excluded.accommodation_summary,
  accommodation_notes = excluded.accommodation_notes,
  highlights = excluded.highlights, tags = excluded.tags, summary = excluded.summary,
  open_points = excluded.open_points, updated_at = now();

insert into ops_supplier_contacts (id, supplier_id, name, role, email, phone, sort_order)
values ('b0000000-0000-0000-0000-000000990001', 'b0000000-0000-0000-0000-000000000000', 'Reservations', 'Reservations',
        'reservations@vescine.it', '+39 0577 741144', 1)
on conflict (id) do update set email = excluded.email, phone = excluded.phone;


-- 1. Classic Room ---------------------------------------------------
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('b0000000-0000-0000-0000-000000000000', 'b0000000-0000-0000-0000-000000010000', E'Classic Room', E'around 15 sqm', 15, 15, E'2 adults', E'Queen bed 160×190 cm', E'The hamlet square and the Tuscan hills', null, E'The Classic Rooms were once where lavender and herbs gathered in the surrounding fields were left to dry. Farmers prepared their harvests here, for natural perfumes, for the kitchen and for medicinal preparations.\nThe most intimate rooms of the hamlet, and the ones that kept most of the original architecture: hand-made terracotta floors and traditional ceilings, restored rather than replaced. The furnishings were designed for Borgo Vescine and made by local craftsmen. The original proportions of the windows and walls were left as they were.', array[E'Former drying rooms for lavender and herbs', E'Hand-made terracotta floors and traditional ceilings', E'Original window and wall proportions kept', E'Furniture designed for the house and made locally'], E'As Classic eram onde a lavanda e as ervas colhidas nos campos ao redor ficavam secando. Ali os camponeses preparavam a colheita, para perfumes naturais, para a cozinha e para preparações medicinais.\nSão os quartos mais íntimos do borgo, e os que mais guardaram a arquitetura original: piso de cotto feito à mão e tetos tradicionais, restaurados em vez de trocados. O mobiliário foi desenhado para o Borgo Vescine e feito por artesãos da região. As proporções originais das janelas e das paredes ficaram como estavam.', array[E'Antigas salas de secagem de lavanda e ervas', E'Piso de cotto feito à mão e tetos tradicionais', E'Proporções originais de janelas e paredes mantidas', E'Móveis desenhados para a casa e feitos na região'], 1)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('b0000000-0000-0000-0000-000000010001', 'b0000000-0000-0000-0000-000000000000', 'b0000000-0000-0000-0000-000000010000', E'https://images.squarespace-cdn.com/content/v1/63fa5a875489c1006b8bcdd1/7cd68fa7-819f-4f75-805d-f42576a8fc4a/100_1IN0104-HDR-Modifica.jpg', E'https://www.vescine.it/classic-room', E'Classic Room', true, false, 1)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('b0000000-0000-0000-0000-000000010002', 'b0000000-0000-0000-0000-000000000000', 'b0000000-0000-0000-0000-000000010000', E'https://images.squarespace-cdn.com/content/v1/63fa5a875489c1006b8bcdd1/4972b88e-eca6-452e-ac93-06edcc2ecce2/102_1IN0139-HDR-Modifica.jpg', E'https://www.vescine.it/classic-room', E'Classic Room', true, false, 2)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('b0000000-0000-0000-0000-000000010003', 'b0000000-0000-0000-0000-000000000000', 'b0000000-0000-0000-0000-000000010000', E'https://images.squarespace-cdn.com/content/v1/63fa5a875489c1006b8bcdd1/10efc549-e567-48a9-a0e5-07b7b8516b57/103_2IN7015.jpg', E'https://www.vescine.it/classic-room', E'Classic Room', true, false, 3)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('b0000000-0000-0000-0000-000000010004', 'b0000000-0000-0000-0000-000000000000', 'b0000000-0000-0000-0000-000000010000', E'https://images.squarespace-cdn.com/content/v1/63fa5a875489c1006b8bcdd1/782d1456-b270-410e-9ce0-77616a861f90/101_1IN0118-HDR-Modifica.jpg', E'https://www.vescine.it/classic-room', E'Classic Room', true, false, 4)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;


-- 2. Deluxe Room ---------------------------------------------------
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('b0000000-0000-0000-0000-000000000000', 'b0000000-0000-0000-0000-000000020000', E'Deluxe Room', E'around 22 to 24 sqm', 22, 24, E'2 adults', E'Queen bed 160×190 cm', E'The hamlet''s stone square or the vineyard ridges of Chianti', null, E'The Deluxe Rooms were the hamlet''s granaries, where the grain and cereals that carried the community from one season to the next were kept. In medieval times grain was not only flour and pasta: it was the reserve that saw a hamlet through a siege or a hard winter.\nThe rooms keep the hand-fired terracotta floors and the beamed ceilings. The furnishings were designed exclusively for Borgo Vescine and made by local artisans. The bathrooms are new, with bathrobe, slippers and locally made products, free of single-use plastic.', array[E'The hamlet''s former granaries', E'Hand-fired terracotta floors and beamed ceilings', E'Views over the square or the Chianti ridges', E'Bathrooms renovated, amenities made locally'], E'As Deluxe eram os celeiros do borgo, onde se guardavam o grão e os cereais que sustentavam a comunidade de uma estação à outra. Na Idade Média o grão não era só farinha e massa: era a reserva que fazia um povoado atravessar um cerco ou um inverno duro.\nOs quartos mantêm o piso de cotto queimado à lenha e os tetos de vigas aparentes. O mobiliário foi desenhado exclusivamente para o Borgo Vescine e feito por artesãos locais. Os banheiros são novos, com roupão, chinelo e produtos de produção local, sem plástico de uso único.', array[E'Antigos celeiros do borgo', E'Piso de cotto queimado à lenha e tetos de vigas', E'Vista para a praça ou para os crinais do Chianti', E'Banheiros reformados, amenidades de produção local'], 2)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('b0000000-0000-0000-0000-000000020001', 'b0000000-0000-0000-0000-000000000000', 'b0000000-0000-0000-0000-000000020000', E'https://images.squarespace-cdn.com/content/v1/63fa5a875489c1006b8bcdd1/31e01f6f-8589-4a09-9eef-f42014ac2ea2/118_1IN7878-HDR-2.jpg', E'https://www.vescine.it/deluxe-room', E'Deluxe Room', true, false, 1)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('b0000000-0000-0000-0000-000000020002', 'b0000000-0000-0000-0000-000000000000', 'b0000000-0000-0000-0000-000000020000', E'https://images.squarespace-cdn.com/content/v1/63fa5a875489c1006b8bcdd1/312963c8-9224-426d-8779-aff318c6257a/108_INF2743-HDR.jpg', E'https://www.vescine.it/deluxe-room', E'Deluxe Room', true, false, 2)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('b0000000-0000-0000-0000-000000020003', 'b0000000-0000-0000-0000-000000000000', 'b0000000-0000-0000-0000-000000020000', E'https://images.squarespace-cdn.com/content/v1/63fa5a875489c1006b8bcdd1/4ec69a60-ba0c-4830-bd7f-b73afe541cd7/117_INF2764.jpg', E'https://www.vescine.it/deluxe-room', E'Deluxe Room', true, false, 3)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('b0000000-0000-0000-0000-000000020004', 'b0000000-0000-0000-0000-000000000000', 'b0000000-0000-0000-0000-000000020000', E'https://images.squarespace-cdn.com/content/v1/63fa5a875489c1006b8bcdd1/1838b108-b3a4-4bee-a889-584792353945/105_INF2737-HDR.jpg', E'https://www.vescine.it/deluxe-room', E'Deluxe Room', true, false, 4)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;


-- 3. Deluxe Plus Room ---------------------------------------------------
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('b0000000-0000-0000-0000-000000000000', 'b0000000-0000-0000-0000-000000030000', E'Deluxe Plus Room', E'around 22 to 24 sqm', 22, 24, E'2 adults', E'Queen bed 160×190 cm', E'The hamlet''s stone paths or the surrounding hills, from a private patio', null, E'The Deluxe Plus Rooms were where grapes were pressed and fermented. In the Middle Ages wine was safer than water, and it was also hospitality, faith and celebration — sustenance, trade and pride for the community. These walls belonged to the winemakers who made the Chianti the region is known for.\nSame materials and same restoration as the Deluxe. What sets them apart is a small private patio, an outdoor corner of their own.', array[E'Where grapes were pressed and fermented', E'Small private patio', E'Hand-fired terracotta floors and beamed ceilings', E'Furniture designed for the house and made locally'], E'As Deluxe Plus eram onde se prensava e se fermentava a uva. Na Idade Média o vinho era mais seguro que a água, e era também hospitalidade, fé e celebração — sustento, comércio e orgulho da comunidade. Estas paredes foram dos vinhateiros que fizeram o Chianti pelo qual a região é conhecida.\nMesmos materiais e mesmo restauro das Deluxe. O que as distingue é um pequeno pátio privativo, um canto ao ar livre só delas.', array[E'Onde se prensava e fermentava a uva', E'Pequeno pátio privativo', E'Piso de cotto queimado à lenha e tetos de vigas', E'Móveis desenhados para a casa e feitos na região'], 3)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('b0000000-0000-0000-0000-000000030001', 'b0000000-0000-0000-0000-000000000000', 'b0000000-0000-0000-0000-000000030000', E'https://images.squarespace-cdn.com/content/v1/63fa5a875489c1006b8bcdd1/8b0630a5-c9ea-4c1f-ba93-f88166d8a0d4/030_1IN7570-HDR.jpg', E'https://www.vescine.it/deluxe-plus-room', E'Deluxe Plus Room', true, false, 1)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('b0000000-0000-0000-0000-000000030002', 'b0000000-0000-0000-0000-000000000000', 'b0000000-0000-0000-0000-000000030000', E'https://images.squarespace-cdn.com/content/v1/63fa5a875489c1006b8bcdd1/737e927e-6698-4b2a-b1be-874537312e5c/036_INF2623-HDR.jpg', E'https://www.vescine.it/deluxe-plus-room', E'Deluxe Plus Room', true, false, 2)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('b0000000-0000-0000-0000-000000030003', 'b0000000-0000-0000-0000-000000000000', 'b0000000-0000-0000-0000-000000030000', E'https://images.squarespace-cdn.com/content/v1/63fa5a875489c1006b8bcdd1/9485f08a-ca3b-4cb4-af2d-d8f7790fa5a2/035_1IN7598-HDR.jpg', E'https://www.vescine.it/deluxe-plus-room', E'Deluxe Plus Room', true, false, 3)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('b0000000-0000-0000-0000-000000030004', 'b0000000-0000-0000-0000-000000000000', 'b0000000-0000-0000-0000-000000030000', E'https://images.squarespace-cdn.com/content/v1/63fa5a875489c1006b8bcdd1/0fde0d2a-8b98-4615-9089-754bba5c3772/092-_2IN9906-HDR.jpg', E'https://www.vescine.it/deluxe-plus-room', E'Deluxe Plus Room', true, false, 4)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;


-- 4. Superior Room ---------------------------------------------------
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('b0000000-0000-0000-0000-000000000000', 'b0000000-0000-0000-0000-000000040000', E'Superior Room', E'around 35 sqm', 35, 35, E'2 adults', E'King bed 180×190 cm', E'The Tuscan hillsides and the hamlet square', null, E'The Superior Rooms were the olive store, where the fruit waited before pressing. In a medieval hamlet olive oil was far more than cooking: it lit the lamps, it went into remedies, it had a place in sacred ritual, and its trade tied the hamlet to the routes across the region.\nThe rooms keep the hand-fired terracotta floors and the exposed beams. The furnishings were made to measure by local artisans, in a style that stays close to the room''s rural origin.', array[E'The hamlet''s former olive store', E'Hand-fired terracotta floors and exposed beams', E'Views over the hillsides and the square', E'Made-to-measure furniture by local artisans'], E'As Superior eram o depósito das azeitonas, onde o fruto esperava a prensagem. Num borgo medieval o azeite era muito mais que cozinha: acendia as lamparinas, entrava nos remédios, tinha lugar no rito sagrado, e o comércio dele ligava o povoado às rotas da região.\nOs quartos mantêm o piso de cotto queimado à lenha e as vigas aparentes. O mobiliário foi feito sob medida por artesãos da região, num estilo que não se afasta da origem rural do quarto.', array[E'Antigo depósito de azeitonas do borgo', E'Piso de cotto queimado à lenha e vigas aparentes', E'Vista para as colinas e para a praça', E'Móveis sob medida de artesãos da região'], 4)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('b0000000-0000-0000-0000-000000040001', 'b0000000-0000-0000-0000-000000000000', 'b0000000-0000-0000-0000-000000040000', E'https://images.squarespace-cdn.com/content/v1/63fa5a875489c1006b8bcdd1/cea8897f-aa28-4f28-87a5-0c57b2b9123c/071-_1IN4762-HDR-Modifica.jpg', E'https://www.vescine.it/superior-room', E'Superior Room', true, false, 1)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('b0000000-0000-0000-0000-000000040002', 'b0000000-0000-0000-0000-000000000000', 'b0000000-0000-0000-0000-000000040000', E'https://images.squarespace-cdn.com/content/v1/63fa5a875489c1006b8bcdd1/d03db0f3-fb66-4b91-adc7-d57f83908885/044_1IN7619-HDR-2-2.jpg', E'https://www.vescine.it/superior-room', E'Superior Room', true, false, 2)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('b0000000-0000-0000-0000-000000040003', 'b0000000-0000-0000-0000-000000000000', 'b0000000-0000-0000-0000-000000040000', E'https://images.squarespace-cdn.com/content/v1/63fa5a875489c1006b8bcdd1/f0a802dc-e662-4558-9c39-6a8491b7f3f9/IMG_1478.JPG', E'https://www.vescine.it/superior-room', E'Superior Room', true, false, 3)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('b0000000-0000-0000-0000-000000040004', 'b0000000-0000-0000-0000-000000000000', 'b0000000-0000-0000-0000-000000040000', E'https://images.squarespace-cdn.com/content/v1/63fa5a875489c1006b8bcdd1/ccff0bcf-84ea-41c0-a9e4-8bb7600d2679/056-_2IN9874.jpg', E'https://www.vescine.it/superior-room', E'Superior Room', true, false, 4)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;


-- 5. Superior Room with Patio ---------------------------------------------------
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('b0000000-0000-0000-0000-000000000000', 'b0000000-0000-0000-0000-000000050000', E'Superior Room with Patio', E'around 35 sqm', 35, 35, E'2 adults + 1', E'King bed 180×190 cm', E'The Tuscan hillsides or the hamlet square, from a private patio', null, E'These rooms were the workshops of the hamlet''s artisans, who made the tools for the farms and the barrels for the wine and the oil — the two things the local economy rested on.\nThe restoration kept that heritage under the surface and added direct access to a private patio, looking either over the Tuscan hillsides or over the hamlet square.', array[E'Former artisans'' workshops', E'Direct access to a private patio', E'Hand-fired terracotta floors and exposed beams', E'Sleeps a third guest'], E'Estes quartos eram as oficinas dos artesãos do borgo, que faziam as ferramentas das fazendas e os barris para o vinho e o azeite — as duas coisas sobre as quais a economia local se apoiava.\nO restauro deixou essa herança por baixo da superfície e acrescentou acesso direto a um pátio privativo, voltado para as colinas toscanas ou para a praça do borgo.', array[E'Antigas oficinas dos artesãos', E'Acesso direto a pátio privativo', E'Piso de cotto queimado à lenha e vigas aparentes', E'Acomoda um terceiro hóspede'], 5)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('b0000000-0000-0000-0000-000000050001', 'b0000000-0000-0000-0000-000000000000', 'b0000000-0000-0000-0000-000000050000', E'https://images.squarespace-cdn.com/content/v1/63fa5a875489c1006b8bcdd1/901b3156-1a99-4272-a107-5f8455a25b3c/IMG_1499.JPG', E'https://www.vescine.it/superior-room-patio', E'Superior Room with Patio', true, false, 1)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('b0000000-0000-0000-0000-000000050002', 'b0000000-0000-0000-0000-000000000000', 'b0000000-0000-0000-0000-000000050000', E'https://images.squarespace-cdn.com/content/v1/63fa5a875489c1006b8bcdd1/8fbdc5db-0534-4be6-9b7c-e7a9f042a1b6/IMG_1513.JPG', E'https://www.vescine.it/superior-room-patio', E'Superior Room with Patio', true, false, 2)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('b0000000-0000-0000-0000-000000050003', 'b0000000-0000-0000-0000-000000000000', 'b0000000-0000-0000-0000-000000050000', E'https://images.squarespace-cdn.com/content/v1/63fa5a875489c1006b8bcdd1/599cef4e-ef4b-459e-b594-a5991e783299/IMG_1500.JPG', E'https://www.vescine.it/superior-room-patio', E'Superior Room with Patio', true, false, 3)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('b0000000-0000-0000-0000-000000050004', 'b0000000-0000-0000-0000-000000000000', 'b0000000-0000-0000-0000-000000050000', E'https://images.squarespace-cdn.com/content/v1/63fa5a875489c1006b8bcdd1/0d0a4225-f8a3-4d3c-b998-f4d5d4f66bde/055_1IN7681-HDR-2-2.jpg', E'https://www.vescine.it/superior-room-patio', E'Superior Room with Patio', true, false, 4)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;


-- 6. Suite ---------------------------------------------------
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('b0000000-0000-0000-0000-000000000000', 'b0000000-0000-0000-0000-000000060000', E'Suite', E'around 40 sqm', 40, 40, E'2 adults + 2', E'King bed 180×190 cm', E'The Tuscan hillsides and the hamlet square', null, E'The Suites were where the hamlet gathered — the halls of communal feasts and celebrations, where people came together to share stories and meals. They are among the largest rooms of the relais.\nMost of the furniture was made by local artisans to designs drawn for the house. The bathrooms were rebuilt entirely. The original size of the hamlet''s windows, walls and rooms was kept, on the principle that a guest should live the place as its inhabitants did.', array[E'The hamlet''s former halls for communal feasts', E'Among the largest rooms of the relais', E'Original room, window and wall sizes kept', E'Bathrooms rebuilt entirely'], E'As Suites eram onde o borgo se reunia — os salões das festas e celebrações comuns, onde as pessoas se juntavam para partilhar histórias e refeições. Estão entre os maiores quartos do relais.\nQuase todo o mobiliário foi feito por artesãos da região a partir de desenhos criados para a casa. Os banheiros foram inteiramente refeitos. As dimensões originais das janelas, das paredes e dos quartos do borgo foram mantidas, pelo princípio de que o hóspede deve viver o lugar como viveram os habitantes dele.', array[E'Antigos salões das festas comuns do borgo', E'Entre os maiores quartos do relais', E'Dimensões originais de quarto, janelas e paredes mantidas', E'Banheiros inteiramente refeitos'], 6)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('b0000000-0000-0000-0000-000000060001', 'b0000000-0000-0000-0000-000000000000', 'b0000000-0000-0000-0000-000000060000', E'https://images.squarespace-cdn.com/content/v1/63fa5a875489c1006b8bcdd1/e9432ce3-26b0-4895-9255-773606483787/063-_1IN4714-HDR.jpg', E'https://www.vescine.it/suite-room', E'Suite', true, false, 1)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('b0000000-0000-0000-0000-000000060002', 'b0000000-0000-0000-0000-000000000000', 'b0000000-0000-0000-0000-000000060000', E'https://images.squarespace-cdn.com/content/v1/63fa5a875489c1006b8bcdd1/152d0f56-61c4-4879-bbb4-c1d808eced10/065-_1IN4738-HDR-Modifica.jpg', E'https://www.vescine.it/suite-room', E'Suite', true, false, 2)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('b0000000-0000-0000-0000-000000060003', 'b0000000-0000-0000-0000-000000000000', 'b0000000-0000-0000-0000-000000060000', E'https://images.squarespace-cdn.com/content/v1/63fa5a875489c1006b8bcdd1/46649470-4ce3-49db-99af-4098cc0b8843/067-_2IN9878.jpg', E'https://www.vescine.it/suite-room', E'Suite', true, false, 3)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('b0000000-0000-0000-0000-000000060004', 'b0000000-0000-0000-0000-000000000000', 'b0000000-0000-0000-0000-000000060000', E'https://images.squarespace-cdn.com/content/v1/63fa5a875489c1006b8bcdd1/755e5b7e-d572-4d65-bd9d-f951b3734154/068-_2IN9883.jpg', E'https://www.vescine.it/suite-room', E'Suite', true, false, 4)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;


-- 7. Suite Superior with Patio ---------------------------------------------------
insert into ops_room_types (supplier_id, id, name, size, size_m2_min, size_m2_max, max_occupancy, beds, view, units, description, highlights, description_pt, highlights_pt, sort_order)
values ('b0000000-0000-0000-0000-000000000000', 'b0000000-0000-0000-0000-000000070000', E'Suite Superior with Patio', E'around 55 sqm', 55, 55, E'2 adults + 2', E'King bed 180×190 cm', E'The Tuscan hills or the central square, from a private patio', null, E'These were the quarters of the hamlet''s stewards — the people who ran daily life and kept the peace among the residents. Each steward answered for a different part of the hamlet, which is why these suites sit in different corners of it, and why they had their own way out to the open air.\nTuscan terracotta ceilings restored, floors of hand-made tiles wood-fired by centuries-old technique, and in some rooms lime plaster sealed with natural wax, redoing the textures of the time. Exposed beams, some of them recovered from the original roofs. A discreet diffuser carries notes drawn from aged wine barrels.\nThe private patio looks over the hills or the square.', array[E'The stewards'' former quarters', E'Private patio with direct access', E'Restored Tuscan terracotta ceilings and wood-fired floor tiles', E'Lime plasterwork sealed with natural wax in selected rooms'], E'Estas eram as moradias dos administradores do borgo — quem conduzia a vida diária e mantinha a harmonia entre os moradores. Cada administrador respondia por uma parte do povoado, e é por isso que estas suítes ficam em cantos diferentes dele, e é por isso que tinham saída própria para fora.\nTetos de cotto toscano restaurados, pisos de ladrilho feito à mão e queimado a lenha segundo técnica secular, e em alguns ambientes reboco de cal selado com cera natural, refazendo as texturas da época. Vigas aparentes, parte delas recuperadas dos telhados originais. Um difusor discreto leva notas tiradas das barricas de vinho envelhecido.\nO pátio privativo dá para as colinas ou para a praça.', array[E'Antigas moradias dos administradores do borgo', E'Pátio privativo com acesso direto', E'Tetos de cotto toscano restaurados e ladrilho queimado a lenha', E'Reboco de cal selado com cera natural em alguns ambientes'], 7)
on conflict (id) do update set
  name = excluded.name, size = excluded.size,
  size_m2_min = excluded.size_m2_min, size_m2_max = excluded.size_m2_max,
  max_occupancy = excluded.max_occupancy, beds = excluded.beds, view = excluded.view,
  units = excluded.units, description = excluded.description, highlights = excluded.highlights,
  description_pt = excluded.description_pt, highlights_pt = excluded.highlights_pt,
  sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('b0000000-0000-0000-0000-000000070001', 'b0000000-0000-0000-0000-000000000000', 'b0000000-0000-0000-0000-000000070000', E'https://images.squarespace-cdn.com/content/v1/63fa5a875489c1006b8bcdd1/112165a3-4bf7-410a-a0af-0cacf50287fa/_1IN6814-HDR.jpg', E'https://www.vescine.it/suite-patio-room', E'Suite Superior with Patio', true, false, 1)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('b0000000-0000-0000-0000-000000070002', 'b0000000-0000-0000-0000-000000000000', 'b0000000-0000-0000-0000-000000070000', E'https://images.squarespace-cdn.com/content/v1/63fa5a875489c1006b8bcdd1/e5a01f65-8adf-4e44-ac49-2b42252d9240/12-_1IN6375-HDR.jpg', E'https://www.vescine.it/suite-patio-room', E'Suite Superior with Patio', true, false, 2)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('b0000000-0000-0000-0000-000000070003', 'b0000000-0000-0000-0000-000000000000', 'b0000000-0000-0000-0000-000000070000', E'https://images.squarespace-cdn.com/content/v1/63fa5a875489c1006b8bcdd1/31962ca4-680b-4b81-879d-982eb1265bb1/20-_1IN6512-HDR.jpg', E'https://www.vescine.it/suite-patio-room', E'Suite Superior with Patio', true, false, 3)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('b0000000-0000-0000-0000-000000070004', 'b0000000-0000-0000-0000-000000000000', 'b0000000-0000-0000-0000-000000070000', E'https://images.squarespace-cdn.com/content/v1/63fa5a875489c1006b8bcdd1/63d32584-33e2-42b5-b215-25b841e5846e/21-_1IN6533-HDR.jpg', E'https://www.vescine.it/suite-patio-room', E'Suite Superior with Patio', true, false, 4)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;


insert into ops_migrations (id) values ('0046-borgo-vescine-ficha') on conflict (id) do nothing;
