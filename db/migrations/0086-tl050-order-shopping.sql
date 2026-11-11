-- =====================================================================
-- 0086 · TL-050-26 · ORDER 1.2 · O SHOPPING DE ROMA, SEPARADO
--
-- Instrução dela, 11/11/26: a experiência de shopping ("Shopping
-- Experience.pdf" da pasta TL 050) é surpresa para ela (Tiffany) e vai
-- numa order separada, fora da quote da 1.1. "Eventuais adicionais de
-- hora serão faturados ao cliente ao final da experiência" — e o
-- cliente tem de declarar que sabe disso.
--
-- ORDER DIRETA, e não quote: é um serviço só, já aprovado (CRM: TL-050-26
-- Aprovada, € 11.065 = 8.465 da 1.1 + 2.600 daqui). Sem opportunity_id de
-- propósito: o gatilho tl_guard_order recusa order ligada a oportunidade
-- sem proposta aceita, e a 1.1 ainda não foi respondida. Fica pelo
-- opportunity_code, como as orders antigas. order_ref "TL050-26.2" segue a
-- grafia gravada na oportunidade, que é a que a 1.1 vai herdar (.1).
--
-- VALOR: € 1.300 por pessoa × 2 = € 2.600, como no PDF ("Price per
-- person") e como fecha a conta do CRM. Hora adicional € 255, NÃO cobrada
-- agora: vai no texto da linha e num aceite OBRIGATÓRIO no checkout
-- (campo checkbox required — o banco recusa o envio sem ele).
--
-- CHECKOUT: contato ligado; viajantes, nascimento e aceite de bagagem
-- desligados (os dados dos dois vêm na order 1.1, e aqui não há
-- transporte). Observações ligadas.
--
-- Só INSERE. Nada existente é tocado.
-- CONFERÊNCIA DA SEÇÃO 7: ops_orders, ops_order_items, ops_order_payments,
-- ops_order_fields (insert) e ops_migrations. Nenhuma tabela do CRM.
-- =====================================================================

insert into ops_orders
  (id, opportunity_code, order_ref, lang, status, agency, final_client, pax_summary,
   travel_window, intro, terms_url, payment_note, checkout_config, internal_notes)
values ('50262600-0000-0000-0000-0000000000c2', 'TL050-26', 'TL050-26.2', 'en', 'draft',
  'Rachel Gutner Silverstein', 'Steven and Tiffany', '2 guests', 'Rome · October 2027',
  E'Private Shoes and Handbags Shopping in Rome: a private Made in Italy experience, built around her preferences.\nThis service is kept separate from the main itinerary.',
  'https://tuscanlandstravel.com/terms-conditions-tours/',
  E'Payment is in Euros and all prices include VAT. 35% deposit at booking and balance up to 50 days before services. Payment by credit card or wire transfer (our team will send all details).',
  '{"lead":"blank","travellers":"off","travellers_count":2,"passport_names":false,"dob":"off","ack_vehicle":false,"remarks":true,"prefill":{}}'::jsonb,
  E'Order 1.2 da TL-050-26 (0086). Surpresa para a Tiffany: não mandar junto com a 1.1. Hora adicional € 255, faturada ao fim da experiência.')
on conflict (id) do nothing;

insert into ops_order_items (id, order_id, sort, service_date, title, details, price, supplier)
values ('50262600-0000-0000-0000-000000000201', '50262600-0000-0000-0000-0000000000c2', 0,
  'Rome · day to be confirmed',
  'Private Shoes and Handbags Shopping, Rome · up to 3 hours',
  E'- Discovery and style research: short questionnaire and photos, selection prepared by a personal stylist\n- Personalized planning: private mood board shared with you first, pieces set aside at the boutiques\n- Private shopping tour of up to 3 hours: Palazzo Fendi, Ferragamo and Bottega Veneta\n- Private fitting room, champagne reception with gourmet bites, one-to-one styling, English-speaking interpreter\n€ 1,300 per person × 2.\nAdditional hour: € 255, charged at the end of the experience if the time is exceeded.\nPrivate driver not included (can be quoted on request).',
  2600, null)
on conflict (id) do nothing;

insert into ops_order_payments (id, order_id, sort, label, due_date, amount)
values
 ('50262600-0000-0000-0000-000000000211','50262600-0000-0000-0000-0000000000c2',0,'Deposit 35%','At booking',910),
 ('50262600-0000-0000-0000-000000000212','50262600-0000-0000-0000-0000000000c2',1,'Balance','Up to 50 days before services',1690)
on conflict (id) do nothing;

insert into ops_order_fields
  (id, order_id, sort, group_key, field_key, label_pt, label_en, input_type, required, mode)
values
 ('50262600-0000-0000-0000-000000000221','50262600-0000-0000-0000-0000000000c2',0,'general','extra_hours',
  'Estou ciente de que a experiência inclui até 3 horas e de que cada hora adicional é cobrada a € 255, faturada ao final da experiência.',
  'I am aware that the experience includes up to 3 hours, and that any additional hour is charged at € 255, billed at the end of the experience.',
  'checkbox', true, 'blank'),
 ('50262600-0000-0000-0000-000000000222','50262600-0000-0000-0000-0000000000c2',1,'general','preferred_day',
  'Dia e horário de preferência em Roma',
  'Preferred day and time in Rome',
  'text', false, 'blank')
on conflict (id) do nothing;

insert into ops_migrations (id) values ('0086-tl050-order-shopping') on conflict (id) do nothing;
