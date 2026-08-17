-- =====================================================================
-- TUSCAN LANDS · HUB DE VENDAS E OPERAÇÕES
-- A OPORTUNIDADE COMO OBJETO CENTRAL
--
-- Rodar DEPOIS de tl-hub-orders.sql, no mesmo projeto Supabase.
--
-- Princípio: isto é um repositório consultável, não um sistema de
-- controle. Briefing e proposta existem para serem abertos, filtrados e
-- reaproveitados em vendas futuras. Só uma regra é bloqueio de verdade:
-- order nasce de proposta aprovada. O resto é informação na tela.
--
-- O que este arquivo cria:
--   ops_opportunities   — o objeto central
--   ops_briefings       — etapa 1, uma por oportunidade
--   ops_proposals       — etapa 2, versionada, com linhas de serviço
--   ops_proposal_items  — o material reaproveitável
--   + views de consulta e a trava da order
--
-- Não apaga nem recria nada. A única alteração em tabela existente é
-- ADICIONAR uma coluna nullable em ops_orders. Rodar duas vezes é seguro.
-- =====================================================================

-- ---------------------------------------------------------------------
-- GUARDA DE COLISÃO
-- O CLAUDE.md supõe que exista uma ops_opportunities vinda do CRM. Se
-- existir mesmo, este script PARA aqui sem mudar nada, em vez de seguir
-- com "if not exists" e deixar o hub apontando para uma tabela alheia
-- com outras colunas. Falhar alto é melhor que quebrar em silêncio.
-- ---------------------------------------------------------------------
do $$
begin
  if exists (
    select 1 from information_schema.tables
    where table_schema = 'public' and table_name = 'ops_opportunities'
  ) and not exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'ops_opportunities'
      and column_name = 'crm_code'
  ) then
    raise exception
      'Já existe uma public.ops_opportunities que NÃO é a do hub. Nada foi alterado. Mande a estrutura dela antes de continuar.';
  end if;
end $$;

-- ------------------------------------------------------- OPORTUNIDADES
create table if not exists ops_opportunities (
  id             uuid primary key default gen_random_uuid(),
  crm_code       text,                          -- número do CRM, texto livre
  title          text not null,                 -- "Família Souza · out 2026"
  lang           text not null default 'pt',    -- 'pt' | 'en'
  agency         text,
  agency_contact text,
  final_client   text,
  -- Desfecho explícito. Nada aqui é definitivo: 'lost' volta para 'open'
  -- se o cliente reaparecer, e é isso que costuma acontecer.
  outcome        text not null default 'open',  -- open | won | lost
  lost_reason    text,                          -- opcional, é informação
  internal_notes text,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now(),
  closed_at      timestamptz,
  constraint ops_opportunities_outcome_chk
    check (outcome in ('open','won','lost'))
);

create index if not exists ops_opp_crm_idx     on ops_opportunities(crm_code);
create index if not exists ops_opp_agency_idx  on ops_opportunities(agency);
create index if not exists ops_opp_outcome_idx on ops_opportunities(outcome);

-- ------------------------------------------------ ETAPA 1 · BRIEFING
-- Uma por oportunidade. completed_at nulo não bloqueia nada: aparece
-- como pendência na tela. O briefing é material de consulta, e é por
-- isso que os campos são texto livre e não formulário rígido.
create table if not exists ops_briefings (
  id               uuid primary key default gen_random_uuid(),
  opportunity_id   uuid not null unique
                   references ops_opportunities(id) on delete cascade,
  travel_window    text,
  pax_summary      text,
  scope            text,   -- o que a agência está pedindo
  budget_note      text,
  constraints_note text,   -- mobilidade, alimentação, datas fixas
  source           text,   -- de onde veio o pedido
  completed_at     timestamptz,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);

