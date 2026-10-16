-- =====================================================================
-- 0070 · A PROPOSTA DA DANIELLE, MONTADA — E AS EXPERIÊNCIAS NO CATÁLOGO
--
-- Pedido dela, outubro/26: "Eu vou parar de ficar montando proposta na
-- mão. Você vai sempre me ajudar com isso." E: "armazene essas
-- experiências com essa descrição, vai me ajudar para propostas futuras".
-- O link que ela mandou:
--   TL-055-26 · Danielle and Philip's Rome Journey · Destinations by Dani
--   ops_proposals.id = f1d3d719-5142-43e7-9359-e2b7249a25d6  (white label)
--
-- A proposta é INTEIRA em inglês (lang = en). Os textos vieram dos
-- modelos de redação dela (set/out-26), ADAPTADOS ao briefing da
-- Danielle (datas, locais) e LIMPOS dos erros de modelo que não são
-- desta viagem: saiu Civitavecchia (ela chega de avião no dia 7), saiu
-- "September 14" (é maio), saiu Orient Express La Minerva (o hotel é o
-- Palazzo Ripetta), e saiu o McArthurGlen do dia de Frascati (não está
-- no briefing). O tom foi preservado — ela pediu "não avacalha a
-- descrição, tem que gerar desejo".
--
-- O QUE ESTE ARQUIVO FAZ, parte a parte:
--
--   1 · CRIA DUAS COLUNAS em ops_catalog (included, included_en) — o
--       catálogo sabia descrever, mas não tinha onde guardar o "o que
--       inclui". Só cria coluna, não toca linha: roda sem precisar de sim.
--
--   2 · GRAVA AS CINCO EXPERIÊNCIAS no catálogo (kind = experience), em
--       inglês, cada uma com a descrição de desejo e a lista do que
--       inclui. São os ativos reutilizáveis que ela pediu: a próxima
--       proposta de Roma puxa daqui, não se escreve de novo.
--
--   3 · PREENCHE A HOSPEDAGEM: Palazzo Ripetta, em DOIS períodos (7–10 de
--       maio, 3 noites; 14–15 de maio, 1 noite), cada linha com as DUAS
--       categorias de quarto (Deluxe e Prestige — pedido dela, out/26)
--       para ela lançar o valor por período. "Deluxe" fica só com o nome:
--       a ficha (0012) descreve Prestige e Luxury Apartment, não Deluxe, e
--       não se inventa metragem. O texto, o site e as fotos do hotel vêm da
--       ficha de catálogo que a 0012 já criou (cópia, não referência viva).
--
--   4 · PREENCHE O DIA A DIA: transfers, recepção VIP, as cinco
--       experiências e os dois jantares de concierge, cada um com a data
--       do seu dia, na ordem do briefing. As experiências são CÓPIA do
--       catálogo (insert ... select). Os transfers e jantares são
--       genéricos e vão escritos aqui. Tudo entra como OPCIONAL — ela
--       pediu "sempre dando a opção de escolher os serviços".
--
--   5 · PÕE A SEÇÃO DO DIA A DIA no modo "uma foto por dia" (modo = dias),
--       que é "as atividades de cada dia" que ela descreveu. A seção da
--       hospedagem fica em blocos, como está.
--
--   6 · ESCREVE A FOLHA DE CURADORIA com o texto do briefing — "Curadoria,
--       o texto é o do briefing", instrução dela. Só entra se ela ainda
--       não tiver criado curadoria nenhuma: curadoria que ela escreveu
--       não é tocada.
--
-- OS VALORES ENTRAM EM BRANCO, de propósito: "os preços eu atualizo
-- depois". Cada categoria de quarto e cada serviço nasce com valor zero,
-- para ela lançar. As FOTOS das experiências e dos transfers ficam
-- vazias: não há foto conferida para elas, e foto inventada quebra na
-- tela do cliente. Ela escolhe a foto de cada dia no editor. A
-- hospedagem já vem com as fotos da ficha.
--
-- ESTE ARQUIVO MEXE EM LINHA QUE JÁ EXISTE (o update em ops_proposals,
-- nas seções e na curadoria desta proposta), e por isso é arquivo
-- próprio e numerado, e CONFIRA e rode você. Todo update é CONDICIONADO:
-- a seção só é renomeada se ainda estiver com o título semeado pelo hub,
-- e a curadoria só entra se não houver nenhuma. Nada que você tenha
-- digitado é sobrescrito. As linhas de serviço são inserções novas
-- (on conflict do nothing), não mexem em passado.
--
-- CONFERÊNCIA DA SEÇÃO 7, relida antes de entregar. Os objetos tocados:
-- ops_catalog (add column; insert das experiências com on conflict do
-- nothing), ops_proposal_items (insert; nenhum update ou delete),
-- ops_proposals (update em UMA linha, pelo id, guardado), ops_migrations
-- (insert). Nenhum drop, alter de tipo, truncate. Nenhuma tabela do CRM
-- é lida, escrita ou citada. Nenhuma service_role key aqui.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1 · O CATÁLOGO GANHA "O QUE INCLUI"
-- Só cria coluna. Linha nenhuma é tocada.
-- ---------------------------------------------------------------------
alter table ops_catalog add column if not exists included    text;
alter table ops_catalog add column if not exists included_en text;
comment on column ops_catalog.included_en is
  'O que a experiência inclui, em inglês. A linha da proposta leva uma cópia.';

