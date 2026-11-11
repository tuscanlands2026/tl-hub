-- =====================================================================
-- 0083 · TL-050-26 · A QUOTE EM TABELA DA RACHEL (Steven e Tiffany)
--
-- Pedido dela, novembro/26: a venda foi aprovada fora do hub (proposta
-- feita à mão, "Rachel TL 050-26 v2.pdf"), e agora precisa virar a
-- quote em tabela para o cliente marcar o que aprova e, depois, a order
-- com os dados dos viajantes. "A soma tem que bater."
--
-- POR QUE A v2 E NÃO A v1 DO DRIVE: o CRM tem a TL-050-26 como Aprovada,
-- € 11.065. A v2 soma € 8.465 com o tour de Florença de 4 horas, e o
-- shopping (que vai na order separada, a "1.2") são € 1.300 × 2 = 2.600.
-- 8.465 + 2.600 = 11.065. Ela confirmou: "é a mesma proposta".
--
-- O QUE JÁ EXISTIA NO HUB E NÃO É TOCADO: a oportunidade
-- a684e4bd-… (crm_code gravado como "TL050-26", sem o hífen), o briefing
-- dela e uma proposta v1 em "apresentada" com uma linha só (transfer de
-- € 210), nunca enviada nem respondida. Nada disso muda aqui.
--
-- O QUE ESTE ARQUIVO FAZ: só INSERE.
--   · uma proposta nova (version 2, layout tabela, inglês) na mesma
--     oportunidade;
--   · as onze linhas, divididas por dia, com os valores do PDF;
--   · o registro em ops_migrations.
-- Nenhum update, nenhum delete. Rodar de novo não duplica (ids fixos,
-- on conflict do nothing).
--
-- TUDO ENTRA COMO ESCOLHA DO CLIENTE (optional = true): ele monta.
-- Os dois tours de Florença (4h com degustação · 3h sem) são um
-- conjunto (choice_group): marcar um desmarca o outro. O underground do
-- Coliseu é extra da linha do Coliseu (+ € 50). O concierge vai como
-- linha própria: € 80 por dia × 6 dias (4 a 9 de outubro) = € 480.
--
-- Condições: o texto da v2, palavra por palavra (35% de sinal, saldo até
-- 50 dias antes). NÃO é o padrão da casa, que hoje diz 45 dias e 100%
-- para ingresso — esta venda foi aprovada com o texto do PDF.
--
-- CONFERÊNCIA DA SEÇÃO 7: toca ops_proposals (insert), ops_proposal_items
-- (insert) e ops_migrations (insert). Nenhuma tabela do CRM lida, escrita
-- ou citada. Nenhuma service_role key.
-- =====================================================================

insert into ops_proposals
  (id, opportunity_id, version, title, lang, layout, pax_summary, travel_window,
   show_prices, intro, sections, conditions_en, terms_url, confirm_mode, internal_notes)
