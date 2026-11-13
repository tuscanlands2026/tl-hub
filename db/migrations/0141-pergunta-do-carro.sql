-- =====================================================================
-- 0141 · ORDER TL-053-26: A PERGUNTA DO MODELO DO CARRO COM O TEXTO DELA
--
-- Instrução dela, 13/11/26: "escreve direito... Please let us know if you
-- have a preference. We do our best to accommodate. Please list two in
-- order of preference." Troca o rótulo da pergunta criada na 0139 (inglês
-- e português). Continua obrigatória.
--
-- Seção 7: update de uma linha de ops_order_fields da order TL-053-26,
-- ainda não confirmada, com o sim dela.
-- =====================================================================

do $$
declare n int;
begin
  update ops_order_fields f set
    label_en = 'Rental car · Category 1: Mercedes GLE, Maserati Grecale Modena or Audi Q8. Please let us know if you have a preference. We will do our best to accommodate it. Please list two models in order of preference.',
    label_pt = 'Carro alugado · Categoria 1: Mercedes GLE, Maserati Grecale Modena ou Audi Q8. Informe se há uma preferência; faremos o possível para atendê-la. Indique dois modelos em ordem de preferência.'
    from ops_orders o
   where f.order_id = o.id and o.token = '58f43f0ef065b4ebb4bf6747cf72339d' and o.confirmed_at is null
     and f.field_key = 'custom.car_models';
  get diagnostics n = row_count;
  if n <> 1 then raise exception '0141: a pergunta do carro não foi encontrada'; end if;
end $$;

insert into ops_migrations (id) values ('0141-pergunta-do-carro') on conflict (id) do nothing;
