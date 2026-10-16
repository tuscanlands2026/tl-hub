-- =====================================================================
-- 0081 · DANIELLE (TL-055-26): FRASCATI NUM CARD SÓ + TEXTO DOS TERMOS
--
-- Ela pediu (out/26): o Frascati é UM card, com a opção 1 e a opção 2
-- dentro (não quebrado em dois). A 0080 tinha quebrado em duas linhas; aqui
-- volta a ser UMA linha, com as duas opções como UNIDADES que se excluem —
-- o código novo (choice_group + unidades) faz "escolher uma ou outra"
-- dentro do mesmo card. Sobe junto do index.html deste PR.
--
-- E nos TERMOS: tira o "For any tour or itinerary involving entrance
-- tickets," da frente da forma de pagamento — vale para esta proposta,
-- direto: 35% de sinal e o saldo até 45 dias antes.
--
-- A linha "...with a private cooking class" (a opção com cooking, da 0080)
-- vira de volta a linha única do Frascati, com as duas opções. A linha
-- "...visit, tasting & lunch" (a segunda, da 0080) sai.
--
-- Miro por proposal_id + título; guardado: a consolidação só roda se as
-- duas linhas da 0080 ainda estiverem como ela as deixou (sem resposta do
-- cliente). Rodar depois da 0080.
--
-- Seção 7: ops_proposal_items (update + delete guardados), ops_proposals
-- (update guardado nos termos), ops_migrations (insert). Sem
-- drop/truncate. Nenhuma tabela do CRM.
-- =====================================================================

-- Proposta: f1d3d719-5142-43e7-9359-e2b7249a25d6

-- ---------------------------------------------------------------------
-- 1 · FRASCATI · volta a ser UM card, com as duas opções como unidades
--     que se excluem (choice_group continua, agora sinalizando a escolha
--     DENTRO do card).
-- ---------------------------------------------------------------------
update ops_proposal_items set
  title = E'Roman Countryside · Frascati Culinary Day',
  title_en = E'Roman Countryside · Frascati Culinary Day',
  price = 0,
  details_en = E'The day begins at your hotel in Rome, where your private driver is waiting for the drive into the hills of the Castelli Romani — about an hour south, to the historic wine region of Frascati. Volcanic terroir, ancient estates and an intimate glimpse of rural Italian life. Your driver stays with you throughout, for an unhurried return to Rome by mid-afternoon. You choose how to spend the day:',
  included_en = E'Private driver from your Rome hotel, at your disposal throughout (about 6 hours). Suggested start: 9:30 am (to be confirmed).',
  units = E'[{"key":"o1","label":"With a private cooking class · private driver, a hands-on cooking class, a winery visit, a guided tasting and lunch","label_en":"With a private cooking class · private driver, a hands-on cooking class, a winery visit, a guided tasting and lunch","price":1999,"optional":true},{"key":"o2","label":"Visit, tasting and lunch · private driver, a winery visit, a guided tasting and a regional lunch","label_en":"Visit, tasting and lunch · private driver, a winery visit, a guided tasting and a regional lunch","price":1560,"optional":true}]'::jsonb
 where proposal_id = 'f1d3d719-5142-43e7-9359-e2b7249a25d6'
   and 'Roman Countryside · Frascati with a private cooking class' in (coalesce(title,''), coalesce(title_en,''))
   and coalesce(jsonb_array_length(units),0) = 0;

-- A segunda linha (visit, tasting & lunch) sai — vira unidade na linha única.
delete from ops_proposal_items
 where proposal_id = 'f1d3d719-5142-43e7-9359-e2b7249a25d6'
   and 'Roman Countryside · Frascati · visit, tasting & lunch' in (coalesce(title,''), coalesce(title_en,''))
   and coalesce(price,0) = 1560
   and coalesce(jsonb_array_length(units),0) = 0;

-- ---------------------------------------------------------------------
-- 2 · TERMOS · a forma de pagamento vale para esta proposta, direto.
--     Tira "For any tour or itinerary involving entrance tickets, ".
-- ---------------------------------------------------------------------
update ops_proposals set conditions = replace(conditions,
    'For any tour or itinerary involving entrance tickets, a deposit of 35% confirms the booking, and the balance is due up to 45 days before travel. Payments can be made via credit card or bank transfer (banking details provided by our team).',
    'A deposit of 35% confirms the booking, and the balance is due up to 45 days before travel. Payment can be made by credit card or bank transfer, with banking details provided by our team.')
 where id = 'f1d3d719-5142-43e7-9359-e2b7249a25d6'
   and position('For any tour or itinerary involving entrance tickets, a deposit of 35%' in coalesce(conditions,'')) > 0;
update ops_proposals set conditions_en = replace(conditions_en,
    'For any tour or itinerary involving entrance tickets, a deposit of 35% confirms the booking, and the balance is due up to 45 days before travel. Payments can be made via credit card or bank transfer (banking details provided by our team).',
    'A deposit of 35% confirms the booking, and the balance is due up to 45 days before travel. Payment can be made by credit card or bank transfer, with banking details provided by our team.')
 where id = 'f1d3d719-5142-43e7-9359-e2b7249a25d6'
   and position('For any tour or itinerary involving entrance tickets, a deposit of 35%' in coalesce(conditions_en,'')) > 0;
update ops_proposals set conditions_pt = replace(conditions_pt,
    'For any tour or itinerary involving entrance tickets, a deposit of 35% confirms the booking, and the balance is due up to 45 days before travel. Payments can be made via credit card or bank transfer (banking details provided by our team).',
    'A deposit of 35% confirms the booking, and the balance is due up to 45 days before travel. Payment can be made by credit card or bank transfer, with banking details provided by our team.')
 where id = 'f1d3d719-5142-43e7-9359-e2b7249a25d6'
   and position('For any tour or itinerary involving entrance tickets, a deposit of 35%' in coalesce(conditions_pt,'')) > 0;

insert into ops_migrations (id) values ('0081-danielle-frascati-um-card-e-termos') on conflict (id) do nothing;