values ('50262600-0000-0000-0000-0000000000b2', 'a684e4bd-cccc-42dd-a239-b2da1fbe411d', 2,
  'Steven and Tiffany · Tenth Anniversary', 'en', 'tabela', '2 adults', 'October 4 to 9, 2027',
  true,
  E'Six days in Italy for your tenth anniversary: Florence and the Chianti hills first, then Rome.\nPlease select every service you approve. The total updates with each selection.',
  '[{"key":"d4","title":"October 4 · Arrival in Rome, on to Florence","title_en":"October 4 · Arrival in Rome, on to Florence","note":"","note_en":""},
    {"key":"d5","title":"October 5 · Florence","title_en":"October 5 · Florence","note":"","note_en":"Choose one of the two tours."},
    {"key":"d6","title":"October 6 · Chianti","title_en":"October 6 · Chianti","note":"","note_en":""},
    {"key":"d7","title":"October 7 · Florence to Rome","title_en":"October 7 · Florence to Rome","note":"","note_en":""},
    {"key":"d8","title":"October 8 · The Vatican","title_en":"October 8 · The Vatican","note":"","note_en":""},
    {"key":"d9","title":"October 9 · Departure","title_en":"October 9 · Departure","note":"","note_en":""},
    {"key":"opt","title":"Extras and Optionals","title_en":"Extras and Optionals","note":"","note_en":"Best requested and confirmed together with the main proposal. Requests made once the trip has started, or as standalone services, are subject to our team''s availability."}]'::jsonb,
  E'**Payment terms**\nPayment is in Euros and all prices include VAT. 35% deposit at booking and balance up to 50 days before services. Payment by credit card or wire transfer (our team will send all details). Conditions valid upon availability at the moment of booking.\n\n**Terms & Conditions for this proposal**\nBy approving this proposal, the client acknowledges and agrees to the terms and conditions outlined herein (also available at the link below).\n- Reservations are only confirmed upon formalization and payment of the deposit. All experiences are subject to availability.\n- Bookings & Tickets: This proposal does not include bookings, reservations, or tickets for monuments and museums before proposal approval.\n- Operational Limits: Tuscan Lands does not provide last-minute services (after the guest''s arrival at the destination) from June to September, or during the holiday season (Christmas and New Year).\n- Weather Policy: All other tours take place rain or shine, except in cases of force majeure. In such events, we will issue a full refund if the tour cannot be rescheduled.\n- Professional Insurance: Tuscan Lands holds all professional liability insurance required by Italian law. This does not replace or include personal travel insurance; it is the traveler''s responsibility to have their own comprehensive travel policy.\n- Personal Belongings: Tuscan Lands and its partners are not responsible for the loss, theft, or damage of personal belongings during the itinerary. Travelers are responsible for their own items at all times.\n- Note (on winery visits with lunch): a visit of this kind is an immersion in the estate''s world of wine, not a restaurant setting. The menu is set rather than à la carte, composed around the ingredients of the season and chosen to sit alongside the wines made on the property, and it is served alike to everyone at the table. Allergies and intolerances are accommodated with advance notice.',
  'https://tuscanlandstravel.com/terms-conditions-tours/',
  'full',
  E'Montada da "Rachel TL 050-26 v2.pdf" (0083). CRM: Aprovada, € 11.065 = esta quote com o tour de 4h (8.465) + shopping da order 1.2 (2.600). Rachel é advisor Fora.')
on conflict (id) do nothing;

insert into ops_proposal_items
  (id, proposal_id, sort, section, kind, service_date, title, title_en, details, details_en,
   price, qty, unit_price, optional, choice_group, extras, units, photos, attachments)
