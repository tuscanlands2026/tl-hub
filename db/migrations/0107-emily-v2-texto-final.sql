-- =====================================================================
-- 0107 · EMILY (TL-053-26, v2): O TEXTO FINAL DAS TELAS
--
-- Ela mandou, nov/26, logo depois das correções da 0106: "texto final é
-- esse". O texto de todas as telas de dia, da folha Ground Services &
-- Concierge e da folha "A journey with Destinations by Dani", copiado
-- exatamente como ela escreveu, com as aspas e apóstrofos dela.
--
-- O que este arquivo troca, e só isto: a abertura de cada base (intro_en
-- da seção), o texto de cada dia (details_en), cada opção (desc, good,
-- included, not_included), e os blocos "Good to know", "Included" e
-- "Not included" de cada serviço. Datas, preços, fotos, o que vem marcado
-- e o texto das linhas da tabela ficam como a 0106 deixou.
--
-- Mudanças que vêm do texto dela e não são só de redação:
--   · "In Rome" na folha Ground Services sai sem data (service_date vazio)
--   · Montalcino opção dois volta a se chamar "Your own wine"
--   · o aperitivo no Tibre ganha o link do vídeo, e o Included vira lista
--   · Pienza, o dia livre e o Coliseu ganham "Not included: lunch."
--   · a taxa do concierge durante a viagem (€ 150 por dia de serviço,
--     sempre mediante disponibilidade) entra como OBSERVAÇÃO, e não como
--     opção — instrução dela: "isso não é uma opção". Vai no bloco
--     Concierge (good_en) e embaixo da tabela de Ground Services em "Your
--     proposal" (note_en da seção). Não soma em lugar nenhum.
--
-- Mira por proposal_id + seção + título. Só roda com a v2 sem resposta.
--
-- Seção 7: update em ops_proposals (uma linha) e ops_proposal_items (as
-- linhas da v2). Com o sim dela, que é o próprio texto que ela mandou.
-- =====================================================================

do $mig$
declare
  v uuid := 'e0530000-0000-0000-0000-000000000002';
