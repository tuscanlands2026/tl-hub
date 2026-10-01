-- =====================================================================
-- 0055 · O BRIEFING DA EMILY, CARREGADO
--
-- Primeiro caso do módulo da 0054, e é o documento real: o briefing de
-- hotelaria da Emily, 20/6 a 5/7/2027, que ela escreveu em outubro/26.
-- O texto veio PALAVRA POR PALAVRA do documento dela — não foi reescrito,
-- não foi resumido, não foi "melhorado". É texto comercial da casa.
--
-- VALIDADE 15 DE NOVEMBRO DE 2026, que é o que a especificação sugeriu:
-- antes da decisão no Thanksgiving.
--
-- AS NOVE PERGUNTAS são as da especificação, na ordem dela, com os mesmos
-- rótulos em inglês e as mesmas opções. As três de hotel aceitam até duas
-- escolhas, que é o "one or at most two per stage" do próprio briefing.
--
-- NASCE COMO RASCUNHO, não como enviado. O link existe desde já, mas quem
-- decide quando mandar é ela — e o status só vira "aberto" quando a
-- advisor abrir de verdade.
--
-- LIGA NA OPORTUNIDADE TL-053-26 se ela existir no banco. Se não existir,
-- o briefing entra sem oportunidade e ela liga depois: briefing não pode
-- deixar de nascer porque a oportunidade ainda não foi cadastrada.
--
-- Rodar depois da 0054, que é quem cria as tabelas.
--
-- Só cria e preenche objetos ops_. Nenhum update ou delete em linha antiga.
-- =====================================================================


insert into ops_advisor_briefings
  (id, title, client_ref, opportunity_id, advisor_name, agency, advisor_email,
   content, valid_until, status)
