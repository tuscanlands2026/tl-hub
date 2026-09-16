-- =====================================================================
-- 0040 — MÓDULO FORNECEDORES
--
-- Hoje os fornecedores estão na memória dela, no Google Maps e em emails.
-- Esta migração é o lugar onde eles passam a morar: ficha, serviços com
-- preço, quartos com tarifa, contatos, fotos e anexos.
--
-- Três decisões que estão no desenho e não em manual nenhum:
--
-- 1) LISTA FECHADA É CHECK, NÃO TEXTO LIVRE. Categoria, região, status,
--    base do preço, unidade, IVA, nome na proposta e as sete linhas da
--    business suite só aceitam os valores combinados. É a IA que preenche
--    a maior parte disso; uma linha de suite escrita diferente é um
--    fornecedor que desaparece do filtro sem ninguém perceber.
--
-- 2) NET OU GROSS VIVE NO SERVIÇO, e nasce "Not stated". Preço sem base
--    declarada não pode se passar por net: é a diferença entre margem e
--    prejuízo, e some no dia em que outra pessoa lançar.
--
-- 3) O CRM veio antes do Hub e tem o cadastro dele (fornecedores_db), que
--    alimenta Booking e custos. A ficha nasce AQUI, e vai para o CRM só
--    quando ela clicar — não faz sentido encher o CRM de fornecedor com
--    quem ela não trabalha sempre. A ligação fica em crm_fornecedor_id,
--    preenchida pela função tl_fornecedor_para_crm (0041/fase própria).
-- =====================================================================

-- ------------------------------------------------------------- listas
-- Em um lugar só, para o check e a tela lerem a mesma verdade.
create or replace function tl_forn_listas(p_qual text)
returns text[] language sql immutable as $$
  select case p_qual
    when 'category' then array['Hotel / Accommodation','Winery','Restaurant',
      'Experience / Activity','Guide','Transfer / Transport','Venue / Events',
      'Private Chef / Catering','Other']
    when 'region' then array['Tuscany','Umbria','Lazio','Other']
    when 'status' then array['Active','To test','In negotiation','Do not use']
    when 'suite' then array['Ground Services','TL Selected Stays','TL Signature Programs',
      'TL Signature Tours and Experiences','VIP Incentive Travel (MICE)',
      'Private Events & Milestones','Concierge Atelier for hotels in Florence']
    when 'price_basis' then array['Net','Gross','Not stated']
    when 'price_unit' then array['per person','per group (total)','per vehicle',
      'per hour','per night','per room per night','flat fee']
    when 'vat' then array['included','excluded','exempt','not stated']
    when 'name_rule' then array['Show supplier name','Hide supplier name']
  end
$$;

-- ------------------------------------------------------------ fornecedor
create table if not exists ops_suppliers (
  id            uuid primary key default gen_random_uuid(),
  name          text not null,
  legal_name    text,
  category      text not null,
  subcategories text[] not null default '{}',
  business_suite text[] not null default '{}',
  status        text not null default 'To test',
  region        text,
  city          text,
  service_area  text,          -- fornecedor móvel: chef, guia, motorista
  address       text,
  lat           double precision,
  lng           double precision,
  coords_approximate boolean not null default true,
  website       text,
  instagram     text,
  languages     text[] not null default '{}',
  rate_type     text,          -- "Dedicated agency rate (net)", "Commissionable 10%"
  supplier_commission text,    -- só faz sentido quando a tarifa é gross
  vat_status    text not null default 'not stated',
  rates_valid_for text,        -- "2027"
  name_rule     text not null default 'Hide supplier name',
  bank_details  text,          -- SENSÍVEL: não sai em proposta nem em export
  payment_terms text,
  booking_terms text,
  cancellation_policy text,
  capacities    text,
  accommodation_summary text,  -- nº de unidades e máx. de hóspedes
  accommodation_notes  text,   -- comodidades comuns a todos os quartos
  highlights    text[] not null default '{}',
  tags          text[] not null default '{}',
  summary       text,
  open_points   text[] not null default '{}',   -- o que falta confirmar
  internal_notes text,
  source_text   text,          -- material bruto de onde a ficha saiu
  -- Ligação com o cadastro do CRM. Sem FK de propósito: tabela de outro
  -- app, no mesmo banco. A ligação é uma escolha dela, por botão.
  crm_fornecedor_id uuid,
  -- Nome normalizado, para achar duplicado ("Borgo Vescine" = "borgovescine").
  name_key      text generated always as
                (lower(regexp_replace(name, '[^A-Za-z0-9]+', '', 'g'))) stored,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  constraint ops_suppliers_category_ck  check (category = any(tl_forn_listas('category'))),
  constraint ops_suppliers_region_ck    check (region is null or region = any(tl_forn_listas('region'))),
  constraint ops_suppliers_status_ck    check (status = any(tl_forn_listas('status'))),
  constraint ops_suppliers_suite_ck     check (business_suite <@ tl_forn_listas('suite')),
  constraint ops_suppliers_vat_ck       check (vat_status = any(tl_forn_listas('vat'))),
  constraint ops_suppliers_namerule_ck  check (name_rule = any(tl_forn_listas('name_rule')))
);
comment on table ops_suppliers is
  'Fornecedores da TL: quem presta o serviço, o que cobra e em que condições. O custo mora aqui; margem, comissão e IVA são do módulo de propostas.';
