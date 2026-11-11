-- =====================================================================
-- 0110 · EMILY (TL-053-26, v2): CONCIERGE SERVICES, OS TEXTOS DE PIENZA E
--        AREZZO, O TRANSFER DE IDA EM ROMA E A TABELA EM GRUPOS
--
-- Instruções dela, nov/26, olhando a v2 no ar depois da 0108:
--
-- 1. "Dining concierge" vira "Concierge services": concierge é mais amplo
--    que restaurante. Os blocos Concierge e Dining concierge viram UM, e
--    o texto deixa claro que os € 60 por dia são deste serviço (seleção,
--    curadoria, reservas antes da viagem). Embaixo, durante a viagem:
--    concierge on-site a partir de € 150 por dia. O bloco "Concierge"
--    separado sai (delete da linha que a 0106 inseriu), e o terceiro
--    parágrafo de "A journey with Destinations by Dani" também.
-- 2. "On any day in Tuscany you'd rather be driven" — "ninguém fala
--    assim". Vira "a private driver at your disposal".
-- 3. Pienza e Arezzo com o texto novo dela; "lunch and transportation".
--    O dia livre e Siena seguem a mesma forma.
-- 4. Vatican, Coliseu e as experiências de luxo de Roma (o aperitivo no
--    Tibre e o shopping) com "one-way transfer from the hotel" no
--    Included.
-- 5. O carro das trufas sai de vez ("sai definitivamente o transporte"):
--    o Not included já diz transportation.
-- 6. A tabela de "Your proposal" em grupos (0109): nas experiências a data
--    e, embaixo, cada serviço ou opção; em Ground Services, por serviço —
--    Transfers, Car rental, Meet and greet, Concierge services. O texto da
--    linha deixa de repetir a data, que agora é o título do grupo.
--    Os blocos de experiência passam a "Cortona Region" e "Castelfalfi
--    Region".
--
-- Mira por proposal_id + seção + título. Só roda com a v2 sem resposta.
--
-- Seção 7: update em ops_proposals (uma linha) e ops_proposal_items (as
-- linhas da v2), e delete de UMA linha (o bloco "Concierge" criado pela
-- 0106 nesta mesma conversa). Com o sim dela, que são as instruções.
-- =====================================================================

do $mig$
declare
  v uuid := 'e0530000-0000-0000-0000-000000000002';
  c text;
