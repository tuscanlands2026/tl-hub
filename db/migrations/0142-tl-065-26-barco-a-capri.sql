-- =====================================================================
-- 0142 · TL-065-26: O BARCO A CAPRI DA DANIELLE, COMPLEMENTO DA TL-055-26
--
-- Instrução dela, 13/11/26: proposta curta, só de experiência, em inglês,
-- no modelo da TL-053-26 (jornada, white label da Destinations by Dani).
-- A Danielle e o Philip estão em Positano de 10 a 14/5/2027 (TL-055-26,
-- order já confirmada); o que se oferece é o barco privado a Capri.
--
--   · três barcos, cada um com meio dia (3h30) e dia inteiro (7h). No barco,
--     meio dia OU dia inteiro (choice_group); entre barcos nada se exclui,
--     como no resto do hub;
--   · valor = tarifa do fornecedor + 10%, que é a comissão da agência:
--       Serapo 42      1.800 → 1.980   ·   2.500 → 2.750
--       XL Marine 43   1.600 → 1.760   ·   2.200 → 2.420
--       Apreamare 100  1.400 → 1.540   ·   1.900 → 2.090
--   · pagamento: 40% de sinal, saldo 45 dias antes da viagem;
--   · sem folha de abertura (assurance vazio): a peça é capa, os barcos e
--     "Your proposal" com as condições;
--   · fornecedor escondido: nome do barco é o do modelo, não o de batismo
--     (com o de batismo o Google acha o fornecedor), e sem link do site.
--     As fotos são do site dele, recortadas sem a sacola com a marca.
--
-- Seção 7: só insert (oportunidade, proposta e linhas novas) e o ajuste da
-- própria proposta recém-criada. Nada que já existia muda. Roda uma vez:
-- se a TL-065-26 já existe, para.
-- =====================================================================

do $$
declare
  opp  uuid;
  prop uuid := 'e0650000-0000-0000-0000-000000000001';
  base ops_proposals%rowtype;
