-- =====================================================================
-- 0116 · EMILY (TL-053-26, v2): O TEXTO FINAL, SEGUNDA VERSÃO
--
-- Arquivo dela, nov/26, "TL-053-26 · Emily & Nathan · Texto final da
-- proposta": o texto de todas as telas, para substituir o atual
-- exatamente como está, e o texto das linhas de "Your proposal" (nome e
-- uma linha de descrição). As mudanças de layout estão num segundo
-- arquivo dela, que ainda não chegou.
--
-- O que muda:
--   · títulos dos dias ("Arriving in Cortona", "Montalcino and its
--     Brunello"…) e textos, com os apóstrofos retos do arquivo dela;
--   · "Getting there" (0115) nos dias de carro próprio, no lugar do
--     "transportation" do Not included, que sai;
--   · "a private car from the hotel" no Included dos dias de Roma;
--   · a abertura de Roma, a folha de hospedagem e o Cortona já definido;
--   · em "Your proposal": o texto e a descrição de cada linha (row,
--     row_desc), a hospedagem agrupada por hotel (row_group), "Your
--     days", "Proposal to follow" e o bloco "Concierge";
--   · o terceiro parágrafo de "A journey with…" volta, sem o carro;
--   · pagamento e condições: o texto inteiro dela, no lugar do atual.
--
-- Mira por proposal_id + seção + título. Só roda com a v2 sem resposta.
--
-- Seção 7: update em ops_proposals (uma linha) e ops_proposal_items (as
-- linhas da v2), com o sim dela, que é o próprio arquivo.
-- =====================================================================

do $mig$
declare
  v uuid := 'e0530000-0000-0000-0000-000000000002';
begin
  if not exists (select 1 from ops_proposals where id = v and responded_at is null) then
    raise notice '0116: v2 já respondida ou inexistente — nada feito';
    return;
  end if;

  -- ── A proposta ──────────────────────────────────────────────────────
  update ops_proposals p set
    sections = (select jsonb_agg(
                  case s->>'key'
                    when 'cortona' then s || jsonb_build_object('intro_en',
                      $t$These are self-drive days: the car is yours, and so is the pace. On the days you'd prefer a private driver at your disposal, our concierge can arrange one, on request and subject to availability.$t$)
                    when 'roma' then s || jsonb_build_object('intro_en',
                      $t$Four nights at the Bulgari, a few minutes' walk from the Spanish Steps. The days below are our suggestion for a complete program in Rome, balancing the experiences with time of your own: an afternoon by the hotel's pool, modeled on the Roman baths, an evening on the rooftop terrace above the city, or simply wandering Rome as you please. On the days with experiences, a private car takes you from the hotel.$t$)
                    when 'stays' then s || jsonb_build_object('intro_en', 'Choose your room in each hotel.')
                    else s end order by o)
                  from jsonb_array_elements(p.sections) with ordinality t(s, o)),
    labels = coalesce(p.labels, '{}'::jsonb) || jsonb_build_object(
      'j_lead', jsonb_build_object('en', $t$Everything below is part of the program we designed for you. If you'd like to fine-tune any part of it, Danielle will adjust it with us.$t$),
      'j_b_days', jsonb_build_object('en', 'Your days'),
      'j_pending', jsonb_build_object('en', 'Proposal to follow')),
    closing_en = '**A journey with Destinations by Dani**' || chr(10)
      || 'Tuscan Lands Travel is the ground partner of Destinations by Dani in Italy. Our team coordinates the trip locally, from the stays to every transfer and experience, in direct contact with Danielle at every step.' || chr(10)
      || 'Before the trip, our concierge can take care of your restaurant reservations, as described in Ground Services & Concierge, and prepares a suggested route for the self-drive days with nothing scheduled, so those days have a direction whenever you want one.' || chr(10)
      || 'During the trip, the concierge remains available through Danielle for whatever comes up along the way, always on request and subject to availability. Our team on the ground follows each day together with Danielle.',
    conditions_en = $c$**PAYMENT**
All prices are in Euros (€) and include VAT. Payments can be made by credit card or bank transfer, and our team will send you the payment links and banking details.
**Deposit:** you may choose between two options.
- Option 1: a 35% deposit on confirmation and the balance by April 21, 2027, 60 days before travel.
- Option 2: a 35% deposit on confirmation, 30% by February 1, 2027, and the remaining 35% by April 21, 2027.
**The Vatican Master Key experience:** as the Vatican Museums open their calendar only at the beginning of 2027, this experience is invoiced once the date is confirmed, with full payment at that time.
**Guarantee:** a credit card guarantee is requested for the rental car and the hotel reservations, and our team will send you a secure link for this.
Please note that we are unable to process split payments among travelers; each booking is settled as a single payment by the agency or the lead client.

**TERMS & CONDITIONS**
By approving this proposal, the client acknowledges and agrees to the terms and conditions outlined herein.
**Validity:** hotel rates are dynamic and may change until the booking is confirmed. All other rates are valid for bookings confirmed by December 31, 2026, subject to availability.
**Availability:** this proposal does not hold any service. Once you approve it, our team reconfirms availability and rates with each supplier and sends you the digital terms to sign, together with the booking details we need and the payment link. Reservations are confirmed upon formalization and payment of the deposit.
**Bookings & Tickets:** tickets for monuments and museums are booked only after approval. As entry requires personalized tickets, we kindly ask the agency to share the guests' names and dates of birth exactly as they appear on their passports. Once issued, tickets are non-refundable, and sites may occasionally close by decision of their own management or in cases of force majeure.
**Scheduled times:** each experience follows its timetable, and should a delay beyond our control occur, such as a flight delay or traffic, the experience will still end at its scheduled time.
**Additional time:** any time beyond the duration included is subject to availability and charged at the end of the service.
**Waiting time on transfers:** a complimentary grace period of 15 minutes is included for all scheduled pickups. For delays of 20 minutes or more, one additional hour of service (€100) applies, charged per full hour started.
**Operational limits:** from June through September, and during the Christmas and New Year holidays, we are unable to accept new service requests after the guests' arrival.
**Weather policy:** tours take place rain or shine, except in cases of force majeure. Should a tour not be possible and rescheduling not be an option, the service will be fully refunded to the agency.
**Photos:** all photos are illustrative.

**SPECIFIC CONDITIONS FOR THIS PROPOSAL**
**Hotels:** rates include VAT, while city tax and extras are paid directly at the hotel. Cancellation is free of charge up to 10 days before arrival.
**Rental car:**
- Category 1: 1,400 km included, with additional kilometers at €3.
- Category 2: 1,050 km included, with additional kilometers at €4.50.
- A refundable security deposit of €3,000 for Category 1, or €4,000 for Category 2, is held on the driver's credit card.
- Fuel is not included.
**Ferrari experience:** 350 km are included, with additional kilometers at €22.50. A refundable security deposit of €4,500 is held on the driver's credit card the day before, and a damage deductible of €15,000 applies.
**Winery lunches:** a visit of this kind is an immersion in the estate's world of wine. The menu is set rather than à la carte, composed around the ingredients of the season and chosen to sit alongside the wines made on the property, and it is served alike to everyone at the table. Allergies and intolerances are accommodated with advance notice.

**GENERAL**
**Cancellation:** cancellations follow the terms and conditions available at https://tuscanlandstravel.com/terms-conditions-tours/, except where specific conditions apply.
**Insurance:** Tuscan Lands Travel holds all professional liability insurance required by Italian law. As this does not replace personal travel insurance, we kindly ask each traveler to carry a comprehensive travel policy.
**Personal belongings:** Tuscan Lands Travel and its partners cannot be held responsible for lost, stolen or damaged personal belongings during the services.$c$,
    updated_at = now()
   where p.id = v;

  -- ── Cortona ─────────────────────────────────────────────────────────
  update ops_proposal_items set
    title = 'Arriving in Cortona', title_en = 'Arriving in Cortona',
    details_en = $t$A private car meets you at Florence airport and brings you to the palace in Cortona in the early afternoon. The rest of the day is for settling in, and for a first walk through Cortona's steep lanes as the Val di Chiana opens out below the town walls.$t$
   where proposal_id = v and section = 'cortona' and title_en in ('Arrival', 'Arriving in Cortona');

  update ops_proposal_items i set
    title = 'Montalcino and its Brunello', title_en = 'Montalcino and its Brunello',
    details_en = 'Your car is delivered in the morning, a few minutes from the palace, and the day belongs to Montalcino, the hill town of Brunello.',
    units = (select jsonb_agg((u - 'not_included_en' - 'good_en') || coalesce(m->(u->>'key'), '{}'::jsonb) order by o)
               from jsonb_array_elements(i.units) with ordinality t(u, o),
                    (select jsonb_build_object(
                       'o1', jsonb_build_object(
                         'desc_en', $t$The visit begins among the vines and in the gardens of the villa, then goes down into the estate's sixteenth-century cellars. At the table, the chef cooks with the season, and the menu stays a surprise until you sit down, each course paired with one of the estate's wines.$t$,
                         'getting_en', 'in your own car, or with a private driver on request.',
                         'included_en', $t$a guided visit to the estate, the chef's lunch and the paired wines.$t$,
                         'row_en', 'Lunch with the chef at a historic estate, Montalcino',
                         'row_desc_en', $t$The estate visit and the chef's lunch, paired with the estate's wines.$t$),
                       'o2', jsonb_build_object(
                         'desc_en', $t$One of Italy's most respected winemakers sets out his base wines in front of you and talks you through each one. Then the blending begins: you taste and adjust, then taste again, with his guidance and your palate deciding, until the glass holds the wine you had in mind. It's bottled and sealed before you leave, and you sign the bottle together.$t$,
                         'good_en', 'should you want more of it at home, we can add a larger production of your blend, up to a full barrel, shipped to your door a few months later, with a personalized label if you wish.',
                         'getting_en', 'in your own car, or with a private driver on request.',
                         'included_en', 'the blending session with the winemaker and your signed bottle.',
                         'not_included_en', 'lunch, the optional production and shipping.',
                         'row_en', 'Your own wine, blended with the winemaker, Montalcino',
                         'row_desc_en', 'The blending session and your signed bottle to take home.')) m) mm)
   where proposal_id = v and section = 'cortona' and title_en in ('Montalcino', 'Montalcino and its Brunello');

  update ops_proposal_items set
    title = $t$The charming towns of Montepulciano and Pienza, in Val d'Orcia$t$,
    title_en = $t$The charming towns of Montepulciano and Pienza, in Val d'Orcia$t$,
    details_en = $t$This is the Tuscany most people picture: the cypress lines and golden hills of the Val d'Orcia, a landscape protected by UNESCO. Montepulciano, home of Vino Nobile, sits on its ridge above the vineyards, and a short drive away Pienza, the town a Renaissance pope rebuilt as his ideal city, looks out over the whole valley. A day to take at your own pace, wandering their lanes and pausing wherever the view invites you.$t$,
    not_included_en = 'lunch.'
   where proposal_id = v and section = 'cortona'
     and title_en in ('Montepulciano and Pienza', $t$The charming towns of Montepulciano and Pienza, in Val d'Orcia$t$);

  update ops_proposal_items set
    title = 'Arezzo and its goldsmiths', title_en = 'Arezzo and its goldsmiths',
    details_en = $t$Arezzo has worked gold for centuries. The morning can begin in the old town, around Piazza Grande, before you continue to the goldsmith's workshop, in Arezzo, outside the historic center. We're shaping this experience around what Emily has in mind and will share it with you soon.$t$,
    getting_en = 'in your own car, or with a private driver on request.',
    not_included_en = 'lunch.',
    row_en = 'The goldsmith experience, Arezzo'
   where proposal_id = v and section = 'cortona' and title_en in ('Arezzo', 'Arezzo and its goldsmiths');

  update ops_proposal_items set
    title = 'Umbria, across the valley', title_en = 'Umbria, across the valley',
    details_en = 'A day for the palace, or for Umbria, just across the valley: Orvieto on its cliff of tuff, or Deruta, where ceramics have been made for centuries. If the craft appeals, our concierge can arrange a visit to a workshop, and even a piece made for you to take home, on request and subject to availability.',
    not_included_en = 'lunch.'
   where proposal_id = v and section = 'cortona' and title_en in ('A day of your own', 'Umbria, across the valley');

  -- ── Castelfalfi ─────────────────────────────────────────────────────
  update ops_proposal_items set
    title = 'Into the Tuscan countryside', title_en = 'Into the Tuscan countryside',
    details_en = 'A drive of under two hours from Cortona, and the afternoon is yours for the spa and the views over the estate.'
   where proposal_id = v and section = 'castelfalfi' and title_en in ('Cortona to Castelfalfi', 'Into the Tuscan countryside');

  update ops_proposal_items set
    title = 'Truffle hunting in the woods', title_en = 'Truffle hunting in the woods',
    details_en = 'In the woods, the truffle hunters and their dogs lead the way, and you see how instinct, knowledge and time come together in this seasonal search. No rush here: the pace is set by the woods and the dogs. The morning ends at their table, with a lunch built around the truffle and a tasting of everything they make: a table full of stories to tell.',
    good_en = null,
    getting_en = 'in your own car, or with a private driver on request.',
    included_en = 'the truffle hunt, the truffle lunch and the tasting.',
    not_included_en = null,
    row_en = 'Truffle hunting in the woods',
    row_desc_en = 'The hunt with the truffle hunters and their dogs, the truffle lunch and the tasting.'
   where proposal_id = v and section = 'castelfalfi' and title_en in ('Truffle hunting', 'Truffle hunting in the woods');

  update ops_proposal_items i set
    title = 'Siena and the towers of San Gimignano', title_en = 'Siena and the towers of San Gimignano',
    details_en = $t$Siena comes first, in the company of a local guide who knows the city's curiosities and takes you where you'd be unlikely to wander on your own. In the afternoon, San Gimignano and its towers, and a winery just outside the walls, where you're welcomed with a glass of wine. After the barrel room, the table is set on a terrace facing the towers: Tuscan recipes in a modern key, each course paired with the estate's wines. It can be lunch, or dinner with the towers in the evening light.$t$,
    getting_en = 'in your own car, or with a private driver on request.',
    included_en = 'your guide in Siena, the winery visit and the paired four-course meal.',
    not_included_en = 'other meals.',
    units = (select jsonb_agg(u || coalesce(m->(u->>'key'), '{}'::jsonb) order by o)
               from jsonb_array_elements(i.units) with ordinality t(u, o),
                    (select jsonb_build_object(
                       'siena', jsonb_build_object('row_en', 'Siena with a private local guide',
                         'row_desc_en', 'A morning in Siena with a guide who knows its curiosities.'),
                       'vinicola', jsonb_build_object('row_en', 'Winery visit and four-course meal, San Gimignano',
                         'row_desc_en', $t$The cellar visit and four courses paired with the estate's wines.$t$)) m) mm)
   where proposal_id = v and section = 'castelfalfi'
     and title_en in ('Siena and San Gimignano', 'Siena and the towers of San Gimignano');

  update ops_proposal_items i set
    title = 'Sunset in the Tuscan hills', title_en = 'Sunset in the Tuscan hills',
    details_en = 'A slow morning at the resort; the rental car is collected before noon.',
    units = (select jsonb_agg(u || coalesce(m->(u->>'key'), '{}'::jsonb) order by o)
               from jsonb_array_elements(i.units) with ordinality t(u, o),
                    (select jsonb_build_object(
                       'o1', jsonb_build_object(
                         'desc_en', 'In the late afternoon, a picnic is set for you on the Castelfalfi estate, with local products and wines, while the sun goes down over the hills.',
                         'included_en', 'the picnic with local products and wines.',
                         'row_en', 'A picnic at sunset on the Castelfalfi estate',
                         'row_desc_en', 'Local products and wines as the sun goes down.'),
                       'o2', jsonb_build_object(
                         'desc_en', $t$In the afternoon, a vintage convertible is waiting at Castelfalfi. Top down, you follow a route we've prepared along the panoramic roads of the area, and arrive at the picnic as the sun begins to set.$t$,
                         'good_en', $t$the car has a manual transmission. If you'd like, a support car can escort you along the way.$t$,
                         'included_en', 'the vintage car for the afternoon, the route and the picnic with local products and wines.',
                         'not_included_en', 'the optional support car.',
                         'row_en', 'A vintage convertible, then the picnic',
                         'row_desc_en', 'An afternoon top down on the panoramic roads, ending at the picnic.')) m) mm)
   where proposal_id = v and section = 'castelfalfi' and title_en in ('Castelfalfi', 'Sunset in the Tuscan hills');

  -- ── Castelfalfi to Rome ─────────────────────────────────────────────
  update ops_proposal_items set
    details_en = 'A Ferrari 296 GTS is waiting at Castelfalfi, and the drive to Rome becomes the day itself. The road takes you through the Tuscan countryside and down to the Argentario coast for lunch by the sea, then on toward Rome and the Bulgari. A lead car with qualified staff travels with you and carries your luggage, so your attention stays on the road. Other models are available on request.',
    good_en = 'the car seats two, and the lead car carries up to three suitcases and three carry-on bags. The security deposit, damage deductible and additional kilometers are set out in the General Conditions.',
    included_en = $t$the Ferrari with up to 350 km, the lead car and its staff, fuel, parking, tolls and Telepass, luggage transport, and transfers to or from the hotel wherever the route can't begin or end there.$t$,
    not_included_en = 'lunch.',
    row_en = 'Behind the wheel of a Ferrari 296 GTS',
    row_desc_en = 'From Castelfalfi to Rome by the Argentario coast, with a lead car carrying your luggage.'
   where proposal_id = v and section = 'aroma' and title_en = 'Behind the wheel of a Ferrari';

  -- ── Rome ────────────────────────────────────────────────────────────
  update ops_proposal_items set
    title = 'Beneath the Colosseum', title_en = 'Beneath the Colosseum',
    details_en = $t$The day begins beneath the arena, in the underground of the Colosseum, where gladiators and animals waited before the games. We aim for the first entry of the morning, when it's at its quietest. From there your guide takes you up into the arena and on to the Roman Forum, and the afternoon is yours in the heart of Rome.$t$
      || chr(10) || chr(10)
      || $t$Each year the Colosseum opens on a few evenings. If one falls during your stay, we'll propose it.$t$,
    included_en = 'your guide, entry to the underground, the arena and the Roman Forum, and a private car from the hotel.',
    not_included_en = 'lunch.',
    row_en = 'Beneath the Colosseum',
    row_desc_en = 'The underground, the arena and the Roman Forum with your guide.'
   where proposal_id = v and section = 'roma' and title_en in ('The Colosseum', 'Beneath the Colosseum');

  update ops_proposal_items set
    details_en = $t$Rome is still quiet when you reach the Vatican, where your private guide and the Clavigero, the keeper of the keys, are waiting. He lifts the historic ring of keys, the Sistine Chapel's among them, and you walk with him through the museums before they open, door after door, as the lights come on along the Galleries of the Tapestries and the Maps and through the Raphael Rooms. Then he unlocks the Sistine Chapel, and you stand beneath Michelangelo's ceiling as the light fills it. Breakfast follows in the Cortile della Pigna, before the museums open for the day.$t$,
    included_en = 'the private early-morning visit with the Clavigero and your guide, breakfast, and a private car from the hotel.',
    not_included_en = 'lunch.',
    row_en = 'Morning · The Vatican Master Key experience',
    row_desc_en = 'The private early-morning visit with the Clavigero and your guide, with breakfast.'
   where proposal_id = v and section = 'roma' and title_en = 'The Vatican Master Key experience';

  update ops_proposal_items set
    details_en = $t$The perfect setting for a toast to a meaningful journey together. A private aperitivo on board while you cruise the Tiber, with a privileged perspective on Rome's historic bridges: a joyful, intimate way to close the afternoon before dinner.$t$
      || chr(10) || chr(10)
      || '[▶ See this experience up close](https://youtube.com/shorts/DU_-fkN3VHU?si=NtEeY5A4mc-nRn7z)',
    included_en = 'a private boat with a dedicated crew, an Italian aperitivo on board, and a private car from the hotel.',
    row_en = 'Afternoon · A private aperitivo on the Tiber',
    row_desc_en = $t$A private boat and an Italian aperitivo beneath Rome's historic bridges.$t$
   where proposal_id = v and section = 'roma' and title_en = 'A private aperitivo on the Tiber';

  update ops_proposal_items i set
    title = $t$Rome's fashion houses, with a personal stylist$t$,
    title_en = $t$Rome's fashion houses, with a personal stylist$t$,
    units = (select jsonb_agg(u || coalesce(m->(u->>'key'), '{}'::jsonb) order by o)
               from jsonb_array_elements(i.units) with ordinality t(u, o),
                    (select jsonb_build_object(
                       'o1', jsonb_build_object(
                         'desc_en', $t$A personal stylist receives you both in the private lounge of one of Rome's great department stores, four floors of Italian and international houses for men and women. She has already chosen pieces for each of you around your tastes, so your time goes to trying on.$t$,
                         'included_en', $t$the stylist's selection and her time with you, and a private car from the hotel.$t$,
                         'not_included_en', 'purchases.',
                         'row_en', 'Together, in a private lounge with a personal stylist',
                         'row_desc_en', 'A first selection chosen for each of you around your tastes.'),
                       'o2', jsonb_build_object(
                         'desc_en', $t$Each of you has a morning or an afternoon of your own with the stylist. It begins before the trip, with a short questionnaire, a few photographs and the outfits you wear most, from which she reads your style and prepares the looks you'll choose from. In Rome, she takes you to the boutiques chosen for you, with a word on each house before you step in, and a breakfast, brunch or aperitivo along the way.$t$,
                         'included_en', 'for each of you, the style analysis, the look selection, the tour with an English-speaking interpreter, and a private car from the hotel.',
                         'not_included_en', 'purchases, a private driver (available on request).',
                         'row_en', 'A styling tour for each of you',
                         'row_desc_en', 'A style analysis before the trip and the boutiques chosen for each of you.')) m) mm)
   where proposal_id = v and section = 'roma'
     and title_en in ('Shopping in Rome', $t$Rome's fashion houses, with a personal stylist$t$);

  update ops_proposal_items set
    title = 'A last morning in Rome', title_en = 'A last morning in Rome',
    details_en = 'A private car takes you from the hotel to Fiumicino, leaving around 9:00 for your 12:20 flight. At the airport, a meet and greet assistant welcomes you at the terminal and accompanies you through to the gate.'
   where proposal_id = v and section = 'roma' and title_en in ('Departure', 'A last morning in Rome');

  -- ── Where you'll stay ───────────────────────────────────────────────
  update ops_proposal_items set details_en = 'Your five nights in Cortona are already arranged.'
   where proposal_id = v and section = 'stays' and title_en = 'Cortona · a historic palace';

  update ops_proposal_items i set
    row_group_en = 'Castelfalfi · June 25 to 29',
    units = (select jsonb_agg(u || coalesce(m->(u->>'key'), '{}'::jsonb) order by o)
               from jsonb_array_elements(i.units) with ordinality t(u, o),
                    (select jsonb_build_object(
                       'u1', jsonb_build_object('row_en', 'Junior Suite Terrace · 4 nights'),
                       'u2', jsonb_build_object('row_en', 'Suite Terrace · 4 nights')) m) mm)
   where proposal_id = v and section = 'stays' and title_en = 'Castelfalfi';

  update ops_proposal_items i set
    row_group_en = 'Bulgari Hotel Roma · June 29 to July 3',
    units = (select jsonb_agg(u || coalesce(m->(u->>'key'), '{}'::jsonb) order by o)
               from jsonb_array_elements(i.units) with ordinality t(u, o),
                    (select jsonb_build_object(
                       'u1', jsonb_build_object('row_en', 'Premium Room · 4 nights'),
                       'u2', jsonb_build_object('row_en', 'Junior Suite · 4 nights')) m) mm)
   where proposal_id = v and section = 'stays' and title_en = 'Bulgari Hotel Roma';

  -- ── Ground Services & Concierge ─────────────────────────────────────
  update ops_proposal_items set
    row_en = 'Private transfer, Florence airport to Cortona',
    row_desc_en = 'A private car from the airport to the palace.'
   where proposal_id = v and section = 'around' and title_en = 'Arrival';

  update ops_proposal_items i set
    good_en = $t$fuel is not included. A refundable security deposit is held on the driver's credit card, and kilometers beyond those included are charged separately, as set out in the General Conditions.$t$,
    units = (select jsonb_agg(u || coalesce(m->(u->>'key'), '{}'::jsonb) order by o)
               from jsonb_array_elements(i.units) with ordinality t(u, o),
                    (select jsonb_build_object(
                       'c1', jsonb_build_object('row_en', 'Category 1 · Grand touring',
                         'row_desc_en', 'Mercedes GLE, Maserati Grecale Modena or Audi Q8 · 1,400 km included · fuel not included'),
                       'c2', jsonb_build_object('row_en', 'Category 2 · Commanding',
                         'row_desc_en', 'Land Rover Defender 110, BMW X7 or Range Rover Sport · 1,050 km included · fuel not included')) m) mm)
   where proposal_id = v and section = 'around' and title_en = 'Your car in Tuscany';

  update ops_proposal_items set
    row_en = 'Private transfer, hotel to Fiumicino Terminal 3',
    row_desc_en = 'A private car for your 12:20 flight.'
   where proposal_id = v and section = 'around' and title_en = 'Departure';

  update ops_proposal_items set
    row_en = 'VIP meet and greet at Fiumicino',
    row_desc_en = 'An assistant from the terminal entrance to the gate.'
   where proposal_id = v and section = 'around' and title_en = 'VIP meet and greet at Fiumicino';

  update ops_proposal_items set
    row_group_en = 'Concierge',
    row_en = 'Before the trip · Restaurant selection and reservations · 13 days × €60',
    row_desc_en = 'A shortlist for each day and the reservations you approve.',
    details_en = $t$Before you travel, our concierge service takes care of the planning around your days, starting with the restaurants. The tables worth planning a day around are often booked months ahead: our team prepares a shortlist for each day, chosen around your route, and once you approve it we make the reservations, always subject to availability. The best-known tables are reserved months in advance, the more local places a few weeks before you leave. If you'd rather book yourselves, we suggest reserving the days that matter most to you early, through your hotel or directly with the restaurants, as tables go quickly in high season.$t$
      || chr(10) || chr(10)
      || '€60 per day for this service: the restaurant selection and reservations before the trip.'
      || chr(10) || chr(10)
      || 'During the trip, any additional services or requests, such as a private driver at your disposal for a day, are handled through our on-site concierge service, from €150 per day, always subject to availability.'
   where proposal_id = v and section = 'around' and title_en = 'Concierge services · optional';
end $mig$;

insert into ops_migrations (id) values ('0116-emily-v2-texto-final-2') on conflict (id) do nothing;
