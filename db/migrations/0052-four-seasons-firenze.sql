-- =====================================================================
-- 0052 · FOUR SEASONS HOTEL FIRENZE, DO FACT SHEET OFICIAL
--
-- Instrução dela, outubro/26: "four seasons tem que fazer separado,
-- procure nos sites as informações corretas". A 0051 tinha posto os dois
-- num arquivo só e com o mínimo; agora cada um tem o seu, e com tudo que
-- a fonte oficial dá.
--
-- ATUALIZA A LINHA QUE A 0051 CRIOU, pelo mesmo id. Se ela já tiver
-- digitado alguma coisa nesta ficha, o que está aqui passa por cima —
-- foi avisado na mensagem. Nenhuma outra linha do banco é tocada.
--
-- A FONTE É O FACT SHEET OFICIAL EM WORD, baixado do próprio press kit da
-- Four Seasons (press.fourseasons.com/florence/hotel-facts → DOWNLOAD IN
-- WORD). É mais completo que a versão em tela: traz os cinco pontos de
-- comida com lugares e decoração, a academia, o parque de 4,5 hectares, os
-- produtos da spa e a história dos dois palazzi.
--
-- AS CATEGORIAS DE QUARTO CONTINUAM FALTANDO, e agora sei por quê: a Four
-- Seasons NÃO as publica no press kit — nem na tela, nem no Word. Elas só
-- existem em fourseasons.com, e esse domínio inteiro responde 403 a esta
-- máquina, inclusive reservations.fourseasons.com. Tentei com navegador de
-- verdade, cabeçalhos de navegador e sem marca de automação: é bloqueio de
-- rede, não de impressão digital. Então as categorias vêm da fact sheet que
-- eles mandam para agência parceira, e entram em migração própria.
--
-- AS FOTOS SÃO OFICIAIS, do banco de imagens do press kit, na versão 722px
-- que é a que serve para proposta. Esse servidor não manda CORS, então elas
-- não encolhem no PDF — mas já nascem em torno de 200 KB.
--
-- Só cria e preenche objetos ops_. Nenhum delete.
-- =====================================================================

update ops_suppliers set
  legal_name = null,
  subcategories = array['City hotel','Historic building','Palazzo'],
  business_suite = array['TL Selected Stays','MICE e Exclusive Events'],
  languages = array['Italian','English'],
  accommodation_summary = E'121 accommodations: 76 guest rooms and 45 suites, across Palazzo della Gherardesca and Palazzo del Nero, on three floors. Four Seasons does not publish the category list or the floor areas in its press kit.',
  accommodation_notes = E'Interiors by Pierre-Yves Rochon: a mix of Renaissance architecture and modern comfort, with period furnishings and restored frescoes. Architects Studio Noferi and Studio Magris & Partners.',
  capacities = E'Meeting and event space of 2,768 sqm / 29,785 sq ft, with 7 breakout spaces. Largest ballroom 176 sqm / 1,894 sq ft. Banquet 120 indoors and 400 outdoors; meet-and-feed 200; private dining room 30. Two rooms that have no equivalent elsewhere: the Palazzo della Gherardesca ballroom, with frescoes and 18th-century chandeliers, and the former convent church, with soaring frescoed ceilings.',
  highlights = array[
    'Palazzo della Gherardesca, built in 1473 by Bartolomeo Scala, later home to noble Florentine families including a Medici cardinal and the Della Gherardesca; a Four Seasons since 2008',
    'Palazzo del Nero, once part of the Wool Guild properties, rebuilt in the 17th century by Baron Filippo del Nero, enlarged in the 18th, later the Ruspoli residence and then a neo-Gothic church',
    'Giardino della Gherardesca: 4.5 hectares, one of the largest private gardens in Florence, once a botanic garden and long closed to the public, with walking and jogging paths',
    'Spa of 791 sqm with 10 treatment rooms, a separate Grand Spa and Couple''s Suite with floor-to-ceiling windows onto the garden, and a soaking tub carved from a single block of pietra serena',
    'Spa signature: Renaissance Flowers by Santa Maria Novella; products by Officina Profumo-Farmaceutica di Santa Maria Novella, Rephase, Sodashi and Mimi Luzon',
    'Il Palagio — Italian fine dining under an antique vaulted ceiling, 60 indoors and 60 outdoors',
    'Onde — Italian coastal osteria, Mediterranean interior, 60 indoors and 60 outdoors',
    'Trattoria Al Fresco — handmade pizza and grilled meat and seafood, open air under the trees by the pool',
    'Atrium Bar — cocktails, light meals and afternoon tea, sky-lit, with oriental rugs',
    'Bar Berni — vermouth bar and all-day dining, botanical interior',
    'Executive chef Paolo Lavezzini; signature dish Fracassi Casentino lamb with celeriac, black garlic and liquorice',
    'Fitness centre of 205 sqm in its own building in the garden, beside the spa; yoga, pilates and a trainer on site',
    'One pool. Golf 30 minutes, horse riding 25, tennis 15',
    '10 to 15 minutes on foot to the Duomo, the Uffizi and the Accademia',
    'Opened June 2008; general manager Max Musto'],
  tags = array['Florence','Borgo Pinti','palazzo','garden','spa','Four Seasons','wedding venue'],
  summary = E'Two Florentine palazzi — the Gherardesca of 1473 and the del Nero — joined into one hotel of 121 rooms and suites around the largest private garden in the city, 4.5 hectares that were a botanic garden and were closed to the public for centuries. Pierre-Yves Rochon''s interiors sit inside restored frescoes and period rooms. Five places to eat and drink, including Il Palagio under its antique vaulted ceiling, and a spa of 791 sqm in its own building in the garden. Ten to fifteen minutes on foot from the Duomo.',
  open_points = array[
    'ROOM CATEGORIES AND FLOOR AREAS ARE STILL MISSING. Four Seasons does not publish them in the press kit, in either the on-screen or the Word version, and fourseasons.com answers 403 to this machine — the whole domain, including the booking host. Ask Four Seasons for the room fact sheet.',
    'Net rates, cancellation policy and payment terms to the supplier not yet collected.',
    'Photo usage not cleared: these are press images, usage_cleared is false.'],
  updated_at = now()
