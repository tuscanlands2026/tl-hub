-- =====================================================================
-- 0127 · EMILY (TL-053-26, v2): TEXTO DO ACEITE NO ENVIO
--
-- Instrução dela, 12/11/26: em vez de "I have read and understood the
-- commercial conditions of this proposal", "eu li e estou de acordo com
-- the commercial and terms and conditions of this proposal".
--
-- O texto da caixinha passa a ser rótulo da proposta (chave 'ack' em
-- ops_proposals.labels, na lista ROTULOS do hub); vazio, continua o padrão
-- de antes, e nenhuma outra proposta muda.
--
-- Seção 7: acrescenta uma chave em labels da v2, com o sim dela.
-- =====================================================================

update ops_proposals
   set labels = coalesce(labels, '{}'::jsonb)
     || '{"ack":{"en":"I have read and agree to the commercial conditions and the terms and conditions of this proposal."}}'::jsonb
 where id = 'e0530000-0000-0000-0000-000000000002' and responded_at is null;

insert into ops_migrations (id) values ('0127-emily-v2-texto-do-aceite') on conflict (id) do nothing;
