-- =====================================================================
-- 0132 · NÚMERO PRÓPRIO DA PROPOSTA E PREÇO "A PARTIR DE" — SÓ CRIA
--
-- Instrução dela, 13/11/26, na v3 da Emily:
--   · "essa proposta tem um novo número: TL-064-26". O número que a peça
--     mostra vem da oportunidade (o.crm_code), e a v1 e a v2 são da mesma
--     oportunidade, TL-053-26. Mudar a oportunidade mudaria as duas.
--     ops_proposals.ref_code é o número daquela proposta; vazio, vale o da
--     oportunidade, como sempre.
--   · o dia de Arezzo tem três escolhas com valor "a partir de" — "From
--     € 350 per person" —, que viram orçamento depois. units[].price_text
--     (e price_text_en) é o que sai no lugar do valor; a opção fica sem
--     price, e por isso não soma.
--
-- tl_get_quote, por troca pontual: 'crm_code' passa a ser
-- coalesce(ref_code, o.crm_code), e cada opção devolve 'price_text'.
--
-- Seção 7: só alter table add column e troca de função. Sem update, sem
-- delete. Nenhuma tabela do CRM.
-- =====================================================================

alter table ops_proposals add column if not exists ref_code text;

do $$
declare d text; antes text;
begin
  d := pg_get_functiondef('public.tl_get_quote(text)'::regprocedure);

  antes := d;
  d := replace(d, $a$'crm_code', o.crm_code,$a$,
                  $b$'crm_code', coalesce(nullif(btrim(pp.ref_code),''), o.crm_code),$b$);
  if d = antes then raise exception '0132: crm_code não encontrado em tl_get_quote'; end if;

  antes := d;
  d := replace(d, $a$'links', coalesce(u->'links', '[]'::jsonb)) order by ord)$a$,
                  $b$'links', coalesce(u->'links', '[]'::jsonb),
            'price_text', case when ing then coalesce(nullif(u->>'price_text_en',''), u->>'price_text')
                               else coalesce(nullif(u->>'price_text',''), u->>'price_text_en') end) order by ord)$b$);
  if d = antes then raise exception '0132: trecho das opções não encontrado em tl_get_quote'; end if;

  execute d;
end $$;

insert into ops_migrations (id) values ('0132-numero-da-proposta-e-preco-em-texto') on conflict (id) do nothing;
