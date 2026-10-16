-- =====================================================================
-- 0082 · CURADORIA TL-053-26: DE "TOSCANA E VENEZA" PARA "TOSCANA E ROMA"
--
-- Pedido dela (out/26): a curadoria de hotéis da advisor (Destinations by
-- Dani, white label, tarifa indicativa por noite) deixa de ter Florença e
-- Veneza e passa a ter ROMA. O desenho das noites, fechado com ela:
--   Cortona 5  +  Toscana 4  +  Roma 4   = 13 noites, de 20/jun a 4/jul/2027
--   (ele quer voar de volta no dia 4). A divisão Toscana/Roma pode variar
--   uma noite conforme a chegada — está dito na folha da curadoria.
--
--   proposta: ops_proposals.id = b59090ad-14dc-45d3-87f5-9f7206834668
--             (link/token d4e8e2a5945f40cd923f99d21d40792f)
--
-- ESTE ARQUIVO MEXE EM LINHA QUE JÁ EXISTE — por isso é arquivo próprio e
-- numerado, e só roda depois do sim dela. O que ele toca, item a item:
--
--   · APAGA as 4 hospedagens de Florença e Veneza (seções sec1 e sec2):
--       delete from ops_proposal_items
--        where proposal_id = 'b59090ad-…' and section in ('sec1','sec2');
--   · REMOVE sec1 (Florence) e sec2 (Venice) do array sections e
--     ACRESCENTA a seção 'roma' (4 noites). A seção 'stays' (Toscana, 4
--     noites) fica exatamente como ela a deixou — título, instrução, modo;
--   · INSERE as 2 hospedagens de Roma (La Minerva e Bulgari), cada uma com
--     duas categorias como unidades, valor POR NOITE (o hub multiplica
--     pelas 4 noites da base e mostra a estimativa);
--   · TROCA o texto da folha da Curadoria (o "primeiro slide") e o título
--     dela para Toscana & Roma;
--   · TROCA cover_title, title e travel_window, que ainda falavam de Veneza
--     e terminavam em 5/jul.
--
-- NÃO TOCA: Toscana (Castelfalfi, Borgo Vescine), sobre nós, respaldo,
-- contracapa, white label, idioma, o token, rate_mode/rate_note (segue
-- indicativo, por noite), e nenhuma outra proposta.
--
-- VALORES (média por noite que ela passou):
--   La Minerva · Grand Deluxe Room            € 3.000  (12.000 / 4 noites)
--   La Minerva · Junior Suite with View       € 3.400  (13.600 / 4 noites)
--   Bulgari    · Deluxe Room (city view)       € 2.750  (2.500 + 10% de taxa)
--   Bulgari    · Premium Room (city view)      € 3.080  (2.800 + 10% de taxa)
--
-- Fatos dos hotéis conferidos no site oficial (orient-express.com e
-- bulgarihotels.com): metragem das categorias, descrição e fotos. O site
-- do Bulgari recusa leitura direta — as fotos das categorias vêm de fonte
-- que serve a imagem (privateupgrades), e as oficiais em 800×600 vão
-- anexas na mensagem para ela subir pela tela se preferir.
--
-- Miro item por proposal_id + seção/título (o id de ops_proposal_items não
-- é estável — salvar no editor recria as linhas). Idempotente: inserts com
-- guarda de "ainda não existe"; updates de texto com guarda na frase atual.
--
-- Seção 7: ops_proposal_items (delete + insert, guardados), ops_proposals
-- (update de sections, curations, cover_title, title, travel_window,
-- guardados), ops_migrations (insert). Sem drop/truncate. Nenhuma tabela
-- do CRM.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1 · SAEM FLORENÇA E VENEZA (as 4 hospedagens das seções sec1 e sec2)
-- ---------------------------------------------------------------------
delete from ops_proposal_items
 where proposal_id = 'b59090ad-14dc-45d3-87f5-9f7206834668'
   and section in ('sec1','sec2');

