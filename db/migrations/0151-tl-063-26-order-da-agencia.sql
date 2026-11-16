-- =====================================================================
-- 0151 · TL-063-26: A PARTE DA AGÊNCIA VIRA SERVICE CONFIRMATION
--
-- Instrução dela, 16/11/26: "a proposta net não está boa, tem que ser no
-- mesmo formato da service confirmation, porque como vai pra agência, ela
-- mesma já manda os dados na aprovação. Então copia o formato, dá a opção
-- da escolha e depois pede nome completo e data de nascimento dos
-- viajantes [e o] aceite dos termos e condições."
--
-- É o desenho da TL-050-26 (0087/0088): caixinha do checkout com preço,
-- que soma no total e vira linha da order ao confirmar. Aqui não há
-- serviço fixo — o quarto e a experiência são escolha da agência —, e por
-- isso a página ganhou, no index.html, o caso "order sem serviço fixo":
-- sem tabela vazia, a lista de escolha se chama "Serviços", e a tela não
-- envia sem nenhum serviço marcado.
--
--   · Deluxe Plus € 1.260 e Superior € 1.728 (2 noites), caça às trufas
--     € 680 (2 × € 340): os valores NET da 0149;
--   · viajantes: 2, nome como no passaporte e data de nascimento, os dois
--     obrigatórios. Sem bloco de contato, sem aceite de veículo, sem
--     observações: ela pediu só isso;
--   · termos: os da casa (TERMS) falam de tour e transfer, então vale o
--     desenho da 0139 — terms_house = false e os termos desta proposta no
--     lugar, palavra por palavra como na 0150. A forma de pagamento vai em
--     payment_note, embaixo do total;
--   · order_ref sem sufixo (0135): TL-063-26. opportunity_id fica nulo,
--     como na TL-053-26: ligar exige proposta aceita.
--
-- A apresentação (#/quote/…) continua sendo o que vai ao casal. O link
-- #/valores/… da proposta net deixa de ser o que se manda à agência; ele
-- continua de pé, sem resposta.
--
-- Só insert: a order e os três campos. Roda uma vez.
-- =====================================================================

insert into ops_orders
  (id, opportunity_code, order_ref, lang, status, agency, agency_contact, final_client,
   pax_summary, travel_window, intro, payment_note, terms_house, terms_extra,
   checkout_config, internal_notes)
values ('e0630000-0000-0000-0000-0000000000c1', 'TL-063-26', 'TL-063-26', 'pt', 'draft',
  'Touristique', 'Bruno', 'Leo e Bruno',
  '2 adultos', '6 a 8 de maio de 2027',
  $i$Valores NET para a agência.
Selecione os serviços aprovados, informe o nome completo e a data de nascimento dos viajantes e confirme o aceite dos termos e condições.$i$,
  $p$Os valores estão em euros e já incluem IVA.
Sinal de 40% na confirmação e saldo até 45 dias antes da viagem. Para valores abaixo de € 1.000, o pagamento é integral na confirmação.
Transferência bancária internacional ou Wise, sem taxas adicionais.
Cartão de crédito ou Pix, com acréscimo de 3% sobre o valor final. O cartão pode ser pago pela Stripe ou pelo PayPal, e o Pix pela Stripe.
O pagamento é sempre em euros, com a conversão feita no momento em que ele acontece. Por ser uma transação internacional, taxas como o IOF ficam por conta do cliente.
A proforma para pagamento segue depois da confirmação.$p$,
  false,
  $t$Ao confirmar, a agência declara estar de acordo com os termos e condições descritos aqui.
**Disponibilidade e valores:** todos os serviços estão sujeitos à disponibilidade, e os valores podem ser alterados sem aviso prévio até a confirmação da reserva. Esta confirmação não bloqueia nem reserva nenhum serviço antes do pagamento.
**Confirmação:** a reserva é feita e confirmada depois desta aprovação e do pagamento do sinal.
**Hospedagem:** tarifa flexível, com café da manhã incluído.
**Clima:** as experiências acontecem com sol ou chuva, salvo em casos de força maior. Se o mau tempo impedir a experiência e não houver como remarcar, o valor do serviço é devolvido integralmente à agência.
**Pedidos de última hora:** de junho a setembro, e nas festas de fim de ano (Natal e Ano-Novo), a Tuscan Lands Travel não aceita novos pedidos depois que o cliente já chegou ao destino.
**Seguro:** a Tuscan Lands Travel tem todos os seguros de responsabilidade profissional exigidos pela lei italiana. Eles não substituem o seguro-viagem pessoal, que cada viajante deve ter.
**Objetos pessoais:** a Tuscan Lands Travel e seus parceiros não se responsabilizam por perda, roubo ou dano de objetos pessoais durante os serviços.$t$,
  '{"lead":"off","travellers":"blank","travellers_count":2,"passport_names":true,"dob":"required","ack_vehicle":false,"remarks":false,"prefill":{}}'::jsonb,
  'Parte da agência da TL-063-26 (0151), no lugar do link de valores da proposta net. Valores NET. Caça às trufas: Castello Monterinaldi (almoço na Villa Pesanella); hotel e degustação: Borgo Vescine.')
on conflict (id) do nothing;

insert into ops_order_fields
  (id, order_id, sort, group_key, field_key, label_pt, label_en, help_pt, input_type, required, mode, prefill_value, price, service_date)
values
 ('e0630000-0000-0000-0000-000000000c11','e0630000-0000-0000-0000-0000000000c1',0,'general','x_deluxe_plus',
  'Borgo Vescine · Deluxe Plus, 2 noites','Borgo Vescine · Deluxe Plus Room, 2 nights',
  '22 a 24 m², cama queen e um pequeno pátio privativo. Tarifa flexível, com café da manhã incluído.',
  'checkbox',false,'blank',null,1260,'6 a 8 de maio'),
 ('e0630000-0000-0000-0000-000000000c12','e0630000-0000-0000-0000-0000000000c1',1,'general','x_superior',
  'Borgo Vescine · Superior, 2 noites','Borgo Vescine · Superior Room, 2 nights',
  'Cerca de 35 m², cama king e vista para as colinas ou para a praça do borgo. Tarifa flexível, com café da manhã incluído.',
  'checkbox',false,'blank',null,1728,'6 a 8 de maio'),
 ('e0630000-0000-0000-0000-000000000c13','e0630000-0000-0000-0000-0000000000c1',2,'general','x_trufas',
  'Caça às trufas no Chianti, com almoço, e degustação de vinhos no Borgo Vescine · 2 pessoas','Truffle hunting in Chianti, with lunch, and wine tasting at Borgo Vescine · 2 guests',
  'Data a definir, de segunda a sexta-feira. Saída às 10h, cerca de 4 horas. Inclui visita à adega histórica e almoço com trufa e vinhos da propriedade; à tarde, degustação no Borgo Vescine.',
  'checkbox',false,'blank',null,680,'A definir')
on conflict (id) do nothing;

insert into ops_migrations (id) values ('0151-tl-063-26-order-da-agencia') on conflict (id) do nothing;
