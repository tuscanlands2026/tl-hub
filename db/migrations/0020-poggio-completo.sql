-- =====================================================================
-- 0020 · O POGGIO COM A CAPA, EM UM ARQUIVO SÓ
--
-- A capa do Poggio não aparece, e a dos outros dois sim. A diferença
-- entre eles é a ordem: Villa e Ripetta já existiam quando a 0018
-- gravou as capas; o Poggio nasce na 0017. Se a 0018 e a 0019 rodarem
-- antes da 0017, elas não têm o que atualizar, e a 0017 cria a linha
-- sem capa.
--
-- Este arquivo acaba com a dependência de ordem: cria o Poggio se ele
-- não existir, já com a capa, e completa a capa se ele existir sem. Um
-- comando só, que dá no mesmo rodando antes, depois ou duas vezes.
--
-- Continua respeitando o que ela escolheu: capa preenchida à mão não é
-- sobrescrita.
--
-- Só toca em objetos ops_. Nada fora desse prefixo.
-- =====================================================================

insert into ops_catalog
  (id, kind, name, region, website, cover_img, accommodation, accommodation_en,
   facilities, facilities_en, descr, descr_en, photos, internal_notes)
values ('c0000000-0000-0000-0000-000000000003', 'stay',
  'Poggio Paradiso Resort & Spa', 'Toscana · Val d''Orcia',
  'https://www.poggioparadisoresort.com/',
  'https://irp.cdn-website.com/d736fd45/dms3rep/multi/DJI_0188.jpg',
  E'Suite Malvasia · categoria Prestige Plus',
  E'Malvasia Suite · Prestige Plus category',
  E'Terme Miele, spa com tratamentos e massagem\nRestaurante L''Olivo Cucina\nPiscina\nQuatro estrelas',
  E'Terme Miele spa, treatments and massage\nL''Olivo Cucina restaurant\nPool\nFour stars',
  E'Resort quatro estrelas no coração da Toscana, na Val d''Orcia, com acomodações reformadas, spa próprio e restaurante.\nAs oito suítes levam o nome das uvas nativas da região, e cada uma tem a atmosfera da sua: a Malvasia é a das aromáticas florais, das notas cítricas e do fundo herbáceo — uva trazida à Toscana pelos navegadores do Mediterrâneo e cultivada desde a Idade Média, quando os Medici ajudaram a difundi-la.\nO Terme Miele é o day spa da casa, com tratamentos e massagem. O L''Olivo Cucina serve a cozinha do resort.',
  E'Four-star resort in the heart of Tuscany, in the Val d''Orcia, with renovated accommodation, its own spa and restaurant.\nThe eight suites are named after the region''s native grape varieties, each carrying the character of its own: the Malvasia is the floral and aromatic one, with citrus notes and a herbal base — a grape brought to Tuscany by Mediterranean traders and grown since the Middle Ages, when the Medici helped spread it.\nTerme Miele is the house day spa, with treatments and massage. L''Olivo Cucina serves the resort''s kitchen.',
  '["https://irp.cdn-website.com/d736fd45/dms3rep/multi/DJI_0188.jpg", "https://irp.cdn-website.com/d736fd45/dms3rep/multi/Poggio+Paradiso+Resort_2025_Romani013.jpg", "https://irp.cdn-website.com/d736fd45/dms3rep/multi/Poggio+Paradiso+Resort_2025_Romani020.jpg", "https://irp.cdn-website.com/d736fd45/dms3rep/multi/Poggio+Paradiso+Resort_2025_Romani034.jpg"]'::jsonb,
  E'Suite Malvasia, categoria Prestige Plus. O site não publica metragem, cama nem ocupação — confirmar com o hotel e escrever na Acomodação. As fotos são do resort, não identificadas por suíte.')
on conflict (id) do update set
  cover_img = coalesce(nullif(ops_catalog.cover_img,''), excluded.cover_img),
  photos    = case when ops_catalog.photos = '[]'::jsonb then excluded.photos else ops_catalog.photos end,
  updated_at = now();

insert into ops_migrations (id) values ('0020-poggio-completo') on conflict (id) do nothing;
