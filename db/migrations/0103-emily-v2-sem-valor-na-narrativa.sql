-- =====================================================================
-- 0103 · EMILY (TL-053-26, v2): SEM VALOR NA TELA DE NARRATIVA
--
-- Regra A1 dela: preço só onde há decisão (quarto, carro, "Your proposal").
-- A conferência da 0102 achou "(2 × € 1.300,00)" no "Included" da opção dois
-- do shopping, que aparece na tela Rome. O valor continua na "Your proposal"
-- (€ 2.600,00); aqui sai só o trecho entre parênteses.
--
-- Mexe só na v2, na linha "Shopping in Rome" (mirada por proposta + título).
-- Guardado: só troca se o trecho ainda estiver lá.
-- Seção 7: ops_proposal_items (update na v2), ops_migrations.
-- =====================================================================
update ops_proposal_items
   set units = replace(units::text, 'for each of you (2 × € 1.300,00), the style analysis', 'for each of you, the style analysis')::jsonb
 where proposal_id = 'e0530000-0000-0000-0000-000000000002'
   and 'Shopping in Rome' in (coalesce(title,''), coalesce(title_en,''))
   and units::text like '%(2 × € 1.300,00)%'
   and exists (select 1 from ops_proposals where id = 'e0530000-0000-0000-0000-000000000002' and responded_at is null);

insert into ops_migrations (id) values ('0103-emily-v2-sem-valor-na-narrativa') on conflict (id) do nothing;
