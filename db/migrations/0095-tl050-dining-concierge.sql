-- =====================================================================
-- 0095 · TL-050-26 · ORDER 1.1 · O CONCIERGE COM O TEXTO DELA
--
-- Instrução dela, 11/11/26, "ficará assim":
--   Dining concierge
--   The tables worth planning a day around are often booked months
--   ahead. We choose restaurants for each day around your route, send
--   you the shortlist, and book the ones you approve before you travel,
--   subject to availability.
--   6 days × €80
--
-- MEXE EM LINHA QUE JÁ EXISTE, por essa instrução: o campo x_concierge
-- da order 1.1 (rascunho, sem confirmação). Título em label, o resto em
-- help (descrição, que sai embaixo do título). Preço e data não mudam.
-- Precisa da 0094 para a descrição descer para a linha da order.
-- CONFERÊNCIA DA SEÇÃO 7: ops_order_fields (update 1 linha), ops_migrations.
-- =====================================================================

update ops_order_fields
   set label_en = 'Dining concierge',
       help_en  = E'The tables worth planning a day around are often booked months ahead. We choose restaurants for each day around your route, send you the shortlist, and book the ones you approve before you travel, subject to availability.\n6 days × €80',
       label_pt = 'Concierge de restaurantes',
       help_pt  = E'As mesas que valem um dia inteiro costumam estar reservadas com meses de antecedência. Escolhemos restaurantes para cada dia de acordo com o roteiro, enviamos a seleção e reservamos os que você aprovar antes da viagem, sujeito a disponibilidade.\n6 dias × €80'
 where order_id = '50262600-0000-0000-0000-0000000000c1' and field_key = 'x_concierge'
   and not exists (select 1 from ops_order_confirmations c where c.order_id = '50262600-0000-0000-0000-0000000000c1');

insert into ops_migrations (id) values ('0095-tl050-dining-concierge') on conflict (id) do nothing;
