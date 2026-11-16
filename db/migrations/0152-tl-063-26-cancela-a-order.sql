-- =====================================================================
-- 0152 · TL-063-26: A ORDER SAI, A VENDA VOLTA À FASE DE PROPOSTA
--
-- Instrução dela, 16/11/26: "cancela como order, não é uma order ainda
-- porque não está vendido, então volta ali realmente para a fase de
-- proposta. E aí vai ser um link para o cliente e um link para a agência
-- com os valores."
--
-- APAGA LINHA QUE JÁ EXISTE, com a instrução dela: a order da 0151
-- (e0630000-…-00c1) e os três campos de checkout dela. Conferido antes:
-- rascunho, nunca respondida, sem linha de serviço, sem parcela e sem
-- proforma. O delete só acontece se continuar assim — se alguém tiver
-- respondido nesse meio-tempo, para.
--
-- Os dois links que ficam são os da proposta net (0146–0150):
--   · #/quote/f562d265208db9dc46ff056418c7d5a7 — apresentação, para o casal;
--   · #/valores/1695a023-ce49-47cc-91d9-2aebf582d41b — os valores NET em
--     uma página, no formato da quote simples, com as condições e o envio,
--     para a agência.
-- O código da página de order sem serviço fixo (index.html, 0151) fica:
-- não muda nenhuma order existente e serve para a próxima.
-- =====================================================================

do $$
declare n int;
begin
  if exists (select 1 from ops_order_confirmations where order_id = 'e0630000-0000-0000-0000-0000000000c1')
     or exists (select 1 from ops_order_items where order_id = 'e0630000-0000-0000-0000-0000000000c1')
     or exists (select 1 from ops_orders where id = 'e0630000-0000-0000-0000-0000000000c1'
                  and (status <> 'draft' or proforma_no is not null)) then
    raise exception '0152: a order da TL-063-26 já tem resposta ou proforma, nada é apagado';
  end if;
  delete from ops_order_fields where order_id = 'e0630000-0000-0000-0000-0000000000c1';
  delete from ops_orders where id = 'e0630000-0000-0000-0000-0000000000c1';
  get diagnostics n = row_count;
  raise notice '0152: % order apagada', n;
end $$;

insert into ops_migrations (id) values ('0152-tl-063-26-cancela-a-order') on conflict (id) do nothing;
