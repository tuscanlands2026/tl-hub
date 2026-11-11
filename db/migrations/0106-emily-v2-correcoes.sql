-- =====================================================================
-- 0106 · EMILY (TL-053-26, v2): AS CORREÇÕES DELA, PONTO POR PONTO
--
-- Instrução dela, nov/26, em arquivo ("TL-053-26 · Emily & Nathan ·
-- Correções da proposta", seções 1 a 11), com os textos em inglês para
-- copiar exatamente, e os dois preços novos: Ferrari 12.300 e Vatican
-- (Clavigero) 9.700.
--
-- O que muda, por seção do arquivo dela:
--   1   data com dia da semana em toda tela de dia (service_date); foto da
--       vinícola em Montalcino; foto de San Gimignano no dia 27
--   2   "Getting around" vira "Ground Services & Concierge" e absorve o
--       Dining, que deixa de ser seção; a folha do Dining some
--   3–5 textos de Montalcino, Arezzo, Truffle hunting, Vatican Master Key,
--       aperitivo no Tibre e partida
--   7   transfers, carro, concierge e dining concierge (€ 60 por dia, 13
--       dias = € 780) na mesma folha
--   8   o texto da agência ("A journey with Destinations by Dani")
--   9   a frase do topo de "Your proposal"
--   10  tudo opcional: o que vem marcado (units[].selected,
--       extras[].selected), o texto de cada linha da tabela (row_en, da
--       0105) e o transporte das trufas fora do incluído
--   11  pagamento, combustível, dining a € 60 por dia, título do Vatican;
--       sem campo de forma de pagamento no envio
--
-- Mira por proposal_id + seção + título, nunca por id: o id da linha não
-- é estável (salvar no editor recria as linhas). A v1 (o estudo, modelo
-- "Primeiro estudo · Luxo") não é tocada.
--
-- Guarda: só roda com a v2 sem resposta de cliente. As trocas de texto
-- nas condições conferem que acharam o trecho; não achando, para tudo.
--
-- Seção 7: update em ops_proposals (uma linha) e ops_proposal_items (as
-- linhas da v2), mais um insert (o bloco "Concierge"). Com o sim dela,
-- que é o próprio arquivo de correções.
-- =====================================================================

do $mig$
declare
  v uuid := 'e0530000-0000-0000-0000-000000000002';
  c text;
begin
  if not exists (select 1 from ops_proposals where id = v and responded_at is null) then
    raise notice '0106: v2 já respondida ou inexistente — nada feito';
    return;
  end if;

  -- ── 1 · Cortona ─────────────────────────────────────────────────────
  update ops_proposal_items set service_date = 'Sunday, June 20'
   where proposal_id = v and section = 'cortona' and title_en = 'Arrival';

  update ops_proposal_items i set
    service_date = 'Monday, June 21',
    optional = true,
    photos = '["fotos/tl053/montalcino-adega.jpg","fotos/tl053/montalcino-espiral.jpg"]'::jsonb,
    units = (select jsonb_agg(u || coalesce(m->(u->>'key'), '{}'::jsonb) order by o)
               from jsonb_array_elements(i.units) with ordinality t(u, o),
                    (select jsonb_build_object(
                       'o1', jsonb_build_object(
                         'selected', true,
                         'desc_en', $t$At one of Montalcino's historic Brunello estates, you walk the vineyard and the gardens of the villa, see where the wine is made today, and go down into its 16th-century cellars. Then the chef's four-course lunch, with a seasonal menu you discover at the table and five of the estate's wines poured alongside.$t$,
                         'included_en', $t$the guided visit of the estate, about two and a half hours, the chef's four-course lunch and five wines.$t$,
                         'row_en', 'Monday, June 21 · Montalcino · Lunch with the chef at a historic estate, with five wines'),
                       'o2', jsonb_build_object(
                         'label', 'Your own wine, blended with the winemaker',
                         'label_en', 'Your own wine, blended with the winemaker',
                         'desc_en', $t$One of Italy's best-known winemakers sits down with you and opens a set of base wines, explaining what each one brings. You tell him the kind of wine you like, and together you blend: different proportions, tasted side by side and adjusted, until the wine is the one you want. He guides every trial, and the choices are yours. Your blend is bottled and sealed in front of you, and you sign the bottle with him.$t$,
                         'good_en', $t$if you'd like more of your wine at home, we can add a larger production of your blend, up to a full barrel, shipped to your door about 100 days later, with a personalized label on request.$t$,
                         'included_en', 'the two-hour session with the winemaker, the tasting of the base wines and your signed bottle.',
                         'not_included_en', 'lunch, the optional production and shipping.',
                         'row_en', 'Monday, June 21 · Montalcino · Your own wine, blended with the winemaker, with your signed bottle')) m) mm)
   where proposal_id = v and section = 'cortona' and title_en = 'Montalcino';

  update ops_proposal_items set service_date = 'Tuesday, June 22'
   where proposal_id = v and section = 'cortona' and title_en = 'Montepulciano and Pienza';

  update ops_proposal_items set
    service_date = 'Wednesday, June 23',
    details_en = $t$Arezzo has been a city of goldsmiths for centuries. If you'd like, start the day in the old town, with Piazza Grande and the streets around it, then continue to the goldsmith's workshop, in Arezzo just outside the historic center. We're shaping this experience around Emily's request and will share the proposal soon.$t$,
    not_included_en = 'lunch.'
   where proposal_id = v and section = 'cortona' and title_en = 'Arezzo';

  update ops_proposal_items set service_date = 'Thursday, June 24'
   where proposal_id = v and section = 'cortona' and title_en = 'A day of your own';

  -- ── 2 · Castelfalfi ─────────────────────────────────────────────────
  update ops_proposal_items set service_date = 'Friday, June 25'
   where proposal_id = v and section = 'castelfalfi' and title_en = 'Cortona to Castelfalfi';

  update ops_proposal_items set
    title = 'Truffle hunting', title_en = 'Truffle hunting',
    service_date = 'Saturday, June 26',
    optional = true,
    details_en = $t$Walking through the woods with the truffle hunters and their dogs for about two hours, you see how instinct, knowledge and time come together in this seasonal search. No rush here: the pace is set by the woods and the dogs. Back at their shop, a lunch built around the truffle and a tasting of everything they make, and a table full of stories to tell.$t$,
    good_en = 'you drive yourselves to the hunt. A private car to and from the hunt can be added on request.',
    included_en = 'the truffle hunt, about two hours, the truffle lunch and the tasting.',
    row_en = 'Saturday, June 26 · Truffle hunting, with truffle lunch and tasting',
    extras = jsonb_build_array(jsonb_build_object(
      'key', 'transp', 'price', 790,
      'label_pt', 'Carro privativo de ida e volta para a caça às trufas',
      'label_en', 'Optional: private car to and from the truffle hunt',
      'row_en', 'Saturday, June 26 · Optional: private car to and from the truffle hunt'))
   where proposal_id = v and section = 'castelfalfi' and title_en in ('Truffles', 'Truffle hunting');

  -- Siena e San Gimignano: as duas partes independentes, e a escolha de
  -- almoço ou jantar embaixo da segunda (extra de valor zero, que vale só
  -- com a vinícola marcada).
  update ops_proposal_items i set
    service_date = 'Sunday, June 27',
    optional = true,
    choice_group = null,
    photos = '["fotos/tl053/san-gimignano.jpg"]'::jsonb,
    units = (select jsonb_agg(u || coalesce(m->(u->>'key'), '{}'::jsonb) order by o)
               from jsonb_array_elements(i.units) with ordinality t(u, o),
                    (select jsonb_build_object(
                       'siena', jsonb_build_object('optional', true, 'selected', true,
                         'row_en', 'Sunday, June 27 · Siena with a private local guide'),
                       'vinicola', jsonb_build_object('optional', true, 'selected', true,
                         'row_en', $t$Sunday, June 27 · San Gimignano · Winery visit and four-course meal with the estate's wines$t$)) m) mm),
    extras = jsonb_build_array(
      jsonb_build_object('key', 'lunch', 'unit', 'vinicola', 'grupo', 'refeicao', 'price', 0,
                         'selected', true, 'label_pt', 'Almoço', 'label_en', 'Lunch'),
      jsonb_build_object('key', 'dinner', 'unit', 'vinicola', 'grupo', 'refeicao', 'price', 0,
                         'label_pt', 'Jantar', 'label_en', 'Dinner'))
   where proposal_id = v and section = 'castelfalfi' and title_en = 'Siena and San Gimignano';

  update ops_proposal_items i set
    service_date = 'Monday, June 28',
    optional = true,
    units = (select jsonb_agg(u || coalesce(m->(u->>'key'), '{}'::jsonb) order by o)
               from jsonb_array_elements(i.units) with ordinality t(u, o),
                    (select jsonb_build_object(
                       'o1', jsonb_build_object('selected', true,
                         'row_en', 'Monday, June 28 · A picnic at sunset on the Castelfalfi estate'),
                       'o2', jsonb_build_object(
                         'row_en', 'Monday, June 28 · A vintage convertible on the panoramic roads, then the picnic')) m) mm),
    extras = jsonb_build_array(jsonb_build_object(
      'key', 'support', 'unit', 'o2', 'price', null,
      'label_pt', 'Carro de apoio',
      'label_en', 'Optional: support car escorting the vintage convertible',
      'row_en', 'Monday, June 28 · Optional: support car escorting the vintage convertible'))
   where proposal_id = v and section = 'castelfalfi' and title_en = 'Castelfalfi';

  -- ── 3 · Castelfalfi to Rome ─────────────────────────────────────────
  update ops_proposal_items set
    service_date = 'Tuesday, June 29', price = 12300, optional = true,
    row_en = 'Tuesday, June 29 · Behind the wheel of a Ferrari 296 GTS, from Castelfalfi to Rome'
   where proposal_id = v and section = 'aroma' and title_en = 'Behind the wheel of a Ferrari';

  -- ── 4 · Rome ────────────────────────────────────────────────────────
  update ops_proposal_items set
    service_date = 'Wednesday, June 30', optional = true,
    row_en = 'Wednesday, June 30 · The Colosseum: underground, arena and Roman Forum, with your guide'
   where proposal_id = v and section = 'roma' and title_en = 'The Colosseum';

  update ops_proposal_items set
    title = 'The Vatican Master Key experience', title_en = 'The Vatican Master Key experience',
    service_date = 'Thursday, July 1 · Morning',
    price = 9700, optional = true,
    details_en = $t$At 6:00, before the Vatican Museums open, you meet your private guide and the Clavigero, the keeper of the keys. He collects the historic ring of some 300 keys, the Sistine Chapel's among them, and you follow him as he unlocks door after door: up the Simonetti staircase into the Pio Clementino, along the Galleries of the Candelabra, the Tapestries and the Maps as he turns on the lights, and through the Raphael Rooms. Around 7:00 he opens the Sistine Chapel and switches on its lights, and you have about twenty minutes under Michelangelo's ceiling. The morning ends with breakfast at the bistro in the Cortile della Pigna.$t$,
    included_en = 'the private early-morning visit with the Clavigero and your guide, about 1 hour 50 minutes, and breakfast.',
    not_included_en = 'lunch.',
    row_en = 'Thursday, July 1 · Morning · The Vatican Master Key experience, private, with breakfast'
   where proposal_id = v and section = 'roma'
     and title_en in ('The Vatican with the keeper of the keys', 'The Vatican Master Key experience');

  update ops_proposal_items set
    title = 'A private aperitivo on the Tiber', title_en = 'A private aperitivo on the Tiber',
    service_date = 'Thursday, July 1 · Afternoon', optional = true,
    details_en = $t$In the late afternoon, a private boat with its crew takes you along the Tiber, under Rome's historic bridges, with an Italian aperitivo on board. A toast to the trip, on the river, before dinner.$t$,
    included_en = 'the private boat with crew, the aperitivo on board, and pick-up at your hotel.',
    row_en = 'Thursday, July 1 · Afternoon · A private aperitivo on the Tiber'
   where proposal_id = v and section = 'roma'
     and title_en in ('A private boat on the Tiber', 'A private aperitivo on the Tiber');

  update ops_proposal_items i set
    service_date = 'Friday, July 2', optional = true,
    units = (select jsonb_agg(u || coalesce(m->(u->>'key'), '{}'::jsonb) order by o)
               from jsonb_array_elements(i.units) with ordinality t(u, o),
                    (select jsonb_build_object(
                       'o1', jsonb_build_object('selected', true,
                         'row_en', 'Friday, July 2 · Shopping together in a private lounge, with a personal stylist'),
                       'o2', jsonb_build_object(
                         'row_en', 'Friday, July 2 · A personal styling tour for each of you, one in the morning and one in the afternoon')) m) mm)
   where proposal_id = v and section = 'roma' and title_en = 'Shopping in Rome';

  update ops_proposal_items set
    service_date = 'Saturday, July 3',
    details_en = 'A private transfer to Fiumicino, Terminal 3, leaving the hotel around 9:00 for the 12:20 flight. At the airport, a VIP meet and greet assistant welcomes you at the terminal entrance and stays with you through check-in and security to the gate.'
   where proposal_id = v and section = 'roma' and title_en = 'Departure';

  -- ── 5 · Where you'll stay: o primeiro quarto de cada hotel marcado ───
  update ops_proposal_items i set
    units = (select jsonb_agg(u || coalesce(m->(u->>'key'), '{}'::jsonb) order by o)
               from jsonb_array_elements(i.units) with ordinality t(u, o),
                    (select jsonb_build_object(
                       'u1', jsonb_build_object('selected', true,
                         'row_en', 'Castelfalfi · June 25 to 29 · Junior Suite Terrace'),
                       'u2', jsonb_build_object(
                         'row_en', 'Castelfalfi · June 25 to 29 · Suite Terrace')) m) mm)
   where proposal_id = v and section = 'stays' and title_en = 'Castelfalfi';

  update ops_proposal_items i set
    units = (select jsonb_agg(u || coalesce(m->(u->>'key'), '{}'::jsonb) order by o)
               from jsonb_array_elements(i.units) with ordinality t(u, o),
                    (select jsonb_build_object(
                       'u1', jsonb_build_object('selected', true,
                         'row_en', 'Bulgari Hotel Roma · June 29 to July 3 · Premium Room'),
                       'u2', jsonb_build_object(
                         'row_en', 'Bulgari Hotel Roma · June 29 to July 3 · Junior Suite')) m) mm)
   where proposal_id = v and section = 'stays' and title_en = 'Bulgari Hotel Roma';

  -- ── 6 · Ground Services & Concierge ─────────────────────────────────
  update ops_proposal_items set
    service_date = 'Sunday, June 20', optional = true,
    details_en = 'Private transfer from Florence airport to the palace in Cortona, about an hour and a half.',
    row_en = 'Sunday, June 20 · Private transfer, Florence airport to Cortona'
   where proposal_id = v and section = 'around' and title_en = 'Arrival';

  update ops_proposal_items i set
    service_date = 'Monday, June 21 to Monday, June 28', optional = true,
    details_en = 'The car is delivered to you in Cortona on the morning of June 21, at the parking area a few minutes from the palace, and collected at Castelfalfi on the morning of June 28. Between those days, the route is yours. The exact model within each category is confirmed by availability.',
    good_en = $t$fuel is not included. A refundable security deposit is held on the driver's credit card, and kilometers beyond those included are charged separately. The terms are in the General Conditions.$t$,
    units = (select jsonb_agg(u || coalesce(m->(u->>'key'), '{}'::jsonb) order by o)
               from jsonb_array_elements(i.units) with ordinality t(u, o),
                    (select jsonb_build_object(
                       'c1', jsonb_build_object('selected', true,
                         'label', 'Category 1 · Grand touring', 'label_en', 'Category 1 · Grand touring',
                         'ficha_en', 'Mercedes GLE, Maserati Grecale Modena or Audi Q8 · 1,400 km included',
                         'row_en', 'June 21 to 28 · Rental car, Category 1 · Grand touring: Mercedes GLE, Maserati Grecale Modena or Audi Q8 · 1,400 km included · fuel not included'),
                       'c2', jsonb_build_object(
                         'label', 'Category 2 · Commanding', 'label_en', 'Category 2 · Commanding',
                         'ficha_en', 'Land Rover Defender 110, BMW X7 or Range Rover Sport · 1,050 km included',
                         'row_en', 'June 21 to 28 · Rental car, Category 2 · Commanding: Land Rover Defender 110, BMW X7 or Range Rover Sport · 1,050 km included · fuel not included')) m) mm)
   where proposal_id = v and section = 'around' and title_en = 'Your car in Tuscany';

  update ops_proposal_items set
    service_date = 'Tuesday, June 29',
    details_en = 'Your drive to Rome is the Ferrari experience. Your luggage travels in the lead car to the hotel.'
   where proposal_id = v and section = 'around' and title_en = 'To Rome';

  update ops_proposal_items set
    service_date = 'Tuesday, June 29 to Saturday, July 3',
    details_en = 'No car is needed. On the days with experiences, a private car takes you from the hotel.'
   where proposal_id = v and section = 'around' and title_en = 'In Rome';

  update ops_proposal_items set
    service_date = 'Saturday, July 3', optional = true,
    details_en = 'Private transfer from the hotel to Fiumicino, Terminal 3, and a VIP meet and greet at the airport, from the terminal entrance through check-in and security to the gate.',
    row_en = 'Saturday, July 3 · Private transfer, hotel to Fiumicino Terminal 3'
   where proposal_id = v and section = 'around' and title_en = 'Departure';

  -- O meet and greet é linha da tabela e não bloco da folha: a folha já o
  -- descreve junto com a partida. Sem texto, a folha não o desenha.
  update ops_proposal_items set
    title = 'VIP meet and greet at Fiumicino', title_en = 'VIP meet and greet at Fiumicino',
    service_date = 'Saturday, July 3', optional = true,
    details = null, details_en = null,
    row_en = 'Saturday, July 3 · VIP meet and greet at Fiumicino, departure'
   where proposal_id = v and section = 'around'
     and title_en in ('Assistance at Fiumicino airport', 'VIP meet and greet at Fiumicino');

  -- O bloco "Concierge" (sem valor), antes do dining concierge.
  if not exists (select 1 from ops_proposal_items
                  where proposal_id = v and section = 'around' and title_en = 'Concierge') then
    insert into ops_proposal_items (proposal_id, sort, section, kind, service_date, title, title_en,
                                    details_en, price, optional, qty, extras, units, photos, attachments)
    values (v, 24, 'around', 'experience', '', 'Concierge', 'Concierge',
            $t$On any day in Tuscany you'd rather not drive, our concierge can arrange a private car and driver, on demand and subject to availability.$t$,
            0, false, 1, '[]', '[]', '[]', '[]');
  end if;

  update ops_proposal_items set
    section = 'around', sort = 25,
    title = 'Dining concierge · optional', title_en = 'Dining concierge · optional',
    optional = true, photos = '[]'::jsonb,
    qty = 13, unit_price = 60, price = 780,
    details_en = 'The tables worth planning a day around are often booked months ahead. Before you travel, our team prepares a shortlist of restaurants for each day, chosen around your route, and once you approve it we make the reservations, always subject to availability. The best-known tables are booked months in advance, the more local places a few weeks before you leave. If you''d rather book yourselves, we suggest reserving the days that matter most to you early, through your hotel or directly with the restaurants, as tables go quickly in high season.' || chr(10) || chr(10) || '€60 per day',
    row_en = 'Dining concierge · optional · 13 days × €60'
   where proposal_id = v and title_en in ('Dining concierge', 'Dining concierge · optional');

  -- ── 7 · A proposta: seções, rótulos, fechamento, pagamento ───────────
  update ops_proposals p set
    sections = (select jsonb_agg(
                  case when s->>'key' = 'around'
                       then s || jsonb_build_object('title', 'Ground Services & Concierge',
                                                    'title_en', 'Ground Services & Concierge')
                       else s end order by o)
                  from jsonb_array_elements(p.sections) with ordinality t(s, o)
                 where s->>'key' <> 'dining'),
    labels = coalesce(p.labels, '{}'::jsonb)
      || jsonb_build_object(
           'j_lead', jsonb_build_object('en', 'Every service below is selected as part of the program we designed for you. You can unselect anything you''d prefer to leave out, and Danielle will adjust it with us.'),
           'j_closing', jsonb_build_object('en', 'A journey with Destinations by Dani')),
    closing_en = '**A journey with Destinations by Dani**' || chr(10)
      || 'Tuscan Lands Travel is the ground partner of Destinations by Dani in Italy. Our team coordinates the trip locally, from the stays to every transfer and experience, in direct contact with Danielle at every step.' || chr(10)
      || 'Before the trip, our concierge can take care of your restaurant reservations, as described in Ground Services & Concierge, and prepares a suggested route for the self-drive days with nothing scheduled, so those days have a direction whenever you want one.' || chr(10)
      || 'During the trip, the concierge remains available through Danielle for what comes up along the way, a private car on a day you''d rather not drive, or a change of plan, always on request and subject to availability. Our team on the ground follows each day together with Danielle.',
    payment_options = '[]'::jsonb
   where p.id = v;

  -- Condições: quatro trocas pontuais (11.1 a 11.4). Cada uma tem de achar
  -- o trecho; sem isso a migração para inteira.
  select conditions_en into c from ops_proposals where id = v;

  if position('For every service except the Vatican experience, two options:' in c) = 0
     and position('For every other service, two options:' in c) = 0 then
    raise exception '0106: parágrafo Payment não encontrado';
  end if;
  c := replace(c,
    'and all prices include VAT. For every service except the Vatican experience, two options:',
    'and all prices include VAT.' || chr(10)
    || 'The Vatican Master Key experience is paid separately. The Vatican Museums open the calendar for these visits only at the beginning of 2027; once your date is confirmed, the experience is invoiced and paid in full, 100% upfront.' || chr(10)
    || 'For every other service, two options:');
  c := replace(c, 'The Vatican experience with the Clavigero follows its own terms, below.' || chr(10), '');

  if position('equal to the maximum liability for damage and theft.' in c) = 0 then
    raise exception '0106: parágrafo Rental car não encontrado';
  end if;
  if position('Fuel is not included and is paid by the client.' in c) = 0 then
    c := replace(c, 'equal to the maximum liability for damage and theft.',
                    'equal to the maximum liability for damage and theft. Fuel is not included and is paid by the client.');
  end if;

  if position('€70 per night.' in c) = 0 and position('€60 per day.' in c) = 0 then
    raise exception '0106: valor do dining concierge não encontrado';
  end if;
  c := replace(c, '€70 per night.', '€60 per day.');

  if position('**The Vatican with the keeper of the keys, July 1**' in c) = 0
     and position('**The Vatican Master Key experience, July 1**' in c) = 0 then
    raise exception '0106: título do Vatican nas condições não encontrado';
  end if;
  c := replace(c, '**The Vatican with the keeper of the keys, July 1**',
                  '**The Vatican Master Key experience, July 1**');

  update ops_proposals set conditions_en = c, updated_at = now() where id = v;
end $mig$;

insert into ops_migrations (id) values ('0106-emily-v2-correcoes') on conflict (id) do nothing;
