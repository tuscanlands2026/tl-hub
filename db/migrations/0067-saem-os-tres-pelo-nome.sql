-- =====================================================================
-- 0067 · OS TRÊS HOTÉIS SAEM — AGORA PELO NOME, QUE É O QUE NÃO MUDA
--
-- Terceira tentativa, e desta vez com a causa achada.
--
-- O ID DE ops_proposal_items NÃO É ESTÁVEL. Salvar a proposta no editor
-- APAGA TODAS AS LINHAS E RECRIA (index.html, em `salvarQuote`:
-- `delete().eq("proposal_id", …)` seguido de `insert`). Os ids fixos que
-- a 0059 escreveu deixaram de existir no primeiro save que ela deu para
-- lançar os valores — as linhas são as mesmas aos olhos dela, e outras
-- para o banco.
--
-- Por isso a 0063 e a 0066 não apagaram nada: as duas miravam
-- '53260000-…-01/04/09', que não existem mais. E por isso a limpeza da
-- Curadoria funcionou na 0066 — ela mira o id da PROPOSTA, que não muda.
--
-- A CHAVE CERTA PARA LINHA DE PROPOSTA É proposal_id + TÍTULO. O título
-- é o que ela vê e o que sobrevive ao save. Os três nomes aqui são
-- inconfundíveis e não se repetem na proposta, então a mira é exata.
-- Confere nos dois idiomas, porque ela edita o editor em português e
-- isso escreve em `title`, não em `title_en`.
--
-- Nada mais é tocado: a Curadoria já foi limpa pela 0066, e o briefing
-- já foi tratado nas anteriores. Rodar duas vezes não faz nada.
--
-- CONFERÊNCIA DA SEÇÃO 7, relida antes de entregar. Os objetos que este
-- arquivo toca, um a um: ops_proposal_items (delete de até TRÊS linhas,
-- por proposta e por título) e ops_migrations (insert). Nenhum drop,
-- alter ou truncate. Nenhuma tabela do CRM é lida, escrita ou citada.
-- Nenhum comando percorre o schema. Nenhuma service_role key aqui.
-- =====================================================================

delete from ops_proposal_items
 where proposal_id = 'b59090ad-14dc-45d3-87f5-9f7206834668'
   and (
     coalesce(nullif(title_en,''), '') in
       ('Dimora Ghirlandaio', 'Belmond Villa San Michele', 'Palazzo Vendramin at Hotel Cipriani')
     or coalesce(nullif(title,''), '') in
       ('Dimora Ghirlandaio', 'Belmond Villa San Michele', 'Palazzo Vendramin at Hotel Cipriani')
   );

insert into ops_migrations (id) values ('0067-saem-os-tres-pelo-nome') on conflict (id) do nothing;
