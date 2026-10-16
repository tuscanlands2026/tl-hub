-- =====================================================================
-- 0075 · DANIELLE (TL-055-26): PREÇO DA VIP ASSISTANCE DA PARTIDA
--
-- Ela confirmou (out/26): a VIP assistance da partida é o mesmo preço da
-- chegada — 275 para 2 pax. Foi o único serviço que tinha ficado sem
-- preço (a 0073 não a lançou porque ela ainda não tinha dito).
--
-- Mira por proposal_id + título; só preenche se ainda estiver zerado, para
-- não passar por cima de algo que ela já tenha lançado. Mesma comissão dos
-- serviços de aeroporto (10%), que já está registrada no catálogo.
--
-- Seção 7: ops_proposal_items (update guardado) e ops_migrations (insert).
-- Sem drop/truncate/delete. Nenhuma tabela do CRM.
-- =====================================================================

update ops_proposal_items set price = 275
 where proposal_id = 'f1d3d719-5142-43e7-9359-e2b7249a25d6'
   and 'VIP assistance · Fiumicino (departure)' in (coalesce(title,''), coalesce(title_en,''))
   and coalesce(price,0) = 0;

insert into ops_migrations (id) values ('0075-danielle-vip-partida') on conflict (id) do nothing;
