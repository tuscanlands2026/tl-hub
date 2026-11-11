-- =====================================================================
-- 0089 · CONDIÇÕES ESPECÍFICAS POR ORDER
--
-- Instrução dela, 11/11/26, na TL-050-26: as cláusulas de atraso e de
-- hora excedente não são aceite solto no formulário — vão "na parte de
-- termos e condições, ali no texto", escritas como termo.
--
-- Os termos da order moram no código (TERMS) e valem para TODA order,
-- inclusive as já confirmadas: mudar ali muda o documento que volta
-- quando ela reabre uma venda entregue. Então a cláusula de uma venda é
-- um CAMPO da order, terms_extra, que sai dentro de Termos e Condições,
-- logo abaixo do título e antes do texto da casa. Vazio não sai.
--
-- Só CRIA: a coluna e nova versão de tl_get_order (que monta campo a
-- campo e passa a devolver terms_extra). Nenhuma linha muda.
-- CONFERÊNCIA DA SEÇÃO 7: ops_orders (add column), tl_get_order.
-- =====================================================================

alter table ops_orders add column if not exists terms_extra text;
comment on column ops_orders.terms_extra is
  'Condições específicas desta order. Sai em Termos e Condições, antes do texto da casa, que não muda.';

create or replace function public.tl_get_order(p_token text)
 returns jsonb
 language plpgsql
 security definer
 set search_path to 'public'
as $function$
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
      'terms_url', o.terms_url, 'terms_extra', o.terms_extra,
      'payment_note', o.payment_note,
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
    'fields', coalesce((select jsonb_agg(jsonb_build_object(
        'field_key', f.field_key, 'group_key', f.group_key,
        'label_pt', f.label_pt, 'label_en', f.label_en,
        'input_type', f.input_type, 'options', f.options,
        'required', f.required, 'mode', f.mode,
        'prefill_value', f.prefill_value,
        'help_pt', f.help_pt, 'help_en', f.help_en,
        'price', f.price, 'service_date', f.service_date) order by f.sort)
      from ops_order_fields f where f.order_id = o.id), '[]'::jsonb)
  ) into result;
  return result;
end $function$;

insert into ops_migrations (id) values ('0089-condicoes-da-order') on conflict (id) do nothing;