-- ------------------------------------------------ ETAPA 2 · PROPOSTAS
-- Várias por oportunidade: negociação gera versão 2, 3...
-- outcome nulo = aguardando, e fica aguardando o tempo que precisar.
-- Uma recusada pode ser aceita meses depois: basta mudar o outcome.
create table if not exists ops_proposals (
  id              uuid primary key default gen_random_uuid(),
  opportunity_id  uuid not null references ops_opportunities(id) on delete cascade,
  version         int  not null default 1,
  title           text,
  summary         text,
  sent_at         timestamptz,
  decided_at      timestamptz,
  outcome         text,   -- null = aguardando | accepted | refused
  -- Venda fechada por telefone é realidade. Sem 'verbal' o sistema
  -- travaria a operação em vez de ajudar.
  acceptance_mode text,   -- written | verbal   (só quando accepted)
  refusal_reason  text,   -- opcional, é informação
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  unique (opportunity_id, version),
  constraint ops_proposals_outcome_chk
    check (outcome is null or outcome in ('accepted','refused')),
  -- Atenção ao coalesce e ao "is distinct from": escrito como
  -- "outcome <> 'accepted' or acceptance_mode in (...)", com
  -- acceptance_mode nulo a expressão dá NULL, e CHECK aceita NULL como
  -- se fosse verdadeiro. A restrição não bloquearia nada.
  constraint ops_proposals_accept_chk
    check (outcome is distinct from 'accepted'
           or coalesce(acceptance_mode,'') in ('written','verbal'))
);

create index if not exists ops_prop_opp_idx     on ops_proposals(opportunity_id);
create index if not exists ops_prop_outcome_idx on ops_proposals(outcome);

-- Só UMA proposta aceita por oportunidade, a qualquer momento.
create unique index if not exists ops_prop_one_accepted_idx
  on ops_proposals(opportunity_id) where outcome = 'accepted';

-- ------------------------------------- O MATERIAL REAPROVEITÁVEL
-- Mesma forma de ops_order_items de propósito: uma linha aprovada
-- vira linha de order sem reescrever nada.
create table if not exists ops_proposal_items (
  id           uuid primary key default gen_random_uuid(),
  proposal_id  uuid not null references ops_proposals(id) on delete cascade,
  sort         int  not null default 0,
  service_date text,
  title        text not null,
  details      text,
  price        numeric(12,2) not null default 0
);

create index if not exists ops_prop_items_prop_idx on ops_proposal_items(proposal_id);
-- Busca por texto no título do serviço, que é como se procura material.
create index if not exists ops_prop_items_title_idx
  on ops_proposal_items(lower(title));

-- ------------------------------------- ORDER PASSA A SER FILHA DA OPP
-- Coluna nova e nullable: nenhuma order existente é afetada, e o app
-- atual continua funcionando enquanto a tela não for atualizada.
alter table ops_orders
  add column if not exists opportunity_id uuid references ops_opportunities(id);

create index if not exists ops_orders_opportunity_idx
  on ops_orders(opportunity_id);

-- =====================================================================
-- A ÚNICA TRAVA: ORDER NASCE DE PROPOSTA APROVADA
-- Vive no banco porque tela pode ser contornada.
-- =====================================================================
create or replace function tl_guard_order()
returns trigger language plpgsql as $$
begin
  -- Order sem oportunidade é o caminho antigo, ainda permitido.
  if new.opportunity_id is null then
    return new;
  end if;

  if not exists (
    select 1 from ops_proposals
    where opportunity_id = new.opportunity_id and outcome = 'accepted'
  ) then
    raise exception
      'Order bloqueada: a oportunidade % não tem proposta aprovada.', new.opportunity_id;
  end if;
  return new;
end $$;

drop trigger if exists ops_orders_guard on ops_orders;
create trigger ops_orders_guard
  before insert or update of opportunity_id on ops_orders
  for each row execute function tl_guard_order();

-- =====================================================================
-- ETAPA DERIVADA
-- Não guardamos "stage" em coluna: valor guardado desanda em relação aos
-- fatos. A etapa é lida dos filhos, então nunca mente.
-- =====================================================================
create or replace function tl_opportunity_stage(p_opp uuid)
returns text language sql stable as $$
  select case
    when o.outcome = 'lost' then 'closed_lost'
    when o.outcome = 'won'  then 'closed_won'
    when not exists (select 1 from ops_proposals p
                     where p.opportunity_id = o.id
                       and p.outcome = 'accepted')      then 'proposal'
    when not exists (select 1 from ops_orders r
                     where r.opportunity_id = o.id
                       and r.status = 'confirmed')      then 'order'
    else 'operating'
  end
  from ops_opportunities o where o.id = p_opp;
$$;

-- =====================================================================
-- AS CAIXINHAS · views de consulta
-- =====================================================================