-- ---------------------------------------------------------------------
-- 2 · AS CINCO EXPERIÊNCIAS DE ROMA, NO CATÁLOGO (reutilizáveis)
-- Em inglês. descr_en é a descrição de desejo; included_en é o que
-- inclui. O par em português fica em branco — ela traduz quando quiser;
-- a proposta é toda em inglês e bloco vazio não sai.
-- on conflict (id) do nothing: rodar de novo não reescreve o que já
-- estiver aqui.
-- ---------------------------------------------------------------------
insert into ops_catalog (id, kind, name, region, descr_en, included_en, internal_notes) values

 ('e7000000-0000-0000-0000-000000000001', 'experience',
  'Private Rome Food Tour', 'Roma',
  E'Roman food is inseparable from place. The recipes that define the city — cacio e pepe, supplì, carciofi alla giudia — were born in specific neighbourhoods, in specific kitchens, and they still taste different depending on where you eat them.\nThis experience moves through Campo de'' Fiori, the Jewish Ghetto and Trastevere with a private food expert: cured meats, aged cheeses, street food, fresh pasta and gelato alongside Italian wines, and as much Roman food history as appetite allows. The route is tailored to what you enjoy, and shellfish is kept to a minimum.',
  E'- Private food expert guide (approx. 3 to 4 hours)\n- Tastings of Roman specialties, sweet and savoury, with wine and water\nMeeting point to be confirmed. Transport not included.',
  E'Modelo de redação da Maria Fernanda, adaptado ao briefing da Danielle (tarde do dia 7, shellfish ao mínimo).'),

 ('e7000000-0000-0000-0000-000000000002', 'experience',
  'Private Colosseum and Roman Forum Tour with Arena', 'Roma',
  E'The first encounter with ancient Rome, with a private guide and direct access to the Arena Floor — the view the gladiators had, and the most powerful perspective on the monument''s architecture. From there the walk continues through the Roman Forum and the Palatine Hill, where the city first began.\nUnderground access is an optional upgrade, subject to availability.',
  E'- Tickets to the Colosseum (with arena floor) and the Roman Forum\n- Private local guide\n- One-way transfer from the hotel\nOptional upgrade: underground access, subject to availability, confirmed about 25 days before the visit.\nDuration: up to 4 hours.',
  E'Upgrade por underground é opcional mediante disponibilidade (instrução dela). Modelo limpo do erro de Civitavecchia — a Danielle chega de avião e isto é o dia seguinte.'),

 ('e7000000-0000-0000-0000-000000000003', 'experience',
  'Roman Countryside · Frascati Culinary Day', 'Roma · Castelli Romani',
  E'A half day into the hills of the Castelli Romani, to the historic wine region of Frascati — volcanic terroir, ancient estates and an intimate glimpse of rural Italian life. You are welcomed at a family-owned winery for a private, hands-on cooking class, followed by a guided tasting of the estate''s wines and a regional lunch. Your private driver is at your disposal throughout, for a seamless return to Rome by mid-afternoon.',
  E'- Private hands-on cooking class with all ingredients\n- Guided tasting of the estate''s wines\n- Regional lunch\n- Private driver at your disposal (approx. 6 hours)\nSuggested start: 9:30 am (to be confirmed).',
  E'Modelo adaptado: fora o McArthurGlen (não está no briefing). Dia de Frascati, volta a Roma de tarde.'),

 ('e7000000-0000-0000-0000-000000000004', 'experience',
  'Luxury Shopping in Rome with a Personal Shopper', 'Roma · Tridente',
  E'Shopping in Rome has its own logic. The streets around Piazza di Spagna follow a hierarchy most visitors read only from the surface — the maisons on Via Condotti, the obvious sequence of flags and windows. What that map doesn''t show is how to move through it well: which houses are worth your time, which pieces travel, and where the smaller ateliers and Roman designers sit alongside them.\nThis is where a personal shopper changes everything. Before the day she spends time understanding your wardrobe, your eye, what you are really looking for, and the route is built from that conversation — three and a half hours through the elegant geometry of the Tridente, renowned Italian maisons alongside leatherworkers and boutiques chosen for craft and character.',
  E'- Pre-tour style consultation\n- Appointment scheduling where applicable\n- 3.5-hour private tour of the Tridente with a dedicated personal shopper\n- Pick-up from your hotel\nNot included: meals and drop-off at the hotel.\nStart: afternoon, to be defined.',
  E'Modelo de redação dela, mantido o tom.'),

 ('e7000000-0000-0000-0000-000000000005', 'experience',
  'Private Boat Experience on the Tiber', 'Roma',
  E'The perfect setting for a toast to a meaningful journey together. A private aperitivo on board while you cruise the Tiber, with a privileged perspective on Rome''s historic bridges — a joyful, intimate way to close the afternoon before dinner.',
  E'- Private luxury boat cruise on the Tiber with a dedicated crew\n- Italian aperitivo on board',
  E'Referência de vídeo no briefing: https://youtube.com/shorts/DU_-fkN3VHU')

