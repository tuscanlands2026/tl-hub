-- =====================================================================
-- 0084 · TL-050-26 · O TEXTO DO CONCIERGE É O DELA
--
-- Instrução dela, 11/11/26, sobre a linha do concierge da quote da 0083:
--   "For the table, our concierge can prepare a curated selection of
--    places in the area and handle the reservations, arranged before you
--    travel (subject to availability) — concierge é isso"
--
-- MEXE EM LINHA QUE JÁ EXISTE: troca a descrição (details_en) de UMA
-- linha da proposta 50262600-…-b2, nunca enviada nem respondida. O sim
-- é a própria instrução dela acima.
--
-- Mira por proposta + título, e não por id: salvar a proposta no editor
-- recria as linhas com id novo. O título é conferido nos dois idiomas.
-- Valor, quantidade e título não mudam.
--
-- CONFERÊNCIA DA SEÇÃO 7: toca ops_proposal_items (update em uma linha)
-- e ops_migrations (insert). Nenhuma tabela do CRM.
-- =====================================================================

update ops_proposal_items
   set details_en = 'For the table, our concierge can prepare a curated selection of places in the area and handle the reservations, arranged before you travel (subject to availability).'
 where proposal_id = '50262600-0000-0000-0000-0000000000b2'
   and (title_en = 'Concierge Service · dining schedule' or title = 'Concierge Service · dining schedule');

insert into ops_migrations (id) values ('0084-tl050-texto-do-concierge') on conflict (id) do nothing;