-- Caixinha 1 · o quadro geral, uma linha por oportunidade.
create or replace view ops_opportunities_board as
select
  o.id, o.crm_code, o.title, o.agency, o.final_client, o.lang, o.outcome,
  tl_opportunity_stage(o.id)                                    as stage,
  (select b.completed_at from ops_briefings b
    where b.opportunity_id = o.id)                              as briefing_done_at,
  -- aviso, não bloqueio
  (select b.completed_at is null from ops_briefings b
    where b.opportunity_id = o.id)                              as briefing_pending,
  (select count(*) from ops_proposals p
    where p.opportunity_id = o.id)                              as proposals,
  (select p.version from ops_proposals p
    where p.opportunity_id = o.id and p.outcome = 'accepted')    as accepted_version,
  (select count(*) from ops_orders r
    where r.opportunity_id = o.id)                              as orders,
  o.created_at, o.updated_at
from ops_opportunities o;

-- Caixinha 2 · Briefings, para abrir por agência.
create or replace view ops_briefings_box as
select
  b.id, b.opportunity_id,
  o.agency, o.final_client, o.crm_code, o.title,
  b.travel_window, b.pax_summary, b.scope, b.budget_note,
  b.constraints_note, b.source,
  b.completed_at is not null as completo,
  b.created_at, b.updated_at
from ops_briefings b
join ops_opportunities o on o.id = b.opportunity_id;

-- Caixinha 3 · Propostas, incluindo as que não viraram venda.
-- É o histórico consultável: recusada e aguardando continuam aqui.
create or replace view ops_proposals_box as
select
  p.id, p.opportunity_id, p.version, p.title, p.summary,
  o.agency, o.final_client, o.crm_code,
  coalesce(p.outcome, 'aguardando')                    as situacao,
  p.acceptance_mode, p.refusal_reason,
  p.sent_at, p.decided_at,
  (select count(*) from ops_proposal_items i
    where i.proposal_id = p.id)                        as servicos,
  (select coalesce(sum(i.price),0) from ops_proposal_items i
    where i.proposal_id = p.id)                        as total,
  p.created_at, p.updated_at
from ops_proposals p
join ops_opportunities o on o.id = p.opportunity_id;

-- Caixinha 4 · O acervo de serviços já escritos.
-- Junta o que existe em propostas e em orders, para você buscar
-- "Siena" e reaproveitar o texto em vez de escrever de novo.
create or replace view ops_service_library as
select
  'proposta'::text            as origem,
  i.title, i.details, i.price, i.service_date,
  o.agency, o.final_client, o.crm_code,
  p.opportunity_id,
  coalesce(p.outcome,'aguardando')  as situacao_origem,
  p.created_at                      as escrito_em
from ops_proposal_items i
join ops_proposals p     on p.id = i.proposal_id
join ops_opportunities o on o.id = p.opportunity_id
union all
select
  'order'::text               as origem,
  i.title, i.details, i.price, i.service_date,
  r.agency, r.final_client, r.opportunity_code,
  r.opportunity_id,
  r.status                          as situacao_origem,
  r.created_at                      as escrito_em
from ops_order_items i
join ops_orders r on r.id = i.order_id;

-- ==================================================================== RLS
alter table ops_opportunities  enable row level security;
alter table ops_briefings      enable row level security;
alter table ops_proposals      enable row level security;
alter table ops_proposal_items enable row level security;

-- Mesmo padrão do módulo Order: só usuário logado. Cliente e agência
-- nunca falam com estas tabelas.
do $$
declare t text;
begin
  foreach t in array array['ops_opportunities','ops_briefings',
                           'ops_proposals','ops_proposal_items']
  loop
    execute format('drop policy if exists "auth_all" on %I', t);
    execute format(
      'create policy "auth_all" on %I for all to authenticated using (true) with check (true)', t);
  end loop;
end $$;

-- Views são de consulta interna. anon não lê nenhuma.
do $$
declare v text;
begin
  foreach v in array array['ops_opportunities_board','ops_briefings_box',
                           'ops_proposals_box','ops_service_library']
  loop
    execute format('revoke all on %I from anon', v);
    execute format('grant select on %I to authenticated', v);
  end loop;
end $$;

-- ------------------------------------------------------------- updated_at
create or replace function tl_touch_updated_at()
returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end $$;

do $$
declare t text;
begin
  foreach t in array array['ops_opportunities','ops_briefings','ops_proposals']
  loop
    execute format('drop trigger if exists %I on %I', t||'_touch', t);
    execute format(
      'create trigger %I before update on %I for each row
       execute function tl_touch_updated_at()', t||'_touch', t);
  end loop;
end $$;