begin
  if not exists (select 1 from ops_proposals where id = v and responded_at is null) then
    raise notice '0107: v2 já respondida ou inexistente — nada feito';
    return;
  end if;

  -- ── As aberturas das bases ──────────────────────────────────────────
  update ops_proposals p set
    sections = (select jsonb_agg(
                  case s->>'key'
                    when 'cortona' then s || jsonb_build_object('intro_en',
                      $t$These are self-drive days: the car is yours, and so is the pace. Whenever you’d rather be driven, our concierge can arrange a private car and driver, on request and subject to availability.$t$)
                    when 'castelfalfi' then s || jsonb_build_object('intro_en',
                      $t$Four nights in the countryside around Castelfalfi. The car stays with you until the morning of June 28, and the days leave time for the resort itself.$t$)
                    when 'around' then s || jsonb_build_object('note_en',
                      'Concierge services during the trip carry a fee of €150 per day of service, and are always subject to availability.')
                    when 'roma' then s || jsonb_build_object('intro_en',
                      $t$Four nights at the Bulgari. The days are placed according to availability once the logistics are confirmed, and on the days with experiences a private car takes you from the hotel.$t$)
                    else s end order by o)
                  from jsonb_array_elements(p.sections) with ordinality t(s, o)),
    closing_en = '**A journey with Destinations by Dani**' || chr(10)
      || $t$Tuscan Lands Travel is the ground partner of Destinations by Dani in Italy. Our team coordinates the trip locally, from the stays to every transfer and experience, in direct contact with Danielle at every step.$t$ || chr(10)
      || $t$Before the trip, our concierge can take care of your restaurant reservations, as described in Ground Services & Concierge, and prepares a suggested route for the self-drive days with nothing scheduled, so those days have a direction whenever you want one.$t$ || chr(10)
      || $t$During the trip, the concierge remains available through Danielle for whatever comes up along the way, a private car on a day you’d rather be driven, or a change of plan, always on request and subject to availability. Our team on the ground follows each day together with Danielle.$t$,
    updated_at = now()
   where p.id = v;

  -- ── Cortona ─────────────────────────────────────────────────────────
  update ops_proposal_items set
    details_en = $t$A private car meets you at Florence airport and brings you to the palace in Cortona in the early afternoon. The rest of the day is for settling in, and for a first walk through Cortona’s steep lanes as the Val di Chiana opens out below the town walls.$t$
   where proposal_id = v and section = 'cortona' and title_en = 'Arrival';

  update ops_proposal_items i set
    details_en = $t$Your car is delivered in the morning, a few minutes from the palace, and the day belongs to Montalcino, the hill town of Brunello.$t$,
    units = (select jsonb_agg((u - 'good_en' - 'not_included_en') || coalesce(m->(u->>'key'), '{}'::jsonb) order by o)
               from jsonb_array_elements(i.units) with ordinality t(u, o),
                    (select jsonb_build_object(
                       'o1', jsonb_build_object(
                         'desc_en', $t$The visit begins among the vines and in the gardens of the villa, then goes down into the estate’s sixteenth-century cellars. At the table, the chef cooks with the season, and the menu stays a surprise until you sit down, each course paired with one of the estate’s wines.$t$,
                         'included_en', $t$the guided visit of the estate, the chef’s lunch and the paired wines.$t$),
                       'o2', jsonb_build_object(
                         'label', 'Your own wine', 'label_en', 'Your own wine',
                         'desc_en', $t$One of Italy’s most respected winemakers sets out his base wines in front of you and talks you through each one. Then the blending begins: you taste and adjust, then taste again, with his guidance and your palate deciding, until the glass holds the wine you had in mind. It’s bottled and sealed before you leave, and you sign the bottle together.$t$,
                         'good_en', $t$should you want more of it at home, we can add a larger production of your blend, up to a full barrel, shipped to your door a few months later, with a personalized label if you wish.$t$,
                         'included_en', 'the blending session with the winemaker and your signed bottle.',
                         'not_included_en', 'lunch, the optional production and shipping.')) m) mm)
   where proposal_id = v and section = 'cortona' and title_en = 'Montalcino';

  update ops_proposal_items set
    details_en = $t$Two hill towns a short drive apart, with the cypress lines and golden hills of the Val d’Orcia between them. Nothing is scheduled: the day is for their lanes and for stopping wherever the view opens up.$t$,
    not_included_en = 'lunch.'
   where proposal_id = v and section = 'cortona' and title_en = 'Montepulciano and Pienza';

  update ops_proposal_items set
    details_en = $t$Arezzo has worked gold for centuries. The morning can begin in the old town, around Piazza Grande, before you continue to the goldsmith’s workshop, in Arezzo, outside the historic center. We’re shaping this experience around Emily’s wishes and will share it with you soon.$t$,
    not_included_en = 'lunch.'
   where proposal_id = v and section = 'cortona' and title_en = 'Arezzo';

  update ops_proposal_items set
    details_en = $t$A day for the palace, or for Umbria, just across the valley: Orvieto on its cliff of tuff, or Deruta, where ceramics have been made for centuries. If the craft appeals, our concierge can arrange a visit to a workshop, and even a piece made for you to take home, on request and subject to availability.$t$,
    not_included_en = 'lunch.'
   where proposal_id = v and section = 'cortona' and title_en = 'A day of your own';

  -- ── Castelfalfi ─────────────────────────────────────────────────────
  update ops_proposal_items set
    details_en = 'A drive of under two hours from Cortona, and the afternoon is yours to settle in.'
   where proposal_id = v and section = 'castelfalfi' and title_en = 'Cortona to Castelfalfi';

  update ops_proposal_items set
    details_en = $t$A self-drive experience. In the woods, the truffle hunters and their dogs lead the way, and you see how instinct, knowledge and time come together in this seasonal search. No rush here: the pace is set by the woods and the dogs. The morning ends at their table, with a lunch built around the truffle and a tasting of everything they make: a table full of stories to tell.$t$,
    good_en = 'a private car to and from the hunt can be arranged on request.',
    included_en = 'the truffle hunt, the truffle lunch and the tasting.',
    not_included_en = null
   where proposal_id = v and section = 'castelfalfi' and title_en = 'Truffle hunting';

  update ops_proposal_items set
    details_en = $t$A self-drive day. Siena comes first, in the company of a local guide who knows the city’s curiosities and takes you where you’d be unlikely to wander on your own. In the afternoon, San Gimignano and its towers, and a winery just outside the walls, where you’re welcomed with a glass of wine. After the barrel room, the table is set on a terrace facing the towers: Tuscan recipes in a modern key, each course paired with the estate’s wines. It can be lunch, or dinner with the towers in the evening light.$t$,
    included_en = 'your guide in Siena, the winery visit and the paired four-course meal.',
    not_included_en = 'other meals.'
   where proposal_id = v and section = 'castelfalfi' and title_en = 'Siena and San Gimignano';

  update ops_proposal_items i set
    details_en = 'A slow morning at the resort; the rental car is collected before noon.',
    units = (select jsonb_agg(u || coalesce(m->(u->>'key'), '{}'::jsonb) order by o)
               from jsonb_array_elements(i.units) with ordinality t(u, o),
                    (select jsonb_build_object(
                       'o1', jsonb_build_object(
                         'desc_en', 'In the late afternoon, a picnic is set for you on the Castelfalfi estate, with local products and wines, while the sun goes down over the hills.',
                         'included_en', 'the picnic with local products and wines.'),
                       'o2', jsonb_build_object(
                         'desc_en', $t$In the afternoon, a vintage convertible is waiting at Castelfalfi. Top down, you follow a route we’ve prepared along the panoramic roads of the area, and arrive at the picnic as the sun begins to set.$t$,
                         'good_en', $t$the car has a manual transmission. If you’d like, a support car can escort you along the way.$t$,
                         'included_en', 'the vintage car for the afternoon, the route and the picnic with local products and wines.',
                         'not_included_en', 'the optional support car.')) m) mm)
   where proposal_id = v and section = 'castelfalfi' and title_en = 'Castelfalfi';

  -- ── Castelfalfi to Rome ─────────────────────────────────────────────
  update ops_proposal_items set
    details_en = 'A Ferrari 296 GTS is waiting at Castelfalfi, and the drive to Rome becomes the day itself. The road takes you through the Tuscan countryside and down to the Argentario coast for lunch by the sea, then on toward Rome and the Bulgari. A lead car with qualified staff travels with you and carries your luggage, so your attention stays on the road. Other models are available on request.',
    good_en = 'the car seats two, and the lead car carries up to three suitcases and three carry-on bags. The security deposit, damage deductible and additional kilometers are set out in the General Conditions.',
    included_en = $t$the Ferrari with up to 350 km, the lead car and its staff, fuel, parking, tolls and Telepass, luggage transport, and transfers to or from the hotel wherever the route can’t begin or end there.$t$,
    not_included_en = 'lunch.'
   where proposal_id = v and section = 'aroma' and title_en = 'Behind the wheel of a Ferrari';

  -- ── Rome ────────────────────────────────────────────────────────────
  update ops_proposal_items set
    details_en = $t$The day begins beneath the arena, in the underground of the Colosseum, where gladiators and animals waited before the games. We aim for the first entry of the morning, when it’s at its quietest. From there your guide takes you up into the arena and on to the Roman Forum, and the afternoon is yours in the heart of Rome.$t$
      || chr(10) || chr(10)
      || $t$Each year the Colosseum opens on a few evenings. If one falls during your stay, we’ll propose it.$t$,
    included_en = 'your guide, entry to the underground, the arena and the Roman Forum, and pick-up at your hotel.',
    not_included_en = 'lunch.'
   where proposal_id = v and section = 'roma' and title_en = 'The Colosseum';

  update ops_proposal_items set
    details_en = $t$Rome is still quiet when you reach the Vatican, where your private guide and the Clavigero, the keeper of the keys, are waiting. He lifts the historic ring of keys, the Sistine Chapel’s among them, and you walk with him through the museums before they open, door after door, as the lights come on along the Galleries of the Tapestries and the Maps and through the Raphael Rooms. Then he unlocks the Sistine Chapel, and you stand beneath Michelangelo’s ceiling as the light fills it. Breakfast follows in the Cortile della Pigna, before the museums open for the day.$t$,
    included_en = 'the private early-morning visit with the Clavigero and your guide, and breakfast.',
    not_included_en = 'lunch.'
   where proposal_id = v and section = 'roma' and title_en = 'The Vatican Master Key experience';

  update ops_proposal_items set
    details_en = $t$The perfect setting for a toast to a meaningful journey together. A private aperitivo on board while you cruise the Tiber, with a privileged perspective on Rome’s historic bridges: a joyful, intimate way to close the afternoon before dinner.$t$
      || chr(10) || chr(10)
      || '[▶ See this experience up close](https://youtube.com/shorts/DU_-fkN3VHU?si=NtEeY5A4mc-nRn7z)',
    included_en = '- Private luxury boat cruise on the Tiber with a dedicated crew' || chr(10)
               || '- Italian aperitivo on board',
    not_included_en = null
   where proposal_id = v and section = 'roma' and title_en = 'A private aperitivo on the Tiber';

  update ops_proposal_items i set
    units = (select jsonb_agg(u || coalesce(m->(u->>'key'), '{}'::jsonb) order by o)
               from jsonb_array_elements(i.units) with ordinality t(u, o),
                    (select jsonb_build_object(
                       'o1', jsonb_build_object(
                         'desc_en', $t$A personal stylist receives you both in the private lounge of one of Rome’s great department stores, four floors of Italian and international houses for men and women. She has already chosen pieces for each of you around your tastes, so your time goes to trying on.$t$,
                         'included_en', $t$the stylist’s selection and her time with you, and a transfer from your hotel.$t$,
                         'not_included_en', 'purchases.'),
                       'o2', jsonb_build_object(
                         'desc_en', $t$Each of you has a morning or an afternoon of your own with the stylist. It begins before the trip, with a short questionnaire, a few photographs and the outfits you wear most, from which she reads your style and prepares the looks you’ll choose from. In Rome, she takes you to the boutiques chosen for you, with a word on each house before you step in, and a breakfast, brunch or aperitivo along the way.$t$,
                         'included_en', 'for each of you, the style analysis, the look selection, the tour with an English-speaking interpreter, and a transfer from your hotel.',
                         'not_included_en', 'purchases, a private driver (available on request).')) m) mm)
   where proposal_id = v and section = 'roma' and title_en = 'Shopping in Rome';

  update ops_proposal_items set
    details_en = 'A private car takes you from the hotel to Fiumicino, leaving around 9:00 for your 12:20 flight. At the airport, a meet and greet assistant welcomes you at the terminal and accompanies you through to the gate.'
   where proposal_id = v and section = 'roma' and title_en = 'Departure';

  -- ── Ground Services & Concierge ─────────────────────────────────────
  update ops_proposal_items set
    details_en = 'A private car meets you at Florence airport and brings you to the palace in Cortona.'
   where proposal_id = v and section = 'around' and title_en = 'Arrival';

  update ops_proposal_items set
    details_en = 'Your car is delivered in Cortona on the morning of June 21, a few minutes from the palace, and collected at Castelfalfi on the morning of June 28. In between, the route is yours. The exact model within each category is confirmed by availability.',
    good_en = $t$fuel is not included. A refundable security deposit is held on the driver’s credit card, and kilometers beyond those included are charged separately, as set out in the General Conditions.$t$
   where proposal_id = v and section = 'around' and title_en = 'Your car in Tuscany';

  update ops_proposal_items set
    details_en = 'Your drive to Rome is the Ferrari experience, with your luggage traveling ahead in the lead car.'
   where proposal_id = v and section = 'around' and title_en = 'To Rome';

  update ops_proposal_items set
    service_date = '',
    details_en = 'No car is needed. On the days with experiences, a private car takes you from the hotel.'
   where proposal_id = v and section = 'around' and title_en = 'In Rome';

  update ops_proposal_items set
    details_en = 'A private car from the hotel to Fiumicino, and a meet and greet assistant at the airport from the terminal to the gate.'
   where proposal_id = v and section = 'around' and title_en = 'Departure';

  update ops_proposal_items set
    details_en = $t$On any day in Tuscany you’d rather be driven, our concierge can arrange a private car and driver, on request and subject to availability.$t$,
    good_en = 'concierge services during the trip carry a fee of €150 per day of service, and are always subject to availability.'
   where proposal_id = v and section = 'around' and title_en = 'Concierge';

  update ops_proposal_items set
    details_en = $t$The tables worth planning a day around are often booked months ahead. Before you travel, our team prepares a shortlist of restaurants for each day, chosen around your route, and once you approve it we make the reservations, always subject to availability. The best-known tables are reserved months in advance, the more local places a few weeks before you leave. If you’d rather book yourselves, we suggest reserving the days that matter most to you early, through your hotel or directly with the restaurants, as tables go quickly in high season.$t$
      || chr(10) || chr(10) || '€60 per day'
   where proposal_id = v and section = 'around' and title_en = 'Dining concierge · optional';
end $mig$;

insert into ops_migrations (id) values ('0107-emily-v2-texto-final') on conflict (id) do nothing;
