-- =====================================================================
-- 0120 · EMILY (TL-053-26, v2): AS TRÊS FOTOS DE CARRO QUE FALTAVAM
--
-- Na 0119 o Maserati Grecale Modena, o Audi Q8 e o BMW X7 ficaram sem
-- foto: os sites da Maserati e da Audi recusam leitura automatizada e o
-- da BMW estava fora do ar. Instrução dela: "busca um modelo na internet,
-- não precisa ser no site oficial se você não conseguir".
--
-- As três vêm da Wikimedia Commons, em licença CC BY-SA 4.0, que pede o
-- nome do autor e a licença junto da foto — por isso cada modelo leva
-- 'credit', e a folha mostra uma linha mínima de crédito embaixo dos
-- cartões dos carros:
--   · Audi Q8 45 TDI — Damian B Oh, CC BY-SA 4.0
--   · Maserati Grecale Modena — Alexander Migl, CC BY-SA 4.0
--   · BMW X7 M50i — Calreyn88, CC BY-SA 4.0
-- Hospedadas em fotos/tl053/, como as outras.
--
-- Seção 7: update de uma linha de ops_proposal_items da v2 (os modelos
-- das duas categorias de carro), com o sim dela.
-- =====================================================================

update ops_proposal_items i set
  units = (select jsonb_agg(
             case u->>'key'
               when 'c1' then u || jsonb_build_object('models', '[
                 {"name":"Mercedes GLE","photo":"fotos/tl053/carro-mercedes-gle.jpg"},
                 {"name":"Maserati Grecale Modena","photo":"fotos/tl053/carro-maserati-grecale.jpg","credit":"Alexander Migl, CC BY-SA 4.0"},
                 {"name":"Audi Q8","photo":"fotos/tl053/carro-audi-q8.jpg","credit":"Damian B Oh, CC BY-SA 4.0"}]'::jsonb)
               when 'c2' then u || jsonb_build_object('models', '[
                 {"name":"Land Rover Defender 110","photo":"fotos/tl053/carro-land-rover-defender.jpg"},
                 {"name":"BMW X7","photo":"fotos/tl053/carro-bmw-x7.jpg","credit":"Calreyn88, CC BY-SA 4.0"},
                 {"name":"Range Rover Sport","photo":"fotos/tl053/carro-range-rover-sport.jpg"}]'::jsonb)
               else u end order by o)
             from jsonb_array_elements(i.units) with ordinality t(u, o))
 where proposal_id = 'e0530000-0000-0000-0000-000000000002'
   and section = 'around' and title_en = 'Your car in Tuscany'
   and exists (select 1 from ops_proposals
                where id = 'e0530000-0000-0000-0000-000000000002' and responded_at is null);

insert into ops_migrations (id) values ('0120-emily-v2-fotos-dos-carros') on conflict (id) do nothing;
