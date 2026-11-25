-- =====================================================================
-- 0158 · TL-066-26: GUIA INCLUSO, TEXTO MAIS LIMPO, ALMOÇO COM VINHO
--
-- Instrução dela, 25/11/26, vendo a 0157:
--   · a guia vai junto e acompanha as visitas em Assis: deixa de ser
--     opcional. Sai o cartão do guia e o valor entra nos dois tamanhos de
--     grupo. Se dá para entrar nas igrejas, ela confirma por e-mail, e o
--     texto não promete;
--   · manhã em Assis, saída do hotel entre 8h30 e 9h, a confirmar;
--   · a vinícola: família, tradição na região de Umbertide, e o aviso que
--     ela já deu à Katie: vinícola na Umbria nem sempre tem o ar rústico
--     da Toscana. É para não criar expectativa errada;
--   · "o menu pode mudar" embaixo do serviço, e nas condições que o almoço
--     é uma experiência em torno dos vinhos: menu único para a mesa, cada
--     prato com o seu vinho.
--
-- PREÇO, os números dela (25/11/26), com guia, almoço e transporte:
--   2 pessoas  € 1.345
--   4 pessoas  € 1.525 (+ € 90 por pessoa a mais, "coloque 180")
--
-- PAGAMENTO, instrução dela: transferência bancária ou cartão com 3% de
-- taxa. Com os dois valores acima de € 1.000, sai a linha do pagamento
-- único abaixo de mil e fica o sinal de 40% com saldo 45 dias antes.
--
-- Seção 7: update e um delete em UMA proposta, a TL-066-26 criada hoje na
-- 0157, sem envio e sem resposta, por instrução dela nesta conversa. As
-- linhas são miradas por proposta + título, porque o id da linha não é
-- estável.
-- =====================================================================

do $$
declare
  prop uuid := 'e0660000-0000-0000-0000-000000000001';
  pag_velho text := $p$All prices are in Euros (€) and include VAT. Payments can be made by credit card or bank transfer, and our team will send you the payment link and banking details.
**Under € 1,000:** a single payment, 100% on confirmation.
**€ 1,000 or more:** 40% on confirmation, and the balance 45 days before travel.$p$;
  pag_novo text := $p$All prices are in Euros (€) and include VAT. Payment can be made by bank wire, or by credit card with a 3% processing fee, and our team will send you the banking details or the payment link.
**Deposit:** 40% on confirmation, and the balance 45 days before travel.$p$;
  velho text := '**Duration:** the day is planned for about 7 hours, from pick-up at the hotel to the return. Any extra time with the vehicle and driver is subject to availability and charged separately.';
  n int;
begin
  if exists (select 1 from ops_proposals where id = prop and responded_at is not null) then
    raise exception '0158: a TL-066-26 já foi respondida, nada muda';
  end if;
  if not exists (select 1 from ops_proposals where id = prop and position(velho in conditions_en) > 0) then
    raise exception '0158: as condições da TL-066-26 não têm o parágrafo da duração';
  end if;
  if not exists (select 1 from ops_proposals where id = prop and position(pag_velho in conditions_en) > 0) then
    raise exception '0158: as condições da TL-066-26 não têm o bloco do pagamento';
  end if;

  update ops_proposals
     set labels = labels || jsonb_build_object('j_lead', jsonb_build_object('en',
           'Select the size of the group. Each price is for the whole group, and the day is private.')),
         conditions_en = replace(replace(conditions_en, pag_velho, pag_novo), velho, velho || E'\n' ||
           '**Lunch at the winery:** the lunch is an experience built around the estate''s wines, so the menu is the same for the whole table and each course is paired with one of them. Please share any dietary restrictions when you confirm.'),
         internal_notes = 'Venda (valores dela, 25/11/26, IVA incluso): 2 pax € 1.345; 4 pax € 1.525 (+ € 90 por pessoa). Comissão da agência 12%, fatura 74-ter. Custo: van 550 + almoço 65/pax + guia 250 (2 pax 930, 4 pax 1.060). Vinícola Blasi Cantina, almoço a € 65/pax (eles cotaram 50/pax e falam em percentual para agência). Van: € 550, 7 horas, IVA incluso. Entrada nas igrejas de Assis: confirmar e avisar por e-mail.'
   where id = prop;

  -- o guia deixa de ser cartão à parte
  delete from ops_proposal_items
   where proposal_id = prop and 'A local guide in Assisi' in (title, title_en);
  get diagnostics n = row_count;
  if n <> 1 then raise exception '0158: esperava o cartão do guia, achou %', n; end if;

  -- o dia
  update ops_proposal_items set
    details = $t$Pick-up at the hotel between 8:30 and 9:00 am, time to be confirmed. The drive to Assisi takes about an hour, almost all on a main road with few curves, and the front seat helps anyone who gets carsick.