on conflict (id) do nothing;

-- ---------------------------------------------------------------------
-- 3 · A HOSPEDAGEM — PALAZZO RIPETTA, DOIS PERÍODOS
-- Texto, site e fotos vêm da ficha de catálogo da 0012 (cópia). As duas
-- categorias de quarto entram como "unidades", cada uma com valor em
-- branco para ela lançar por período. optional = false: o hotel é a
-- base da viagem; o que se escolhe é a categoria.
-- ---------------------------------------------------------------------
insert into ops_proposal_items
  (id, proposal_id, sort, catalog_id, section, kind, service_date,
   title, title_en, details, details_en, facilities, facilities_en,
   included_pt, included_en, website, photos, units, qty, unit_price,
   price, optional, extras, attachments, supplier)
select E'55260000-0000-0000-0000-000000000001', E'f1d3d719-5142-43e7-9359-e2b7249a25d6',
  0, c.id, E'stays', 'stay', E'May 7 to 10, 2027 · 3 nights',
  c.name, c.name, null, c.descr_en, null, c.facilities_en,
  null, E'Breakfast · flexible rate',
  c.website, c.photos,
  E'[{"key":"u1","label":"Deluxe room","label_en":"Deluxe room","price":0,"optional":false},{"key":"u2","label":"Prestige room · 30 sqm · 2 guests · king bed (twins on request)","label_en":"Prestige room · 30 sqm · 2 guests · king bed (twins on request)","price":0,"optional":false}]'::jsonb,
  1, null, 0, false, '[]'::jsonb, '[]'::jsonb, c.name
