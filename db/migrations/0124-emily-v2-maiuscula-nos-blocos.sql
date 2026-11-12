-- =====================================================================
-- 0124 · EMILY (TL-053-26, v2): BLOCO COM RÓTULO COMEÇA COM MAIÚSCULA
--
-- Instrução dela, 12/11/26: "no Good to Know, sim, começa sempre com
-- letra maiúscula". Vale para todo bloco com rótulo — Good to know,
-- Included, Not included, Getting there —, no serviço e em cada opção:
-- "fuel is not included" → "Fuel is not included", "lunch." → "Lunch.".
-- Só a primeira letra muda; o resto do texto fica como está.
--
-- Seção 7: update de linhas da v2 em ops_proposal_items, com o sim dela.
-- Só enquanto a proposta não foi respondida.
-- =====================================================================

create or replace function pg_temp.cap(t text) returns text language sql immutable as
$f$ select case when t ~ '^[a-z]' then upper(left(t,1)) || substr(t,2) else t end $f$;

update ops_proposal_items i set
  good_en         = pg_temp.cap(good_en),
  included_en     = pg_temp.cap(included_en),
  not_included_en = pg_temp.cap(not_included_en),
  getting_en      = pg_temp.cap(getting_en),
  units = case when jsonb_array_length(coalesce(units,'[]'::jsonb)) = 0 then units else
    (select jsonb_agg((select coalesce(jsonb_object_agg(k, case
               when k in ('good','good_en','included','included_en','not_included','not_included_en','getting','getting_en')
                    and jsonb_typeof(v) = 'string'
               then to_jsonb(pg_temp.cap(v #>> '{}')) else v end), '{}'::jsonb)
             from jsonb_each(u) e(k, v)) order by o)
       from jsonb_array_elements(i.units) with ordinality t(u, o)) end
 where proposal_id = 'e0530000-0000-0000-0000-000000000002'
   and exists (select 1 from ops_proposals
                where id = 'e0530000-0000-0000-0000-000000000002' and responded_at is null);

insert into ops_migrations (id) values ('0124-emily-v2-maiuscula-nos-blocos') on conflict (id) do nothing;
