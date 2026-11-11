-- =====================================================================
-- 0094 · O EXTRA QUE VIRA LINHA LEVA A DESCRIÇÃO DELE
--
-- Na TL-050-26 ela escreveu o concierge com título e descrição ("Dining
-- concierge" e o texto embaixo). A descrição mora em help_pt/help_en do
-- campo — que a página já mostra — e, ao confirmar, passa a ser o
-- details da linha criada na order, no idioma da order. Sem descrição,
-- continua o aviso de antes.
--
-- Só troca a função tl_submit_confirmation (versão da 0087 com essa
-- linha mudada). Nenhuma linha de tabela muda.
-- CONFERÊNCIA DA SEÇÃO 7: função tl_*. Nenhuma tabela do CRM.
-- =====================================================================

create or replace function public.tl_submit_confirmation(p_token text, p_payload jsonb)
 returns jsonb
 language plpgsql
 security definer
 set search_path to 'public'
as $function$
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
  ord      int;
  tit      text;
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

  -- Aceite de bagagem: configurável em aparecer, não em ser opcional.
  if b_veh and coalesce((p_payload->>'ack_vehicle')::boolean, false) is not true then
    missing := array_append(missing, 'ack_vehicle');
  end if;

  if b_lead <> 'off' then
    if coalesce(btrim(p_payload->>'lead_name'), '')  = '' then
      missing := array_append(missing, 'lead_name');
    end if;
    if coalesce(btrim(p_payload->>'lead_phone'), '') = '' then
      missing := array_append(missing, 'lead_phone');
    end if;
  end if;

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
      'required', f.required, 'value', v,
      'price', f.price, 'service_date', f.service_date);
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

  -- Extra marcado vira linha da order, no fim, com o valor do campo.
  -- O preço vem do banco, nunca do navegador.
  select coalesce(max(sort), -1) into ord from ops_order_items where order_id = o.id;
  for f in
    select * from ops_order_fields
     where order_id = o.id and input_type = 'checkbox' and price is not null
     order by sort
  loop
    if coalesce(p_payload->'field_values'->>f.field_key, '') = 'true' then
      tit := case when o.lang = 'en' then coalesce(nullif(f.label_en,''), f.label_pt) else f.label_pt end;
      if not exists (select 1 from ops_order_items i
                      where i.order_id = o.id and i.title = tit
                        and coalesce(i.service_date,'') = coalesce(f.service_date,'')) then
        ord := ord + 1;
        insert into ops_order_items (order_id, sort, service_date, title, details, price)
        values (o.id, ord, f.service_date, tit,
                coalesce(nullif(case when o.lang = 'en' then f.help_en else f.help_pt end, ''),
                         case when o.lang = 'en' then 'Extra selected at confirmation'
                              else 'Extra escolhido na confirmação' end),
                f.price);
      end if;
    end if;
  end loop;

  update ops_orders
     set status='confirmed', confirmed_at=now(), updated_at=now()
   where id=o.id;

  return jsonb_build_object('ok', true);
end $function$;

insert into ops_migrations (id) values ('0094-descricao-do-extra') on conflict (id) do nothing;