from ops_catalog c where c.id = E'c0000000-0000-0000-0000-000000000002'
on conflict (id) do nothing;

insert into ops_proposal_items
  (id, proposal_id, sort, catalog_id, section, kind, service_date,
   title, title_en, details, details_en, facilities, facilities_en,
   included_pt, included_en, website, photos, units, qty, unit_price,
   price, optional, extras, attachments, supplier)
select E'55260000-0000-0000-0000-000000000002', E'f1d3d719-5142-43e7-9359-e2b7249a25d6',
  1, c.id, E'stays', 'stay', E'May 14 to 15, 2027 · 1 night',
  c.name, c.name, null, c.descr_en, null, c.facilities_en,
  null, E'Breakfast · flexible rate',
  c.website, c.photos,
  E'[{"key":"u1","label":"Deluxe room","label_en":"Deluxe room","price":0,"optional":false},{"key":"u2","label":"Prestige room · 30 sqm · 2 guests · king bed (twins on request)","label_en":"Prestige room · 30 sqm · 2 guests · king bed (twins on request)","price":0,"optional":false}]'::jsonb,
  1, null, 0, false, '[]'::jsonb, '[]'::jsonb, c.name
from ops_catalog c where c.id = E'c0000000-0000-0000-0000-000000000002'
on conflict (id) do nothing;

-- ---------------------------------------------------------------------
-- 4 · O DIA A DIA (seção ground, na ordem do briefing)
-- Transfers, recepção VIP e jantares vão escritos aqui (genéricos). As
-- cinco experiências são CÓPIA do catálogo (insert ... select). Tudo
-- opcional, valor em branco, sem foto (ela escolhe a foto de cada dia).
-- ---------------------------------------------------------------------

-- May 7 · Arrival ------------------------------------------------------
insert into ops_proposal_items
  (id, proposal_id, sort, section, kind, service_date, title, title_en,
   details, details_en, included_en, photos, units, qty, unit_price,
   price, optional, extras, attachments)
values
 (E'55260000-0000-0000-0000-000000000011', E'f1d3d719-5142-43e7-9359-e2b7249a25d6',
  10, E'ground', 'transfer', E'Friday, May 7 · Arrival',
  E'VIP meet & greet · Fiumicino (arrival)', E'VIP meet & greet · Fiumicino (arrival)',
  null, E'A dedicated greeter waits at the gate and escorts you through immigration, baggage claim and customs, all the way to your driver.',
  null, '[]'::jsonb, '[]'::jsonb, 1, null, 0, true, '[]'::jsonb, '[]'::jsonb),

 (E'55260000-0000-0000-0000-000000000012', E'f1d3d719-5142-43e7-9359-e2b7249a25d6',
  11, E'ground', 'transfer', E'Friday, May 7 · Arrival',
  E'Private arrival transfer · Fiumicino → Palazzo Ripetta', E'Private arrival transfer · Fiumicino → Palazzo Ripetta',
  null, E'A private transfer meets your 10:50 am arrival and takes you into the city, to Palazzo Ripetta.',
  null, '[]'::jsonb, '[]'::jsonb, 1, null, 0, true, '[]'::jsonb, '[]'::jsonb)
on conflict (id) do nothing;

insert into ops_proposal_items
  (id, proposal_id, sort, catalog_id, section, kind, service_date,
   title, title_en, details, details_en, included_pt, included_en,
   website, photos, units, qty, unit_price, price, optional, extras, attachments, supplier)
select E'55260000-0000-0000-0000-000000000013', E'f1d3d719-5142-43e7-9359-e2b7249a25d6',
  12, c.id, E'ground', 'experience', E'Friday, May 7 · Arrival',
  c.name, c.name, null, c.descr_en, null, c.included_en,
  c.website, '[]'::jsonb, '[]'::jsonb, 1, null, 0, true, '[]'::jsonb, '[]'::jsonb, c.name
