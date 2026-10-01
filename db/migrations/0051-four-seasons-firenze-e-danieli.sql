-- =====================================================================
-- 0051 · FOUR SEASONS FIRENZE E DANIELI VENEZIA, SEM OS QUARTOS
--
-- Pedido dela, outubro/26. Estes dois são os únicos da leva que ficaram
-- SEM a lista de quartos, e o motivo não é falta de procura:
-- fourseasons.com é bloqueado na borda (Akamai devolve "Access Denied"),
-- por leitura simples e por navegador. É de lá que sai a metragem de cada
-- categoria.
--
-- O QUE ENTROU É OFICIAL, e saiu do press kit da própria Four Seasons:
--   · Firenze, da página de FACTS, com todos os blocos abertos: 121
--     quartos (76 + 45 suítes), os dois palazzi e a história de cada um,
--     a spa de 791 m² com 10 salas, os restaurantes com nome e chef, e o
--     Giardino della Gherardesca;
--   · Danieli, do comunicado de reabertura de 30 de julho de 2026, porque
--     a página de FACTS dele ainda não existe — o hotel acabou de reabrir.
--
-- NÃO INVENTEI CATEGORIA DE QUARTO. Dava para copiar metragem de site de
-- terceiro, e eu não copiei: no Danieli as fontes de terceiros dizem 176
-- quartos e 79 suítes, e o comunicado da própria Four Seasons diz 120
-- agora e 168 em 2027. Uma das duas está errada, e numa proposta de
-- cliente isso é o número errado impresso.
--
-- COMO SE COMPLETA, e está escrito na ficha: a Four Seasons manda a fact
-- sheet de quartos para agência parceira. Os dois contatos de imprensa
-- estão gravados. Com o arquivo na mão, as categorias entram em migração
-- própria.
--
-- Só cria e preenche objetos ops_. Nenhum update ou delete em linha antiga.
-- =====================================================================

insert into ops_suppliers
  (id, name, category, subcategories, business_suite, status, region, city, address,
   website, languages, name_rule, vat_status,
   accommodation_summary, capacities, highlights, tags, summary,
   open_points, internal_notes)
values ('19000000-0000-0000-0000-000000000000',
  'Four Seasons Hotel Firenze', 'Hotel / Accommodation',
  array['City hotel','Historic building'],
  array['TL Selected Stays','MICE e Exclusive Events'],
  'To test', 'Tuscany', 'Firenze',
  'Borgo Pinti 99, 50121 Firenze',
  'https://www.fourseasons.com/florence/',
  array['Italian','English'],
  'Show supplier name', 'not stated',
  E'121 accommodations: 76 guest rooms and 45 suites, across Palazzo della Gherardesca and Palazzo del Nero, on three floors. Room categories and floor areas are not published on the press site.',
  E'Meeting and event space totalling 2,768 sqm / 29,785 sq ft. Largest ballroom 176 sqm / 1,894 sq ft. Banquet capacity 120, meet-and-feed capacity 200.',
  array[
    'Palazzo della Gherardesca, built in 1473 by Bartolomeo Scala, later home to noble Florentine families including a Medici cardinal',
    'Palazzo del Nero, once part of the Wool Guild properties, rebuilt in the 17th century by Baron Filippo del Nero',
    'Giardino della Gherardesca, one of the largest private gardens in Florence, once a botanic garden and long closed to the public',
    'Spa of 791 sqm with 10 treatment rooms, a Grand Spa and Couple''s Suite onto the private garden, and a soaking tub carved from a single block of pietra serena',
    'Signature treatment: Renaissance Flowers by Santa Maria Novella',
    'Restaurants: Il Palagio (Italian fine dining) and Onde (Italian coastal osteria), executive chef Paolo Lavezzini',
    'Interiors by Pierre-Yves Rochon; restored period frescoes',
    '10 to 15 minutes on foot to the Duomo, the Uffizi and the Accademia',
    'Opened June 2008'],
  array['Florence','Borgo Pinti','palazzo','garden','spa','Four Seasons'],
  E'Two Florentine palazzi — the Gherardesca of 1473 and the del Nero — joined into one hotel of 121 rooms and suites, around the largest private garden in the city. Pierre-Yves Rochon''s interiors sit inside restored frescoes and period rooms, and the spa of 791 sqm occupies its own building in the garden. Ten to fifteen minutes on foot from the Duomo.',
  array[
    'ROOM CATEGORIES AND FLOOR AREAS ARE MISSING: fourseasons.com is blocked at the edge and the press kit does not break them down. Ask Four Seasons for the room fact sheet and they go in.',
    'Net rates, cancellation policy and payment terms to the supplier not yet collected.',
    'No photo: the image library needs press credentials.'],
  E'Ficha montada do PRESS KIT OFICIAL da Four Seasons (press.fourseasons.com/florence/hotel-facts), lido em navegador com todos os blocos abertos. É fonte oficial.\nfourseasons.com é BLOQUEADO na borda (Akamai: ''Access Denied''), tanto por leitura simples quanto por navegador. É de lá que sai a lista de quartos com metragem, e por isso ela não está aqui. Metragem de terceiro não entra: já vi número divergente entre fontes.\nCOMO COMPLETAR: a Four Seasons manda a fact sheet de quartos para agência parceira. Pedindo à Caterina Tritto (caterina.tritto@fourseasons.com, +39 055 262 6222), em um e-mail vem a lista com metragem. Me mande o arquivo e eu lanço as categorias.\nContato de imprensa e reservas confirmados em outubro/26.' )
