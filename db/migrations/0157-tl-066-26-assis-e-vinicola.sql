-- =====================================================================
-- 0157 · TL-066-26: ASSIS E ALMOÇO NA VINÍCOLA, FAMÍLIA PALM
--
-- Instrução dela, 25/11/26: proposta de uma página, no modelo da TL-065-26
-- (modelo='pagina', que ela passa a chamar de "One Page Experience"), para
-- a Katie Bernal-Silva, da Amber Fern Hospitality (rede Fora). Os sogros
-- dela ficam no Vocabolo Moscatelli em abril de 2027; dia provável 9/4.
-- 2 a 4 adultos, número ainda aberto.
--
--   · o dia: van com motorista, cerca de 7 horas, saída e volta no hotel.
--     Manhã em Assis (cerca de 2 horas); na volta, visita da adega antiga
--     e almoço-degustação numa vinícola de família perto do hotel;
--   · guia local em Assis é opcional, cartão à parte;
--   · fornecedor escondido: a vinícola não é nomeada, e a única foto dela
--     é a da adega, sem marca. A do portal e as de garrafa levam o nome;
--   · white label com o logo da Amber Fern (versão branca do site dela,
--     amber-fern.com), sobre a foto da faixa.
--
-- PREÇO. Custo: van 550 (7h, IVA incluso), almoço 65 por pessoa, guia 250.
-- Venda = custo ÷ 0,73, para que 12% do preço sejam da agência e 15% da
-- Tuscan Lands; arredondado para cima, ao múltiplo de 5. Fatura 74-ter:
-- o IVA de 22% incide sobre a margem (venda − custo) e sai da parte da TL.
--
--   2 pessoas   custo  680 → venda  935 · agência 112,20 · IVA 74-ter 45,98 · TL líquido  96,82
--   4 pessoas   custo  810 → venda 1110 · agência 133,20 · IVA 74-ter 54,10 · TL líquido 112,70
--   guia        custo  250 → venda  345 · agência  41,40 · IVA 74-ter 17,13 · TL líquido  36,47
--
-- Pagamento (instrução dela): abaixo de € 1.000, pagamento único, 100% na
-- confirmação. De € 1.000 para cima, 40% e saldo 45 dias antes, como na
-- TL-065-26.
--
-- Seção 7: só insert (oportunidade, proposta e linhas novas) e o ajuste da
-- própria proposta recém-criada. Nada que já existia muda. Roda uma vez:
-- se a TL-066-26 já existe, para.
-- =====================================================================

do $$
declare
  opp  uuid;
  prop uuid := 'e0660000-0000-0000-0000-000000000001';
