-- =====================================================================
-- 0160 · TL-066-26: SEM TAXA DE CARTÃO, E O PREÇO QUE A ABSORVE
--
-- Instrução dela, 25/11/26: tirar os 3% do cartão das condições e pôr a
-- taxa dentro do preço. A conta: dos 100% do preço, 3% são do cartão,
-- 12% da agência, e a Tuscan Lands tem de ficar com 15% LÍQUIDOS "de
-- qualquer maneira" — por isso também depois do IVA 74-ter, que incide
-- sobre a margem (venda − custo) e sai da parte dela.
--
--   P − custo − 0,03 P − 0,12 P − (P − custo) × 22/122 = 0,15 P
--   P = custo × 0,8197 / 0,5197  (≈ custo × 1,577), para cima de 5 em 5
--
--   2 pessoas  custo   930 → 1.470 · cartão 44,10 · agência 176,40 · IVA 97,38 · TL 222,12 (15,1%)
--   4 pessoas  custo 1.060 → 1.675 · cartão 50,25 · agência 201,00 · IVA 110,90 · TL 252,85 (15,1%)
--
-- Custo: van 550 + almoço 65/pax + guia 250.
--
-- Seção 7: update em UMA proposta, a TL-066-26 (0157), sem envio e sem
-- resposta, por instrução dela nesta conversa. Linha mirada por proposta
-- + título; a troca de texto se prende à frase que muda.
-- =====================================================================

do $$
declare
  prop uuid := 'e0660000-0000-0000-0000-000000000001';
  velho text := 'Payment can be made by bank wire, or by credit card with a 3% processing fee, and our team will send you the banking details or the payment link.';
  novo  text := 'Payment can be made by bank wire or by credit card, with no added fees, and our team will send you the banking details or the payment link.';
  n int;
begin
  if exists (select 1 from ops_proposals where id = prop and responded_at is not null) then
    raise exception '0160: a TL-066-26 já foi respondida, nada muda';
  end if;
  if not exists (select 1 from ops_proposals where id = prop and position(velho in conditions_en) > 0) then
    raise exception '0160: as condições da TL-066-26 não têm a frase dos 3%%';
  end if;

  update ops_proposals
     set conditions_en = replace(conditions_en, velho, novo),
         internal_notes = 'Venda = custo × 0,8197 / 0,5197, para cima de 5 em 5: 3% cartão (incluso, sem taxa ao cliente) + 12% agência + 15% TL líquido depois do IVA 74-ter. 2 pax: custo 930 (van 550 + almoço 130 + guia 250) → 1.470; TL líquido 222,12. 4 pax: custo 1.060 → 1.675; TL líquido 252,85. Vinícola Blasi Cantina, almoço a € 65/pax (eles cotaram 50/pax e falam em percentual para agência). Van: € 550, 7 horas, IVA incluso. Entrada nas igrejas de Assis: confirmar e avisar por e-mail.'
   where id = prop;

  update ops_proposal_items
     set units = (select jsonb_agg(case u->>'key'
                    when 'pax2' then jsonb_set(u, '{price}', '1470')
                    when 'pax4' then jsonb_set(u, '{price}', '1675')
                    else u end order by ord)
                  from jsonb_array_elements(units) with ordinality as e(u, ord))
   where proposal_id = prop and 'Price for the day' in (title, title_en);
  get diagnostics n = row_count;
  if n <> 1 then raise exception '0160: cartão do preço não encontrado'; end if;
end $$;

insert into ops_migrations (id) values ('0160-tl-066-26-preco-com-cartao') on conflict (id) do nothing;
