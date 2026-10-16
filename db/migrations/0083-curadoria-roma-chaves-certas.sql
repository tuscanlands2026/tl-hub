-- =====================================================================
-- 0083 · CURADORIA TL-053-26: AS CHAVES CERTAS DA FOLHA (conserta a 0082)
--
-- A 0082 gravou a folha da Curadoria com as chaves de SAÍDA ('title' e
-- 'dias'), mas o tl_get_quote monta a folha a partir das chaves de
-- ARMAZENAMENTO — title_pt/title_en, dest_pt/dest_en, dias_pt/dias_en
-- (migração 0036). Com as chaves erradas, a função resolvia a folha para
-- VAZIO: o texto nunca aparecia na página nem no editor.
--
-- Aqui a folha volta, agora nas chaves certas. Como a proposta é em
-- inglês, o texto entra em _en e também em _pt (o resolvedor faz
-- coalesce(_en, _pt) — assim nunca esvazia em nenhuma das duas línguas).
--
-- Regra "arquivo entregue não se reescreve": a 0082 fica como está e o
-- conserto vem neste arquivo novo. Mexe na folha (campo que ela quer
-- trocado) da proposta b59090ad; não toca em item, seção nem em nenhuma
-- outra proposta.
--
-- Seção 7: ops_proposals (update da folha), ops_migrations (insert).
-- =====================================================================

update ops_proposals set curations = jsonb_build_array(
  jsonb_build_object(
    'opcao', '',
    'cor', 'verde',
    'dest_pt', null,
    'dest_en', null,
    'title_pt', E'Tuscany & Rome · Hotel Curation Brief',
    'title_en', E'Tuscany & Rome · Hotel Curation Brief',
    'dias_pt', E'Here''s a first selection of hotels for June 20 to July 4, 2027.
After your five nights in Cortona, we''d suggest four nights in the Tuscan countryside and four in Rome, flying home on the 4th. We started from what you love about Four Seasons and leaned toward smaller houses, where you get space, a real king bed and privacy. Rates are indicative for now and will move with the final dates, and the split between Tuscany and Rome can shift by a night depending on where you land.

TUSCANY, 4 nights

Cortona covers the south. For the next four nights we move closer to Florence, into wine country.

Castelfalfi. A medieval borgo inside a 2,700-acre estate with its own vineyards and olive groves, between San Gimignano and Volterra. Long walks from the door, and a large spa for the afternoons.

Borgo Vescine. A 13th-century village in Chianti Classico, 28 rooms, vineyards around it and a pool facing the hills.

ROME, 4 nights

Four nights in the centre to close the trip, both houses within walking distance of the Pantheon and the river.

La Minerva. An Orient Express house in a 17th-century palazzo on Piazza della Minerva, right behind the Pantheon. Reopened in 2025 with Art Deco interiors and a rooftop over the historic centre.

Bulgari Hotel Roma. The group''s Rome house on Piazza Augusto Imperatore, facing the Mausoleum of Augustus, with interiors in travertine and coloured marble, a spa and the Niko Romito restaurant.

If you''d like a few days by the sea before Rome, the Tuscan stay could move toward the southern coast near the islands — late June is the start of the season there.',
    'dias_en', E'Here''s a first selection of hotels for June 20 to July 4, 2027.
After your five nights in Cortona, we''d suggest four nights in the Tuscan countryside and four in Rome, flying home on the 4th. We started from what you love about Four Seasons and leaned toward smaller houses, where you get space, a real king bed and privacy. Rates are indicative for now and will move with the final dates, and the split between Tuscany and Rome can shift by a night depending on where you land.

TUSCANY, 4 nights

Cortona covers the south. For the next four nights we move closer to Florence, into wine country.

Castelfalfi. A medieval borgo inside a 2,700-acre estate with its own vineyards and olive groves, between San Gimignano and Volterra. Long walks from the door, and a large spa for the afternoons.

Borgo Vescine. A 13th-century village in Chianti Classico, 28 rooms, vineyards around it and a pool facing the hills.

ROME, 4 nights

Four nights in the centre to close the trip, both houses within walking distance of the Pantheon and the river.

La Minerva. An Orient Express house in a 17th-century palazzo on Piazza della Minerva, right behind the Pantheon. Reopened in 2025 with Art Deco interiors and a rooftop over the historic centre.

Bulgari Hotel Roma. The group''s Rome house on Piazza Augusto Imperatore, facing the Mausoleum of Augustus, with interiors in travertine and coloured marble, a spa and the Niko Romito restaurant.

If you''d like a few days by the sea before Rome, the Tuscan stay could move toward the southern coast near the islands — late June is the start of the season there.'
  ))
 where id = 'b59090ad-14dc-45d3-87f5-9f7206834668';

insert into ops_migrations (id) values ('0083-curadoria-roma-chaves-certas') on conflict (id) do nothing;
