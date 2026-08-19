-- =====================================================================
-- EXEMPLO · a proposta TL-039-26 carregada como quote
--
-- Rodar DEPOIS de tl-hub-quote.sql. Só insere; não altera nem apaga
-- nada. Os UUIDs são fixos e o "on conflict do nothing" faz com que
-- rodar duas vezes não duplique.
--
-- Conferência da seção 7: toca apenas ops_opportunities, ops_briefings,
-- ops_proposals e ops_proposal_items. Nenhuma tabela do CRM, nenhum
-- delete, nenhum comando que percorra o schema.
--
-- ---------------------------------------------------------------------
-- DUAS COISAS QUE EU DECIDI E VOCÊ PRECISA CONFERIR
--
-- 1. Os adicionais de transfer estavam em percentual na sua proposta
--    ("upgrade para van +15%", "adicional 22h–5h +20%"). O modelo só
--    guarda valor fixo, então converti sobre o preço de cada trecho:
--    van 15% de 990 = 149; noturno 20% de 990 = 198; van 15% de 460 =
--    69; van 15% de 1290 = 194. Confira os arredondamentos.
--
-- 2. Na Opção 2 não consegui ler no PDF o preço do aluguel do carro —
--    ele não aparece na tabela. Deixei a linha com valor zero e um
--    aviso no texto, para você preencher antes de mandar.
-- =====================================================================

insert into ops_opportunities (id, crm_code, title, lang, agency, final_client, internal_notes)
values ('39262600-0000-0000-0000-000000000001', 'TL-039-26',
        'Camila · Toscana e Umbria · mai 2027', 'pt', 'Refina Travel', 'Camila',
        'Casal, casamento na Umbria em 5 de maio.')
on conflict (id) do nothing;

insert into ops_briefings (opportunity_id, travel_window, pax_summary, scope, constraints_note, source)
values ('39262600-0000-0000-0000-000000000001', '4 – 9 mai 2027', '2 adultos',
  'Casamento na Umbria em 5 de maio. Chegada e saída por Roma Fiumicino, com duas noites na '
  'Umbria e três em Florença. Dois desenhos possíveis: serviço privativo em todos os trechos, '
  'ou privativo com aluguel de carro no miolo da viagem.',
  'Data do casamento é fixa: 5 de maio, com motorista à disposição no dia. Horários de voo a confirmar.',
  'Refina Travel')
on conflict (opportunity_id) do nothing;

-- ------------------------------------------------- OPÇÃO 1 · v1
insert into ops_proposals
  (id, opportunity_id, version, title, lang, pax_summary, travel_window, show_prices, intro, payment_note)
values ('39262600-0000-0000-0000-0000000000a1','39262600-0000-0000-0000-000000000001', 1,
  'Opção 1 · serviço privativo em todos os trechos', 'pt', '2 adultos', '4 – 9 mai 2027', true,
  E'O começo de maio traz dias quentes e ensolarados, com noites amenas. A paisagem está no auge, '
  'verde e florida, e as manhãs e tardes ficam ideais para experiências ao ar livre e para viajar '
  'pelas estradas da Umbria e da Toscana. O pôr do sol por volta das 20h30 é ideal para um aperitivo ao aberto.',
  E'PAGAMENTO\nEm euros, com câmbio da data de cada pagamento, por cartão de débito multimoeda, '
  'crédito internacional ou transferência bancária. Eventuais taxas como o IOF são de responsabilidade '
  'do cliente. Nossa equipe fornece o link de pagamento com as instruções.\n\n'
  'Transferência bancária ou cartão à vista: 30% de sinal e o restante em até 2 parcelas iguais, '
  'a última até 01/12/2026. Ou Pix à vista, com repasse de taxas e conversão em reais no ato.\n\n'
  'NÃO INCLUSOS\nReservas de restaurantes; aluguel de carros; seguro viagem; passeios e experiências; '
  'refeições não mencionadas; impostos hoteleiros e city tax, pagos no check-in.\n\n'
  'Validade destas condições: 01 de setembro, ou enquanto houver disponibilidade das tarifas. '
  'Esta proposta não contempla pré-bloqueios ou reservas.')
