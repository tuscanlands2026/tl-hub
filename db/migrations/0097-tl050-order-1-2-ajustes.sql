-- =====================================================================
-- 0097 · TL-050-26 · ORDER 1.2 (SHOPPING) · AJUSTES DELA
--
-- Instrução dela, 11/11/26, sobre a 1.2:
--   · "inclua como extra o driver 80 euros";
--   · as "Specific conditions of this order" da 1.1 valem aqui também;
--   · o aceite "I am aware that the experience includes up to 3 hours…"
--     sai (a cláusula "Additional time" cobre, e a linha do serviço já diz
--     € 255 por hora adicional);
--   · "Preferred day and time" vira PERÍODO, não horário: manhã ou tarde.
--
-- MEXE EM LINHA QUE JÁ EXISTE, por essa instrução, só na order 1.2
-- (rascunho, sem confirmação):
--   · ops_orders: terms_extra, só se estiver vazio;
--   · ops_order_fields: APAGA extra_hours; preferred_day vira escolha;
--     INSERE o extra do motorista (€ 80, Oct 8).
-- As parcelas (455 + 845) NÃO são tocadas aqui: com o motorista marcado o
-- total vai a € 1.380, e o que fazer com elas é pergunta para ela.
-- CONFERÊNCIA DA SEÇÃO 7: ops_orders, ops_order_fields, ops_migrations.
-- Nenhuma tabela do CRM.
-- =====================================================================

update ops_orders
   set terms_extra = E'**Scheduled times and delays.** Each experience follows its scheduled timetable and ends at the agreed time. Delays caused by circumstances beyond Tuscan Lands Travel''s control, such as flight delays, airport procedures or traffic, reduce the duration of the experience accordingly and do not extend its scheduled end time. No refund or compensation is due for the time lost.\n**Additional time.** Services are provided for the duration stated in this order. Any time beyond the duration included, such as additional hours of a driver, guide or experience, is subject to availability and is charged to the client at the end of the service.',
       updated_at = now()
 where id = '50262600-0000-0000-0000-0000000000c2' and coalesce(terms_extra,'') = ''
   and not exists (select 1 from ops_order_confirmations c where c.order_id = '50262600-0000-0000-0000-0000000000c2');

delete from ops_order_fields
 where order_id = '50262600-0000-0000-0000-0000000000c2' and field_key = 'extra_hours'
   and not exists (select 1 from ops_order_confirmations c where c.order_id = '50262600-0000-0000-0000-0000000000c2');

update ops_order_fields
   set input_type = 'select',
       options    = '["Morning","Afternoon"]'::jsonb,
       label_en   = 'Preferred period in Rome (morning or afternoon)',
       label_pt   = 'Período de preferência em Roma (manhã ou tarde)'
 where order_id = '50262600-0000-0000-0000-0000000000c2' and field_key = 'preferred_day'
   and not exists (select 1 from ops_order_confirmations c where c.order_id = '50262600-0000-0000-0000-0000000000c2');

insert into ops_order_fields
  (order_id, sort, group_key, field_key, label_pt, label_en, input_type, required, mode, price, service_date)
select '50262600-0000-0000-0000-0000000000c2', -1, 'general', 'x_driver',
       'Motorista particular', 'Private driver', 'checkbox', false, 'blank', 80, 'Oct 8'
 where not exists (select 1 from ops_order_confirmations c where c.order_id = '50262600-0000-0000-0000-0000000000c2')
on conflict (order_id, field_key) do nothing;

insert into ops_migrations (id) values ('0097-tl050-order-1-2-ajustes') on conflict (id) do nothing;
