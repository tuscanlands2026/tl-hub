-- =====================================================================
-- 0088 · EMILY (TL-053-26, v2): SAI O QUARTO COMUNICANTE
--
-- Mesma instrução da 0087 ("coloca as informações que são úteis"): o
-- card do Castelfalfi trazia, da ficha, "Connected rooms available on
-- request in selected categories." Quarto comunicante é para quem viaja
-- com mais gente; são dois adultos. Sai a frase, fica o resto da estrutura.
--
-- A ficha do fornecedor não é tocada. Mexe só na v2, guardado pela frase.
-- Seção 7: ops_proposal_items (update na v2), ops_migrations (insert).
-- =====================================================================

update ops_proposal_items set
  facilities_en = replace(facilities_en, ' Connected rooms available on request in selected categories.', '')
 where proposal_id = 'e0530000-0000-0000-0000-000000000002'
   and 'Castelfalfi' in (coalesce(title,''), coalesce(title_en,''))
   and position('Connected rooms available on request' in coalesce(facilities_en,'')) > 0
   and exists (select 1 from ops_proposals p
                where p.id = 'e0530000-0000-0000-0000-000000000002' and p.responded_at is null);

insert into ops_migrations (id) values ('0088-emily-v2-sem-quarto-comunicante') on conflict (id) do nothing;
