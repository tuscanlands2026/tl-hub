-- =====================================================================
-- 0133 · EMILY (v3, agora TL-064-26): O DIA DE AREZZO, O NÚMERO NOVO, OS
--        APROVADOS "IN TL-053-26" E AS CONDIÇÕES SEM HOTEL E SEM CARRO
--
-- Instruções dela, 13/11/26, com o sim por escrito:
--   · o dia 23, que estava "Proposal to follow", ganha as duas oficinas:
--     Steli d'oro primeiro (a experiência "behind the scenes", a partir de
--     € 350 por pessoa, ou a visita privada, a partir de € 250 por pessoa)
--     e Lorini Gioielli (visita privada, a partir de € 250 por pessoa). Ela
--     escolhe UMA (choice_group). O valor é "a partir de" e não soma
--     (price_text, 0132). Sem "no commitment to buy". Compra de joia,
--     transporte e almoço não inclusos; peça sob encomenda tem orçamento à
--     parte. Depois do ateliê, sugestão de almoço na região e da cidade
--     velha. Fotos das duas oficinas, dos sites delas (fotos/tl053/).
--   · a v3 tem número próprio: TL-064-26 (ref_code, 0132). A v1 e a v2
--     continuam TL-053-26.
--   · o que já foi aprovado sai "Approved in TL-053-26".
--   · nas condições saem a parte do hotel e a do carro alugado, que já
--     estão na outra proposta: o bloco "Hotels", o bloco "Rental car", a
--     linha "Guarantee" (que fala só de carro e hotel) e o trecho de hotel
--     da "Validity".
--
-- Seção 7: update só na v3 (e0530000-…-0003) e nas linhas dela, nascidas
-- na 0131. A v2 e a v1 não são tocadas. Cada troca de texto se prende à
-- frase que troca, e para se não achar.
-- =====================================================================

do $$
declare
  v3 uuid := 'e0530000-0000-0000-0000-000000000003';
  c text; d text; n int;
begin
  if exists (select 1 from ops_proposals where id = v3 and responded_at is not null) then
    raise exception '0133: a v3 já foi respondida, nada muda';
  end if;

  -- 1 · número e rótulos
  update ops_proposals set
    ref_code = 'TL-064-26',
    labels = coalesce(labels, '{}'::jsonb)
      || '{"j_approved":{"en":"Approved in TL-053-26"},
           "j_approved_note":{"en":"Approved in TL-053-26, not included in this total"}}'::jsonb
   where id = v3;

  -- 2 · condições sem hotel e sem carro
  select conditions_en into c from ops_proposals where id = v3;

  d := c;
  c := replace(c, E'**Guarantee:** a credit card guarantee is requested for the rental car and the hotel reservations, and our team will send you a secure link for this.\n', '');
  if c = d then raise exception '0133: linha Guarantee não encontrada'; end if;

  d := c;
  c := replace(c, '**Validity:** hotel rates are dynamic and may change until the booking is confirmed. All other rates are valid for bookings confirmed by December 31, 2026, subject to availability.',
                  '**Validity:** rates are valid for bookings confirmed by December 31, 2026, subject to availability.');
  if c = d then raise exception '0133: Validity não encontrada'; end if;

  d := c;
  c := replace(c, E'**Hotels:** rates include VAT, while city tax and extras are paid directly at the hotel. Cancellation is free of charge up to 10 days before arrival.\n', '');
  if c = d then raise exception '0133: bloco Hotels não encontrado'; end if;

  d := c;
  c := replace(c, E'**Rental car:**\n- Category 1: 1,400 km included, with additional kilometers at €3.\n- Category 2: 1,050 km included, with additional kilometers at €4.50.\n- A refundable security deposit of €3,000 for Category 1, or €4,000 for Category 2, is held on the driver''s credit card.\n- Fuel is not included.\n- Cancellation: 20% of the rental amount is paid on confirmation and is non-refundable in case of cancellation; the balance is paid 30 days before the start of the rental and is non-refundable in case of cancellation.\n', '');
  if c = d then raise exception '0133: bloco Rental car não encontrado'; end if;

  update ops_proposals set conditions_en = c where id = v3;

  -- 3 · o dia de Arezzo. Cada opção leva 'label' além de 'label_en': o
  --     editor descarta, ao salvar, opção sem nome em português.
  update ops_proposal_items set
    optional = true,
    choice_group = 'arezzo',
    price = 0,
    row_en = null, row_desc_en = null,
    details_en = $t$Arezzo has worked gold for centuries, and it is still one of Italy's goldsmithing towns. The morning begins at a goldsmith's atelier, and we have designed two ways to spend it, built on what the ateliers already do and shaped for this trip: a hands-on morning at the goldsmith's bench, or a private visit, with time to see the collections and, if a piece speaks to Emily, to choose it or start one designed for her.