values ('b0000001-0000-0000-0000-000000000001',
  E'Emily''s Family Journey (2 pax) · Tuscany (including Florence) and Venice',
  E'Emily & husband · 20/6 a 5/7/2027 · TL-053-26',
  (select id from ops_opportunities where crm_code = 'TL-053-26' limit 1),
  null, null, null,
  E'## Where we are\n\nThis is our first hotel selection for Emily and her husband, June 20 to July 5, 2027. We took Four Seasons, the reference you gave us, as the starting point, and looked for properties that spare their guests too much exposure. The selection mixes boutique houses with five-star luxury hotels where the stay is already part of the experience.\n\nIndicative rates come with this selection. They are dynamic and subject to change, but they give Emily a first reference. Logistics, transport options, transfers and experiences come next, once the hotels are chosen.\n\n## The nights\n\nArriving June 20 and leaving July 5 gives 15 nights. Our suggestion:\n\n| Stay | Dates | Nights |\n| --- | --- | --- |\n| Cortona | Jun 20 to Jun 25 | 5 |\n| Second base in Tuscany | Jun 25 to Jun 29 | 4 |\n| Florence | Jun 29 to Jul 2 | 3 |\n| Venice | Jul 2 to Jul 5 | 3 |\n\nThe four nights at the second base are deliberate. These hotels are part of the trip in their own right, so we want the couple to have time to enjoy them, and we will pace the program with that in mind.\n\n## Why the route runs this way\n\nCortona already covers the south of Tuscany, so the second base moves to the centre, closer to Florence. That is where we concentrate the experiences and the private access for them: estate kitchens, wine producers, artisan workshops. It also keeps the drives short, and from Florence the train to Venice takes about two hours.\n\n## Second base in Tuscany, 4 nights\n\n| Hotel | Suggested category |\n| --- | --- |\n| [Dimora Ghirlandaio](https://dimoraghirlandaio.it/en/accommodations/il-frantoio/) · Impruneta, 15 min from Florence | La Limonaia or Villa Lo Studio, for the couple alone |\n| [Castelfalfi](https://www.castelfalfi.com/stay) · Montaione | Suite or Castelfalfi Suite |\n| [Borgo Vescine](https://www.vescine.it/) · Radda in Chianti | Superior Suite |\n\nDimora Ghirlandaio is the one we would lead with for Emily''s privacy: the estate rents its houses individually, so the couple has a home of their own with the hotel''s restaurant, breakfast, pool and spa around it. Castelfalfi offers the most space and facilities. Borgo Vescine is the most intimate, with 28 rooms in the heart of Chianti Classico.\n\n## Florence, 3 nights\n\nVilla San Michele and Collegio alla Querce sit outside the centre, on the hills above the city, and both run a shuttle into town. We chose them so the couple does not need to sleep in the city. If staying in the centre matters to Emily, the Four Seasons is there, and we can replace one of the hill options with another central hotel. Florence has other good ones.\n\n| Hotel | Suggested category |\n| --- | --- |\n| Villa San Michele, A Belmond Hotel · Fiesole | Garden Suite |\n| Collegio alla Querce, Auberge Collection · below Fiesole | Junior Suite or Suite |\n| Four Seasons Hotel Firenze · city centre | Premier Room or Suite |\n\nAt Villa San Michele the entry rooms are the weaker part of the house, so we suggest going straight to a garden suite.\n\n## Venice, 3 nights\n\n| Hotel | Suggested category |\n| --- | --- |\n| Danieli, Venezia, A Four Seasons Hotel · Riva degli Schiavoni | Premium Lagoon-View Room or Lagoon-View Suite |\n| Aman Venice · Grand Canal | Palazzo Room or Suite |\n| Palazzo Vendramin at Hotel Cipriani · Giudecca | Vendramin Suite |\n\nWe kept the Marriott properties out, as they are very large, and looked for smaller scale instead: Aman has 24 rooms, Palazzo Vendramin 17, with the Cipriani''s pool and gardens next door. The Danieli reopened as a Four Seasons in July 2026 and is still restoring its Excelsior wing in 2027, so we will ask for a room away from any work and confirm the spa is open.\n\n## If Emily and her husband love the sea\n\nLate June is the very start of summer on the coast. If they enjoy the sea, we can replace the second Tuscan base with a stay on the southern Tuscan coast, close to the islands. The area is lively in summer, yet it has a few excellent hotels where a couple can stay private and quiet. Let us know if this fits their profile and we will review the route.\n\n## One more option: a single base near Florence\n\nBecause Cortona already gives them the south, we can also skip the second move and keep the couple in one hotel just outside Florence for the 7 nights after Cortona. On Florence days they take the hotel shuttle into town; on countryside days they head out with a rental car or a private driver at their disposal. Villa San Michele, Collegio alla Querce and Dimora Ghirlandaio all work as that base.\n\n## Once the hotels are set\n\nThe hotels decide where the trip lands, including the airport they fly into, so they come first. With them confirmed, we prepare the full program: local coordination, VIP reception at the airport, every transfer, and a study of whether each leg works best with a rental car, a driver at their disposal or a mix. We will keep the days well paced and leave some free for them to enjoy the hotels themselves.\n\nThe experiences we have in mind for each stage:\n\n- **Cortona:** the Val d''Orcia, Pienza, Montepulciano and Montalcino, and a crossing into Umbria for its ceramics, artisan workshops, historic towns and nature, with a summer truffle hunt alongside a local producer.\n- **Second base:** cooking with local producers and families, and the villages around San Gimignano and Volterra.\n- **Florence:** beyond the city itself, the historic botteghe, from goldsmiths to leather and other artisan workshops, and dinners in private palazzi we can open for them.\n- **Venice:** the classics done well, a Murano glass furnace, a goldsmith''s workshop, and a slower way through the city away from the main routes.\n\n## About the rates\n\nAll rates indicated with this selection are per night, before city tax, and reflect current pricing. Most of these hotels price 2027 dynamically, so they may change. Once Emily chooses her hotels, we request firm rates, with a king bed and single mattress confirmed in writing, and move to the formal proposal.\n\nEarly July is peak season everywhere on this route, a good reason to hold rooms early. It is also when Tuscan towns stage their historical re-enactments and medieval festivals. We will try to fit one into the program, a very local moment for them.\n\n## Key definitions for the proposal phase\n\nThe questions below are exactly these, and your answers come back to us straight away.\n\nWe will handle Venice as well, so the whole journey runs with one point of contact.',
  date '2026-11-15',
  'rascunho')
