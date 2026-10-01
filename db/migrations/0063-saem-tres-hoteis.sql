-- =====================================================================
-- 0063 · SAEM TRÊS HOTÉIS: GHIRLANDAIO, VILLA SAN MICHELE E VENDRAMIN
--
-- Instrução dela, outubro/26: "tira villa ghirlandaio do briefing e da
-- proposta, não tá disponível" · "tira o villa san michele do briefing
-- e da proposta, não tá disponível" · e, sobre o Palazzo Vendramin at
-- Hotel Cipriani, "tira esse também".
--
-- CADA UM APARECE EM QUATRO OU CINCO LUGARES, e quase sempre dentro de
-- uma frase que fala de outro hotel. Tirar só o nome deixaria o texto
-- quebrado — "the first two options" com uma opção só, "we can replace
-- one of the hill options" sem segunda colina. Então sai o nome E a
-- frase, e as vizinhas são reescritas para continuarem verdadeiras.
--
-- DEPOIS DISTO CADA BASE FICA COM DOIS HOTÉIS:
--   Toscana  · Castelfalfi, Borgo Vescine
--   Florença · Collegio alla Querce, Four Seasons Hotel Firenze
--   Veneza   · Danieli, Aman Venice
--
-- AS PERGUNTAS do briefing perdem as opções correspondentes, e isso só
-- acontece SE NINGUÉM TIVER RESPONDIDO AINDA: com resposta gravada, a
-- opção some e a resposta antiga fica apontando para o nada. Havendo
-- resposta, este bloco não faz nada — e aí a decisão é dela.
--
-- O arquivo cobre o texto ANTES e DEPOIS da 0060 na frase do Marriott e
-- no parágrafo do Vendramin, então roda tendo a 0060 sido rodada ou não.
--
-- CONFERÊNCIA DA SEÇÃO 7, relida antes de entregar. Os objetos que este
-- arquivo toca, um a um: ops_proposal_items (delete de TRÊS linhas, por
-- id), ops_proposals (update de curations em UMA linha, por id),
-- ops_advisor_briefings (update de UMA coluna de texto, por id),
-- ops_advisor_questions (update de options em TRÊS linhas, por id) e
-- ops_migrations (insert). Nenhum drop, alter ou truncate. Nenhuma
-- tabela do CRM é lida, escrita ou citada. Nenhum comando percorre o
-- schema. Nenhuma service_role key aparece aqui.
-- =====================================================================

-- 1 · AS TRÊS LINHAS DA PROPOSTA ----------------------------------------
-- Por id e com o título conferido: se ela tiver renomeado a linha, o
-- comando não apaga nada.
delete from ops_proposal_items
 where id = '53260000-0000-0000-0000-000000000001' and proposal_id = 'b59090ad-14dc-45d3-87f5-9f7206834668'
   and title_en = E'Dimora Ghirlandaio';
delete from ops_proposal_items
 where id = '53260000-0000-0000-0000-000000000004' and proposal_id = 'b59090ad-14dc-45d3-87f5-9f7206834668'
   and title_en = E'Belmond Villa San Michele';
delete from ops_proposal_items
 where id = '53260000-0000-0000-0000-000000000009' and proposal_id = 'b59090ad-14dc-45d3-87f5-9f7206834668'
   and title_en = E'Palazzo Vendramin at Hotel Cipriani';

-- 2 · A FOLHA DE CURADORIA ----------------------------------------------
-- Mexe no texto de verdade (jsonb_set), e não no jsonb serializado: o
-- caminho é escolhido pela chave que estiver preenchida, en ou pt.
update ops_proposals p
   set curations = jsonb_set(p.curations, s.caminho, to_jsonb(
         replace(replace(replace(replace(replace(s.txt,
           E'Dimora Ghirlandaio. The Ghirlandaio family''s summer home in the 14th century, 15 minutes from Florence. We''d reserve one of the estate''s houses just for the two of you, with the restaurant, pool and spa a short walk away.\n\n',
           E''),
           E'Villa San Michele. A former convent on the Fiesole hillside, reopened in 2026 after an 18-month restoration, with a Guerlain spa and Florence spread out below. We''d go straight to a garden suite.\n\n',
           E''),
           E'Palazzo Vendramin at Hotel Cipriani. A residence on Giudecca beside the Cipriani and connected to it, so its pool and gardens are yours too.\n\n',
           E''),
           E'Palazzo Vendramin at Hotel Cipriani. Seventeen rooms in a 15th-century residence on Giudecca, connected to the Cipriani, so its pool and gardens are yours too.\n\n',
           E''),
           E'The first two options sit on the hills just above the city, with a shuttle into town, so you can spend the day in Florence and sleep in the quiet.',
           E'Collegio alla Querce sits on the hill just above the city, with a shuttle into town, so you can spend the day in Florence and sleep in the quiet.') )),
       updated_at = now()
  from (select
          case when coalesce(curations->0->>'dias_en','') <> ''
               then '{0,dias_en}' else '{0,dias_pt}' end::text[] as caminho,
          coalesce(nullif(curations->0->>'dias_en',''), curations->0->>'dias_pt') as txt
          from ops_proposals where id = 'b59090ad-14dc-45d3-87f5-9f7206834668') s
 where p.id = 'b59090ad-14dc-45d3-87f5-9f7206834668'
   and s.txt like '%Dimora Ghirlandaio.%';

