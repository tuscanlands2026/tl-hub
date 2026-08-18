-- =====================================================================
-- TUSCAN LANDS · HUB DE VENDAS E OPERAÇÕES
-- CHECKOUT CONFIGURÁVEL + LINK DOS TERMOS
--
-- Rodar DEPOIS de tl-hub-orders.sql, no mesmo projeto Supabase.
-- Rodar ANTES de tl-hub-notify.sql (o e-mail lê o que este arquivo cria).
--
-- Ordem completa dos arquivos:
--   1. tl-hub-orders.sql
--   2. tl-hub-opportunities.sql
--   3. tl-hub-checkout.sql        <- este
--   4. tl-hub-notify.sql          <- reaplicar, foi reescrito
--
-- ---------------------------------------------------------------------
-- CONFERÊNCIA DA SEÇÃO 7 DO PLANO — feita antes de entregar, por escrito.
-- Objetos que este arquivo cria ou altera, um a um:
--   ops_orders                (alter add column, 2 colunas novas)
--   ops_order_confirmations   (alter add column, 1 coluna nova)
--   ops_order_fields          (create table)
--   tl_get_order              (replace — função do hub, nasceu em
--                              tl-hub-orders.sql, não é objeto do CRM)
--   tl_submit_confirmation    (replace — idem)
-- Nenhum drop de tabela. Nenhum delete, truncate ou update de dados.
-- Nenhuma tabela do CRM é lida, escrita ou citada. Nenhum comando
-- percorre o schema. Nenhuma service_role key aparece aqui.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1 · COLUNAS NOVAS NA ORDER
--
-- terms_url: endereço dos termos e condições completos publicados. O
-- texto integral continua dentro do documento, na constante TERMS. O
-- link é adicional, não substituto: um link é uma promessa que pode
-- quebrar, e o que o cliente assinou tem de estar no papel que ele
-- assinou.
--
-- checkout_config: quais blocos fixos do checkout aparecem para a
-- agência e o que já vai preenchido. Nulo = tudo aparece vazio, que é
-- exatamente o comportamento de hoje. Nenhuma order existente muda.
-- ---------------------------------------------------------------------
alter table ops_orders add column if not exists terms_url       text;
alter table ops_orders add column if not exists checkout_config jsonb;

comment on column ops_orders.terms_url is
  'URL pública dos termos e condições. Some do documento quando vazio.';
comment on column ops_orders.checkout_config is
  'Blocos fixos do checkout: {"lead":"blank|prefilled|off","adults":...,'
  '"children":...,"ack_vehicle":bool,"remarks":bool,"prefill":{...}}. '
  'Nulo = tudo blank, tudo ligado.';

-- ---------------------------------------------------------------------
-- 2 · OS CAMPOS VARIÁVEIS DAQUELE CHECKOUT
--
-- Os três estados da seção 4 do plano:
--   não aparece            -> a linha não existe nesta tabela
--   aparece vazio          -> mode = 'blank'
--   aparece preenchido     -> mode = 'prefilled', com prefill_value
--
-- "Não aparece" é ausência de linha, e não um terceiro valor em mode,
-- porque campo que não aparece não tem estado nenhum a guardar: não tem
-- ordem, não tem obrigatoriedade, não tem valor. Guardar linha desligada
-- criaria a chance de ela vazar para o documento por engano.
--
-- group_key é o tipo de serviço (transfer, tour, hotel, dinner,
-- experience, general). Serve para agrupar na tela e no e-mail.
-- ---------------------------------------------------------------------
create table if not exists ops_order_fields (
  id            uuid primary key default gen_random_uuid(),
  order_id      uuid not null references ops_orders(id) on delete cascade,
  sort          int  not null default 0,
  group_key     text not null default 'general',
  field_key     text not null,               -- 'transfer.flight_in'
  label_pt      text not null,
  label_en      text,                        -- nulo cai no label_pt
  input_type    text not null default 'text',-- text|textarea|number|date|select|checkbox
  options       jsonb not null default '[]'::jsonb,  -- só para select
  required      boolean not null default false,
  mode          text not null default 'blank',       -- blank|prefilled
  prefill_value text,
  help_pt       text,
  help_en       text,
  constraint ops_order_fields_mode_chk
    check (mode in ('blank','prefilled')),
  constraint ops_order_fields_type_chk
    check (input_type in ('text','textarea','number','date','select','checkbox')),
  -- Mesmo campo duas vezes no mesmo checkout é sempre engano.
  constraint ops_order_fields_unique unique (order_id, field_key)
);