on conflict (id) do nothing;

insert into ops_proposal_items
  (proposal_id, sort, service_date, title, details, price, optional, choice_group, extras)
values
 ('39262600-0000-0000-0000-0000000000a1',0,'4 – 6 mai','Borghi dell''Eremo · Umbria',
  E'Quarto superior, 35 m², café da manhã, tarifa flexível.\nPropriedade rural adults only entre a Umbria e a Toscana, a poucos minutos de Cibottola.',
  706, false, 'Hospedagem na Umbria', '[]'),
 ('39262600-0000-0000-0000-0000000000a1',1,'4 – 6 mai','Relais Villa Monte Solare · Umbria',
  E'Quarto prestige, 30 m², café da manhã, tarifa flexível.\nResidência nobre do fim do século XV em Panicale, entre oliveiras e vinhedos.',
  697, false, 'Hospedagem na Umbria', '[]'),
 ('39262600-0000-0000-0000-0000000000a1',2,'6 – 9 mai','Hotel Calimala · Florença',
  E'Deluxe room, 23 m², café da manhã, tarifa flexível.\nPalazzo do século XIX sobre o Mercato Nuovo, a poucos minutos da Ponte Vecchio.',
  2344, false, 'Hospedagem em Florença', '[]'),
 ('39262600-0000-0000-0000-0000000000a1',3,'6 – 9 mai','Tivoli Palazzo Gaddi · Florença',
  E'Premium Grand Room, 30 m², café da manhã, tarifa flexível.\nPalazzo do fim do século XVI a cem metros do mercato de San Lorenzo.',
  2791, false, 'Hospedagem em Florença', '[]'),
 ('39262600-0000-0000-0000-0000000000a1',4,'4 mai','Transfer Roma FCO – hotel na Umbria',
  E'Mercedes Sedan, até 2 bagagens grandes e 1 pequena, conforme legislação local.\nHorário do voo a confirmar.',
  990, false, null,
  '[{"key":"van","label_pt":"Upgrade para van (excesso de bagagem)","label_en":"Van upgrade (extra luggage)","price":149},
    {"key":"noturno","label_pt":"Adicional entre 22h e 5h","label_en":"Night surcharge 22h–5h","price":198}]'),
 ('39262600-0000-0000-0000-0000000000a1',5,'5 mai','Motorista à disposição · casamento',
  E'4 horas, Mercedes Sedan, adicional noturno já incluso.\nHora adicional, a partir de 30 minutos excedentes: € 150.',
  520, false, null, '[]'),
 ('39262600-0000-0000-0000-0000000000a1',6,'6 mai','Transfer Umbria – hotel em Florença',
  'Mercedes Sedan, até 2 bagagens grandes e 1 pequena, conforme legislação local.',
  460, false, null,
  '[{"key":"van","label_pt":"Upgrade para van (excesso de bagagem)","label_en":"Van upgrade (extra luggage)","price":69},
    {"key":"noturno","label_pt":"Adicional entre 22h e 5h","label_en":"Night surcharge 22h–5h","price":92}]'),
 ('39262600-0000-0000-0000-0000000000a1',7,'9 mai','Transfer hotel em Florença – Roma FCO',
  E'Mercedes Sedan, até 2 bagagens grandes e 1 pequena, conforme legislação local.\nHorário do voo a confirmar.',
  1290, false, null,
  '[{"key":"van","label_pt":"Upgrade para van (excesso de bagagem)","label_en":"Van upgrade (extra luggage)","price":194},
    {"key":"noturno","label_pt":"Adicional entre 22h e 5h","label_en":"Night surcharge 22h–5h","price":258}]'),
 ('39262600-0000-0000-0000-0000000000a1',8,'4 mai','Meet and Greet · chegada em Fiumicino',
  E'Recepção no gate de desembarque, acompanhamento pelo controle de documentos, assistência com a bagagem e condução até o motorista.\nInclui duas horas de acesso à sala VIP do Terminal 3 como cortesia.',
  390, true, null, '[]'),
 ('39262600-0000-0000-0000-0000000000a1',9,'9 mai','Meet and Greet · embarque para o Brasil',
  E'Recepção no ponto de desembarque dos veículos, assistência com a bagagem e no check-in, tax free, acompanhamento pelo controle de documentos até o portão de embarque.',
  390, true, null, '[]');