on conflict (id) do update set
  name = excluded.name, category = excluded.category, subcategories = excluded.subcategories,
  business_suite = excluded.business_suite, region = excluded.region, city = excluded.city,
  address = excluded.address, website = excluded.website, name_rule = excluded.name_rule,
  accommodation_summary = excluded.accommodation_summary, capacities = excluded.capacities,
  highlights = excluded.highlights, tags = excluded.tags, summary = excluded.summary,
  open_points = excluded.open_points, updated_at = now();

insert into ops_supplier_contacts (id, supplier_id, name, role, email, phone, sort_order)
values ('19000000-0000-0000-0000-000000990001', '19000000-0000-0000-0000-000000000000', 'Caterina Tritto',
        'Director of Public Relations and Marketing',
        'caterina.tritto@fourseasons.com', '+39 055 262 6222', 1)
on conflict (id) do update set email = excluded.email, phone = excluded.phone;

insert into ops_suppliers
  (id, name, category, subcategories, business_suite, status, region, city, address,
   website, languages, name_rule, vat_status,
   accommodation_summary, highlights, tags, summary, open_points, internal_notes)
values ('29000000-0000-0000-0000-000000000000',
  'Danieli, Venezia, A Four Seasons Hotel', 'Hotel / Accommodation',
  array['City hotel','Historic building'],
  array['TL Selected Stays'],
  'To test', 'Other', 'Venezia',
  'Riva degli Schiavoni 4196, 30122 Venezia',
  'https://www.fourseasons.com/venice/',
  array['Italian','English'],
  'Show supplier name', 'not stated',
  E'Reopened on 30 July 2026 with 120 rooms and suites, growing to 168 once the restoration of Palazzo Danieli Excelsior is complete in 2027. An expanded collection of Junior Suites and One-Bedroom Suites; many suites can be extended through connecting rooms. Room categories and floor areas are not published yet.',
  array[
    'Palazzo Dandolo, built in 1471 as the residence of the Dandolo family, one of the finest examples of Venetian Gothic architecture',
    'Palazzo Casa Nuova, once home to the Treasury of the Venetian Republic',
    'Palazzo Danieli Excelsior, under restoration until 2027',
    'On the Riva degli Schiavoni, with the Lagoon and San Giorgio Maggiore from the rooftop',
    'Interiors by Pierre-Yves Rochon, in a lagoon palette of celadon green, soft blue, terracotta, ochre and powder pink',
    'Murano glass, terrazzo floors and bespoke Rubelli textiles',
    'Artwork collection drawn from the spirit of the Grand Tour',
    'Restaurant and Bar Terrazza Danieli on the roof, executive chef Adriano Rausa',
    'Danieli Spa from late 2026: three treatment rooms, one for couples, sauna and hammam'],
  array['Venice','Riva degli Schiavoni','palazzo','Four Seasons','new opening'],
  E'Venice''s oldest grand hotel, reopened by Four Seasons on 30 July 2026 after four years of restoration. Three palazzi on the Riva degli Schiavoni, the oldest of them the Dandolo residence of 1471, with the Lagoon and San Giorgio Maggiore from the rooftop restaurant. Pierre-Yves Rochon''s interiors take their palette from the lagoon and their materials from the city: Murano glass, terrazzo, Rubelli textiles.',
  array[
    'ROOM CATEGORIES AND FLOOR AREAS ARE MISSING: the hotel has no FACTS page on the press site yet and fourseasons.com is blocked at the edge. Ask Four Seasons for the room fact sheet.',
    'Third-party sites say 176 rooms and 79 suites; the Four Seasons release says 120 now and 168 in 2027. The official figure was kept.',
    'The spa opens late 2026: do not promise it for an earlier date.',
    'Net rates, cancellation policy and payment terms to the supplier not yet collected.',
    'No photo: the image library needs press credentials.'],
  E'Ficha montada do COMUNICADO OFICIAL de reabertura da Four Seasons (press.fourseasons.com/venice/hotel-news/2026/now-open), lido em navegador.\nA página de FACTS deste hotel ainda não existe no site de imprensa — ele reabriu em julho/26 e o press kit está incompleto. fourseasons.com é bloqueado na borda.\nUMA DIVERGÊNCIA QUE VALE REGISTRAR: sites de terceiros dizem 176 quartos e 79 suítes. O comunicado da própria Four Seasons diz 120 agora e 168 quando o Palazzo Danieli Excelsior ficar pronto, em 2027. Ficou o número oficial.\nCOMO COMPLETAR: pedir a fact sheet de quartos à Caterina Sacone (caterina.sacone@fourseasons.com, +39 335 795 2689). Me mande o arquivo e eu lanço as categorias.\nA spa abre no fim de 2026: três salas de tratamento, uma para casal, sauna e hammam. Ao vender para data anterior, não prometer spa.' )
on conflict (id) do update set
  name = excluded.name, category = excluded.category, subcategories = excluded.subcategories,
  business_suite = excluded.business_suite, region = excluded.region, city = excluded.city,
  address = excluded.address, website = excluded.website, name_rule = excluded.name_rule,
  accommodation_summary = excluded.accommodation_summary,
  highlights = excluded.highlights, tags = excluded.tags, summary = excluded.summary,
  open_points = excluded.open_points, updated_at = now();

insert into ops_supplier_contacts (id, supplier_id, name, role, email, phone, sort_order)
values ('29000000-0000-0000-0000-000000990001', '29000000-0000-0000-0000-000000000000', 'Caterina Sacone',
        'Public Relations and Marketing Manager',
        'caterina.sacone@fourseasons.com', '+39 335 795 2689', 1)
on conflict (id) do update set email = excluded.email, phone = excluded.phone;

insert into ops_migrations (id) values ('0051-four-seasons-firenze-e-danieli') on conflict (id) do nothing;
