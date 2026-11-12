-- =====================================================================
-- 0115 · "GETTING THERE" E A DESCRIÇÃO DA LINHA — SÓ CRIA
--
-- Texto final dela para a TL-053-26, nov/26, traz duas peças novas:
--   · GETTING THERE — um rótulo próprio, ao lado de Included, Not
--     included e Good to know, em cada dia de carro próprio ("in your own
--     car, or with a private driver on request"). Vale no serviço e em
--     cada opção do dia.
--   · em "Your proposal", cada linha com o nome do serviço e, embaixo,
--     uma linha de descrição ("The estate visit and the chef's lunch,
--     paired with the estate's wines").
--
--   ops_proposal_items getting_pt/_en      o "Getting there" do serviço
--   ops_proposal_items row_desc_pt/_en     a descrição da linha da tabela
--   units[].getting/_en, units[].row_desc/_en (jsonb), e o mesmo nos
--   extras, que já saem inteiros
--
-- Vazio é o normal: sem eles nada aparece, e proposta que já existe não
-- muda. tl_get_quote passa a devolver 'getting' e 'row_desc' no serviço e
-- na opção, por TROCA PONTUAL no texto da função, como na 0101/0105/0109.
--
-- Seção 7: só alter table add column e troca de função. Sem update, sem
-- delete. Nenhuma tabela do CRM.
-- =====================================================================

alter table ops_proposal_items add column if not exists getting_pt  text;
alter table ops_proposal_items add column if not exists getting_en  text;
alter table ops_proposal_items add column if not exists row_desc_pt text;
alter table ops_proposal_items add column if not exists row_desc_en text;

do $$
declare d text; antes text;
begin
  d := pg_get_functiondef('public.tl_get_quote(text)'::regprocedure);

  -- 1 · opção: getting e row_desc
  antes := d;
  d := replace(d,
    $a$'row', case when ing then coalesce(nullif(u->>'row_en',''), u->>'row') else coalesce(nullif(u->>'row',''), u->>'row_en') end) order by ord)$a$,
    $b$'row', case when ing then coalesce(nullif(u->>'row_en',''), u->>'row') else coalesce(nullif(u->>'row',''), u->>'row_en') end,
            'getting', case when ing then coalesce(nullif(u->>'getting_en',''), u->>'getting') else coalesce(nullif(u->>'getting',''), u->>'getting_en') end,
            'row_desc', case when ing then coalesce(nullif(u->>'row_desc_en',''), u->>'row_desc') else coalesce(nullif(u->>'row_desc',''), u->>'row_desc_en') end) order by ord)$b$);
  if d = antes then raise exception '0115: trecho das unidades não encontrado'; end if;

  -- 2 · serviço: getting e row_desc
  antes := d;
  d := replace(d,
    $a$else coalesce(nullif(i.row_group_pt,''), i.row_group_en) end) order by i.sort)$a$,
    $b$else coalesce(nullif(i.row_group_pt,''), i.row_group_en) end,
        'getting', case when ing then coalesce(nullif(i.getting_en,''), i.getting_pt)
                        else coalesce(nullif(i.getting_pt,''), i.getting_en) end,
        'row_desc', case when ing then coalesce(nullif(i.row_desc_en,''), i.row_desc_pt)
                         else coalesce(nullif(i.row_desc_pt,''), i.row_desc_en) end) order by i.sort)$b$);
  if d = antes then raise exception '0115: trecho da linha não encontrado'; end if;

  execute d;
end $$;

insert into ops_migrations (id) values ('0115-getting-there-e-descricao-da-linha') on conflict (id) do nothing;
