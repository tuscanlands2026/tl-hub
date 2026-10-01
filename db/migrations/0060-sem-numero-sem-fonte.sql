-- =====================================================================
-- 0060 · SAI O QUE NÃO TEM FONTE
--
-- Instrução dela, outubro/26, sobre o Aman Venice: "24 quartos, não fui
-- eu. Então, se não tem a fonte, não coloca."
--
-- Ela está certa, e o número é meu. Procurei em tudo que o aman.com
-- publica — a página do hotel, as quatro de acomodação, as onze de
-- categoria, a de contato, a de eventos e o press: o Aman NÃO publica
-- quantos quartos tem. O 24 veio de memória, que não é fonte.
--
-- Pelo mesmo motivo saem outros três números que eu escrevi sem fonte:
-- os 17 quartos do Palazzo Vendramin (a Belmond não publica, e nem
-- lista mais o Vendramin como categoria), e os séculos dos dois
-- palácios. O que fica é só o que o site de cada um afirma.
--
-- O QUE ESTE ARQUIVO MEXE, e por isso ele é separado e numerado:
--   · ops_advisor_briefings.content — a frase do briefing da Emily que
--     a 0055 carregou. Se a 0055 ainda não tiver rodado, este comando
--     não acha nada e não faz nada; RODE A 0055 ANTES, senão o texto
--     antigo volta depois.
--   · ops_proposals.curations da TL-053-26 — as duas frases da folha de
--     Curadoria. É texto da proposta dela, por isso as duas versões
--     estão escritas aqui embaixo, antes e depois, para ela conferir.
--
-- Os dois comandos são TROCA DE FRASE, e não reescrita do bloco: o
-- resto do texto dela não é tocado. São idempotentes — rodando duas
-- vezes, a segunda não acha mais a frase antiga e não faz nada.
--
-- ANTES → DEPOIS, no briefing:
--   "...looked for smaller scale instead: Aman has 24 rooms, Palazzo
--    Vendramin 17, with the Cipriani's pool and gardens next door."
--   "...looked for smaller scale instead: Aman occupies a single palazzo
--    on the Grand Canal, and Palazzo Vendramin is a residence beside the
--    Cipriani, with its pool and gardens next door."
--
-- ANTES → DEPOIS, na Curadoria:
--   "Aman Venice. Twenty-four rooms in a 16th-century palazzo on the
--    Grand Canal, Tiepolo ceilings and one of the few private gardens on
--    the water."
--   "Aman Venice. One of the eight monumental palazzos on the Grand
--    Canal, with Tiepolo frescoes and one of the few private gardens on
--    the water."
--
--   "Palazzo Vendramin at Hotel Cipriani. Seventeen rooms in a
--    15th-century residence on Giudecca, connected to the Cipriani, so
--    its pool and gardens are yours too."
--   "Palazzo Vendramin at Hotel Cipriani. A residence on Giudecca beside
--    the Cipriani and connected to it, so its pool and gardens are yours
--    too."
--
-- CONFERÊNCIA DA SEÇÃO 7, relida antes de entregar. Os objetos que este
-- arquivo toca, um a um: ops_advisor_briefings (update de UMA coluna de
-- texto, por id), ops_proposals (update de curations em UMA linha, por
-- id) e ops_migrations (insert). Nenhum drop, alter, truncate ou delete.
-- Nenhuma tabela do CRM é lida, escrita ou citada. Nenhum comando
-- percorre o schema. Nenhuma service_role key aparece aqui.
-- =====================================================================

-- 1 · O briefing da Emily -----------------------------------------------
update ops_advisor_briefings
   set content = replace(content,
         E'Aman has 24 rooms, Palazzo Vendramin 17, with the Cipriani''s pool and gardens next door.',
         E'Aman occupies a single palazzo on the Grand Canal, and Palazzo Vendramin is a residence beside the Cipriani, with its pool and gardens next door.'),
       updated_at = now()
 where id = 'b0000001-0000-0000-0000-000000000001'
   and content like '%Aman has 24 rooms%';

-- 2 · A folha de Curadoria da proposta ----------------------------------
-- Troca dentro do texto serializado, com guarda: as duas frases não têm
-- aspas nem quebra de linha, então a troca é exata e não mexe na
-- estrutura do jsonb.
update ops_proposals
   set curations = replace(
         replace(curations::text,
           'Aman Venice. Twenty-four rooms in a 16th-century palazzo on the Grand Canal, Tiepolo ceilings and one of the few private gardens on the water.',
           'Aman Venice. One of the eight monumental palazzos on the Grand Canal, with Tiepolo frescoes and one of the few private gardens on the water.'),
         'Palazzo Vendramin at Hotel Cipriani. Seventeen rooms in a 15th-century residence on Giudecca, connected to the Cipriani, so its pool and gardens are yours too.',
         'Palazzo Vendramin at Hotel Cipriani. A residence on Giudecca beside the Cipriani and connected to it, so its pool and gardens are yours too.')::jsonb,
       updated_at = now()
 where id = 'b59090ad-14dc-45d3-87f5-9f7206834668'
   and curations::text like '%Twenty-four rooms%';

insert into ops_migrations (id) values ('0060-sem-numero-sem-fonte') on conflict (id) do nothing;
