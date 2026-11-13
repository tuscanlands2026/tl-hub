-- =====================================================================
-- 0140 · CORRIGE A 0139: AS DUAS PERGUNTAS SAEM SOB "GENERAL INFORMATION"
--
-- A 0139 criou as perguntas do modelo do carro e da forma de pagamento no
-- grupo 'custom', que na página sai com o título cru "CUSTOM". Passam para
-- o grupo 'general', que a página já chama de "General information".
-- Rótulo, tipo e obrigatoriedade não mudam.
--
-- Seção 7: update de duas linhas que a 0139 criou na order TL-053-26,
-- ainda não confirmada.
-- =====================================================================

do $$
declare n int;
begin
  update ops_order_fields f set group_key = 'general'
    from ops_orders o
   where f.order_id = o.id and o.token = '58f43f0ef065b4ebb4bf6747cf72339d' and o.confirmed_at is null
     and f.field_key in ('custom.car_models', 'custom.payment_option') and f.group_key = 'custom';
  get diagnostics n = row_count;
  if n <> 2 then raise exception '0140: esperava duas perguntas, achou %', n; end if;
end $$;

insert into ops_migrations (id) values ('0140-perguntas-em-general-information') on conflict (id) do nothing;
