-- =====================================================================
-- TUSCAN LANDS · HUB DE VENDAS E OPERAÇÕES
-- Módulo ORDER (confirmação de serviços assinada pelo cliente/agência)
-- Rodar no SQL Editor do projeto Supabase do HUB (não o do CRM).
-- =====================================================================
-- Nota: opportunity_code é texto livre, o número gerado no CRM.
-- Não criei foreign key para ops_opportunities de propósito, para não
-- quebrar nada do que já existe. Se quiser amarrar depois, é um ALTER.
-- =====================================================================

create extension if not exists "pgcrypto";

-- ---------------------------------------------------------------- ORDERS
create table if not exists ops_orders (
  id                uuid primary key default gen_random_uuid(),
  opportunity_code  text not null,
  order_ref         text not null,
  lang              text not null default 'pt',      -- 'pt' | 'en'
  status            text not null default 'draft',   -- draft | sent | confirmed
  agency            text,
  agency_contact    text,
  final_client      text,
  pax_summary       text,
  travel_window     text,
  intro             text,
  internal_notes    text,
  token             text unique not null default encode(gen_random_bytes(16),'hex'),
  token_expires_at  timestamptz,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  confirmed_at      timestamptz
);

create index if not exists ops_orders_opp_idx on ops_orders(opportunity_code);
create index if not exists ops_orders_token_idx on ops_orders(token);

-- ----------------------------------------------------------------- ITEMS
create table if not exists ops_order_items (
  id           uuid primary key default gen_random_uuid(),
  order_id     uuid not null references ops_orders(id) on delete cascade,
  sort         int  not null default 0,
  service_date text,
  title        text not null,
  details      text,
  price        numeric(12,2) not null default 0
);
create index if not exists ops_order_items_order_idx on ops_order_items(order_id);

-- -------------------------------------------------------------- PAYMENTS
create table if not exists ops_order_payments (
  id        uuid primary key default gen_random_uuid(),
  order_id  uuid not null references ops_orders(id) on delete cascade,
  sort      int not null default 0,
  label     text not null,
  due_date  text,
  amount    numeric(12,2) not null default 0,
  status    text not null default 'pending'   -- pending | paid
);
create index if not exists ops_order_payments_order_idx on ops_order_payments(order_id);

-- ---------------------------------------------------------- CONFIRMATIONS
create table if not exists ops_order_confirmations (
  id             uuid primary key default gen_random_uuid(),
  order_id       uuid not null references ops_orders(id) on delete cascade,
  lead_name      text,
  lead_email     text,
  lead_phone     text,
  adults         jsonb not null default '[]'::jsonb,  -- ["Nome Sobrenome", ...]
  children       jsonb not null default '[]'::jsonb,  -- [{"age":7}, ...]
  ack_vehicle    boolean not null default false,
  ack_terms      boolean not null default false,
  signature_name text,
  remarks        text,
  submitted_at   timestamptz not null default now()
);
create index if not exists ops_order_conf_order_idx on ops_order_confirmations(order_id);

-- ==================================================================== RLS
alter table ops_orders              enable row level security;
alter table ops_order_items         enable row level security;
alter table ops_order_payments      enable row level security;
alter table ops_order_confirmations enable row level security;

-- Só usuário logado (você) mexe nas tabelas. O cliente nunca toca direto:
-- ele passa pelas funções abaixo, que rodam com privilégio próprio.
do $$
declare t text;
begin
  foreach t in array array['ops_orders','ops_order_items','ops_order_payments','ops_order_confirmations']
  loop
    execute format('drop policy if exists "auth_all" on %I', t);
    execute format(
      'create policy "auth_all" on %I for all to authenticated using (true) with check (true)', t);
  end loop;
end $$;

-- ============================================== LEITURA PÚBLICA POR TOKEN
create or replace function tl_get_order(p_token text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare o ops_orders%rowtype; result jsonb;
begin
  select * into o from ops_orders where token = p_token;
  if not found then return null; end if;
  if o.token_expires_at is not null and o.token_expires_at < now() then
    return jsonb_build_object('expired', true);
  end if;

  select jsonb_build_object(
    'order', jsonb_build_object(
      'id', o.id, 'opportunity_code', o.opportunity_code, 'order_ref', o.order_ref,
      'lang', o.lang, 'status', o.status, 'agency', o.agency,
      'final_client', o.final_client, 'pax_summary', o.pax_summary,
      'travel_window', o.travel_window, 'intro', o.intro,
      'confirmed_at', o.confirmed_at),
    'items', coalesce((select jsonb_agg(jsonb_build_object(
        'service_date', i.service_date, 'title', i.title,
        'details', i.details, 'price', i.price) order by i.sort)
      from ops_order_items i where i.order_id = o.id), '[]'::jsonb),
    'payments', coalesce((select jsonb_agg(jsonb_build_object(
        'label', p.label, 'due_date', p.due_date,
        'amount', p.amount, 'status', p.status) order by p.sort)
      from ops_order_payments p where p.order_id = o.id), '[]'::jsonb)
  ) into result;

  return result;
end $$;

-- ============================================ ENVIO DA CONFIRMAÇÃO (ANON)
create or replace function tl_submit_confirmation(p_token text, p_payload jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare o ops_orders%rowtype;
begin
  select * into o from ops_orders where token = p_token;
  if not found then return jsonb_build_object('ok', false, 'error', 'not_found'); end if;
  if o.status = 'confirmed' then
    return jsonb_build_object('ok', false, 'error', 'already_confirmed');
  end if;

  insert into ops_order_confirmations
    (order_id, lead_name, lead_email, lead_phone, adults, children,
     ack_vehicle, ack_terms, signature_name, remarks)
  values (o.id,
     p_payload->>'lead_name', p_payload->>'lead_email', p_payload->>'lead_phone',
     coalesce(p_payload->'adults','[]'::jsonb), coalesce(p_payload->'children','[]'::jsonb),
     coalesce((p_payload->>'ack_vehicle')::boolean,false),
     coalesce((p_payload->>'ack_terms')::boolean,false),
     p_payload->>'signature_name', p_payload->>'remarks');

  update ops_orders
     set status='confirmed', confirmed_at=now(), updated_at=now()
   where id=o.id;

  return jsonb_build_object('ok', true);
end $$;

revoke all on function tl_get_order(text) from public;
revoke all on function tl_submit_confirmation(text, jsonb) from public;
grant execute on function tl_get_order(text) to anon, authenticated;
grant execute on function tl_submit_confirmation(text, jsonb) to anon, authenticated;