on conflict (id) do nothing;


-- As nove perguntas, na ordem da especificação ------------------
insert into ops_advisor_questions (id, briefing_id, sort, kind, label, options, max_choices, required)
values ('b0000001-0000-0000-0000-000000010001', 'b0000001-0000-0000-0000-000000000001', 1, 'escolha_multipla', E'Second base in Tuscany: which hotels should we request?',
        E'["Dimora Ghirlandaio", "Castelfalfi", "Borgo Vescine"]'::jsonb, 2, true)
on conflict (id) do nothing;
insert into ops_advisor_questions (id, briefing_id, sort, kind, label, options, max_choices, required)
values ('b0000001-0000-0000-0000-000000010002', 'b0000001-0000-0000-0000-000000000001', 2, 'escolha_multipla', E'Florence: which hotels should we request?',
        E'["Villa San Michele", "Collegio alla Querce", "Four Seasons Hotel Firenze", "Another hotel in the centre"]'::jsonb, 2, true)
on conflict (id) do nothing;
insert into ops_advisor_questions (id, briefing_id, sort, kind, label, options, max_choices, required)
values ('b0000001-0000-0000-0000-000000010003', 'b0000001-0000-0000-0000-000000000001', 3, 'escolha_multipla', E'Venice: which hotels should we request?',
        E'["Danieli, A Four Seasons Hotel", "Aman Venice", "Palazzo Vendramin at Hotel Cipriani"]'::jsonb, 2, true)
on conflict (id) do nothing;
insert into ops_advisor_questions (id, briefing_id, sort, kind, label, options, max_choices, required)
values ('b0000001-0000-0000-0000-000000010004', 'b0000001-0000-0000-0000-000000000001', 4, 'texto', E'Arrival airport',
        E'[]'::jsonb, null, true)
on conflict (id) do nothing;
insert into ops_advisor_questions (id, briefing_id, sort, kind, label, options, max_choices, required)
values ('b0000001-0000-0000-0000-000000010005', 'b0000001-0000-0000-0000-000000000001', 5, 'texto', E'Departure airport',
        E'[]'::jsonb, null, true)
on conflict (id) do nothing;
insert into ops_advisor_questions (id, briefing_id, sort, kind, label, options, max_choices, required)
values ('b0000001-0000-0000-0000-000000010006', 'b0000001-0000-0000-0000-000000000001', 6, 'texto', E'Where is the villa in Cortona?',
        E'[]'::jsonb, null, true)
on conflict (id) do nothing;
insert into ops_advisor_questions (id, briefing_id, sort, kind, label, options, max_choices, required)
values ('b0000001-0000-0000-0000-000000010007', 'b0000001-0000-0000-0000-000000000001', 7, 'escolha_unica', E'How would they like to move around?',
        E'["Rental car", "Private driver", "A mix", "Not sure yet"]'::jsonb, null, true)
on conflict (id) do nothing;
insert into ops_advisor_questions (id, briefing_id, sort, kind, label, options, max_choices, required)
values ('b0000001-0000-0000-0000-000000010008', 'b0000001-0000-0000-0000-000000000001', 8, 'sim_nao', E'Would they consider the southern Tuscan coast instead of the second base?',
        E'[]'::jsonb, null, false)
on conflict (id) do nothing;
insert into ops_advisor_questions (id, briefing_id, sort, kind, label, options, max_choices, required)
values ('b0000001-0000-0000-0000-000000010009', 'b0000001-0000-0000-0000-000000000001', 9, 'sim_nao', E'Would they prefer a single base near Florence after Cortona?',
        E'[]'::jsonb, null, false)
on conflict (id) do nothing;

insert into ops_migrations (id) values ('0055-briefing-da-emily') on conflict (id) do nothing;