create index if not exists ops_order_fields_order_idx on ops_order_fields(order_id);

alter table ops_order_fields enable row level security;
drop policy if exists "auth_all" on ops_order_fields;
create policy "auth_all" on ops_order_fields
  for all to authenticated using (true) with check (true);

-- ---------------------------------------------------------------------
-- 3 · O QUE A AGÊNCIA RESPONDEU NOS CAMPOS VARIÁVEIS
--
-- Guardado como retrato, não como referência: rótulo, estado e valor
-- juntos, no idioma em que foram mostrados. Se a configuração da order
-- mudar depois, o que a agência assinou continua legível exatamente
-- como estava na tela dela. Referência a ops_order_fields mentiria.
-- ---------------------------------------------------------------------
alter table ops_order_confirmations
  add column if not exists fields jsonb not null default '[]'::jsonb;

comment on column ops_order_confirmations.fields is
  'Retrato dos campos variáveis no momento do envio: '
  '[{"key","label_pt","label_en","value","mode","required","group_key"}]';

-- =====================================================================
-- 4 · LEITURA PÚBLICA POR TOKEN — agora carrega campos, config e link
-- =====================================================================
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
      'terms_url', o.terms_url,
      'checkout_config', coalesce(o.checkout_config, '{}'::jsonb),
      'confirmed_at', o.confirmed_at),
    'items', coalesce((select jsonb_agg(jsonb_build_object(
        'service_date', i.service_date, 'title', i.title,
        'details', i.details, 'price', i.price) order by i.sort)
      from ops_order_items i where i.order_id = o.id), '[]'::jsonb),
    'payments', coalesce((select jsonb_agg(jsonb_build_object(
        'label', p.label, 'due_date', p.due_date,
        'amount', p.amount, 'status', p.status) order by p.sort)
      from ops_order_payments p where p.order_id = o.id), '[]'::jsonb),
    -- Sem id interno: o navegador do cliente não precisa dele.
    'fields', coalesce((select jsonb_agg(jsonb_build_object(
        'field_key', f.field_key, 'group_key', f.group_key,
        'label_pt', f.label_pt, 'label_en', f.label_en,
        'input_type', f.input_type, 'options', f.options,
        'required', f.required, 'mode', f.mode,
        'prefill_value', f.prefill_value,
        'help_pt', f.help_pt, 'help_en', f.help_en) order by f.sort)
      from ops_order_fields f where f.order_id = o.id), '[]'::jsonb)
  ) into result;

  return result;
end $$;

