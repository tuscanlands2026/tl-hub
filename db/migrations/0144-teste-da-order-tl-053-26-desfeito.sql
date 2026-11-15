-- =====================================================================
-- 0144 · DESFAZ O TESTE DE ENVIO DA ORDER TL-053-26
--
-- Instrução dela, 15/11/26: "faz o teste respondendo, eu recebo a
-- confirmação, aí você apaga tudo, para a cliente poder responder".
-- O teste foi feito pela própria página da order, com o contato "TESTE
-- Tuscan Lands", e mandou o aviso por e-mail de verdade para booking@.
--
-- Isto apaga a confirmação de teste e devolve a order ao estado de antes:
-- status 'draft', sem confirmed_at e com o updated_at que ela tinha. O
-- registro do e-mail em ops_notifications fica, como histórico do teste.
--
-- Só apaga se a confirmação for a do teste (lead_name 'TESTE Tuscan
-- Lands') e se for a ÚNICA da order: se a cliente tiver respondido no
-- meio, nada é apagado e o arquivo para.
--
-- Seção 7: delete de uma linha e update de uma linha, com o sim dela.
-- Aplicada 15/11/26.
-- =====================================================================

do $$
declare ord uuid; n int; outras int;
begin
  select id into ord from ops_orders where token = '58f43f0ef065b4ebb4bf6747cf72339d';
  if ord is null then raise exception '0144: order TL-053-26 não encontrada'; end if;

  select count(*) into outras from ops_order_confirmations
   where order_id = ord and coalesce(lead_name,'') <> 'TESTE Tuscan Lands';
  if outras > 0 then
    raise exception '0144: há confirmação que não é o teste — nada é apagado';
  end if;

  delete from ops_order_confirmations where order_id = ord and lead_name = 'TESTE Tuscan Lands';
  get diagnostics n = row_count;
  if n <> 1 then raise exception '0144: esperava uma confirmação de teste, achou %', n; end if;

  update ops_orders set status = 'draft', confirmed_at = null,
         updated_at = '2026-11-13 19:47:06.091+00'
   where id = ord;
end $$;

insert into ops_migrations (id) values ('0144-teste-da-order-tl-053-26-desfeito') on conflict (id) do nothing;
