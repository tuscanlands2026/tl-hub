-- =====================================================================
-- 0002 · COMISSÃO DE AGÊNCIA
--
-- Relatório interno: para cada serviço da order, quanto a agência
-- recebe de comissão, mais as instruções de emissão da nota e os dados
-- para a remessa. Ela gera pelo hub e manda para a agência.
--
-- A alíquota fica na LINHA, não na order: na TL-034-26 o transfer é
-- comissionado a 10% e os demais a 12%, e há linha que se chama
-- "transfer" e leva visita a vinícola dentro. Uma alíquota por order
-- obrigaria a escolher errado em alguma linha; por linha, o padrão é
-- sugerido e ela confere.
--
-- Nada disso sai para o cliente: tl_get_order monta o objeto campo a
-- campo e não devolve commission_pct.
--
-- Só toca em objetos ops_. Nada fora desse prefixo.
-- =====================================================================

alter table ops_order_items add column if not exists commission_pct numeric(5,2);
comment on column ops_order_items.commission_pct is
  'Percentual de comissão da agência nesta linha. Interno: nunca sai em tl_get_order.';

-- Blocos de texto do relatório, editáveis por ela sem mexer em código.
-- Mesma tabela do texto padrão da proposta, criada na migração da quote.
insert into ops_text_defaults (key, pt, en) values
  ('commission_billto', E'TUSCAN LANDS DI BATISTELLA MARIA FERNANDA\nPiazza dell''Unità Italiana, 17 — 50065 Sieci (FI), Itália\nP.IVA 06873750480\nC.F. BTSMFR80C68Z602L\nTel: +39 347 760 6931\nE-mail: hello@tuscanlandstravel.com', null),
  ('commission_terms',  E'Os valores estão em euros. Para a conversão, solicitamos utilizar a cotação do euro comercial na data da emissão — geralmente utilizamos a referência do site Remessa Online, mas podem utilizar outro site com cotação oficial, se preferirem.\nComo se trata de uma emissão para o exterior, recomendamos verificar com a contabilidade local ou com a prefeitura da sua cidade o procedimento adequado. Algumas prefeituras exigem cadastro prévio do tomador estrangeiro, e certos campos (como CNPJ) podem ser preenchidos com formatos padrão, como "isento", ou uma sequência genérica de zeros. Confirme com seu contador.\nPor favor, enviar uma cópia da NF para hello@tuscanlandstravel.com. Para pagamento, informe também os dados bancários completos — banco, agência, conta e titular — para emitirmos a remessa do exterior.', null)
on conflict (key) do update
   set pt = coalesce(nullif(ops_text_defaults.pt,''), excluded.pt),
       updated_at = now();

insert into ops_migrations (id) values ('0002-comissao-de-agencia')
on conflict (id) do nothing;