-- =====================================================================
-- 5 · ENVIO DA CONFIRMAÇÃO
--
-- A validação passa a existir aqui dentro, e não só na tela. Tela se
-- contorna com o console aberto; esta função não. O que a função exige
-- é exatamente o que a configuração da order manda exigir — nem mais,
-- para não travar venda legítima, nem menos, para não gravar
-- confirmação sem nome de quem assinou.
--
-- O retrato dos campos é montado a partir de ops_order_fields, nunca do
-- que o navegador mandou. Campo que a Maria Fernanda não configurou não
-- entra na confirmação mesmo que apareça no payload.
-- =====================================================================
create or replace function tl_submit_confirmation(p_token text, p_payload jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  o        ops_orders%rowtype;
  cfg      jsonb;
  f        ops_order_fields%rowtype;
  v        text;
  snap     jsonb := '[]'::jsonb;
  missing  text[] := '{}';
  adults   jsonb;
  b_lead   text;
  b_adults text;
begin
  select * into o from ops_orders where token = p_token;
  if not found then return jsonb_build_object('ok', false, 'error', 'not_found'); end if;
  if o.token_expires_at is not null and o.token_expires_at < now() then
    return jsonb_build_object('ok', false, 'error', 'expired');
  end if;
  if o.status = 'confirmed' then
    return jsonb_build_object('ok', false, 'error', 'already_confirmed');
  end if;

  cfg      := coalesce(o.checkout_config, '{}'::jsonb);
  b_lead   := coalesce(cfg->>'lead',   'blank');
  b_adults := coalesce(cfg->>'adults', 'blank');
  adults   := coalesce(p_payload->'adults', '[]'::jsonb);

  -- Aceite dos termos e assinatura não são configuráveis. Sem os dois
  -- isto não é uma confirmação, é um formulário preenchido.
  if coalesce((p_payload->>'ack_terms')::boolean, false) is not true then
    missing := array_append(missing, 'ack_terms');
  end if;
  if coalesce(btrim(p_payload->>'signature_name'), '') = '' then
    missing := array_append(missing, 'signature_name');
  end if;

  if b_lead <> 'off' then
    if coalesce(btrim(p_payload->>'lead_name'), '')  = '' then
      missing := array_append(missing, 'lead_name');
    end if;
    if coalesce(btrim(p_payload->>'lead_email'), '') = '' then
      missing := array_append(missing, 'lead_email');
    end if;
  end if;

  -- Bloco de adultos ligado e vazio é o erro que estraga a reserva no
  -- fornecedor. Mostrar o campo e aceitar vazio seria pior que não
  -- perguntar.
  if b_adults <> 'off' and jsonb_array_length(adults) = 0 then
    missing := array_append(missing, 'adults');
  end if;

  for f in
    select * from ops_order_fields where order_id = o.id order by sort
  loop
    v := nullif(btrim(coalesce(p_payload->'field_values'->>f.field_key, '')), '');
    if f.required and (v is null or (f.input_type = 'checkbox' and v <> 'true')) then
      missing := array_append(missing, coalesce(f.label_pt, f.field_key));
    end if;
    snap := snap || jsonb_build_object(
      'key', f.field_key, 'group_key', f.group_key,
      'label_pt', f.label_pt, 'label_en', coalesce(f.label_en, f.label_pt),
      'input_type', f.input_type, 'mode', f.mode,
      'required', f.required, 'value', v);
  end loop;

  if array_length(missing, 1) > 0 then
    return jsonb_build_object('ok', false, 'error', 'missing_fields',
                              'missing', to_jsonb(missing));
  end if;

  insert into ops_order_confirmations
    (order_id, lead_name, lead_email, lead_phone, adults, children,
     ack_vehicle, ack_terms, signature_name, remarks, fields)
  values (o.id,
     p_payload->>'lead_name', p_payload->>'lead_email', p_payload->>'lead_phone',
     adults, coalesce(p_payload->'children','[]'::jsonb),
     coalesce((p_payload->>'ack_vehicle')::boolean,false),
     coalesce((p_payload->>'ack_terms')::boolean,false),
     p_payload->>'signature_name', p_payload->>'remarks', snap);

  update ops_orders
     set status='confirmed', confirmed_at=now(), updated_at=now()
   where id=o.id;

  return jsonb_build_object('ok', true);
end $$;

revoke all on function tl_get_order(text) from public;
revoke all on function tl_submit_confirmation(text, jsonb) from public;
grant execute on function tl_get_order(text) to anon, authenticated;
grant execute on function tl_submit_confirmation(text, jsonb) to anon, authenticated;
