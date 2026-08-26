-- =====================================================================
-- 0017 · POGGIO PARADISO RESORT & SPA, E O CATÁLOGO ABERTO A ELA
--
-- 1. O resort da Val d'Orcia entra no catálogo, com a Suite Malvasia
--    como a acomodação desta venda. O site não publica metragem, cama
--    nem ocupação das suítes — o texto de cada uma fala da uva que dá
--    nome ao quarto. O que dá para afirmar está aqui; o que não dá
--    fica em branco para ela preencher, e não inventado.
--
-- 2. `kind` ganha 'transfer' de verdade no uso: ela vai cadastrar os
--    transfers e os extras que se repetem — assistência, mensageria —
--    e daí em diante puxá-los pelo nome como puxa hospedagem. A coluna
--    já existia desde a 0006; o que faltava era a tela, que entra no
--    hub nesta mesma leva.
--
-- Só toca em objetos ops_. Nada fora desse prefixo.
-- =====================================================================

insert into ops_catalog
  (id, kind, name, region, website, accommodation, accommodation_en,
   facilities, facilities_en, descr, descr_en, photos, internal_notes)
values ('c0000000-0000-0000-0000-000000000003', 'stay',
  'Poggio Paradiso Resort & Spa', 'Toscana · Val d''Orcia',
  'https://www.poggioparadisoresort.com/',
  E'Suite Malvasia · categoria Prestige Plus',
  E'Malvasia Suite · Prestige Plus category',
  E'Terme Miele, spa com tratamentos e massagem\nRestaurante L''Olivo Cucina\nPiscina\nQuatro estrelas',
  E'Terme Miele spa, treatments and massage\nL''Olivo Cucina restaurant\nPool\nFour stars',
  E'Resort quatro estrelas no coração da Toscana, na Val d''Orcia, com acomodações reformadas, spa próprio e restaurante.\nAs oito suítes levam o nome das uvas nativas da região, e cada uma tem a atmosfera da sua: a Malvasia é a das aromáticas florais, das notas cítricas e do fundo herbáceo — uva trazida à Toscana pelos navegadores do Mediterrâneo e cultivada desde a Idade Média, quando os Medici ajudaram a difundi-la.\nO Terme Miele é o day spa da casa, com tratamentos e massagem. O L''Olivo Cucina serve a cozinha do resort.',
  E'Four-star resort in the heart of Tuscany, in the Val d''Orcia, with renovated accommodation, its own spa and restaurant.\nThe eight suites are named after the region''s native grape varieties, each carrying the character of its own: the Malvasia is the floral and aromatic one, with citrus notes and a herbal base — a grape brought to Tuscany by Mediterranean traders and grown since the Middle Ages, when the Medici helped spread it.\nTerme Miele is the house day spa, with treatments and massage. L''Olivo Cucina serves the resort''s kitchen.',
  '["https://irp.cdn-website.com/d736fd45/dms3rep/multi/DJI_0188.jpg", "https://irp.cdn-website.com/d736fd45/dms3rep/multi/Poggio+Paradiso+Resort_2025_Romani013.jpg", "https://irp.cdn-website.com/d736fd45/dms3rep/multi/Poggio+Paradiso+Resort_2025_Romani020.jpg", "https://irp.cdn-website.com/d736fd45/dms3rep/multi/Poggio+Paradiso+Resort_2025_Romani034.jpg"]'::jsonb,
  E'Suite Malvasia, categoria Prestige Plus. O site não publica metragem, cama nem ocupação — confirmar com o hotel e escrever na Acomodação. As fotos são do resort, não identificadas por suíte: trocar pelas da Malvasia quando o hotel mandar.')
on conflict (id) do update set
  accommodation = excluded.accommodation, accommodation_en = excluded.accommodation_en,
  facilities = excluded.facilities, facilities_en = excluded.facilities_en,
  descr = excluded.descr, descr_en = excluded.descr_en,
  photos = excluded.photos, updated_at = now();

insert into ops_migrations (id) values ('0017-poggio-paradiso') on conflict (id) do nothing;
