-- =====================================================================
-- 0064 · SAI A FRASE DA FESTA MEDIEVAL, DO BRIEFING DA EMILY
--
-- Instrução dela, outubro/26: "tira".
--
-- A frase é "We will try to fit one into the program, a very local moment
-- for them.", na seção "About the rates". É a última da lista de promessas
-- que a 0062 levantou, e a razão é a mesma das outras quatro: as datas
-- dessas festas não dependem dela. O "try to" hedgia, mas continuava
-- sendo compromisso com coisa de terceiro.
--
-- ANTES:
--   "Early July is peak season everywhere on this route, a good reason to
--    hold rooms early. It is also when Tuscan towns stage their historical
--    re-enactments and medieval festivals. We will try to fit one into the
--    program, a very local moment for them."
-- DEPOIS:
--   "Early July is peak season everywhere on this route, a good reason to
--    hold rooms early. It is also when Tuscan towns stage their historical
--    re-enactments and medieval festivals."
--
-- O que sobra é fato: as festas acontecem, e ela não prometeu nada sobre
-- elas. É a regra que ficou escrita no CLAUDE.md — fato e oferta ficam,
-- execução sai.
--
-- É TROCA DE FRASE com guarda, e não reescrita do bloco. Idempotente.
-- Roda em qualquer ordem em relação à 0061, 0062 e 0063 — são frases
-- diferentes. Se a 0055 ainda não tiver rodado, não acha nada.
--
-- CONFERÊNCIA DA SEÇÃO 7, relida antes de entregar. Os objetos que este
-- arquivo toca, um a um: ops_advisor_briefings (update de UMA coluna de
-- texto, por id) e ops_migrations (insert). Nenhum drop, alter, truncate
-- ou delete. Nenhuma tabela do CRM é lida, escrita ou citada. Nenhum
-- comando percorre o schema. Nenhuma service_role key aparece aqui.
-- =====================================================================

update ops_advisor_briefings
   set content = replace(content,
         E' We will try to fit one into the program, a very local moment for them.',
         E''),
       updated_at = now()
 where id = 'b0000001-0000-0000-0000-000000000001'
   and content like '%We will try to fit one into the program%';

insert into ops_migrations (id) values ('0064-sai-a-festa-medieval') on conflict (id) do nothing;
