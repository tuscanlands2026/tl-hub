-- =====================================================================
-- 0091 · "TERMOS COMPLEMENTARES" NO LINK DOS TERMOS — SÓ DAQUI EM DIANTE
--
-- Instrução dela, 11/11/26: a frase antes do link dos termos, no
-- documento da order, passa a ser
--   EN "The complementary terms and conditions for this booking are
--       available at:"
--   PT "Os termos e condições complementares a esta contratação estão
--       disponíveis em:"
-- no padrão, para todas as orders — e, perguntada, escolheu: as orders
-- JÁ CONFIRMADAS continuam com a frase que o cliente assinou ("Full
-- terms and conditions:").
--
-- O corte é um CAMPO, e não uma data: terms_complementary. Nasce true
-- (frase nova) para toda order, inclusive as que nascerem da proposta ou
-- da duplicação; as 13 orders confirmadas hoje recebem false.
--
-- Preencher campo NOVO em linha antiga não apaga nada; o "sim" foi dado
-- na resposta dela (opção 1). Também entra em tl_get_order.
-- CONFERÊNCIA DA SEÇÃO 7: ops_orders (add column + update só da coluna
-- nova nas confirmadas), tl_get_order, ops_migrations. Nenhuma tabela do
-- CRM.
-- =====================================================================

alter table ops_orders add column if not exists terms_complementary boolean not null default true;
comment on column ops_orders.terms_complementary is
  'false = order confirmada antes de nov/26: mantém "Full terms and conditions:". true = frase dos termos complementares.';

update ops_orders set terms_complementary = false
 where status = 'confirmed' and terms_complementary is true
   and not exists (select 1 from ops_migrations where id = '0091-termos-complementares');

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
      'terms_complementary', o.terms_complementary,
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

insert into ops_migrations (id) values ('0091-termos-complementares') on conflict (id) do nothing;
