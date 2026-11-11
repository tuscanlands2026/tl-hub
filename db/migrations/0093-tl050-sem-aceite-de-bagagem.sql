-- =====================================================================
-- 0093 · TL-050-26 · ORDER 1.1 SEM O ACEITE DE BAGAGEM
--
-- Instrução dela, 11/11/26, sobre "I am aware of the luggage volume limit
-- for the type of vehicle selected": "isso sai".
--
-- MEXE EM LINHA QUE JÁ EXISTE, por essa instrução: só a chave
-- ack_vehicle do checkout_config da order 1.1, de true para false. Nada
-- mais do checkout muda. Guardado: só sem confirmação.
-- CONFERÊNCIA DA SEÇÃO 7: ops_orders (update 1 linha), ops_migrations.
-- =====================================================================

update ops_orders
   set checkout_config = jsonb_set(coalesce(checkout_config,'{}'::jsonb), '{ack_vehicle}', 'false'::jsonb),
       updated_at = now()
 where id = '50262600-0000-0000-0000-0000000000c1'
   and not exists (select 1 from ops_order_confirmations c where c.order_id = '50262600-0000-0000-0000-0000000000c1');

insert into ops_migrations (id) values ('0093-tl050-sem-aceite-de-bagagem') on conflict (id) do nothing;
