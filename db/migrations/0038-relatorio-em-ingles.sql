-- =====================================================================
-- 0038-relatorio-em-ingles.sql
--   Versão inglesa é inteira em inglês, e não uma inglesa com pedaços
--   em português.
-- =====================================================================
-- Correção dela, setembro/26: "versão inglês é tudo em inglês e
-- português é tudo em português". Na 0037 eu tinha ESCONDIDO do
-- relatório inglês as duas partes que vinham em português — as
-- instruções de emissão e a coluna Inclusos. Esconder não é traduzir:
-- a agência de fora ficava sem saber como faturar.
--
-- Aqui as duas ganham versão inglesa de verdade:
--  · commission_terms.en  — o texto adaptado, e não traduzido ao pé da
--    letra: prefeitura e CNPJ não existem fora do Brasil, e mandar uma
--    agência americana procurar a prefeitura dela seria ruído. O que é
--    universal continua: moeda, câmbio da data, cópia da nota, dados
--    bancários completos para a remessa.
--  · commission_basis_en — o "Inclusos" é campo escrito à mão por ela
--    ("só transfer"), e campo único não tem como sair em dois idiomas.
--    Ganha par, editável ao lado do português na tabela de serviços.
-- ---------------------------------------------------------------------

-- 1) Inclusos em inglês, por linha de serviço ------------------------
alter table ops_order_items
  add column if not exists commission_basis_en text;
comment on column ops_order_items.commission_basis_en is
  'O "Inclusos" do relatório de comissão em inglês. Vazio: a coluna não sai no relatório inglês.';

-- 2) Instruções de emissão em inglês ---------------------------------
-- Só preenche se ainda estiver vazio: texto que ela editou não se
-- reescreve por migração.
update ops_text_defaults
   set en = E'All amounts are in euros. Please issue your invoice in euros or, if your invoice must be in another currency, convert at the commercial euro rate of the issue date and state the rate you used.\n__Invoicing a company abroad may take extra steps in your country: some tax authorities ask for the foreign customer to be registered first, or expect a local tax number in fields that do not apply to us. Our full details are in the block above — please confirm the procedure with your accountant before issuing.__\nPlease send a copy of the invoice to hello@tuscanlandstravel.com. For payment, include your complete bank details — bank, account number, IBAN or routing code, SWIFT/BIC and account holder — so we can arrange the international transfer.',
       updated_at = now()
 where key = 'commission_terms' and (en is null or btrim(en) = '');

-- 3) Dados para emissão em inglês ------------------------------------
-- Mesmos dados, palavras em inglês: "Itália" e "Tel" não são dado, são
-- rótulo, e rótulo em português num documento inglês é o mesmo problema.
update ops_text_defaults
   set en = E'TUSCAN LANDS DI BATISTELLA MARIA FERNANDA\nPiazza dell''Unità Italiana, 17 — 50065 Sieci (FI), Italy\nVAT 06873750480\nTax code BTSMFR80C68Z602L\nPhone: +39 347 760 6931\nE-mail: hello@tuscanlandstravel.com',
       updated_at = now()
 where key = 'commission_billto' and (en is null or btrim(en) = '');

insert into ops_migrations (id) values ('0038-relatorio-em-ingles') on conflict (id) do nothing;
