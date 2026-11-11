-- =====================================================================
-- 0096 · TL-050-26 · A DESCRIÇÃO DO DINING CONCIERGE, DE NOVO
--
-- A 0095 gravou o texto dela no campo x_concierge. Às 16:48 a order foi
-- salva pelo editor que ainda estava no ar, o anterior ao #68, que
-- regravava os campos do checkout SEM a descrição (help_pt/help_en). A
-- descrição sumiu por esse defeito, que o #68 corrigiu. Não foi
-- apagada por ela.
--
-- Reaplica o mesmo texto da 0095, que é o dela ("ficará assim"), e só
-- onde a descrição está vazia: o título, o preço e o resto do que ela
-- salvou ficam como estão.
-- CONFERÊNCIA DA SEÇÃO 7: ops_order_fields (update 1 linha, guardado),
-- ops_migrations. Nenhuma tabela do CRM.
-- =====================================================================

update ops_order_fields
   set help_en = E'The tables worth planning a day around are often booked months ahead. We choose restaurants for each day around your route, send you the shortlist, and book the ones you approve before you travel, subject to availability.\n6 days × €80',
       help_pt = E'As mesas que valem um dia inteiro costumam estar reservadas com meses de antecedência. Escolhemos restaurantes para cada dia de acordo com o roteiro, enviamos a seleção e reservamos os que você aprovar antes da viagem, sujeito a disponibilidade.\n6 dias × €80'
 where order_id = '50262600-0000-0000-0000-0000000000c1' and field_key = 'x_concierge'
   and coalesce(help_en,'') = ''
   and not exists (select 1 from ops_order_confirmations c where c.order_id = '50262600-0000-0000-0000-0000000000c1');

insert into ops_migrations (id) values ('0096-tl050-concierge-descricao-de-novo') on conflict (id) do nothing;
