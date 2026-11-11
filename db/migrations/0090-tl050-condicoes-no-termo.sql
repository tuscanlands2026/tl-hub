-- =====================================================================
-- 0090 · TL-050-26 · ORDER 1.1 · OS DOIS ACEITES VIRAM CLÁUSULA
--
-- Instrução dela, 11/11/26: "essa parte dos termos e condições você vai
-- colocar na parte de termos e condições ali no texto também ... escreve
-- com estilo de termos e condições, não assim". Precisa da 0089.
--
-- MEXE EM LINHA QUE JÁ EXISTE, por essa instrução, e só na order 1.1
-- (rascunho, nunca respondida — conferido antes):
--   · grava terms_extra com as duas cláusulas, só se estiver vazio;
--   · APAGA os dois campos de aceite (ack_delay, ack_extra_time) do
--     checkout dessa order, só enquanto ela não tiver confirmação.
-- O aceite dos termos, que é obrigatório e fixo, passa a cobrir as duas.
--
-- CONFERÊNCIA DA SEÇÃO 7: ops_orders (update 1 linha, guardado),
-- ops_order_fields (delete de 2 linhas, guardado), ops_migrations.
-- =====================================================================

update ops_orders
   set terms_extra = E'**Scheduled times and delays.** Each experience follows its scheduled timetable and ends at the agreed time. Delays caused by circumstances beyond Tuscan Lands Travel''s control, such as flight delays, airport procedures or traffic, reduce the duration of the experience accordingly and do not extend its scheduled end time. No refund or compensation is due for the time lost.\n**Additional time.** Services are provided for the duration stated in this order. Any time beyond the duration included, such as additional hours of a driver, guide or experience, is subject to availability and is charged to the client at the end of the service.',
       updated_at = now()
 where id = '50262600-0000-0000-0000-0000000000c1' and coalesce(terms_extra,'') = '';

delete from ops_order_fields
 where order_id = '50262600-0000-0000-0000-0000000000c1'
   and field_key in ('ack_delay','ack_extra_time')
   and not exists (select 1 from ops_order_confirmations c
                    where c.order_id = '50262600-0000-0000-0000-0000000000c1');

insert into ops_migrations (id) values ('0090-tl050-condicoes-no-termo') on conflict (id) do nothing;
