-- =====================================================================
-- 0142 · ORDER TL-053-26: A PERGUNTA DO CARRO EM DUAS LINHAS
--
-- Instrução dela, 13/11/26: "Rental car category 1, tal, tal, tal. Depois
-- na linha de baixo: please let us know if you have a preference, we will
-- do our best to accommodate it (please list your order of preference)".
-- O rótulo da pergunta ganha uma quebra de linha, e a página passa a
-- respeitá-la (só muda pergunta que tem quebra; nenhuma tinha).
--
-- Seção 7: update de uma linha de ops_order_fields da order TL-053-26,
-- ainda não confirmada, com o sim dela.
-- =====================================================================

do $$
declare n int;
begin
  update ops_order_fields f set
    label_en = E'Rental car · Category 1: Mercedes GLE, Maserati Grecale Modena or Audi Q8.\nPlease let us know if you have a preference, we will do our best to accommodate it (please list your order of preference).',
    label_pt = E'Carro alugado · Categoria 1: Mercedes GLE, Maserati Grecale Modena ou Audi Q8.\nInforme se há uma preferência, faremos o possível para atendê-la (indique a sua ordem de preferência).'
    from ops_orders o
   where f.order_id = o.id and o.token = '58f43f0ef065b4ebb4bf6747cf72339d' and o.confirmed_at is null
     and f.field_key = 'custom.car_models';
  get diagnostics n = row_count;
  if n <> 1 then raise exception '0142: a pergunta do carro não foi encontrada'; end if;
end $$;

insert into ops_migrations (id) values ('0142-pergunta-do-carro-em-duas-linhas') on conflict (id) do nothing;