from ops_catalog c where c.id = E'e7000000-0000-0000-0000-000000000001'
on conflict (id) do nothing;

-- May 8 · The Colosseum ------------------------------------------------
insert into ops_proposal_items
  (id, proposal_id, sort, catalog_id, section, kind, service_date,
   title, title_en, details, details_en, included_pt, included_en,
   website, photos, units, qty, unit_price, price, optional, extras, attachments, supplier)
select E'55260000-0000-0000-0000-000000000014', E'f1d3d719-5142-43e7-9359-e2b7249a25d6',
  13, c.id, E'ground', 'experience', E'Saturday, May 8 · The Colosseum',
  c.name, c.name, null, c.descr_en, null, c.included_en,
  c.website, '[]'::jsonb, '[]'::jsonb, 1, null, 0, true, '[]'::jsonb, '[]'::jsonb, c.name
from ops_catalog c where c.id = E'e7000000-0000-0000-0000-000000000002'
on conflict (id) do nothing;

insert into ops_proposal_items
  (id, proposal_id, sort, catalog_id, section, kind, service_date,
   title, title_en, details, details_en, included_pt, included_en,
   website, photos, units, qty, unit_price, price, optional, extras, attachments, supplier)
select E'55260000-0000-0000-0000-000000000015', E'f1d3d719-5142-43e7-9359-e2b7249a25d6',
  14, c.id, E'ground', 'experience', E'Saturday, May 8 · The Colosseum',
  c.name, c.name, null, c.descr_en, null, c.included_en,
  c.website, '[]'::jsonb, '[]'::jsonb, 1, null, 0, true, '[]'::jsonb, '[]'::jsonb, c.name
from ops_catalog c where c.id = E'e7000000-0000-0000-0000-000000000004'
on conflict (id) do nothing;

-- May 9 · Frascati -----------------------------------------------------
insert into ops_proposal_items
  (id, proposal_id, sort, catalog_id, section, kind, service_date,
   title, title_en, details, details_en, included_pt, included_en,
   website, photos, units, qty, unit_price, price, optional, extras, attachments, supplier)
select E'55260000-0000-0000-0000-000000000016', E'f1d3d719-5142-43e7-9359-e2b7249a25d6',
  15, c.id, E'ground', 'experience', E'Sunday, May 9 · Frascati',
  c.name, c.name, null, c.descr_en, null, c.included_en,
  c.website, '[]'::jsonb, '[]'::jsonb, 1, null, 0, true, '[]'::jsonb, '[]'::jsonb, c.name
from ops_catalog c where c.id = E'e7000000-0000-0000-0000-000000000003'
on conflict (id) do nothing;

insert into ops_proposal_items
  (id, proposal_id, sort, section, kind, service_date, title, title_en,
   details, details_en, included_en, photos, units, qty, unit_price,
   price, optional, extras, attachments)
values
 (E'55260000-0000-0000-0000-000000000017', E'f1d3d719-5142-43e7-9359-e2b7249a25d6',
  16, E'ground', 'experience', E'Sunday, May 9 · Frascati',
  E'Anniversary dinner · arranged by our concierge', E'Anniversary dinner · arranged by our concierge',
  null, E'To celebrate your 17th anniversary, a special table reserved by our concierge for the evening.',
  null, '[]'::jsonb, '[]'::jsonb, 1, null, 0, true, '[]'::jsonb, '[]'::jsonb)
on conflict (id) do nothing;

-- May 10 · On to Positano ---------------------------------------------
insert into ops_proposal_items
  (id, proposal_id, sort, section, kind, service_date, title, title_en,
   details, details_en, included_en, photos, units, qty, unit_price,
   price, optional, extras, attachments)
