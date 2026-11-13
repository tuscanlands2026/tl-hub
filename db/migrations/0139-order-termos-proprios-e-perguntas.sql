-- =====================================================================
-- 0139 · ORDER COM TERMOS PRÓPRIOS NO LUGAR DOS DA CASA, E A ORDER DA
--        EMILY (TL-053-26) COM OS TERMOS, O PAGAMENTO E AS PERGUNTAS DELA
--
-- Instrução dela, 13/11/26, na Services Confirmation da TL-053-26: "como
-- tem os termos e condições fixos ali, você vai substituir por este aqui,
-- porque ali é só hotel e carro". Os termos da casa (TERMS, no código)
-- falam de tours e transfers e valem para todas as orders, então não se
-- mexe neles: a order ganha uma chave.
--
--   ops_orders.terms_house   false = as condições desta order (terms_extra)
--                            SUBSTITUEM os termos da casa. Nulo = o de sempre.
--   tl_get_order passa a devolver terms_house (troca pontual).
--   checkout_config.trav_note: nota dela embaixo do bloco dos viajantes.
--
-- E a order TL-053-26 (token 58f43f0e…):
--   · terms_house = false, com os termos que ela mandou (hotéis e carro),
--     palavra por palavra, e os termos de pagamento repetidos da proposta;
--   · nome completo e nascimento dos dois, sem o aviso de bilhete de
--     monumento (a order é só hotel e carro), e a nota: "(For hotels that
--     request a credit card guarantee, we will let you know how to proceed.)";
--   · sai a pergunta da garantia em cartão (criada na 0131);
--   · entram duas perguntas obrigatórias: preferência de modelo do carro
--     (pelo menos dois, em ordem) e a forma de pagamento (opção 1 ou 2).
--
-- Seção 7: add column e troca de função; update e delete só na order
-- TL-053-26, criada na 0131 e ainda não confirmada, com o sim dela.
-- =====================================================================

alter table ops_orders add column if not exists terms_house boolean;

do $$
declare d text; antes text; ord uuid; n int;
begin
  d := pg_get_functiondef('public.tl_get_order(text)'::regprocedure);
  antes := d;
  d := replace(d, $a$'terms_tickets', o.terms_tickets,$a$,
                  $b$'terms_tickets', o.terms_tickets,
      'terms_house', o.terms_house,$b$);
  if d = antes then raise exception '0139: trecho dos termos não encontrado em tl_get_order'; end if;
  execute d;

  select id into ord from ops_orders
   where token = '58f43f0ef065b4ebb4bf6747cf72339d' and confirmed_at is null;
  if ord is null then raise exception '0139: a order TL-053-26 não foi encontrada, ou já foi confirmada'; end if;

  update ops_orders set
    terms_house = false,
    terms_extra = $t$**Hotels:**
Rates include VAT, while city tax and extras are paid directly at the hotel.
Cancellation is free of charge up to 10 days before arrival.

**Rental car:**
Category 1: 1,400 km included, with additional kilometers at €3.
A refundable security deposit of €3,000 for Category 1.
Fuel is not included.
Cancellation: 20% of the rental amount is paid on confirmation and is non-refundable in case of cancellation.

**Payment:**
All prices are in Euros (€) and include VAT. Payments can be made by credit card or bank transfer, and our team will send you the payment links and banking details.
Deposit: you may select between two options.
- Option 1: a 35% deposit on confirmation and the balance by April 21, 2027, 60 days before travel.
- Option 2: a 35% deposit on confirmation, 30% by February 1, 2027, and the remaining 35% by April 21, 2027.
Please note that we are unable to process split payments among travelers; each booking is settled as a single payment by the agency or the lead client.$t$,
    checkout_config = coalesce(checkout_config, '{}'::jsonb)
      || jsonb_build_object('passport_names', false, 'dob', 'required',
           'trav_note', '(For hotels that request a credit card guarantee, we will let you know how to proceed.)'),
    updated_at = now()
   where id = ord;

  delete from ops_order_fields where order_id = ord and field_key = 'custom.card_guarantee';
  get diagnostics n = row_count;
  if n <> 1 then raise exception '0139: a pergunta do cartão não foi encontrada'; end if;

  insert into ops_order_fields
    (order_id, sort, group_key, field_key, label_pt, label_en, input_type, options, required, mode)
  values
    (ord, 0, 'custom', 'custom.car_models',
     'Carro alugado · Categoria 1: Mercedes GLE, Maserati Grecale Modena ou Audi Q8. Informe se os modelos são indiferentes ou se há uma preferência, indicando pelo menos dois em ordem de preferência.',
     'Rental car · Category 1: Mercedes GLE, Maserati Grecale Modena or Audi Q8. Please let us know if the models make no difference to you or if you have a preference, listing at least two in order of preference.',
     'textarea', '[]'::jsonb, true, 'blank'),
    (ord, 1, 'custom', 'custom.payment_option',
     'Forma de pagamento preferida',
     'Preferred payment option',
     'select',
     '["Option 1: a 35% deposit on confirmation and the balance by April 21, 2027, 60 days before travel.","Option 2: a 35% deposit on confirmation, 30% by February 1, 2027, and the remaining 35% by April 21, 2027."]'::jsonb,
     true, 'blank');
end $$;

insert into ops_migrations (id) values ('0139-order-termos-proprios-e-perguntas') on conflict (id) do nothing;
