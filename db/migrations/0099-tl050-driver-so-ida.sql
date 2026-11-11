-- =====================================================================
-- 0099 · TL-050-26 · ORDER 1.2 · O MOTORISTA É SÓ A IDA ATÉ O LOCAL
--
-- Instrução dela, 11/11/26: "o private driver é só transporte até o
-- local". O extra da 0097 dizia só "Private driver", que lê como
-- motorista à disposição. Passa a dizer o que é, no mesmo padrão dos
-- pick-ups da 1.1. Preço e data não mudam.
--
-- MEXE EM LINHA QUE JÁ EXISTE, por essa instrução: o campo x_driver da
-- order 1.2 (rascunho, sem confirmação), só se ainda tiver o rótulo da 0097.
-- CONFERÊNCIA DA SEÇÃO 7: ops_order_fields (update 1 linha), ops_migrations.
-- =====================================================================

update ops_order_fields
   set label_en = 'Hotel pick-up for the shopping experience (one way)',
       label_pt = 'Pick-up no hotel para a experiência de shopping (ida)'
 where order_id = '50262600-0000-0000-0000-0000000000c2' and field_key = 'x_driver'
   and label_en = 'Private driver'
   and not exists (select 1 from ops_order_confirmations c where c.order_id = '50262600-0000-0000-0000-0000000000c2');

insert into ops_migrations (id) values ('0099-tl050-driver-so-ida') on conflict (id) do nothing;