The morning is in Assisi, with a local guide who stays with you through the visits. Around midday you head back toward the hotel, for lunch at a family winery in the Umbertide area.
Wineries in Umbria don't always have the rustic look people picture from Tuscany. This one is a family estate with a long tradition in the area: the visit starts in its 18th-century cellar, and lunch is served in the contemporary building right next to it, each course with its own wine:
- Bruschetta with the estate's olive oil, and a classic-method sparkling wine
- Cured meats made at the estate and cheeses, with two white wines
- Lasagna, with a red wine
- Porchetta made at the estate, with a red wine
- Small sweets, with the estate's white passito$t$,
    included_pt = $t$- Private van with driver, from the hotel and back, about 7 hours
- Local guide in Assisi for the morning
- Visit of the 18th-century cellar
- Lunch at the winery, paired with the estate's wines$t$,
    good_pt = $t$The menu may change.
Besides the reds, the pairing includes a sparkling wine, two whites and a sweet white.
The pick-up time and the date are subject to confirmation.$t$
  where proposal_id = prop and 'Assisi, and lunch at a family winery' in (title, title_en);
  get diagnostics n = row_count;
  if n <> 1 then raise exception '0158: linha do dia não encontrada'; end if;
  update ops_proposal_items set details_en = details, included_en = included_pt, good_en = good_pt
   where proposal_id = prop and 'Assisi, and lunch at a family winery' in (title, title_en);

  -- o cartão do preço, com a guia dentro
  update ops_proposal_items set
    title = 'Price for the day', title_en = 'Price for the day',
    details = 'Van with driver, local guide in Assisi, the cellar visit and lunch.',
    details_en = 'Van with driver, local guide in Assisi, the cellar visit and lunch.',
    units = jsonb_build_array(
      jsonb_build_object('key','pax2', 'optional',true, 'price',1345,
        'label','For 2 guests', 'label_en','For 2 guests',
        'ficha','Guide, van and lunch for two', 'ficha_en','Guide, van and lunch for two',
        'row','Assisi and the winery · 2 guests', 'row_en','Assisi and the winery · 2 guests',
        'row_desc','Van, guide in Assisi, cellar visit and wine lunch',
        'row_desc_en','Van, guide in Assisi, cellar visit and wine lunch'),
      jsonb_build_object('key','pax4', 'optional',true, 'price',1525,
        'label','For 4 guests', 'label_en','For 4 guests',
        'ficha','Guide, van and lunch for four', 'ficha_en','Guide, van and lunch for four',
        'row','Assisi and the winery · 4 guests', 'row_en','Assisi and the winery · 4 guests',
        'row_desc','Van, guide in Assisi, cellar visit and wine lunch',
        'row_desc_en','Van, guide in Assisi, cellar visit and wine lunch'))
  where proposal_id = prop and 'The day, by group size' in (title, title_en);
  get diagnostics n = row_count;
  if n <> 1 then raise exception '0158: cartão do preço não encontrado'; end if;
end $$;

insert into ops_migrations (id) values ('0158-tl-066-26-guia-incluso-e-texto') on conflict (id) do nothing;