-- ---------------------------------------------------------------------
-- 2 · AS SEÇÕES: tira sec1/sec2, mantém 'stays', acrescenta 'roma'
--     O jsonb_agg preserva tudo que ela escreveu em 'stays'. A guarda
--     "not exists roma" deixa o arquivo rodar de novo sem duplicar.
-- ---------------------------------------------------------------------
update ops_proposals set sections = (
    select coalesce(jsonb_agg(s order by ord), '[]'::jsonb)
      from jsonb_array_elements(sections) with ordinality t(s, ord)
     where s->>'key' not in ('sec1','sec2')
  ) || '[{"key":"roma","modo":"blocos","note":"Select your stay for this trip","photo":null,"title":"Rome","nights":4}]'::jsonb
 where id = 'b59090ad-14dc-45d3-87f5-9f7206834668'
   and not exists (
         select 1 from jsonb_array_elements(sections) e where e->>'key' = 'roma');

-- ---------------------------------------------------------------------
-- 3 · AS DUAS HOSPEDAGENS DE ROMA
--     Texto em inglês (a proposta é inteira em inglês), nas colunas-base
--     e nas _en, como as linhas da Toscana. Valor POR NOITE nas unidades.
-- ---------------------------------------------------------------------

-- 3a · LA MINERVA (Orient Express)
insert into ops_proposal_items
  (id, proposal_id, sort, section, kind, service_date,
   title, title_en, details, details_en, facilities, facilities_en,
   website, photos, units, qty, unit_price, price, optional,
   extras, attachments, supplier)
select
  E'53260000-0000-0000-0000-00000000000a',
  E'b59090ad-14dc-45d3-87f5-9f7206834668', 20, E'roma', 'stay',
  E'June 29 to July 3, 2027',
  E'La Minerva', E'La Minerva',
  null,
  E'An Orient Express hotel in a 17th-century palazzo on Piazza della Minerva, a step behind the Pantheon. The house reopened in 2025 with 93 rooms and suites, Art Deco interiors by Hugo Toro, a rooftop restaurant and bar over the historic centre, and a spa. Piazza Navona and the Trevi Fountain are both a short walk away.',
  null,
  E'Interiors by Hugo Toro. Rooftop restaurant and bar, and a spa.',
  E'https://www.orient-express.com/la-minerva/',
  E'["https://medias.orient-express.com/sites/default/files/styles/w3840/public/mobile/2058x3084/la%20minerva%20orient%20express%20%C2%A9%20mr.%20tripper-46_1.webp", "https://medias.orient-express.com/sites/default/files/styles/w3840/public/mobile/768x768/La%20Minerva%20-%20Deluxe%20Room%20With%20minerva%20square%20view%201.webp", "https://medias.orient-express.com/sites/default/files/styles/w3840/public/mobile/768x768/Credit_Alexandre_Tabaste_R502_horizontal_HD%20%281%29.webp"]'::jsonb,
  E'[{"key":"u1","label":"Grand Deluxe Room · 41 m² / 441 sq ft","label_en":"Grand Deluxe Room · 41 m² / 441 sq ft","price":3000,"optional":true},{"key":"u2","label":"Junior Suite with View · 49 m² / 527 sq ft","label_en":"Junior Suite with View · 49 m² / 527 sq ft","price":3400,"optional":true}]'::jsonb,
  1, null, 0, true, '[]'::jsonb, '[]'::jsonb, E'La Minerva (Orient Express)'
where not exists (
  select 1 from ops_proposal_items x
   where x.proposal_id = 'b59090ad-14dc-45d3-87f5-9f7206834668'
     and 'La Minerva' in (coalesce(x.title,''), coalesce(x.title_en,'')));

-- 3b · BULGARI HOTEL ROMA
insert into ops_proposal_items
  (id, proposal_id, sort, section, kind, service_date,
   title, title_en, details, details_en, facilities, facilities_en,
   website, photos, units, qty, unit_price, price, optional,
   extras, attachments, supplier)
