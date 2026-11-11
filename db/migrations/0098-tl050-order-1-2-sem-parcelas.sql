-- =====================================================================
-- 0098 · TL-050-26 · ORDER 1.2 SEM PARCELAS GRAVADAS, COMO A 1.1
--
-- Instrução dela, 11/11/26: "deixa número 1, como no outro". Com o
-- motorista como extra (0097) o total depende do que ele marcar, e as
-- parcelas fixas (455 + 845 = 1.300) deixariam de bater.
--
-- MEXE EM LINHA QUE JÁ EXISTE, por essa instrução, só na order 1.2
-- (rascunho, sem confirmação):
--   · APAGA as duas parcelas;
--   · o texto de pagamento ganha a frase da proforma, igual à 1.1 — só se
--     ainda for o texto que a 0086 gravou.
-- CONFERÊNCIA DA SEÇÃO 7: ops_order_payments (delete de 2 linhas),
-- ops_orders (update 1 linha), ops_migrations. Nenhuma tabela do CRM.
-- =====================================================================

delete from ops_order_payments
 where order_id = '50262600-0000-0000-0000-0000000000c2'
   and not exists (select 1 from ops_order_confirmations c where c.order_id = '50262600-0000-0000-0000-0000000000c2');

update ops_orders
   set payment_note = E'Payment is in Euros and all prices include VAT. 35% deposit at booking and balance up to 50 days before services. Payment by credit card or wire transfer.\nA proforma invoice for payment will be sent once you confirm this order.',
       updated_at = now()
 where id = '50262600-0000-0000-0000-0000000000c2'
   and payment_note = 'Payment is in Euros and all prices include VAT. 35% deposit at booking and balance up to 50 days before services. Payment by credit card or wire transfer (our team will send all details).'
   and not exists (select 1 from ops_order_confirmations c where c.order_id = '50262600-0000-0000-0000-0000000000c2');

insert into ops_migrations (id) values ('0098-tl050-order-1-2-sem-parcelas') on conflict (id) do nothing;