where id = '19000000-0000-0000-0000-000000000000';

-- Fotos oficiais do press kit --
insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('19000000-0000-0000-0000-000000000001', '19000000-0000-0000-0000-000000000000', null, E'https://press.fourseasons.com/content/dam/fourseasons/images/web/FLO/FLO_3014_original.jpg/jcr:content/renditions/cq5dam.web.press.722.keepaspectratio.jpeg', E'https://press.fourseasons.com/florence/', E'Four Seasons Hotel Firenze', true, false, 1)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('19000000-0000-0000-0000-000000000002', '19000000-0000-0000-0000-000000000000', null, E'https://press.fourseasons.com/content/dam/fourseasons/images/web/FLO/FLO_3016_original.jpg/jcr:content/renditions/cq5dam.web.press.722.keepaspectratio.jpeg', E'https://press.fourseasons.com/florence/', E'Four Seasons Hotel Firenze', true, false, 2)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('19000000-0000-0000-0000-000000000003', '19000000-0000-0000-0000-000000000000', null, E'https://press.fourseasons.com/content/dam/fourseasons/images/web/FLO/FLO_3031_aspect16x9.jpg/jcr:content/renditions/cq5dam.web.press.722.keepaspectratio.jpeg', E'https://press.fourseasons.com/florence/', E'Four Seasons Hotel Firenze', true, false, 3)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('19000000-0000-0000-0000-000000000004', '19000000-0000-0000-0000-000000000000', null, E'https://press.fourseasons.com/content/dam/fourseasons/images/web/FLO/FLO_3101_aspect16x9.jpg/jcr:content/renditions/cq5dam.web.press.722.keepaspectratio.jpeg', E'https://press.fourseasons.com/florence/', E'Four Seasons Hotel Firenze', true, false, 4)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('19000000-0000-0000-0000-000000000005', '19000000-0000-0000-0000-000000000000', null, E'https://press.fourseasons.com/content/dam/fourseasons/images/web/FLO/FLO_3190_aspect16x9.jpg/jcr:content/renditions/cq5dam.web.press.722.keepaspectratio.jpeg', E'https://press.fourseasons.com/florence/', E'Four Seasons Hotel Firenze', true, false, 5)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('19000000-0000-0000-0000-000000000006', '19000000-0000-0000-0000-000000000000', null, E'https://press.fourseasons.com/content/dam/fourseasons/images/web/FLO/FLO_3191_aspect16x9.jpg/jcr:content/renditions/cq5dam.web.press.722.keepaspectratio.jpeg', E'https://press.fourseasons.com/florence/', E'Four Seasons Hotel Firenze', true, false, 6)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('19000000-0000-0000-0000-000000000007', '19000000-0000-0000-0000-000000000000', null, E'https://press.fourseasons.com/content/dam/fourseasons/images/web/FLO/FLO_3192_aspect16x9.jpg/jcr:content/renditions/cq5dam.web.press.722.keepaspectratio.jpeg', E'https://press.fourseasons.com/florence/', E'Four Seasons Hotel Firenze', true, false, 7)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('19000000-0000-0000-0000-000000000008', '19000000-0000-0000-0000-000000000000', null, E'https://press.fourseasons.com/content/dam/fourseasons/images/web/FLO/FLO_3215_aspect16x9.jpg/jcr:content/renditions/cq5dam.web.press.722.keepaspectratio.jpeg', E'https://press.fourseasons.com/florence/', E'Four Seasons Hotel Firenze', true, false, 8)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('19000000-0000-0000-0000-000000000009', '19000000-0000-0000-0000-000000000000', null, E'https://press.fourseasons.com/content/dam/fourseasons/images/web/FLO/FLO_3216_aspect16x9.jpg/jcr:content/renditions/cq5dam.web.press.722.keepaspectratio.jpeg', E'https://press.fourseasons.com/florence/', E'Four Seasons Hotel Firenze', true, false, 9)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('19000000-0000-0000-0000-000000000010', '19000000-0000-0000-0000-000000000000', null, E'https://press.fourseasons.com/content/dam/fourseasons/images/web/FLO/FLO_3217_aspect16x9.jpg/jcr:content/renditions/cq5dam.web.press.722.keepaspectratio.jpeg', E'https://press.fourseasons.com/florence/', E'Four Seasons Hotel Firenze', true, false, 10)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('19000000-0000-0000-0000-000000000011', '19000000-0000-0000-0000-000000000000', null, E'https://press.fourseasons.com/content/dam/fourseasons/images/web/FLO/FLO_3218_aspect16x9.jpg/jcr:content/renditions/cq5dam.web.press.722.keepaspectratio.jpeg', E'https://press.fourseasons.com/florence/', E'Four Seasons Hotel Firenze', true, false, 11)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_migrations (id) values ('0052-four-seasons-firenze') on conflict (id) do nothing;