select
  E'53260000-0000-0000-0000-00000000000b',
  E'b59090ad-14dc-45d3-87f5-9f7206834668', 21, E'roma', 'stay',
  E'June 29 to July 3, 2027',
  E'Bulgari Hotel Roma', E'Bulgari Hotel Roma',
  null,
  E'The Bulgari group''s Rome house, opened in 2023 on Piazza Augusto Imperatore, facing the restored Mausoleum of Augustus. Interiors by Antonio Citterio Patricia Viel in travertine and coloured marble, a spa with an indoor pool, Il Ristorante Niko Romito, and a rooftop terrace over the city. The Spanish Steps, the Ara Pacis and the Tiber are all within a few minutes'' walk.',
  null,
  E'Interiors by Antonio Citterio Patricia Viel. Il Ristorante Niko Romito, a rooftop terrace, and a spa with an indoor pool.',
  E'https://www.bulgarihotels.com/en_US/rome',
  E'["https://media.privateupgrades.com/_data/default-room_image/21/109679/deluxe-room-bulgari-hotel-roma_800x800_auto.jpg", "https://media.privateupgrades.com/_data/default-room_image/21/109655/premium-room-bulgari-hotel-roma1_800x800_auto.jpg"]'::jsonb,
  E'[{"key":"u1","label":"Deluxe Room · city view · 37 m² / 398 sq ft","label_en":"Deluxe Room · city view · 37 m² / 398 sq ft","price":2750,"optional":true},{"key":"u2","label":"Premium Room · city view · 49 m² / 527 sq ft","label_en":"Premium Room · city view · 49 m² / 527 sq ft","price":3080,"optional":true}]'::jsonb,
  1, null, 0, true, '[]'::jsonb, '[]'::jsonb, E'Bulgari Hotel Roma'
where not exists (
  select 1 from ops_proposal_items x
   where x.proposal_id = 'b59090ad-14dc-45d3-87f5-9f7206834668'
     and 'Bulgari Hotel Roma' in (coalesce(x.title,''), coalesce(x.title_en,'')));

-- ---------------------------------------------------------------------
-- 4 · A FOLHA DA CURADORIA (o primeiro slide) — Toscana & Roma
--     Guarda na frase atual: só troca se ainda falar de Veneza, para não
--     passar por cima de uma edição que ela tenha feito à mão.
-- ---------------------------------------------------------------------
update ops_proposals set curations = jsonb_build_array(
  jsonb_build_object(
    'opcao', '',
    'cor', 'verde',
    'destinos', null,
    'title', E'Tuscany & Rome · Hotel Curation Brief',
    'dias', E'Here''s a first selection of hotels for June 20 to July 4, 2027.
After your five nights in Cortona, we''d suggest four nights in the Tuscan countryside and four in Rome, flying home on the 4th. We started from what you love about Four Seasons and leaned toward smaller houses, where you get space, a real king bed and privacy. Rates are indicative for now and will move with the final dates, and the split between Tuscany and Rome can shift by a night depending on where you land.

TUSCANY, 4 nights

Cortona covers the south. For the next four nights we move closer to Florence, into wine country.

Castelfalfi. A medieval borgo inside a 2,700-acre estate with its own vineyards and olive groves, between San Gimignano and Volterra. Long walks from the door, and a large spa for the afternoons.

Borgo Vescine. A 13th-century village in Chianti Classico, 28 rooms, vineyards around it and a pool facing the hills.

ROME, 4 nights

Four nights in the centre to close the trip, both houses within walking distance of the Pantheon and the river.

La Minerva. An Orient Express house in a 17th-century palazzo on Piazza della Minerva, right behind the Pantheon. Reopened in 2025 with Art Deco interiors and a rooftop over the historic centre.

Bulgari Hotel Roma. The group''s Rome house on Piazza Augusto Imperatore, facing the Mausoleum of Augustus, with interiors in travertine and coloured marble, a spa and the Niko Romito restaurant.

If you''d like a few days by the sea before Rome, the Tuscan stay could move toward the southern coast near the islands — late June is the start of the season there.'
  ))
 where id = 'b59090ad-14dc-45d3-87f5-9f7206834668'
   and curations::text like '%Venice%';

-- ---------------------------------------------------------------------
-- 5 · OS TÍTULOS QUE AINDA FALAVAM DE VENEZA E TERMINAVAM EM 5/JUL
--     Cada um guardado no valor atual, para não clobrar edição dela.
-- ---------------------------------------------------------------------
update ops_proposals set cover_title = 'Tuscany and Rome'
 where id = 'b59090ad-14dc-45d3-87f5-9f7206834668'
   and cover_title = 'Tuscany, Florence and Venice';

update ops_proposals set title = 'Tuscany and Rome 2027'
 where id = 'b59090ad-14dc-45d3-87f5-9f7206834668'
   and title = 'Tuscany and Venice 2027';

update ops_proposals set travel_window = 'June 20-July 4, 2027'
 where id = 'b59090ad-14dc-45d3-87f5-9f7206834668'
   and travel_window = 'June 20-July 5, 2027';

insert into ops_migrations (id) values ('0082-curadoria-toscana-e-roma') on conflict (id) do nothing;
