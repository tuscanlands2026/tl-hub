-- =====================================================================
-- 0084 · EMILY (TL-053-26, v2): CORTONA NA SEÇÃO, NO CAMPO CERTO
--
-- Erro meu na 0083: a menção a Cortona foi para `note`/`title` da seção da
-- Toscana, que é o par em PORTUGUÊS. A proposta é em inglês, e a seção
-- dela tem `note_en`/`title_en` — é o que `tl_get_quote` devolve. No link,
-- continuava "Select your stay for this trip".
--
-- Conserto: o texto inglês vai para `note_en`/`title_en`, e `note`/`title`
-- voltam ao que eram na v1 ("Select your stay for this trip" e o título
-- com o espaço no fim), para não deixar inglês no campo português.
--
-- Mexe só na v2 (e0530000-…-0002), criada pela 0083 nesta mesma conversa,
-- sem resposta de cliente e sem link enviado. A v1 (o estudo) não é tocada.
-- Guardado: só troca se a nota inglesa ainda for a genérica.
--
-- Seção 7: ops_proposals (update de uma linha nova) e ops_migrations.
-- =====================================================================

update ops_proposals p set sections = (
  select jsonb_agg(
           case when s->>'key' = 'stays'
                then s || jsonb_build_object(
                       'title',    'Tuscany countryside ',
                       'note',     'Select your stay for this trip',
                       'title_en', 'Tuscany countryside',
                       'note_en',  'After five nights in Cortona, June 20 to 25, four nights in the Tuscan countryside. Select your stay for June 25 to 29.')
                else s end
           order by o)
    from jsonb_array_elements(p.sections) with ordinality as t(s, o))
 where p.id = 'e0530000-0000-0000-0000-000000000002'
   and p.responded_at is null
   and exists (select 1 from jsonb_array_elements(p.sections) s
                where s->>'key' = 'stays'
                  and coalesce(s->>'note_en','') = 'Select your stay for this trip');

insert into ops_migrations (id) values ('0084-emily-v2-cortona-na-secao') on conflict (id) do nothing;
