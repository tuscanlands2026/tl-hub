-- =====================================================================
-- 0108 · EMILY (TL-053-26, v2): "TRANSPORTATION" NOS DIAS DE CARRO PRÓPRIO
--
-- Instrução dela, nov/26, logo depois da 0107: "nos dias self drive, além
-- do lunch not included, coloque transportation".
--
-- Os dias de carro próprio são os do carro alugado com experiência ou
-- passeio: 21 (Montalcino, nas duas opções), 22 (Montepulciano e Pienza),
-- 23 (Arezzo), 24 (dia livre), 26 (trufas) e 27 (Siena e San Gimignano).
-- Ficam de fora o 25, que é o próprio deslocamento de Cortona ao
-- Castelfalfi, e o 28, em que o carro é devolvido de manhã.
--
-- Só muda o "Not included". Onde já havia "lunch." vira "lunch,
-- transportation."; onde o almoço está incluído, entra só
-- "transportation.".
--
-- Mira por proposal_id + seção + título. Só roda com a v2 sem resposta.
--
-- Seção 7: update em ops_proposal_items (seis linhas da v2), com o sim
-- dela, que é a própria instrução.
-- =====================================================================

do $mig$
declare
  v uuid := 'e0530000-0000-0000-0000-000000000002';
begin
  if not exists (select 1 from ops_proposals where id = v and responded_at is null) then
    raise notice '0108: v2 já respondida ou inexistente — nada feito';
    return;
  end if;

  update ops_proposal_items i set
    units = (select jsonb_agg(u || coalesce(m->(u->>'key'), '{}'::jsonb) order by o)
               from jsonb_array_elements(i.units) with ordinality t(u, o),
                    (select jsonb_build_object(
                       'o1', jsonb_build_object('not_included_en', 'transportation.'),
                       'o2', jsonb_build_object('not_included_en', 'lunch, transportation, the optional production and shipping.')) m) mm)
   where proposal_id = v and section = 'cortona' and title_en = 'Montalcino';

  update ops_proposal_items set not_included_en = 'lunch, transportation.'
   where proposal_id = v and section = 'cortona'
     and title_en in ('Montepulciano and Pienza', 'Arezzo', 'A day of your own');

  update ops_proposal_items set not_included_en = 'transportation.'
   where proposal_id = v and section = 'castelfalfi' and title_en = 'Truffle hunting';

  update ops_proposal_items set not_included_en = 'other meals, transportation.'
   where proposal_id = v and section = 'castelfalfi' and title_en = 'Siena and San Gimignano';
end $mig$;

insert into ops_migrations (id) values ('0108-emily-v2-transportation') on conflict (id) do nothing;