begin
  if exists (select 1 from ops_opportunities where crm_code = 'TL-065-26') then
    raise exception '0142: a TL-065-26 já existe';
  end if;
  -- logo e agência vêm da TL-055-26, a proposta que esta complementa
  select * into base from ops_proposals where id = 'f1d3d719-5142-43e7-9359-e2b7249a25d6';
  if not found then raise exception '0142: proposta da TL-055-26 não encontrada'; end if;

  insert into ops_opportunities (crm_code, title, lang, agency, agency_contact, final_client, outcome, internal_notes)
  select 'TL-065-26', 'Danielle and Philip · Capri by boat', 'en', o.agency, o.agency_contact, o.final_client, 'open',
         'Complemento da TL-055-26 (order confirmada): barco privado de Positano a Capri. Fornecedor Lucibello Positano.'
    from ops_opportunities o where o.crm_code = 'TL-055-26'
  returning id into opp;
  if opp is null then raise exception '0142: TL-055-26 não encontrada'; end if;

  insert into ops_proposals (
    id, opportunity_id, version, title, lang, layout, modelo, rate_type,
    white_label, agency_logo, agency_logo_bg,
    cover_img, cover_tag_pt, cover_tag_en, cover_title, travel_window, pax_summary,
    show_prices, confirm_mode, show_summary, show_conditions, preselect, payment_options,
    sections, labels, conditions_en, internal_notes)
  values (
    prop, opp, 1, 'Capri by private boat', 'en', 'apresentada', 'jornada', 'comissionado',
    true, base.agency_logo, base.agency_logo_bg,
    'fotos/tl065/capa-capri.jpg', 'Positano · Capri', 'Positano · Capri', 'Danielle and Philip',
    'May 10 to 14, 2027', '2 adults',
    true, 'full', true, true, false, '[]'::jsonb,
    jsonb_build_array(jsonb_build_object(
      'key','capri', 'tipo','transporte', 'modo','blocos', 'nights', null,
      'title','A private boat to Capri · From Positano',
      'title_en','A private boat to Capri · From Positano')),
    jsonb_build_object(
      'j_lead', jsonb_build_object('en',
        'Select one boat and the length of the day. Each price is for the whole boat, private for the two of you.')),
$c$**PAYMENT**
All prices are in Euros (€) and include VAT. Payments can be made by credit card or bank transfer, and our team will send you the payment link and banking details.
**Deposit:** 40% on confirmation, and the balance 45 days before travel.
Please note that we are unable to process split payments among travelers; each booking is settled as a single payment by the agency or the lead client.

**TERMS & CONDITIONS**
By approving this proposal, the client acknowledges and agrees to the terms and conditions outlined herein.
**Availability:** this proposal does not hold any service. Once you approve it, our team reconfirms availability and rates with the supplier and sends you the digital terms to sign, together with the booking details we need and the payment link. Reservations are confirmed upon formalization and payment of the deposit.
**Departure times:** each boat day follows its departure time, and should a delay beyond our control occur, the day will still end at its scheduled time.
**Operational limits:** from June through September, and during the Christmas and New Year holidays, we are unable to accept new service requests after the guests' arrival.
**Weather and sea:** boat trips depend on sea conditions, and the call on the day is the skipper's. Should the trip not be possible and rescheduling not be an option, the service will be fully refunded to the agency.
**Photos:** all photos are illustrative.

**GENERAL**
**Cancellation:** cancellations follow the terms and conditions available at https://tuscanlandstravel.com/terms-conditions-tours/, except where specific conditions apply.
**Insurance:** Tuscan Lands Travel holds all professional liability insurance required by Italian law. As this does not replace personal travel insurance, we kindly ask each traveler to carry a comprehensive travel policy.
**Personal belongings:** Tuscan Lands Travel and its partners cannot be held responsible for lost, stolen or damaged personal belongings during the services.$c$,
    'Fornecedor: Lucibello Positano. Custo → venda (+10%, comissão da agência): Serapo 42 meio dia 1.800 → 1.980, dia inteiro 2.500 → 2.750; XL Marine 43 meio dia 1.600 → 1.760, dia inteiro 2.200 → 2.420; Apreamare 100 meio dia 1.400 → 1.540, dia inteiro 1.900 → 2.090.');

  -- O gatilho de padrões encheu a folha de abertura; nesta peça ela não sai.
  update ops_proposals set assurance_pt = '', assurance_en = '' where id = prop;

  -- 0 · o dia, sem valor: texto, incluso e o que é bom saber, uma vez só
  insert into ops_proposal_items (proposal_id, sort, section, kind, optional, price, supplier,
    title, title_en, details, details_en, included_pt, included_en, good_pt, good_en, photos, units, extras)
  values (prop, 0, 'capri', 'experience', false, 0, 'Lucibello Positano',
    'A day on the water, Positano to Capri', 'A day on the water, Positano to Capri',
$t$The boat is private, with your own skipper, and leaves from Positano. Where it goes is up to you: we can shape the route with you before the day, and the skipper adjusts it on board. There is time to swim and snorkel along the way, and lunch can be at a restaurant you reach from the sea.
On the full day you can also go ashore at Marina Grande, in Capri.$t$,
$t$The boat is private, with your own skipper, and leaves from Positano. Where it goes is up to you: we can shape the route with you before the day, and the skipper adjusts it on board. There is time to swim and snorkel along the way, and lunch can be at a restaurant you reach from the sea.
On the full day you can also go ashore at Marina Grande, in Capri.$t$,
$t$- Skipper and fuel
- Beach towels, sun pads and a sun awning
- Inner cabin, with toilet and shower
- Bluetooth sound system
- Water, soft drinks and snacks
- A bottle of Champagne and a gift bag
- On the full day, the landing fee at Marina Grande$t$,
$t$- Skipper and fuel
- Beach towels, sun pads and a sun awning
- Inner cabin, with toilet and shower
- Bluetooth sound system
- Water, soft drinks and snacks
- A bottle of Champagne and a gift bag
- On the full day, the landing fee at Marina Grande$t$,
$t$Boarding is at a private pier in Positano, with a dedicated front desk and a lounge where you can wait with a cool drink.
Lunch at the restaurant is not included, and there is no open bar on board.
The boat day can be any day of your stay in Positano, subject to availability.$t$,
$t$Boarding is at a private pier in Positano, with a dedicated front desk and a lounge where you can wait with a cool drink.
Lunch at the restaurant is not included, and there is no open bar on board.
The boat day can be any day of your stay in Positano, subject to availability.$t$,
    '["fotos/tl065/capri-faraglioni.jpg"]'::jsonb, '[]'::jsonb, '[]'::jsonb);

  -- 1 a 3 · os barcos. No barco, meio dia ou dia inteiro.
  insert into ops_proposal_items (proposal_id, sort, section, kind, optional, price, supplier, choice_group,
    title, title_en, row_group_pt, row_group_en, details, details_en, photos, units, extras)
  select prop, b.sort, 'capri', 'experience', true, 0, 'Lucibello Positano', b.grupo,
         b.nome, b.nome, b.nome, b.nome, b.txt, b.txt, b.fotos,
         jsonb_build_array(
           jsonb_build_object('key','half', 'optional',true, 'price',b.meio,
             'label','Half day · 3 hours 30', 'label_en','Half day · 3 hours 30',
             'ficha','Departing at 9:00 am or 2:00 pm', 'ficha_en','Departing at 9:00 am or 2:00 pm',
             'row', b.curto||' · Half day to Capri', 'row_en', b.curto||' · Half day to Capri',
             'row_desc','3 hours 30, from Positano', 'row_desc_en','3 hours 30, from Positano'),
           jsonb_build_object('key','full', 'optional',true, 'price',b.inteiro,
             'label','Full day · 7 hours', 'label_en','Full day · 7 hours',
             'ficha','Departing at 9:00, 9:30 or 10:00 am · landing at Marina Grande included',
             'ficha_en','Departing at 9:00, 9:30 or 10:00 am · landing at Marina Grande included',
             'row', b.curto||' · Full day to Capri', 'row_en', b.curto||' · Full day to Capri',
             'row_desc','7 hours, from Positano, with landing at Marina Grande',
             'row_desc_en','7 hours, from Positano, with landing at Marina Grande')),
         '[]'::jsonb
    from (values
      (1, 'serapo', 'Di Donna Serapo 42 HT', 'Serapo 42', 1980, 2750,
       'Red hull, teak decks and a hardtop that keeps the cockpit in the shade. The largest of the three, at 12.8 metres, with two cabins below.',
       '["fotos/tl065/serapo-42.jpg","fotos/tl065/serapo-42-deck.jpg"]'::jsonb),
      (2, 'xl43', 'XL Marine 43 Open Cruise', 'XL Marine 43', 1760, 2420,
       'A long, low open yacht in white, with a wide sun pad at the bow. 12.2 metres, and the quickest of the three.',
       '["fotos/tl065/xl-marine-43.jpg","fotos/tl065/xl-marine-43-deck.jpg"]'::jsonb),
      (3, 'apreamare', 'Apreamare 100 gozzo', 'Apreamare 100', 1540, 2090,
       'The lines of the traditional gozzo of the Gulf of Naples, in navy and teak. At 9.9 metres it is the smallest, and the one with the slowest pace.',
       '["fotos/tl065/apreamare-100.jpg","fotos/tl065/apreamare-100-deck.jpg"]'::jsonb)
    ) as b(sort, grupo, nome, curto, meio, inteiro, txt, fotos);
end $$;

insert into ops_migrations (id) values ('0142-tl-065-26-barco-a-capri') on conflict (id) do nothing;