values
 (E'55260000-0000-0000-0000-000000000018', E'f1d3d719-5142-43e7-9359-e2b7249a25d6',
  17, E'ground', 'transfer', E'Monday, May 10 · On to Positano',
  E'Private transfer · Palazzo Ripetta → train station', E'Private transfer · Palazzo Ripetta → train station',
  null, E'After checkout, a private transfer to the station for your onward journey to Positano. The Positano days are planned on your side.',
  null, '[]'::jsonb, '[]'::jsonb, 1, null, 0, true, '[]'::jsonb, '[]'::jsonb)
on conflict (id) do nothing;

-- May 14 · Back in Rome ------------------------------------------------
insert into ops_proposal_items
  (id, proposal_id, sort, section, kind, service_date, title, title_en,
   details, details_en, included_en, photos, units, qty, unit_price,
   price, optional, extras, attachments)
values
 (E'55260000-0000-0000-0000-000000000019', E'f1d3d719-5142-43e7-9359-e2b7249a25d6',
  18, E'ground', 'transfer', E'Friday, May 14 · Back in Rome',
  E'Private transfer · train station → Palazzo Ripetta', E'Private transfer · train station → Palazzo Ripetta',
  null, E'On your return from Positano, a private transfer from the station back to Palazzo Ripetta.',
  null, '[]'::jsonb, '[]'::jsonb, 1, null, 0, true, '[]'::jsonb, '[]'::jsonb)
on conflict (id) do nothing;

insert into ops_proposal_items
  (id, proposal_id, sort, catalog_id, section, kind, service_date,
   title, title_en, details, details_en, included_pt, included_en,
   website, photos, units, qty, unit_price, price, optional, extras, attachments, supplier)
select E'55260000-0000-0000-0000-00000000001a', E'f1d3d719-5142-43e7-9359-e2b7249a25d6',
  19, c.id, E'ground', 'experience', E'Friday, May 14 · Back in Rome',
  c.name, c.name, null, c.descr_en, null, c.included_en,
  c.website, '[]'::jsonb, '[]'::jsonb, 1, null, 0, true, '[]'::jsonb, '[]'::jsonb, c.name
from ops_catalog c where c.id = E'e7000000-0000-0000-0000-000000000005'
on conflict (id) do nothing;

insert into ops_proposal_items
  (id, proposal_id, sort, section, kind, service_date, title, title_en,
   details, details_en, included_en, photos, units, qty, unit_price,
   price, optional, extras, attachments)
values
 (E'55260000-0000-0000-0000-00000000001b', E'f1d3d719-5142-43e7-9359-e2b7249a25d6',
  20, E'ground', 'experience', E'Friday, May 14 · Back in Rome',
  E'Farewell dinner · arranged by our concierge', E'Farewell dinner · arranged by our concierge',
  null, E'A last dinner in Rome at a special place, reserved by our concierge after the boat experience.',
  null, '[]'::jsonb, '[]'::jsonb, 1, null, 0, true, '[]'::jsonb, '[]'::jsonb)
on conflict (id) do nothing;

-- May 15 · Departure ---------------------------------------------------
insert into ops_proposal_items
  (id, proposal_id, sort, section, kind, service_date, title, title_en,
   details, details_en, included_en, photos, units, qty, unit_price,
   price, optional, extras, attachments)
values
 (E'55260000-0000-0000-0000-00000000001c', E'f1d3d719-5142-43e7-9359-e2b7249a25d6',
  21, E'ground', 'transfer', E'Saturday, May 15 · Departure',
  E'Private departure transfer · Palazzo Ripetta → Fiumicino', E'Private departure transfer · Palazzo Ripetta → Fiumicino',
  null, E'A private transfer to Fiumicino for your 1:10 pm flight home.',
  null, '[]'::jsonb, '[]'::jsonb, 1, null, 0, true, '[]'::jsonb, '[]'::jsonb),

 (E'55260000-0000-0000-0000-00000000001d', E'f1d3d719-5142-43e7-9359-e2b7249a25d6',
  22, E'ground', 'transfer', E'Saturday, May 15 · Departure',
  E'VIP assistance · Fiumicino (departure)', E'VIP assistance · Fiumicino (departure)',
  null, E'Dedicated assistance at the airport on departure, from the entrance through to the gate.',
  null, '[]'::jsonb, '[]'::jsonb, 1, null, 0, true, '[]'::jsonb, '[]'::jsonb)