comment on column ops_suppliers.bank_details is
  'Dado sensível. Não entra em proposta nem em exportação para terceiros.';
comment on column ops_suppliers.name_rule is
  'Se o nome do fornecedor pode aparecer na proposta. Hotel e restaurante mostram; o resto esconde.';
comment on column ops_suppliers.crm_fornecedor_id is
  'fornecedores_db.id do CRM, quando ela mandou copiar. Sem FK: outro app, mesma base.';

create index if not exists ops_suppliers_name_idx   on ops_suppliers (name_key);
create index if not exists ops_suppliers_cat_idx    on ops_suppliers (category, region, status);
create index if not exists ops_suppliers_coords_idx on ops_suppliers (lat, lng);
create index if not exists ops_suppliers_suite_idx  on ops_suppliers using gin (business_suite);
create index if not exists ops_suppliers_tags_idx   on ops_suppliers using gin (tags);

-- --------------------------------------------------------------- contatos
create table if not exists ops_supplier_contacts (
  id          uuid primary key default gen_random_uuid(),
  supplier_id uuid not null references ops_suppliers(id) on delete cascade,
  name text, role text, email text, phone text, whatsapp text,
  sort_order  int not null default 0
);
create index if not exists ops_supplier_contacts_sup_idx on ops_supplier_contacts (supplier_id, sort_order);

-- ---------------------------------------------------------------- serviços
create table if not exists ops_supplier_services (
  id          uuid primary key default gen_random_uuid(),
  supplier_id uuid not null references ops_suppliers(id) on delete cascade,
  name        text not null,
  type        text,
  description text,
  duration    text,
  languages   text[] not null default '{}',
  includes    text[] not null default '{}',
  price_adult numeric(12,2),
  price_child numeric(12,2),
  price_basis text not null default 'Not stated',
  price_unit  text,
  price_notes text,            -- faixas etárias, grátis até X, suplementos
  min_pax     int,
  max_pax     int,
  extras      text,
  schedule    text,
  meeting_point text,
  restrictions  text,
  notes       text,
  -- Bloco neutro: o que vai para a proposta quando o nome fica escondido.
  -- Não pode permitir achar o fornecedor no Google (regra 3.4 da spec).
  proposal_name        text,
  proposal_description text,
  sort_order  int not null default 0,
  constraint ops_services_basis_ck check (price_basis = any(tl_forn_listas('price_basis'))),
  constraint ops_services_unit_ck  check (price_unit is null or price_unit = any(tl_forn_listas('price_unit')))
);
comment on column ops_supplier_services.price_basis is
  'Net, Gross ou Not stated. Nasce Not stated: preço sem base declarada não se passa por net.';
create index if not exists ops_services_sup_idx on ops_supplier_services (supplier_id, sort_order);

-- Preço TOTAL por número de pax (tour privado): uma linha por faixa.
create table if not exists ops_service_price_tiers (
  id          uuid primary key default gen_random_uuid(),
  service_id  uuid not null references ops_supplier_services(id) on delete cascade,
  pax         int not null check (pax > 0),
  total_price numeric(12,2) not null,
  unique (service_id, pax)
);
comment on table ops_service_price_tiers is
  'Faixa de preço por tamanho de grupo, quando o valor é total. A tela mostra o total e o por pessoa.';

