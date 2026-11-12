-- =====================================================================
-- 0128 · EMILY (TL-053-26, v2): ROME COM NOME DE MENU, COMO AS OUTRAS BASES
--
-- Instrução dela, 12/11/26: "o título tem que acompanhar o menu". O título
-- de cada folha passa a ser o nome do menu, com a data na linha pequena
-- acima. Rome era a única base sem nome de menu (j_menu_roma) e ficava no
-- formato antigo, "Rome · June 29 to July 3"; com o rótulo ela sai igual às
-- outras: "June 29 to July 3" em cima, "Rome" no título.
--
-- Seção 7: acrescenta uma chave em labels da v2, com o sim dela.
-- =====================================================================

update ops_proposals
   set labels = coalesce(labels, '{}'::jsonb) || '{"j_menu_roma":{"en":"Rome"}}'::jsonb
 where id = 'e0530000-0000-0000-0000-000000000002' and responded_at is null;

insert into ops_migrations (id) values ('0128-emily-v2-menu-de-roma') on conflict (id) do nothing;
