-- =====================================================================
-- 0092 · TL-050-26 · ORDER 1.2 · SHOPPING PARA UMA PESSOA, DIA 8
--
-- Instrução dela, 11/11/26: "o shopping é para 1 pessoa · dia 8 outubro".
-- A 0086 tinha gravado € 1.300 × 2 = € 2.600 (o PDF diz "price per
-- person" e a soma do CRM batia com dois). Agora: uma pessoa, € 1.300,
-- em 8 de outubro de 2027.
--
-- MEXE EM LINHA QUE JÁ EXISTE, por essa instrução, só na order 1.2 —
-- rascunho, sem confirmação (conferido antes). Cada update é guardado
-- pelo valor antigo, para não passar por cima de uma correção dela:
--   · cabeçalho: 1 guest, Rome · October 8, 2027;
--   · linha: data Oct 8, valor 1.300, "× 2" sai do texto;
--   · parcelas: sinal 35% = 455, saldo = 845 (soma 1.300).
--
-- ATENÇÃO para o CRM: a TL-050-26 consta lá como € 11.065, que contava o
-- shopping duas vezes. Com uma pessoa a venda fica € 9.765 + os extras
-- que ele marcar na 1.1. O hub não escreve no CRM.
--
-- CONFERÊNCIA DA SEÇÃO 7: ops_orders, ops_order_items, ops_order_payments
-- (update guardado, uma order), ops_migrations. Nenhuma tabela do CRM.
-- =====================================================================

update ops_orders
   set pax_summary = '1 guest', travel_window = 'Rome · October 8, 2027', updated_at = now()
 where id = '50262600-0000-0000-0000-0000000000c2' and pax_summary = '2 guests'
   and not exists (select 1 from ops_order_confirmations c where c.order_id = '50262600-0000-0000-0000-0000000000c2');

update ops_order_items
   set service_date = 'Oct 8', price = 1300,
       details = replace(details, E'€ 1,300 per person × 2.\n', '')
 where id = '50262600-0000-0000-0000-000000000201' and price = 2600;

update ops_order_payments set amount = 455
 where id = '50262600-0000-0000-0000-000000000211' and amount = 910;
update ops_order_payments set amount = 845
 where id = '50262600-0000-0000-0000-000000000212' and amount = 1690;

insert into ops_migrations (id) values ('0092-tl050-shopping-uma-pessoa') on conflict (id) do nothing;