on conflict (id) do nothing;

-- ---------------------------------------------------------------------
-- 5 · A SEÇÃO DO DIA A DIA VAI PARA "UMA FOTO POR DIA"
-- modo é estrutura, não texto: muda sempre. O título/instrução só muda
-- se ainda estiver com o que o hub semeou — se ela já escreveu o dela,
-- o dela fica. O merge (||) preserva o resto da seção.
-- ---------------------------------------------------------------------
update ops_proposals set sections = (
  select jsonb_agg(
           case
             when s->>'key' = 'ground' then
               (s || '{"modo":"dias"}'::jsonb)
               || case when s->>'title' = 'Ground Services'
                       then jsonb_build_object(
                              'title','Your Days in Rome',
                              'note','Experiences and private services, day by day — choose what you''d like.')
                       else '{}'::jsonb end
             else s
           end order by ord)
    from jsonb_array_elements(sections) with ordinality t(s, ord)),
  updated_at = now()
 where id = 'f1d3d719-5142-43e7-9359-e2b7249a25d6'
   and sections is not null and jsonb_array_length(sections) > 0;

-- ---------------------------------------------------------------------
-- 6 · A FOLHA DE CURADORIA, COM O TEXTO DO BRIEFING
-- "Curadoria, o texto é o do briefing." Só entra se ela ainda não tiver
-- criado curadoria nenhuma — curadoria que ela escreveu não é tocada.
-- O corpo (dias_en) é o programa do briefing: cada linha "- Dia: ..."
-- vira um item, com a parte antes dos dois-pontos em itálico.
-- ---------------------------------------------------------------------
update ops_proposals set
  curations = jsonb_build_array(jsonb_build_object(
    'opcao', '',
    'cor', 'verde',
    'title_en', E'The Days We''ve Shaped',
    'title_pt', '',
    'dest_en', E'Rome · 7–15 May 2027 · 2 guests',
    'dest_pt', '',
    'dias_en', E'We''ve shaped these days around your 17th anniversary, with a few special moments and plenty of time to enjoy Rome on your own.\n- Friday, May 7 · Arrival: you land at 10:50 am. A private transfer takes you to Palazzo Ripetta, with an optional VIP meet and greet at the airport. In the late afternoon, a private food tour designed for you — Rome told through its flavours.\n- Saturday, May 8 · The Colosseum: the Colosseum in the morning with a private guide, including the arena and the underground upon availability. In the afternoon, the boutiques of central Rome with a personal shopper.\n- Sunday, May 9 · Frascati: a half day out of the city. A private driver takes you to a winery in Frascati for a pasta class, lunch and a tasting, back in Rome by mid-afternoon. In the evening, a special dinner to celebrate your anniversary.\n- Monday, May 10 · On to Positano: checkout and a private transfer to the train station. The Positano days are planned on your side.\n- Friday, May 14 · Back in Rome: a private transfer from the station to the hotel. At the end of the day, a private boat experience on the Tiber, followed by dinner at a special place for your last evening in Rome.\n- Saturday, May 15 · Departure: a private transfer to Fiumicino for your 1:10 pm flight, with optional VIP assistance at the airport.\nFor a future return, there is a lot more we would love to share: a drive through the countryside near Rome in a vintage car or a Ferrari, or the Vatican behind closed doors.',
    'dias_pt', '')),
  updated_at = now()
 where id = 'f1d3d719-5142-43e7-9359-e2b7249a25d6'
   and coalesce(jsonb_array_length(curations), 0) = 0;

insert into ops_migrations (id) values ('0070-proposta-danielle-rome') on conflict (id) do nothing;
