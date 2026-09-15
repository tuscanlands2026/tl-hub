-- =====================================================================
-- 0037-proforma-invoice.sql
--   Proforma invoice da order: número próprio, começando em 159/26.
-- =====================================================================
-- Pedido dela, setembro/26: além do PDF de confirmação que já existe, a
-- order precisa de um segundo documento no estilo "proforma invoice",
-- para ela emitir e mandar à agência na hora. A numeração continua de
-- onde a dela parou: a próxima é a 159 de 2026.
--
-- O número é GRAVADO na order, e não calculado na hora de imprimir: se
-- fosse calculado, reabrir o documento daria outro número e a agência
-- receberia duas proformas diferentes do mesmo serviço.
-- ---------------------------------------------------------------------

alter table ops_orders
  add column if not exists proforma_no   text,
  add column if not exists proforma_date date;
comment on column ops_orders.proforma_no is
  'Número da proforma no formato 159/26. Gravado na primeira emissão e nunca recalculado.';

-- Contador por ano. Uma linha por ano, e o ano de 2026 começa em 158
-- para a próxima ser a 159 — que é onde a numeração dela está.
create table if not exists ops_proforma_seq (
  ano    int  primary key,
  ultimo int  not null default 0
);
insert into ops_proforma_seq (ano, ultimo) values (2026, 158)
  on conflict (ano) do nothing;

alter table ops_proforma_seq enable row level security;
drop policy if exists "auth_all" on ops_proforma_seq;
create policy "auth_all" on ops_proforma_seq for all to authenticated using (true) with check (true);

-- =====================================================================
-- tl_proforma_no: devolve o número da order, criando na primeira vez.
-- Idempotente de propósito: chamar de novo devolve o mesmo número.
-- =====================================================================
create or replace function tl_proforma_no(p_order uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  o     ops_orders%rowtype;
  v_ano int := extract(year from current_date)::int;   -- v_ prefixo: "ano" colide com a coluna
  prox  int;
begin
  select * into o from ops_orders where id = p_order;
  if not found then return jsonb_build_object('ok', false, 'error', 'not_found'); end if;
  if o.proforma_no is not null and btrim(o.proforma_no) <> '' then
    return jsonb_build_object('ok', true, 'no', o.proforma_no,
                              'date', coalesce(o.proforma_date, current_date), 'novo', false);
  end if;

  -- Trava a linha do ano: duas emissões ao mesmo tempo não pegam o
  -- mesmo número.
  insert into ops_proforma_seq (ano, ultimo) values (v_ano, 0) on conflict (ano) do nothing;
  update ops_proforma_seq set ultimo = ultimo + 1 where ano = v_ano
    returning ultimo into prox;

  update ops_orders
     set proforma_no = prox::text || '/' || to_char(make_date(v_ano,1,1), 'YY'),
         proforma_date = current_date,
         updated_at = now()
   where id = p_order
   returning proforma_no, proforma_date into o.proforma_no, o.proforma_date;

  return jsonb_build_object('ok', true, 'no', o.proforma_no, 'date', o.proforma_date, 'novo', true);
end $$;

revoke all on function tl_proforma_no(uuid) from public;
grant execute on function tl_proforma_no(uuid) to authenticated;

-- Texto da proforma: condições de pagamento e dados bancários, que ela
-- escreve uma vez e vale para todas. Em branco, o documento sai sem o
-- bloco em vez de sair com um rótulo vazio.
insert into ops_text_defaults (key, pt, en) values
  ('proforma_terms',
   E'**Forma de pagamento**\nTransferência bancária internacional em euros.\n**Dados bancários**\nPreencha aqui os dados da conta (banco, IBAN, BIC/SWIFT e titular).',
   E'**Payment**\nInternational bank transfer in euros.\n**Bank details**\nFill in the account details here (bank, IBAN, BIC/SWIFT and account holder).')
  on conflict (key) do nothing;

insert into ops_migrations (id) values ('0037-proforma-invoice') on conflict (id) do nothing;
