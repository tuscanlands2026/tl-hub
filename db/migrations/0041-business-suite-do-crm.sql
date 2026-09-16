-- =====================================================================
-- 0041 — A BUSINESS SUITE PASSA A SER A LISTA DO CRM
--
-- A 0040 usou as sete linhas que estavam na especificação. Ela corrigiu:
-- as linhas de verdade são SEIS, e são as do CRM, palavra por palavra —
-- TL Selected Stays, TL Signature Experiences, TL Signature Programs,
-- Concierge, Ground Services, MICE e Exclusive Events.
--
-- Isto não é detalhe de rótulo. A linha é o elo entre o fornecedor daqui e
-- a venda lá no CRM (public.tipos_servico): nome diferente é linha que não
-- encontra a venda. "TL Signature Tours and Experiences" e
-- "TL Signature Experiences" são a mesma coisa para ela e coisas diferentes
-- para o banco.
--
-- Consultoria existe no CRM e NÃO entra aqui: é serviço que a TL vende, não
-- linha em que um fornecedor entrega.
--
-- A conversão junta duas linhas antigas numa: "Private Events & Milestones"
-- (casamento, aniversário) vai para "MICE e Exclusive Events", porque é onde
-- o CRM põe evento exclusivo — não existe linha separada de casamento lá.
-- =====================================================================

create or replace function tl_forn_listas(p_qual text)
returns text[] language sql immutable as $$
  select case p_qual
    when 'category' then array['Hotel / Accommodation','Winery','Restaurant',
      'Experience / Activity','Guide','Transfer / Transport','Venue / Events',
      'Private Chef / Catering','Other']
    when 'region' then array['Tuscany','Umbria','Lazio','Other']
    when 'status' then array['Active','To test','In negotiation','Do not use']
    -- a lista do CRM, sem Consultoria
    when 'suite' then array['TL Selected Stays','TL Signature Experiences',
      'TL Signature Programs','Concierge','Ground Services','MICE e Exclusive Events']
    when 'price_basis' then array['Net','Gross','Not stated']
    when 'price_unit' then array['per person','per group (total)','per vehicle',
      'per hour','per night','per room per night','flat fee']
    when 'vat' then array['included','excluded','exempt','not stated']
    when 'name_rule' then array['Show supplier name','Hide supplier name']
  end
$$;

-- Converte o que já está gravado. Sem isto, a ficha antiga fica com uma
-- linha que o filtro novo não conhece e o fornecedor desaparece da busca.
update ops_suppliers set business_suite = (
  select coalesce(array_agg(distinct nova order by nova), '{}'::text[])
    from (
      select case s
        when 'TL Signature Tours and Experiences'        then 'TL Signature Experiences'
        when 'VIP Incentive Travel (MICE)'               then 'MICE e Exclusive Events'
        when 'Private Events & Milestones'               then 'MICE e Exclusive Events'
        when 'Concierge Atelier for hotels in Florence'  then 'Concierge'
        else s end as nova
        from unnest(business_suite) as s
    ) x
    where nova = any(tl_forn_listas('suite'))
)
where business_suite <> '{}'::text[]
  and not (business_suite <@ tl_forn_listas('suite'));

insert into ops_migrations (id) values ('0041-business-suite-do-crm') on conflict (id) do nothing;