values
 -- October 4 ----------------------------------------------------------
 ('50262600-0000-0000-0000-000000000101','50262600-0000-0000-0000-0000000000b2', 0,'d4','experience','Oct 4',
  'VIP airport reception · Rome Fiumicino (arrival)','VIP airport reception · Rome Fiumicino (arrival)',
  null, E'Greeting at the gate, escort through immigration, baggage assistance and porter service to the transfer.',
  390, 1, null, true, null, '[]','[]','[]','[]'),
 ('50262600-0000-0000-0000-000000000102','50262600-0000-0000-0000-0000000000b2', 1,'d4','transfer','Oct 4',
  'Private transfer Rome FCO → Four Seasons Florence, with a wine experience in Montalcino','Private transfer Rome FCO → Four Seasons Florence, with a wine experience in Montalcino',
  null, E'- Private transfer from Rome FCO to the hotel in Florence\n- Private visit to the estate, historic cellars and areas usually closed to guests\n- Three-course lunch paired with four of the estate''s wines\nFlight time to be confirmed. Travel time from FCO to Montalcino is around 2h45 to 3 hours; feasibility to be confirmed against the final flight time. In case of delay at arrival or at airport procedures, the experience duration can be reduced.',
  2175, 1, null, true, null, '[]','[]','[]','[]'),

 -- October 5 ----------------------------------------------------------
 ('50262600-0000-0000-0000-000000000103','50262600-0000-0000-0000-0000000000b2', 2,'d5','experience','Oct 5',
  'Discovery Tour of Florence · 4 hours, food tastings included','Discovery Tour of Florence · 4 hours, food tastings included',
  null, E'- Private local guide\n- Food tastings along the route\nSuggested time: 10:00 am. Duration: up to 4 hours.',
  700, 1, null, true, 'florence_tour', '[]','[]','[]','[]'),
 ('50262600-0000-0000-0000-000000000104','50262600-0000-0000-0000-0000000000b2', 3,'d5','experience','Oct 5',
  'Discovery Tour of Florence · 3 hours, no food tasting','Discovery Tour of Florence · 3 hours, no food tasting',
  null, E'- Private local guide\nDuration: up to 3 hours.',
  455, 1, null, true, 'florence_tour', '[]','[]','[]','[]'),

 -- October 6 ----------------------------------------------------------
 ('50262600-0000-0000-0000-000000000105','50262600-0000-0000-0000-0000000000b2', 4,'d6','experience','Oct 6',
  'Chianti Experience · Badia a Passignano and winery lunch','Chianti Experience · Badia a Passignano and winery lunch',
  null, E'- Private visit to Badia a Passignano, hosted by a monk of the abbey or a local guide (upon availability)\n- Lunch at a local production winery: guided cellar visit and 3-course lunch with wine pairing\n- Full day, approx. 5 to 6 hours including transfer time, in a Mercedes Sedan with an English-speaking driver',
  1350, 1, null, true, null, '[]','[]','[]','[]'),

 -- October 7 ----------------------------------------------------------
 ('50262600-0000-0000-0000-000000000106','50262600-0000-0000-0000-0000000000b2', 5,'d7','transfer','Oct 7',
  'Private transfer Florence → Rome (non-stop)','Private transfer Florence → Rome (non-stop)',
  null, E'From the hotel in Florence directly to the hotel in Rome, arrival around 1 pm.',
  1360, 1, null, true, null, '[]','[]','[]','[]'),
 ('50262600-0000-0000-0000-000000000107','50262600-0000-0000-0000-0000000000b2', 6,'d7','experience','Oct 7',
  'Private tour · Colosseum with arena, Roman Forum and Palatine Hill','Private tour · Colosseum with arena, Roman Forum and Palatine Hill',
  null, E'- Tickets to the Colosseum (with arena) and private local guide\n- One-way transfer from the hotel\nSuggested time: 2:30 pm. Duration: up to 4 hours.',
  895, 1, null, true, null,
  '[{"key":"underground","label_pt":"Upgrade para o underground (confirmado 25 dias antes)","label_en":"Upgrade to the underground (to be confirmed 25 days before the tour)","price":50}]',
  '[]','[]','[]'),

 -- October 8 ----------------------------------------------------------
 ('50262600-0000-0000-0000-000000000108','50262600-0000-0000-0000-0000000000b2', 7,'d8','experience','Oct 8',
  'Private Vatican Breakfast Tour (early access)','Private Vatican Breakfast Tour (early access)',
  null, E'- American breakfast at the bistro in the Cortile della Pigna\n- Private guide through the museums on one of the first time slots, to the Sistine Chapel',
  980, 1, null, true, null, '[]','[]','[]','[]'),

 -- October 9 ----------------------------------------------------------
 ('50262600-0000-0000-0000-000000000109','50262600-0000-0000-0000-0000000000b2', 8,'d9','transfer','Oct 9',
  'Private transfer St. Regis Rome → Rome FCO','Private transfer St. Regis Rome → Rome FCO',
  null, null,
  225, 1, null, true, null, '[]','[]','[]','[]'),
 ('50262600-0000-0000-0000-000000000110','50262600-0000-0000-0000-0000000000b2', 9,'d9','experience','Oct 9',
  'VIP airport reception · Rome Fiumicino (departure)','VIP airport reception · Rome Fiumicino (departure)',
  null, E'Greeting at the transportation drop-off zone, baggage and check-in assistance, escort through immigration and to the boarding gate. Complimentary access to the Premium Private Lounge.',
  390, 1, null, true, null, '[]','[]','[]','[]'),

 -- Extras and Optionals ----------------------------------------------
 ('50262600-0000-0000-0000-000000000111','50262600-0000-0000-0000-0000000000b2',10,'opt','extra','Oct 4 to 9',
  'Concierge Service · dining schedule','Concierge Service · dining schedule',
  null, E'Dedicated management of the dining schedule, including all bookings and reconfirmations to help secure seating and availability.',
  480, 6, 80, true, null, '[]','[]','[]','[]')
on conflict (id) do nothing;

insert into ops_migrations (id) values ('0083-tl050-quote-rachel') on conflict (id) do nothing;