begin
  if not exists (select 1 from ops_proposals where id = v and responded_at is null) then
    raise notice '0110: v2 já respondida ou inexistente — nada feito';
    return;
  end if;

  -- ── A proposta: aberturas, nota, rótulos, fechamento ────────────────
  update ops_proposals p set
    sections = (select jsonb_agg(
                  case s->>'key'
                    when 'cortona' then s || jsonb_build_object('intro_en',
                      $t$These are self-drive days: the car is yours, and so is the pace. On the days you’d prefer a private driver at your disposal, our concierge can arrange one, on request and subject to availability.$t$)
                    when 'around' then s || jsonb_build_object('note_en',
                      'During the trip, additional services and requests are handled through our on-site concierge service, from €150 per day, always subject to availability.')
                    else s end order by o)
                  from jsonb_array_elements(p.sections) with ordinality t(s, o)),
    labels = coalesce(p.labels, '{}'::jsonb) || jsonb_build_object(
      'j_b_exp_cortona', jsonb_build_object('en', 'Experiences · Cortona Region'),
      'j_b_exp_castelfalfi', jsonb_build_object('en', 'Experiences · Castelfalfi Region')),
    closing_en = '**A journey with Destinations by Dani**' || chr(10)
      || $t$Tuscan Lands Travel is the ground partner of Destinations by Dani in Italy. Our team coordinates the trip locally, from the stays to every transfer and experience, in direct contact with Danielle at every step.$t$ || chr(10)
      || $t$Before the trip, our concierge can take care of your restaurant reservations, as described in Ground Services & Concierge, and prepares a suggested route for the self-drive days with nothing scheduled, so those days have a direction whenever you want one.$t$,
    updated_at = now()
   where p.id = v;

  select conditions_en into c from ops_proposals where id = v;
  if position('**Dining concierge**' in c) = 0 and position('**Concierge services**' in c) = 0 then
    raise exception '0110: parágrafo do dining concierge nas condições não encontrado';
  end if;
  c := replace(c, '**Dining concierge**', '**Concierge services**');
  if position('on-site concierge service' in c) = 0 then
    if position('€60 per day.' in c) = 0 then
      raise exception '0110: valor do concierge nas condições não encontrado';
    end if;
    c := replace(c, '€60 per day.',
      '€60 per day. During the trip, additional services and requests are handled through our on-site concierge service, from €150 per day, subject to availability.');
  end if;
  update ops_proposals set conditions_en = c where id = v;

  -- ── Cortona ─────────────────────────────────────────────────────────
  update ops_proposal_items i set
    units = (select jsonb_agg(u || coalesce(m->(u->>'key'), '{}'::jsonb) order by o)
               from jsonb_array_elements(i.units) with ordinality t(u, o),
                    (select jsonb_build_object(
                       'o1', jsonb_build_object('row_en', 'Option one · Montalcino · Lunch with the chef at a historic estate'),
                       'o2', jsonb_build_object('row_en', 'Option two · Montalcino · Your own wine, blended with the winemaker')) m) mm)
   where proposal_id = v and section = 'cortona' and title_en = 'Montalcino';

  update ops_proposal_items set
    details_en = $t$This is the Tuscany most people picture: the cypress lines and golden hills of the Val d’Orcia, a landscape protected by UNESCO. Montepulciano, home of Vino Nobile, sits on its ridge above the vineyards, and a short drive away Pienza, the town a Renaissance pope rebuilt as his ideal city, looks out over the whole valley. A day to take at your own pace, wandering their lanes and pausing wherever the view invites you.$t$,
    not_included_en = 'lunch and transportation.'
   where proposal_id = v and section = 'cortona' and title_en = 'Montepulciano and Pienza';

  update ops_proposal_items set
    details_en = $t$Arezzo has worked gold for centuries. The morning can begin in the old town, around Piazza Grande, before you continue to the goldsmith’s workshop, in Arezzo, outside the historic center. We’re shaping this experience around what Emily has in mind and will share it with you soon.$t$,
    not_included_en = 'lunch and transportation.'
   where proposal_id = v and section = 'cortona' and title_en = 'Arezzo';

  update ops_proposal_items set not_included_en = 'lunch and transportation.'
   where proposal_id = v and section = 'cortona' and title_en = 'A day of your own';

  -- ── Castelfalfi ─────────────────────────────────────────────────────
  update ops_proposal_items set
    extras = '[]'::jsonb,
    row_en = 'Truffle hunting, with truffle lunch and tasting'
   where proposal_id = v and section = 'castelfalfi' and title_en = 'Truffle hunting';

  update ops_proposal_items i set
    not_included_en = 'other meals and transportation.',
    units = (select jsonb_agg(u || coalesce(m->(u->>'key'), '{}'::jsonb) order by o)
               from jsonb_array_elements(i.units) with ordinality t(u, o),
                    (select jsonb_build_object(
                       'siena', jsonb_build_object('row_en', 'Siena with a private local guide'),
                       'vinicola', jsonb_build_object('row_en', $t$San Gimignano · Winery visit and four-course meal with the estate's wines$t$)) m) mm)
   where proposal_id = v and section = 'castelfalfi' and title_en = 'Siena and San Gimignano';

  update ops_proposal_items i set
    units = (select jsonb_agg(u || coalesce(m->(u->>'key'), '{}'::jsonb) order by o)
               from jsonb_array_elements(i.units) with ordinality t(u, o),
                    (select jsonb_build_object(
                       'o1', jsonb_build_object('row_en', 'Option one · A picnic at sunset on the Castelfalfi estate'),
                       'o2', jsonb_build_object('row_en', 'Option two · A vintage convertible on the panoramic roads, then the picnic')) m) mm),
    extras = (select jsonb_agg(e || case when e->>'key' = 'support'
                                         then jsonb_build_object('row_en', 'Support car escorting the vintage convertible')
                                         else '{}'::jsonb end)
                from jsonb_array_elements(i.extras) e)
   where proposal_id = v and section = 'castelfalfi' and title_en = 'Castelfalfi';

  -- ── Castelfalfi to Rome ─────────────────────────────────────────────
  update ops_proposal_items set row_en = 'Behind the wheel of a Ferrari 296 GTS, from Castelfalfi to Rome'
   where proposal_id = v and section = 'aroma' and title_en = 'Behind the wheel of a Ferrari';

  -- ── Rome ────────────────────────────────────────────────────────────
  update ops_proposal_items set
    included_en = 'your guide, entry to the underground, the arena and the Roman Forum, and a one-way transfer from the hotel.',
    row_en = 'The Colosseum: underground, arena and Roman Forum, with your guide'
   where proposal_id = v and section = 'roma' and title_en = 'The Colosseum';

  update ops_proposal_items set
    included_en = 'the private early-morning visit with the Clavigero and your guide, breakfast, and a one-way transfer from the hotel.',
    row_en = 'Morning · The Vatican Master Key experience, private, with breakfast'
   where proposal_id = v and section = 'roma' and title_en = 'The Vatican Master Key experience';

  update ops_proposal_items set
    included_en = '- Private luxury boat cruise on the Tiber with a dedicated crew' || chr(10)
               || '- Italian aperitivo on board' || chr(10)
               || '- One-way transfer from the hotel',
    row_en = 'Afternoon · A private aperitivo on the Tiber'
   where proposal_id = v and section = 'roma' and title_en = 'A private aperitivo on the Tiber';

  update ops_proposal_items i set
    units = (select jsonb_agg(u || coalesce(m->(u->>'key'), '{}'::jsonb) order by o)
               from jsonb_array_elements(i.units) with ordinality t(u, o),
                    (select jsonb_build_object(
                       'o1', jsonb_build_object(
                         'included_en', $t$the stylist’s selection and her time with you, and a one-way transfer from the hotel.$t$,
                         'row_en', 'Option one · Shopping together in a private lounge, with a personal stylist'),
                       'o2', jsonb_build_object(
                         'included_en', 'for each of you, the style analysis, the look selection, the tour with an English-speaking interpreter, and a one-way transfer from the hotel.',
                         'row_en', 'Option two · A personal styling tour for each of you, one in the morning and one in the afternoon')) m) mm)
   where proposal_id = v and section = 'roma' and title_en = 'Shopping in Rome';

  -- ── Ground Services & Concierge: grupos por serviço ─────────────────
  update ops_proposal_items set
    row_group_en = 'Transfers',
    row_en = 'Sunday, June 20 · Florence airport to the palace in Cortona'
   where proposal_id = v and section = 'around' and title_en = 'Arrival';

  update ops_proposal_items set
    row_group_en = 'Transfers',
    row_en = 'Saturday, July 3 · Hotel to Fiumicino, Terminal 3'
   where proposal_id = v and section = 'around' and title_en = 'Departure';

  update ops_proposal_items i set
    row_group_en = 'Car rental · June 21 to 28',
    units = (select jsonb_agg(u || coalesce(m->(u->>'key'), '{}'::jsonb) order by o)
               from jsonb_array_elements(i.units) with ordinality t(u, o),
                    (select jsonb_build_object(
                       'c1', jsonb_build_object('row_en', 'Option one · Category 1 · Grand touring: Mercedes GLE, Maserati Grecale Modena or Audi Q8 · 1,400 km included · fuel not included'),
                       'c2', jsonb_build_object('row_en', 'Option two · Category 2 · Commanding: Land Rover Defender 110, BMW X7 or Range Rover Sport · 1,050 km included · fuel not included')) m) mm)
   where proposal_id = v and section = 'around' and title_en = 'Your car in Tuscany';

  update ops_proposal_items set
    row_group_en = 'Meet and greet',
    row_en = 'Saturday, July 3 · VIP meet and greet at Fiumicino, departure'
   where proposal_id = v and section = 'around' and title_en = 'VIP meet and greet at Fiumicino';

  -- O bloco Concierge separado sai: vira parte do Concierge services.
  delete from ops_proposal_items
   where proposal_id = v and section = 'around' and title_en = 'Concierge' and coalesce(price, 0) = 0;

  update ops_proposal_items set
    title = 'Concierge services · optional', title_en = 'Concierge services · optional',
    row_group_en = 'Concierge services',
    row_en = 'Before the trip · restaurant selection, curation and reservations · 13 days × €60',
    details_en = $t$Before you travel, our concierge service takes care of the planning around your days, starting with the restaurants. The tables worth planning a day around are often booked months ahead: our team prepares a shortlist for each day, chosen around your route, and once you approve it we make the reservations, always subject to availability. The best-known tables are reserved months in advance, the more local places a few weeks before you leave. If you’d rather book yourselves, we suggest reserving the days that matter most to you early, through your hotel or directly with the restaurants, as tables go quickly in high season.$t$
      || chr(10) || chr(10)
      || '€60 per day for this service: the selection, curation and reservations before the trip.'
      || chr(10) || chr(10)
      || 'During the trip, any additional services or requests, such as a private driver at your disposal for a day, are handled through our on-site concierge service, from €150 per day, always subject to availability.',
    good_en = null
   where proposal_id = v and section = 'around'
     and title_en in ('Dining concierge · optional', 'Concierge services · optional');
end $mig$;

insert into ops_migrations (id) values ('0110-emily-v2-concierge-e-tabela') on conflict (id) do nothing;