-- 3 · O TEXTO DO BRIEFING -----------------------------------------------
update ops_advisor_briefings set content =
  replace(replace(replace(replace(replace(replace(replace(replace(replace(content,
         E'| [Dimora Ghirlandaio](https://dimoraghirlandaio.it/en/accommodations/il-frantoio/) · Impruneta, 15 min from Florence | La Limonaia or Villa Lo Studio, for the couple alone |\n',
         E''),
         E'Dimora Ghirlandaio is the one we would lead with for Emily''s privacy: the estate rents its houses individually, so the couple has a home of their own with the hotel''s restaurant, breakfast, pool and spa around it. ',
         E''),
         E'Villa San Michele and Collegio alla Querce sit outside the centre, on the hills above the city, and both run a shuttle into town. We chose them so the couple does not need to sleep in the city. If staying in the centre matters to Emily, the Four Seasons is there, and we can replace one of the hill options with another central hotel. Florence has other good ones.\n',
         E'Collegio alla Querce sits outside the centre, on the hill above the city, and runs a shuttle into town. We chose it so the couple does not need to sleep in the city. If staying in the centre matters to Emily, the Four Seasons is there, and we can replace the hill option with another central hotel. Florence has other good ones.\n'),
         E'| Villa San Michele, A Belmond Hotel · Fiesole | Garden Suite |\n',
         E''),
         E'At Villa San Michele the entry rooms are the weaker part of the house, so we suggest going straight to a garden suite.\n\n',
         E''),
         E'| Palazzo Vendramin at Hotel Cipriani · Giudecca | Vendramin Suite |\n',
         E''),
         E'We kept the Marriott properties out, as they are very large, and looked for smaller scale instead: Aman has 24 rooms, Palazzo Vendramin 17, with the Cipriani''s pool and gardens next door.',
         E'We kept the Marriott properties out, as they are very large, and looked for smaller scale instead: Aman occupies a single palazzo on the Grand Canal.'),
         E'We kept the Marriott properties out, as they are very large, and looked for smaller scale instead: Aman occupies a single palazzo on the Grand Canal, and Palazzo Vendramin is a residence beside the Cipriani, with its pool and gardens next door.',
         E'We kept the Marriott properties out, as they are very large, and looked for smaller scale instead: Aman occupies a single palazzo on the Grand Canal.'),
         E'Villa San Michele, Collegio alla Querce and Dimora Ghirlandaio all work as that base.',
         E'Collegio alla Querce works as that base.'),
  updated_at = now()
 where id = 'b0000001-0000-0000-0000-000000000001'
   and content like '%Dimora Ghirlandaio is the one%';

-- 4 · AS OPÇÕES DAS TRÊS PERGUNTAS --------------------------------------
-- Só mexe se ninguém tiver respondido: opção que some com resposta
-- gravada deixa a resposta apontando para o nada.
update ops_advisor_questions set options = E'["Castelfalfi", "Borgo Vescine"]'::jsonb
 where id = 'b0000001-0000-0000-0000-000000010001'
   and not exists (select 1 from ops_advisor_answers a
                    where a.briefing_id = 'b0000001-0000-0000-0000-000000000001');
update ops_advisor_questions set options = E'["Collegio alla Querce", "Four Seasons Hotel Firenze", "Another hotel in the centre"]'::jsonb
 where id = 'b0000001-0000-0000-0000-000000010002'
   and not exists (select 1 from ops_advisor_answers a
                    where a.briefing_id = 'b0000001-0000-0000-0000-000000000001');
update ops_advisor_questions set options = E'["Danieli, A Four Seasons Hotel", "Aman Venice"]'::jsonb
 where id = 'b0000001-0000-0000-0000-000000010003'
   and not exists (select 1 from ops_advisor_answers a
                    where a.briefing_id = 'b0000001-0000-0000-0000-000000000001');

insert into ops_migrations (id) values ('0063-saem-tres-hoteis') on conflict (id) do nothing;
