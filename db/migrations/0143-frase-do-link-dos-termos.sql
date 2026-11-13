-- =====================================================================
-- 0143 · A FRASE ANTES DO LINK DOS TERMOS É EDITÁVEL NA ORDER
--
-- Instrução dela, 13/11/26, na order TL-053-26: saem os termos da casa
-- (Transportation, General conditions, Booking and cancellation) — feito na
-- 0139 —, mas FICA a última linha, com o link dos termos complementares,
-- dizendo que o que não está mencionado aqui está lá. "Deixa esse campo
-- para alterar."
--
--   ops_orders.terms_link_text   a frase antes do link; vazio, a padrão
--                                ("The complementary terms and conditions
--                                for this booking are available at:").
--   tl_get_order devolve o campo (troca pontual).
--
-- E na order TL-053-26:
--   · a frase: "For anything not mentioned above, the complementary terms
--     and conditions for this booking apply, available at:";
--   · de novo a pergunta do carro em duas linhas (a 0142 foi desfeita por
--     um salvamento do editor aberto antes dela).
--
-- Seção 7: add column e troca de função; update na order TL-053-26, ainda
-- não confirmada, com o sim dela.
-- =====================================================================

alter table ops_orders add column if not exists terms_link_text text;

do $$
declare d text; antes text; ord uuid; n int;
begin
  d := pg_get_functiondef('public.tl_get_order(text)'::regprocedure);
  antes := d;
  d := replace(d, $a$'terms_house', o.terms_house,$a$,
                  $b$'terms_house', o.terms_house,
      'terms_link_text', o.terms_link_text,$b$);
  if d = antes then raise exception '0143: trecho dos termos não encontrado em tl_get_order'; end if;
  execute d;

  select id into ord from ops_orders
   where token = '58f43f0ef065b4ebb4bf6747cf72339d' and confirmed_at is null;
  if ord is null then raise exception '0143: a order TL-053-26 não foi encontrada, ou já foi confirmada'; end if;

  update ops_orders set
    terms_link_text = 'For anything not mentioned above, the complementary terms and conditions for this booking apply, available at:'
   where id = ord;

  update ops_order_fields set
    label_en = E'Rental car · Category 1: Mercedes GLE, Maserati Grecale Modena or Audi Q8.\nPlease let us know if you have a preference, we will do our best to accommodate it (please list your order of preference).',
    label_pt = E'Carro alugado · Categoria 1: Mercedes GLE, Maserati Grecale Modena ou Audi Q8.\nInforme se há uma preferência, faremos o possível para atendê-la (indique a sua ordem de preferência).'
   where order_id = ord and field_key = 'custom.car_models';
  get diagnostics n = row_count;
  if n <> 1 then raise exception '0143: a pergunta do carro não foi encontrada'; end if;
end $$;

insert into ops_migrations (id) values ('0143-frase-do-link-dos-termos') on conflict (id) do nothing;