begin
  if exists (select 1 from ops_opportunities where crm_code = 'TL-066-26') then
    raise exception '0157: a TL-066-26 já existe';
  end if;

  insert into ops_opportunities (crm_code, title, lang, agency, agency_contact, final_client, outcome, internal_notes)
  values ('TL-066-26', 'Palm family · Assisi and a winery lunch', 'en',
          'Amber Fern Hospitality', 'Katie Bernal-Silva', 'Palm family', 'open',
          'Agência Amber Fern Hospitality (Fora). Sogros da Katie no Vocabolo Moscatelli, abril/2027, dia provável 9/4, 2 a 4 adultos. Vinícola: Blasi Cantina, Umbertide (degustação "Blasi 360"). Van: € 550 o dia inteiro, 7 horas.')
  returning id into opp;

  insert into ops_proposals (
    id, opportunity_id, version, title, lang, layout, modelo, rate_type,
    white_label, agency_logo, agency_logo_bg,
    cover_img, cover_tag_pt, cover_tag_en, cover_title, travel_window, pax_summary,
    show_prices, confirm_mode, show_summary, show_conditions, preselect, payment_options,
    sections, labels, conditions_en, internal_notes)
  values (
    prop, opp, 1, 'Assisi and a winery lunch', 'en', 'apresentada', 'pagina', 'comissionado',
    true, 'fotos/tl066/logo-amberfern.png', false,
    'fotos/tl066/assisi-faixa.jpg', 'Assisi · Umbria', 'Assisi · Umbria', 'The Palm family',
    'April 9, 2027', '2 to 4 adults',
    true, 'full', true, true, false, '[]'::jsonb,
    jsonb_build_array(jsonb_build_object(
      'key','assisi', 'tipo','transporte', 'modo','blocos', 'nights', null,
      'title','A private day from Vocabolo Moscatelli',
      'title_en','A private day from Vocabolo Moscatelli')),
    jsonb_build_object(
      'j_lead', jsonb_build_object('en',
        'Select the size of the group, and add the guide in Assisi if you like. Each price is for the whole group, and the day is private.'),
      'j_cover_credit', jsonb_build_object('en',
        'Photo: Adrian Michael · CC BY-SA 3.0')),
$c$**PAYMENT**
All prices are in Euros (€) and include VAT. Payments can be made by credit card or bank transfer, and our team will send you the payment link and banking details.
**Under € 1,000:** a single payment, 100% on confirmation.
**€ 1,000 or more:** 40% on confirmation, and the balance 45 days before travel.
Please note that we are unable to process split payments among travelers; each booking is settled as a single payment by the agency or the lead client.

**TERMS & CONDITIONS**
By approving this proposal, the client acknowledges and agrees to the terms and conditions outlined herein.
**Availability:** this proposal does not hold any service. Once you approve it, our team reconfirms availability and rates with the suppliers and sends you the digital terms to sign, together with the booking details we need and the payment link. Reservations are confirmed upon formalization and payment.
**Duration:** the day is planned for about 7 hours, from pick-up at the hotel to the return. Any extra time with the vehicle and driver is subject to availability and charged separately.
**Operational limits:** we are unable to accept new service requests after the guests' arrival.
**Photos:** all photos are illustrative.

**GENERAL**
**Cancellation:** cancellations follow the terms and conditions available at https://tuscanlandstravel.com/terms-conditions-tours/, except where specific conditions apply.
**Insurance:** Tuscan Lands Travel holds all professional liability insurance required by Italian law. As this does not replace personal travel insurance, we kindly ask each traveler to carry a comprehensive travel policy.
**Personal belongings:** Tuscan Lands Travel and its partners cannot be held responsible for lost, stolen or damaged personal belongings during the services.$c$,
    'Custo → venda (÷ 0,73: 12% agência + 15% TL, fatura 74-ter). 2 pax: van 550 + almoço 130 = 680 → 935. 4 pax: 550 + 260 = 810 → 1.110. Guia 2h: 250 → 345. Vinícola Blasi Cantina, almoço a € 65/pax (eles cotaram 50/pax e falam em percentual para agência). Van: € 550, 7 horas, IVA incluso.');

  -- O gatilho de padrões encheu a folha de abertura; nesta peça ela não sai.
  update ops_proposals set assurance_pt = '', assurance_en = '' where id = prop;

  -- 0 · o dia, sem valor: o texto, o que está incluído e o que é bom saber
  insert into ops_proposal_items (proposal_id, sort, section, kind, optional, price, supplier,
    title, title_en, details, details_en, included_pt, included_en, good_pt, good_en, photos, units, extras)
  values (prop, 0, 'assisi', 'experience', false, 0, 'Blasi Cantina · van a definir',
    'Assisi, and lunch at a family winery', 'Assisi, and lunch at a family winery',
$t$A private day with your own driver, from the hotel and back in about 7 hours. The drive to Assisi takes about an hour, almost all on a main road with very few curves. For anyone who gets carsick, the front seat makes the ride easier.
The morning is in Assisi, about two hours in the town. With a local guide you go deeper into its streets and its history; without one, the time is yours to walk it at your own pace.
On the way back, lunch is at a family winery close to the hotel, where an 18th-century cellar stands next to a contemporary building. The visit starts in the old cellar, for about 30 to 40 minutes, and lunch is served in the new one, each course with its wine:
- Bruschetta with the estate's olive oil, and a classic-method sparkling wine
- Cured meats made at the estate and cheeses, with two white wines
- Lasagna, with a red wine
- Porchetta made at the estate, with a red wine
- Small sweets, with the estate's white passito$t$,
$t$A private day with your own driver, from the hotel and back in about 7 hours. The drive to Assisi takes about an hour, almost all on a main road with very few curves. For anyone who gets carsick, the front seat makes the ride easier.
The morning is in Assisi, about two hours in the town. With a local guide you go deeper into its streets and its history; without one, the time is yours to walk it at your own pace.
On the way back, lunch is at a family winery close to the hotel, where an 18th-century cellar stands next to a contemporary building. The visit starts in the old cellar, for about 30 to 40 minutes, and lunch is served in the new one, each course with its wine:
- Bruschetta with the estate's olive oil, and a classic-method sparkling wine
- Cured meats made at the estate and cheeses, with two white wines
- Lasagna, with a red wine
- Porchetta made at the estate, with a red wine
- Small sweets, with the estate's white passito$t$,
$t$- Private van with driver, about 7 hours, from the hotel and back
- Visit of the 18th-century cellar
- Tasting lunch at the winery, with the wines listed above$t$,
$t$- Private van with driver, about 7 hours, from the hotel and back
- Visit of the 18th-century cellar
- Tasting lunch at the winery, with the wines listed above$t$,
$t$Besides the two reds, the pairing includes a sparkling wine, two whites and a sweet white.
Please let us know of any dietary restrictions when you confirm.
The date is subject to the winery's availability.$t$,
$t$Besides the two reds, the pairing includes a sparkling wine, two whites and a sweet white.
Please let us know of any dietary restrictions when you confirm.
The date is subject to the winery's availability.$t$,
    '[]'::jsonb, '[]'::jsonb, '[]'::jsonb);

  -- 1 · o dia, por tamanho do grupo: 2 OU 4 pessoas
  insert into ops_proposal_items (proposal_id, sort, section, kind, optional, price, supplier, choice_group,
    title, title_en, row_group_pt, row_group_en, details, details_en, photos, units, extras)
  values (prop, 1, 'assisi', 'experience', true, 0, 'Blasi Cantina · van a definir', 'dia',
    'The day, by group size', 'The day, by group size', 'Assisi and the winery', 'Assisi and the winery',
    'Van with driver, the cellar visit and the tasting lunch.',
    'Van with driver, the cellar visit and the tasting lunch.',
    '["fotos/tl066/adega-historica.jpg"]'::jsonb,
    jsonb_build_array(
      jsonb_build_object('key','pax2', 'optional',true, 'price',935,
        'label','For 2 guests', 'label_en','For 2 guests',
        'ficha','About 7 hours · lunch for two', 'ficha_en','About 7 hours · lunch for two',
        'row','Assisi and the winery · 2 guests', 'row_en','Assisi and the winery · 2 guests',
        'row_desc','Private van, about 7 hours, with the cellar visit and tasting lunch',
        'row_desc_en','Private van, about 7 hours, with the cellar visit and tasting lunch'),
      jsonb_build_object('key','pax4', 'optional',true, 'price',1110,
        'label','For 4 guests', 'label_en','For 4 guests',
        'ficha','About 7 hours · lunch for four', 'ficha_en','About 7 hours · lunch for four',
        'row','Assisi and the winery · 4 guests', 'row_en','Assisi and the winery · 4 guests',
        'row_desc','Private van, about 7 hours, with the cellar visit and tasting lunch',
        'row_desc_en','Private van, about 7 hours, with the cellar visit and tasting lunch')),
    '[]'::jsonb);

  -- 2 · o guia em Assis, à parte
  insert into ops_proposal_items (proposal_id, sort, section, kind, optional, price, supplier, choice_group,
    title, title_en, row_group_pt, row_group_en, details, details_en, photos, units, extras)
  values (prop, 2, 'assisi', 'experience', true, 0, 'guia local a definir', 'guia',
    'A local guide in Assisi', 'A local guide in Assisi', 'Guide in Assisi', 'Guide in Assisi',
    'Two hours in the town with a local guide, private for the group.',
    'Two hours in the town with a local guide, private for the group.',
    '["fotos/tl066/assisi-vicolo.jpg"]'::jsonb,
    jsonb_build_array(
      jsonb_build_object('key','guia', 'optional',true, 'price',345,
        'label','Guided visit · 2 hours', 'label_en','Guided visit · 2 hours',
        'ficha','Same price for 2 or 4 guests', 'ficha_en','Same price for 2 or 4 guests',
        'row','Local guide in Assisi', 'row_en','Local guide in Assisi',
        'row_desc','2 hours, private for the group', 'row_desc_en','2 hours, private for the group')),
    '[]'::jsonb);
end $$;

insert into ops_migrations (id) values ('0157-tl-066-26-assis-e-vinicola') on conflict (id) do nothing;
