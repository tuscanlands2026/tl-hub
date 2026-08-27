-- =====================================================================
-- 0028 · A DATA DE NASCIMENTO PASSA A SER ESCOLHA DELA
--
-- A regra de agosto/26 era nome E data de nascimento de todo viajante,
-- criança inclusive, porque bilhete de monumento é nominal e a data
-- decide meia-entrada ou gratuidade. Isso continua verdade — quando a
-- venda tem bilhete nominal.
--
-- Só que nem toda order tem. Numa venda de transfer, pedir a data de
-- nascimento de cada passageiro é pedir dado pessoal que ninguém vai
-- usar, e é uma linha a mais para a agência travar. Instrução dela em
-- agosto/26: quando não é mandatório, não precisa.
--
-- Vira escolha por order, em checkout_config.dob:
--   required (padrão) — pede e exige, como era
--   optional          — pede, e aceita em branco
--   off               — não pergunta
--
-- O padrão é required de propósito: order que já existe não muda de
-- comportamento, e esquecer de configurar erra para o lado seguro.
--
-- O NOME continua obrigatório sempre. Sem nome não há reserva em
-- fornecedor nenhum, e disso ela não abriu mão.
--
-- Só toca em objetos ops_. Nada fora desse prefixo.
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
  travs    jsonb;
  trav     jsonb;
  n        int;
  b_lead   text;
  b_trav   text;
  b_dob    text;
  b_veh    boolean;
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
  b_lead   := coalesce(cfg->>'lead',       'blank');
  b_trav   := coalesce(cfg->>'travellers', 'blank');
  b_veh    := coalesce((cfg->>'ack_vehicle')::boolean, true);
  travs    := coalesce(p_payload->'travellers', '[]'::jsonb);

  -- O aceite dos termos não é configurável. Sem ele isto não é uma
  -- confirmação, é um formulário preenchido.
  if coalesce((p_payload->>'ack_terms')::boolean, false) is not true then
    missing := array_append(missing, 'ack_terms');
  end if;

  -- O aceite de bagagem é configurável em aparecer ou não, mas não em
  -- ser opcional: se ele aparece, tem de ser marcado. Bagagem além do
  -- previsto significa veículo maior no dia, com custo que ninguém
  -- combinou. Deixar passar em branco seria guardar a dúvida em vez de
  -- resolvê-la antes da viagem.
  if b_veh and coalesce((p_payload->>'ack_vehicle')::boolean, false) is not true then
    missing := array_append(missing, 'ack_vehicle');
  end if;

  if b_lead <> 'off' then
    if coalesce(btrim(p_payload->>'lead_name'), '')  = '' then
      missing := array_append(missing, 'lead_name');
    end if;
    -- Telefone com código de país, ativo durante a viagem. É o número que
    -- o motorista liga quando o voo atrasa; sem ele o serviço para.
    if coalesce(btrim(p_payload->>'lead_phone'), '') = '' then
      missing := array_append(missing, 'lead_phone');
    end if;
  end if;

  -- Bloco de viajantes ligado e vazio é o erro que estraga a reserva no
  -- fornecedor. Mostrar o campo e aceitar vazio seria pior que não
  -- perguntar. Nome e nascimento valem para todos: o bilhete é nominal e
  -- a idade decide meia ou gratuidade.
  b_dob := coalesce(nullif(cfg->>'dob',''), 'required');
  if b_dob not in ('required','optional','off') then b_dob := 'required'; end if;

  if b_trav <> 'off' then
    if jsonb_array_length(travs) = 0 then
      missing := array_append(missing, 'travellers');
    else
      n := 0;
      for trav in select * from jsonb_array_elements(travs) loop
        n := n + 1;
        if coalesce(btrim(trav->>'name'), '') = '' then
          missing := array_append(missing, 'traveller_name_' || n::text);
        end if;
        -- A data de nascimento só é cobrada quando a order diz que
        -- é. Nome continua sempre obrigatório.
        if b_dob = 'required' and coalesce(btrim(trav->>'dob'), '') = '' then
          missing := array_append(missing, 'traveller_dob_' || n::text);
        end if;
      end loop;
    end if;
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
    (order_id, lead_name, lead_email, lead_phone, travellers,
     ack_vehicle, ack_terms, remarks, fields)
  values (o.id,
     p_payload->>'lead_name', p_payload->>'lead_email', p_payload->>'lead_phone',
     travs,
     coalesce((p_payload->>'ack_vehicle')::boolean,false),
     coalesce((p_payload->>'ack_terms')::boolean,false),
     p_payload->>'remarks', snap);

  update ops_orders
     set status='confirmed', confirmed_at=now(), updated_at=now()
   where id=o.id;

  return jsonb_build_object('ok', true);
end $$;

revoke all on function tl_get_order(text) from public;
revoke all on function tl_submit_confirmation(text, jsonb) from public;
grant execute on function tl_get_order(text) to anon, authenticated;
grant execute on function tl_submit_confirmation(text, jsonb) to anon, authenticated;

comment on column ops_orders.checkout_config is
  'Blocos fixos do checkout. dob vale required, optional ou off: quando a venda não tem bilhete nominal, pedir a data de nascimento é pedir dado que ninguém vai usar.';

insert into ops_migrations (id) values ('0028-nascimento-opcional') on conflict (id) do nothing;
