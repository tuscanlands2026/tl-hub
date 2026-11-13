-- =====================================================================
-- 0135 · ORDER SEM SUFIXO; PRAZO E PREÇOS DE AREZZO NA TL-064-26
--
-- Instruções dela, 13/11/26:
--   1 · número da order: "não tem nem ponto 1, ponto 2, nada". A order que
--       nasce da proposta leva só o código da oportunidade (TL-064-26), sem
--       ".1". Troca pontual em tl_order_from_quote; orders que já existem
--       não mudam de número.
--   2 · a proposta da TL-064-26 vale até 30/11/2026, 23:59 na Itália.
--   3 · Arezzo, para duas pessoas: a experiência na Steli d'oro custa
--       € 250 por pessoa, € 500 no total, e SOMA; as duas visitas privadas
--       (Steli d'oro e Lorini) são "from € 300", e continuam sem somar.
--
-- Seção 7: troca de função; update na proposta da TL-064-26 e no dia de
-- Arezzo dela, com o sim dela. Só enquanto a proposta não foi respondida.
-- =====================================================================

do $$
declare
  d text; antes text; n int;
  prop uuid := 'e0530000-0000-0000-0000-000000000003';
begin
  -- 1 · número sem sufixo
  d := pg_get_functiondef('public.tl_order_from_quote(uuid)'::regprocedure);
  antes := d;
  d := replace(d,
    $a$select coalesce(o.crm_code, pp.title, 'TL') || '.' ||
         (1 + (select count(*) from ops_orders r where r.opportunity_id = o.id
                 or (r.opportunity_id is null and coalesce(o.crm_code,'') <> ''
                     and r.opportunity_code = o.crm_code)))
    into ref;$a$,
    $b$select coalesce(nullif(o.crm_code,''), pp.title, 'TL') into ref;$b$);
  if d = antes then raise exception '0135: numeração não encontrada em tl_order_from_quote'; end if;
  execute d;

  if exists (select 1 from ops_proposals where id = prop and responded_at is not null) then
    raise exception '0135: a proposta já foi respondida, nada muda';
  end if;

  -- 2 · prazo
  update ops_proposals set token_expires_at = '2026-11-30 22:59:59+00' where id = prop;

  -- 3 · preços de Arezzo
  update ops_proposal_items i set units = (
      select jsonb_agg(case u->>'key'
        when 'steli_lab' then (u - 'price_text_en' - 'price_text')
             || jsonb_build_object('price', 500,
                  'row_desc_en', $t$Two hours at the goldsmith's bench with Steve Angeli · € 250 per person$t$)
        when 'steli_visit'  then u || jsonb_build_object('price_text_en', 'From € 300')
        when 'lorini_visit' then u || jsonb_build_object('price_text_en', 'From € 300')
        else u end order by o)
      from jsonb_array_elements(i.units) with ordinality t(u, o))
   where proposal_id = prop and title_en = 'Arezzo and its goldsmiths';
  get diagnostics n = row_count;
  if n <> 1 then raise exception '0135: o dia de Arezzo não foi encontrado'; end if;
end $$;

insert into ops_migrations (id) values ('0135-order-sem-sufixo-prazo-e-precos-de-arezzo') on conflict (id) do nothing;
