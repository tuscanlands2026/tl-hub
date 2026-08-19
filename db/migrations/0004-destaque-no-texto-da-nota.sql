-- =====================================================================
-- 0004 · DESTAQUE NO TEXTO DE COMO EMITIR A NOTA
--
-- O parágrafo sobre emissão para o exterior é o que mais gera dúvida na
-- agência — cadastro do tomador estrangeiro, CNPJ "isento". Ela pediu
-- para destacá-lo, e o hub passou a entender __texto__ como sublinhado,
-- do mesmo jeito que já entendia **texto** como negrito.
--
-- O update só troca o texto se ele ainda for exatamente o que a 0002
-- gravou. Se ela já tiver editado, fica como está: corrigir o texto
-- dela sem avisar seria pior do que não destacar.
--
-- Só toca em objetos ops_. Nada fora desse prefixo.
-- =====================================================================

update ops_text_defaults
   set pt = E'Os valores estão em euros. Para a conversão, solicitamos utilizar a cotação do euro comercial na data da emissão — geralmente utilizamos a referência do site Remessa Online, mas podem utilizar outro site com cotação oficial, se preferirem.\n__Como se trata de uma emissão para o exterior, recomendamos verificar com a contabilidade local ou com a prefeitura da sua cidade o procedimento adequado. Algumas prefeituras exigem cadastro prévio do tomador estrangeiro, e certos campos (como CNPJ) podem ser preenchidos com formatos padrão, como "isento", ou uma sequência genérica de zeros. Confirme com seu contador.__\nPor favor, enviar uma cópia da NF para hello@tuscanlandstravel.com. Para pagamento, informe também os dados bancários completos — banco, agência, conta e titular — para emitirmos a remessa do exterior.',
       updated_at = now()
 where key = 'commission_terms'
   and pt = E'Os valores estão em euros. Para a conversão, solicitamos utilizar a cotação do euro comercial na data da emissão — geralmente utilizamos a referência do site Remessa Online, mas podem utilizar outro site com cotação oficial, se preferirem.\nComo se trata de uma emissão para o exterior, recomendamos verificar com a contabilidade local ou com a prefeitura da sua cidade o procedimento adequado. Algumas prefeituras exigem cadastro prévio do tomador estrangeiro, e certos campos (como CNPJ) podem ser preenchidos com formatos padrão, como "isento", ou uma sequência genérica de zeros. Confirme com seu contador.\nPor favor, enviar uma cópia da NF para hello@tuscanlandstravel.com. Para pagamento, informe também os dados bancários completos — banco, agência, conta e titular — para emitirmos a remessa do exterior.';

insert into ops_migrations (id) values ('0004-destaque-no-texto-da-nota')
on conflict (id) do nothing;
