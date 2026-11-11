-- =====================================================================
-- 0088 · TL-050-26 · ORDER 1.1 — SERVIÇOS APROVADOS, EXTRAS À ESCOLHA,
--        E OS DADOS DOS VIAJANTES NA MESMA PÁGINA
--
-- Instrução dela, 11/11/26, revisando a quote da 0083: "ele tá aprovando
-- os dois serviços ... vamos colocar como opção só os extras". Os
-- serviços entram fechados; à escolha ficam o pick-up do hotel no
-- Coliseu e no Vaticano (€ 80 cada), o underground (€ 50) e o concierge.
-- E na mesma aprovação vêm nome como no passaporte, nascimento, alergias
-- e voos. Precisa da 0087 (extra com preço na order).
--
-- O que ela decidiu nesta revisão:
--   · dia 4 e dia 9 "tudo junto": uma linha por dia, com as duas partes
--     descritas dentro;
--   · Florença: só o tour de 4 horas — a opção de 3 horas sai;
--   · Coliseu: o "one-way transfer from the hotel" deixa de ser incluso
--     e vira extra de € 80, como no Vaticano;
--   · concierge é contratado ANTES da viagem, e as reservas dependem de
--     disponibilidade;
--   · atraso que não depende da TL (voo, por exemplo) não estende a
--     experiência: ela termina no horário previsto. Vai num aceite
--     obrigatório até entrar nos termos gerais;
--   · hotéis: Four Seasons Hotel Firenze e The St. Regis Rome;
--   · agência: Curated Travel by RGS (advisor Rachel Gutner Silverstein).
--
-- Sem parcelas gravadas: o total depende dos extras que ele marcar, e
-- parcela fixa ficaria errada. A forma de pagamento vai no texto, e a
-- proforma sai depois da confirmação, com o número certo.
--
-- MEXE EM LINHA QUE JÁ EXISTE, por instrução dela ("você tem que pôr o
-- nome da agência"), e só onde estava vazio ou com o nome da pessoa:
--   · ops_opportunities TL050-26: agency e agency_contact, só se agency
--     estiver vazia;
--   · ops_orders 1.2 (0086): agency vira a agência e o nome dela vai para
--     agency_contact, só se ainda estiver como a 0086 gravou.
-- O resto é INSERÇÃO. A quote da 0083 não é tocada (nunca foi enviada nem
-- respondida) e deixa de ser o link a mandar.
--
-- CONFERÊNCIA DA SEÇÃO 7: ops_opportunities (update 1 linha, guardado),
-- ops_orders (update 1 linha guardado + insert), ops_order_items e
-- ops_order_fields (insert), ops_migrations. Nenhuma tabela do CRM.
-- =====================================================================

update ops_opportunities
   set agency = 'Curated Travel by RGS', agency_contact = 'Rachel Gutner Silverstein', updated_at = now()
 where id = 'a684e4bd-cccc-42dd-a239-b2da1fbe411d' and coalesce(agency,'') = '';

update ops_orders
   set agency = 'Curated Travel by RGS', agency_contact = 'Rachel Gutner Silverstein', updated_at = now()
 where id = '50262600-0000-0000-0000-0000000000c2' and agency = 'Rachel Gutner Silverstein';

insert into ops_orders
  (id, opportunity_code, order_ref, lang, status, agency, agency_contact, final_client,
   pax_summary, travel_window, intro, terms_url, payment_note, checkout_config, internal_notes)
values ('50262600-0000-0000-0000-0000000000c1', 'TL050-26', 'TL050-26.1', 'en', 'draft',
  'Curated Travel by RGS', 'Rachel Gutner Silverstein', 'Steven and Tiffany',
  '2 adults', 'October 4 to 9, 2027',
  E'Your tenth anniversary in Italy: Florence and the Chianti hills first, then Rome.\nThe services below are approved. Please choose any optional extras, then complete the travellers'' details and confirm.',
  'https://tuscanlandstravel.com/terms-conditions-tours/',
  E'Payment is in Euros and all prices include VAT. 35% deposit at booking and balance up to 50 days before services. Payment by credit card or wire transfer.\nA proforma invoice for payment will be sent once you confirm this order.',
  '{"lead":"blank","travellers":"blank","travellers_count":2,"passport_names":true,"dob":"required","ack_vehicle":true,"remarks":true,"prefill":{}}'::jsonb,
  E'Order 1.1 da TL-050-26 (0088): serviços aprovados da v2, extras à escolha. Substitui a quote da 0083 como link a mandar. A 1.2 (shopping) é surpresa: não mandar junto.')
on conflict (id) do nothing;

insert into ops_order_items (id, order_id, sort, service_date, title, details, price, op_tipo)
values
 ('50262600-0000-0000-0000-000000000301','50262600-0000-0000-0000-0000000000c1',0,'Oct 4',
  'Arrival · VIP reception at Rome Fiumicino and private transfer to Four Seasons Hotel Firenze, with a wine experience in Montalcino',
  E'VIP airport reception (arrival): greeting at the gate, escort through immigration, baggage assistance and porter service to the transfer.\nPrivate transfer from Rome FCO to Four Seasons Hotel Firenze, with a stop at a wine estate in Montalcino: private visit to the historic cellars and areas usually closed to guests, three-course lunch paired with four of the estate''s wines.\nTravel time from FCO to Montalcino is around 2h45 to 3 hours. The experience keeps its scheduled end time: a late arrival shortens it.',
  2565, null),
 ('50262600-0000-0000-0000-000000000302','50262600-0000-0000-0000-0000000000c1',1,'Oct 5',
  'Discovery Tour of Florence · 4 hours, food tastings included',
  E'Private local guide and food tastings along the route. Suggested time: 10:00 am.',
  700, null),
 ('50262600-0000-0000-0000-000000000303','50262600-0000-0000-0000-0000000000c1',2,'Oct 6',
  'Chianti Experience · Badia a Passignano and winery lunch',
  E'Private visit to Badia a Passignano, hosted by a monk of the abbey or a local guide (upon availability). Lunch at a local production winery: guided cellar visit and 3-course lunch with wine pairing. Full day, approx. 5 to 6 hours including transfer time, in a Mercedes Sedan with an English-speaking driver.',
  1350, null),
 ('50262600-0000-0000-0000-000000000304','50262600-0000-0000-0000-0000000000c1',3,'Oct 7',
  'Private transfer Four Seasons Hotel Firenze → The St. Regis Rome (non-stop)',
  E'Arrival in Rome around 1 pm.',
  1360, 'transfer'),
 ('50262600-0000-0000-0000-000000000305','50262600-0000-0000-0000-0000000000c1',4,'Oct 7',
  'Private tour · Colosseum with arena, Roman Forum and Palatine Hill',
  E'Tickets to the Colosseum (with arena) and private local guide. Suggested time: 2:30 pm. Duration: up to 4 hours.',
  895, null),
 ('50262600-0000-0000-0000-000000000306','50262600-0000-0000-0000-0000000000c1',5,'Oct 8',
  'Private Vatican Breakfast Tour (early access)',
  E'American breakfast at the bistro in the Cortile della Pigna, then a private guide through the museums on one of the first time slots, to the Sistine Chapel.',
  980, null),
 ('50262600-0000-0000-0000-000000000307','50262600-0000-0000-0000-0000000000c1',6,'Oct 9',
  'Departure · private transfer The St. Regis Rome → Rome Fiumicino, with VIP departure reception',
  E'Private transfer from the hotel to FCO.\nVIP airport reception (departure): greeting at the drop-off zone, baggage and check-in assistance, escort through immigration and to the boarding gate. Complimentary access to the Premium Private Lounge.',
  615, null)
on conflict (id) do nothing;

insert into ops_order_fields
  (id, order_id, sort, group_key, field_key, label_pt, label_en, input_type, required, mode, prefill_value, price, service_date)
values
 -- extras (caixinha com preço: soma no total e vira linha ao confirmar)
 ('50262600-0000-0000-0000-000000000311','50262600-0000-0000-0000-0000000000c1',0,'general','x_pickup_colosseum',
  'Pick-up no hotel para o tour do Coliseu (ida)','Hotel pick-up for the Colosseum tour (one way)','checkbox',false,'blank',null,80,'Oct 7'),
 ('50262600-0000-0000-0000-000000000312','50262600-0000-0000-0000-0000000000c1',1,'general','x_underground',
  'Upgrade para o underground do Coliseu (confirmado 25 dias antes)','Colosseum underground upgrade (to be confirmed 25 days before the tour)','checkbox',false,'blank',null,50,'Oct 7'),
 ('50262600-0000-0000-0000-000000000313','50262600-0000-0000-0000-0000000000c1',2,'general','x_pickup_vatican',
  'Pick-up no hotel para o Vaticano (ida)','Hotel pick-up for the Vatican tour (one way)','checkbox',false,'blank',null,80,'Oct 8'),
 ('50262600-0000-0000-0000-000000000314','50262600-0000-0000-0000-0000000000c1',3,'general','x_concierge',
  'Concierge: seleção de restaurantes e reservas, contratado antes da viagem (sujeito a disponibilidade) · 6 dias × € 80',
  'Concierge Service: a curated selection of places for the table, with the reservations handled for you. Booked before you travel; reservations subject to availability · 6 days × € 80','checkbox',false,'blank',null,480,'Oct 4 to 9'),
 -- hotéis, já preenchidos para conferir
 ('50262600-0000-0000-0000-000000000321','50262600-0000-0000-0000-0000000000c1',4,'hotel','hotel_florence',
  'Hotel em Florença','Hotel in Florence','text',true,'prefilled','Four Seasons Hotel Firenze',null,null),
 ('50262600-0000-0000-0000-000000000322','50262600-0000-0000-0000-0000000000c1',5,'hotel','hotel_rome',
  'Hotel em Roma','Hotel in Rome','text',true,'prefilled','The St. Regis Rome',null,null),
 -- saúde e voos
 ('50262600-0000-0000-0000-000000000331','50262600-0000-0000-0000-0000000000c1',6,'health','diet',
  'Algum dos viajantes possui restrições alimentares ou alergias? Se sim, informe o nome e a restrição',
  'Do any of the travellers have dietary restrictions or allergies? If so, please give the name and the restriction','textarea',true,'blank',null,null,null),
 ('50262600-0000-0000-0000-000000000332','50262600-0000-0000-0000-0000000000c1',7,'transfer','flight_in',
  'Voo de chegada — data, número, companhia aérea, horário e aeroporto',
  'Arrival flight — date, number, airline, time and airport','textarea',true,'blank',null,null,null),
 ('50262600-0000-0000-0000-000000000333','50262600-0000-0000-0000-0000000000c1',8,'transfer','flight_out',
  'Voo de retorno — data, número, companhia aérea e horário',
  'Departure flight — date, number, airline and time','textarea',true,'blank',null,null,null),
 -- aceites
 ('50262600-0000-0000-0000-000000000341','50262600-0000-0000-0000-0000000000c1',9,'general','ack_delay',
  'Estou ciente de que as experiências terminam no horário previsto: um atraso que não depende da Tuscan Lands (por exemplo, um voo atrasado) reduz a experiência, e não a estende.',
  'I understand that each experience ends at its scheduled time: a delay outside Tuscan Lands'' control (for example, a late flight) shortens the experience and does not extend it.','checkbox',true,'blank',null,null,null),
 ('50262600-0000-0000-0000-000000000342','50262600-0000-0000-0000-0000000000c1',10,'general','ack_extra_time',
  'Estou ciente de que tempo além do incluído (horas extras de motorista, guia ou experiência) é cobrado ao final do serviço.',
  'I understand that any time beyond what is included (additional hours of a driver, guide or experience) is charged at the end of the service.','checkbox',true,'blank',null,null,null)
on conflict (id) do nothing;

insert into ops_migrations (id) values ('0088-tl050-order-1-1') on conflict (id) do nothing;
