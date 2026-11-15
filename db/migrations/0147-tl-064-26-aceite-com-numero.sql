-- =====================================================================
-- 0147 · O ACEITE DA TL-064-26 DIZ O NÚMERO DA PROPOSTA
--
-- Pedido dela (12/11/26, retomado em 15/11/26): o texto da caixinha do
-- aceite termina com o número da proposta, e não "this proposal". O
-- rascunho de 12/11 (0129, nunca aplicado) mirava a v2 da TL-053-26;
-- essa v2 já tem resposta gravada e a aprovação da agência foi feita em
-- cima do texto antigo, então ela fica como está. Vale só para a
-- proposta das experiências (TL-064-26, v1), que ainda não foi respondida.
--
-- Seção 7: update de uma linha que já existe, com o sim dela (15/11/26).
-- Só troca se o texto for exatamente o atual e se não houver resposta.
-- =====================================================================

update ops_proposals
   set labels = jsonb_set(labels, '{ack}',
         jsonb_build_object('en', 'I have read and agree to the commercial conditions and the terms and conditions of proposal TL-064-26.'))
 where id = 'e0530000-0000-0000-0000-000000000003'
   and responded_at is null
   and labels->'ack'->>'en' = 'I have read and agree to the commercial conditions and the terms and conditions of this proposal.';

insert into ops_migrations (id) values ('0147-tl-064-26-aceite-com-numero') on conflict (id) do nothing;
