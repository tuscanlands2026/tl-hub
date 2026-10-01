-- =====================================================================
-- 0061 · SAI A FRASE DA CAMA, DO BRIEFING DA EMILY
--
-- Instrução dela, outubro/26: "tira isso do briefing — we request firm
-- rates, with a king bed and single mattress confirmed in writing".
--
-- A frase está na seção "About the rates" do briefing que a 0055
-- carregou. Sai só o trecho da cama; o resto do parágrafo fica, porque
-- pedir tarifa firme antes da proposta formal continua valendo.
--
-- ANTES:
--   "Once Emily chooses her hotels, we request firm rates, with a king
--    bed and single mattress confirmed in writing, and move to the
--    formal proposal."
-- DEPOIS:
--   "Once Emily chooses her hotels, we request firm rates and move to
--    the formal proposal."
--
-- É TROCA DE FRASE, e não reescrita do bloco: nada mais do texto é
-- tocado. Idempotente — rodando duas vezes, a segunda não acha mais a
-- frase antiga e não faz nada.
--
-- SE A 0055 AINDA NÃO TIVER RODADO, este comando não acha nada e não faz
-- nada; rode a 0055 antes, senão o texto antigo volta depois.
--
-- CONFERÊNCIA DA SEÇÃO 7, relida antes de entregar. Os objetos que este
-- arquivo toca, um a um: ops_advisor_briefings (update de UMA coluna de
-- texto, por id) e ops_migrations (insert). Nenhum drop, alter, truncate
-- ou delete. Nenhuma tabela do CRM é lida, escrita ou citada. Nenhum
-- comando percorre o schema. Nenhuma service_role key aparece aqui.
-- =====================================================================

update ops_advisor_briefings
   set content = replace(content,
         E'Once Emily chooses her hotels, we request firm rates, with a king bed and single mattress confirmed in writing, and move to the formal proposal.',
         E'Once Emily chooses her hotels, we request firm rates and move to the formal proposal.'),
       updated_at = now()
 where id = 'b0000001-0000-0000-0000-000000000001'
   and content like '%single mattress confirmed in writing%';

insert into ops_migrations (id) values ('0061-sai-a-frase-da-cama') on conflict (id) do nothing;