-- ----------------------------------------------------------------- quartos
create table if not exists ops_room_types (
  id          uuid primary key default gen_random_uuid(),
  supplier_id uuid not null references ops_suppliers(id) on delete cascade,
  name        text not null,
  -- METRAGEM EM DOIS MODOS. Ela pediu m² e sq ft juntos: o cliente é
  -- americano e não faz a conta de cabeça. O texto guarda o que a fonte
  -- disse ("approx. 22-24 m²", com faixa e tudo), e os dois números são
  -- o que a tela usa para mostrar as duas unidades — inclusive na faixa
  -- ("22–24 m² · 237–258 sq ft"). Converter na hora de exibir seria
  -- refazer a leitura do texto a cada tela.
  size        text,            -- como a fonte diz, sempre em m²
  size_m2_min numeric(8,2),
  size_m2_max numeric(8,2),    -- igual ao min quando não é faixa
  max_occupancy text,
  beds        text,
  view        text,
  units       text,            -- quantos quartos deste tipo
  description text,
  highlights  text[] not null default '{}',   -- o que distingue esta categoria
  sort_order  int not null default 0
);
comment on column ops_room_types.size_m2_min is
  'Metragem em m² para a tela mostrar m² e sq ft. Faixa usa min e max; valor único repete nos dois.';
create index if not exists ops_room_types_sup_idx on ops_room_types (supplier_id, sort_order);

create table if not exists ops_room_rates (
  id           uuid primary key default gen_random_uuid(),
  room_type_id uuid not null references ops_room_types(id) on delete cascade,
  season text, dates text, board text,        -- BB, HB, RO...
  price        numeric(12,2),
  price_unit   text not null default 'per room per night',
  price_basis  text not null default 'Not stated',
  sort_order   int not null default 0,
  constraint ops_room_rates_unit_ck  check (price_unit = any(tl_forn_listas('price_unit'))),
  constraint ops_room_rates_basis_ck check (price_basis = any(tl_forn_listas('price_basis')))
);
create index if not exists ops_room_rates_type_idx on ops_room_rates (room_type_id, sort_order);

-- ------------------------------------------------------------------- fotos
-- A foto pode ser do fornecedor, de um serviço ou de um tipo de quarto.
create table if not exists ops_supplier_photos (
  id           uuid primary key default gen_random_uuid(),
  supplier_id  uuid not null references ops_suppliers(id) on delete cascade,
  service_id   uuid references ops_supplier_services(id) on delete set null,
  room_type_id uuid references ops_room_types(id) on delete set null,
  url          text,           -- endereço público (balde do Hub ou site)
  storage_path text,           -- caminho no balde, quando o envio foi dela
  drive_url    text,           -- original em alta, no Drive
  source_url   text,           -- de onde a foto veio, quando não é dela
  caption      text,           -- em inglês
  ok_for_proposal boolean not null default false,  -- sem logo nem nome visível
  usage_cleared   boolean not null default false,  -- fornecedor liberou o uso
  sort_order   int not null default 0,
  created_at   timestamptz not null default now()
);
comment on column ops_supplier_photos.usage_cleared is
  'Uso liberado pelo fornecedor. Foto puxada do site do fornecedor nasce false: direito de imagem não se presume.';
create index if not exists ops_supplier_photos_sup_idx on ops_supplier_photos (supplier_id, sort_order);

-- ------------------------------------------------------------------ anexos
-- Tarifário, contrato, PDF que chegou por email. Balde PRIVADO: documento
-- comercial não fica de pé aberto para quem descobre o endereço.
create table if not exists ops_supplier_files (
  id          uuid primary key default gen_random_uuid(),
  supplier_id uuid not null references ops_suppliers(id) on delete cascade,
  bucket      text not null default 'ops-fornecedores',
  storage_path text not null,
  file_name   text,
  created_at  timestamptz not null default now()
);
create index if not exists ops_supplier_files_sup_idx on ops_supplier_files (supplier_id, created_at);

-- --------------------------------------------------------------- updated_at
do $$
begin
  execute 'drop trigger if exists ops_suppliers_touch on ops_suppliers';
  execute 'create trigger ops_suppliers_touch before update on ops_suppliers
           for each row execute function tl_touch_updated_at()';
end $$;

-- ---------------------------------------------------------------------- RLS
-- Padrão do Hub: quem está logado vê e mexe; anon não enxerga nada. O link
-- público da proposta usa funções tl_ próprias, e nenhuma delas lê daqui.
do $$
declare t text;
begin
  foreach t in array array['ops_suppliers','ops_supplier_contacts','ops_supplier_services',
                           'ops_service_price_tiers','ops_room_types','ops_room_rates',
                           'ops_supplier_photos','ops_supplier_files']
  loop
    execute format('alter table %I enable row level security', t);
    execute format('drop policy if exists "auth_all" on %I', t);
    execute format('create policy "auth_all" on %I for all to authenticated using (true) with check (true)', t);
    execute format('revoke all on %I from anon', t);
  end loop;
end $$;

insert into ops_migrations (id) values ('0040-fornecedores') on conflict (id) do nothing;