We suggest two ateliers with very different hands, so Emily can see which style is closer to what she has in mind.

**Steli d'oro.** A family atelier founded in 2002 by the goldsmith Steve Angeli and run today with Silvia. In 2025 the Tuscany Region named Steve a Maestro Artigiano, a title given to craftsmen for the quality of their work and for passing the craft on. The atelier is best known for engagement and wedding rings made to measure, and also makes necklaces and other rings, and reworks pieces that already exist. [Visit the Steli d'oro website](https://www.stelidoro.it/)

**Lorini Gioielli.** Jacopo is a goldsmith and gemologist who makes only one-of-a-kind pieces in 18 kt gold, with diamonds and natural gemstones, and he can also design a necklace or a bracelet in gold with an essential line. [Visit the Lorini Gioielli website](https://www.lorinigioielli.com/en)

After the atelier, we suggest lunch in the area and an afternoon in the old town: Piazza Grande, on its slope, and Piero della Francesca's frescoes of the Legend of the True Cross in the Basilica of San Francesco.$t$,
    included_en = null,
    not_included_en = $t$Any jewellery purchase, transportation and lunch. If Emily would like to commission a piece, we will request a separate quote for that work before anything is defined.$t$,
    good_en = $t$A piece already available may need small adjustments, such as resizing, which can take a few days. A piece made for Emily needs design and handcrafting, and can take several weeks depending on the project; if she would like to wear it during the trip, please let us know.
We can also book the lunch for you.$t$,
    units = jsonb_build_array(
      jsonb_build_object('key','steli_lab','optional',true,
        'label_en', $t$Behind the scenes of the atelier, at Steli d'oro$t$,
        'label', $t$Behind the scenes of the atelier, at Steli d'oro$t$,
        'desc_en', $t$Two hours with Steve Angeli in his workshop. He shows how a jewel is made, from the first idea to the metal, and the old techniques behind the details. Then it is your turn: you sit at the master's bench and try stone setting with your own hands. To close, the showroom is yours to explore, with a glass of Tuscan Vin Santo and cantuccini from the Arezzo area.$t$,
        'included_en', $t$Guided visit of the workshop with Steve Angeli, the goldsmith's techniques and process explained, a personal bench for stone setting, the showroom with Vin Santo and cantuccini.$t$,
        'photos', jsonb_build_array('fotos/tl053/steli-bancada.jpg','fotos/tl053/steli-showroom.jpg'),
        'row_en', $t$Behind the scenes of the atelier · Steli d'oro$t$,
        'row_desc_en', $t$Two hours at the goldsmith's bench with Steve Angeli$t$,
        'price_text_en', 'From € 350 per person'),
      jsonb_build_object('key','steli_visit','optional',true,
        'label_en', $t$A private visit to Steli d'oro$t$,
        'label', $t$A private visit to Steli d'oro$t$,
        'desc_en', $t$Time in the boutique and the workshop, at your own pace, to see how they work and what they make. If a piece catches Emily's eye, she can choose it, or talk with Steve about one made for her. Once we know her taste, we can ask the atelier to set aside a few pieces from their collection before the visit.$t$,
        'photos', jsonb_build_array('fotos/tl053/steli-aliancas.jpg','fotos/tl053/steli-showroom.jpg'),
        'row_en', $t$Private atelier visit · Steli d'oro$t$,
        'row_desc_en', 'The boutique and the workshop, at your own pace',
        'price_text_en', 'From € 250 per person'),
      jsonb_build_object('key','lorini_visit','optional',true,
        'label_en', 'A private visit to Lorini Gioielli',
        'label', 'A private visit to Lorini Gioielli',
        'desc_en', $t$A private meeting in the atelier, with a visit to the laboratory to see Jacopo's work up close. Emily can look at the pieces available, or tell Jacopo her idea and start a design with him.$t$,
        'photos', jsonb_build_array('fotos/tl053/lorini-anel.jpg','fotos/tl053/lorini-pulseira.jpg','fotos/tl053/lorini-pingente.jpg'),
        'row_en', 'Private atelier visit · Lorini Gioielli',
        'row_desc_en', $t$The atelier and the laboratory, with Jacopo$t$,
        'price_text_en', 'From € 250 per person'))
   where proposal_id = v3 and title_en = 'Arezzo and its goldsmiths';
  get diagnostics n = row_count;
  if n <> 1 then raise exception '0133: o dia de Arezzo não foi encontrado na v3'; end if;
end $$;

insert into ops_migrations (id) values ('0133-emily-v3-arezzo-numero-e-condicoes') on conflict (id) do nothing;
