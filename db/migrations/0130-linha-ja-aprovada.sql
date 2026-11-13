-- =====================================================================
-- 0130 · LINHA JÁ APROVADA NA PROPOSTA — SÓ CRIA
--
-- Instrução dela, 13/11/26, na TL-053-26: a agência aprovou os quartos e o
-- carro ("Suite Terrace at Castelfalfi, Junior Suite in Rome, Category 1").
-- Esses viram uma order já, e a v3 da proposta segue para ela escolher só
-- as experiências. Na v3 os quartos e o carro aparecem como APROVADOS: com
-- valor, sem caixinha, fora do total e fora da resposta — senão a segunda
-- order levaria os hotéis de novo.
--
--   ops_proposal_items.approved   true = já aprovado, em order à parte
--
-- Nulo é o de sempre: nenhuma proposta que já existe muda.
--
-- Três trocas pontuais em funções no ar, cada uma conferindo que achou o
-- trecho:
--   1 · tl_get_quote devolve 'approved' em cada linha;
--   2 · tl_submit_quote pula a linha aprovada — não soma, não entra nas
--       linhas da resposta, não vai para o e-mail nem para a order. Tela
--       se contorna; a função não;
--   3 · tl_order_from_quote numera a order contando também as orders que
--       só têm o código TL em texto (opportunity_code). A primeira order da
--       TL-053-26 nasce assim, sem ligar à oportunidade, porque ligar exige
--       proposta aceita, e a v2 fica em aberto por instrução dela. Sem esta
--       troca a segunda order sairia com o mesmo número, .1.
--
-- Seção 7: só alter table add column e troca de função. Sem update, sem
-- delete. Nenhuma tabela do CRM.
-- =====================================================================

alter table ops_proposal_items add column if not exists approved boolean;

do $$
declare d text; antes text;
begin
  -- 1 · tl_get_quote
  d := pg_get_functiondef('public.tl_get_quote(text)'::regprocedure);
  antes := d;
  d := replace(d,
    $a$else coalesce(nullif(i.row_date_pt,''), i.row_date_en) end) order by i.sort)$a$,
    $b$else coalesce(nullif(i.row_date_pt,''), i.row_date_en) end,
        'approved', coalesce(i.approved, false)) order by i.sort)$b$);
  if d = antes then raise exception '0130: trecho da linha não encontrado em tl_get_quote'; end if;
  execute d;

  -- 2 · tl_submit_quote
  d := pg_get_functiondef('public.tl_submit_quote(text,jsonb)'::regprocedure);
  antes := d;
  d := replace(d,
    $a$for it in select * from ops_proposal_items where proposal_id = pp.id order by sort loop$a$,
    $b$for it in select * from ops_proposal_items where proposal_id = pp.id and approved is not true order by sort loop$b$);
  if d = antes then raise exception '0130: laço das linhas não encontrado em tl_submit_quote'; end if;
  execute d;

  -- 3 · tl_order_from_quote
  d := pg_get_functiondef('public.tl_order_from_quote(uuid)'::regprocedure);
  antes := d;
  d := replace(d,
    $a$(1 + (select count(*) from ops_orders r where r.opportunity_id = o.id))$a$,
    $b$(1 + (select count(*) from ops_orders r where r.opportunity_id = o.id
                 or (r.opportunity_id is null and coalesce(o.crm_code,'') <> ''
                     and r.opportunity_code = o.crm_code)))$b$);
  if d = antes then raise exception '0130: numeração não encontrada em tl_order_from_quote'; end if;
  execute d;
end $$;

insert into ops_migrations (id) values ('0130-linha-ja-aprovada') on conflict (id) do nothing;