-- ------------------------------------------------- OPÇÃO 2 · v2
insert into ops_proposals
  (id, opportunity_id, version, title, lang, pax_summary, travel_window, show_prices, intro, payment_note)
values ('39262600-0000-0000-0000-0000000000a2','39262600-0000-0000-0000-000000000001', 2,
  'Opção 2 · serviço privativo e aluguel de carro', 'pt', '2 adultos', '4 – 9 mai 2027', true,
  E'Mesmo desenho da Opção 1, com carro alugado no miolo da viagem: o casal recebe o veículo na chegada '
  'a Fiumicino e o entrega em Florença, mantendo o serviço privativo nas pontas.',
  E'ATENÇÃO — falta o valor do aluguel do carro nesta versão. A linha está com zero.\n\n'
  'PAGAMENTO\nEm euros, com câmbio da data de cada pagamento. Serviços de aluguel de carro disponíveis '
  'somente com contratação de hospedagem.\n\n'
  'NÃO INCLUSOS\nReservas de restaurantes; combustível, pedágios e estacionamentos; seguro viagem; '
  'passeios e experiências; refeições não mencionadas; impostos hoteleiros e city tax, pagos no check-in.')
on conflict (id) do nothing;

insert into ops_proposal_items
  (proposal_id, sort, service_date, title, details, price, optional, choice_group, extras)
values
 ('39262600-0000-0000-0000-0000000000a2',0,'4 – 6 mai','Borghi dell''Eremo · Umbria',
  'Quarto superior, 35 m², café da manhã, tarifa flexível.', 706, false, 'Hospedagem na Umbria', '[]'),
 ('39262600-0000-0000-0000-0000000000a2',1,'4 – 6 mai','Relais Villa Monte Solare · Umbria',
  'Quarto prestige, 30 m², café da manhã, tarifa flexível.', 697, false, 'Hospedagem na Umbria', '[]'),
 ('39262600-0000-0000-0000-0000000000a2',2,'6 – 9 mai','Hotel Calimala · Florença',
  'Deluxe room, 23 m², café da manhã, tarifa flexível.', 2344, false, 'Hospedagem em Florença', '[]'),
 ('39262600-0000-0000-0000-0000000000a2',3,'6 – 9 mai','Tivoli Palazzo Gaddi · Florença',
  'Premium Grand Room, 30 m², café da manhã, tarifa flexível.', 2791, false, 'Hospedagem em Florença', '[]'),
 ('39262600-0000-0000-0000-0000000000a2',4,'4 mai','Recepção em Fiumicino e entrega do veículo alugado',
  E'Entrega do carro no aeroporto, no desembarque. Horário do voo a confirmar.\nPREÇO A PREENCHER.',
  0, false, null, '[]'),
 ('39262600-0000-0000-0000-0000000000a2',5,'6 mai','Entrega do veículo alugado em Florença',
  'Retirada no hotel do cliente.', 0, false, null, '[]'),
 ('39262600-0000-0000-0000-0000000000a2',6,'9 mai','Transfer hotel em Florença – Roma FCO',
  'Mercedes Sedan, até 2 bagagens grandes e 1 pequena, conforme legislação local.',
  1290, false, null,
  '[{"key":"van","label_pt":"Upgrade para van (excesso de bagagem)","label_en":"Van upgrade (extra luggage)","price":194}]'),
 ('39262600-0000-0000-0000-0000000000a2',7,'4 mai','Meet and Greet · chegada em Fiumicino',
  'Recepção no gate, acompanhamento no controle de documentos e assistência com a bagagem. Inclui duas horas de sala VIP do Terminal 3 como cortesia.',
  390, true, null, '[]'),
 ('39262600-0000-0000-0000-0000000000a2',8,'9 mai','Meet and Greet · embarque para o Brasil',
  'Assistência com bagagem e check-in, tax free, acompanhamento até o portão de embarque.',
  390, true, null, '[]');
