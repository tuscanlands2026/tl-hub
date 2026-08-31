-- =====================================================================
-- 0033 · BORGO VESCINE ENTRA NO CATÁLOGO, COM A CAMERA DELUXE
--
-- Pedido dela em agosto/26, para a v2 da TL-042-26: mais uma Selected
-- Stay no Chianti Classico, com a Deluxe como a acomodação da venda.
--
-- Tudo escrito do que o hotel publica em vescine.it — a página da
-- Camera Deluxe e a home. Nada de memória. O que o site publica e que
-- entrou aqui: 5 estrelas, borgo do século XIII em Radda in Chianti,
-- 20 km de Siena e 42 de Florença, 42 hectares de propriedade, adega
-- secular com degustação, restaurantes, piscina com jardim italiano.
--
-- O que o site NÃO publica e por isso não está aqui: spa. A palavra
-- que aparece na home é "Vespa", da experiência de passeio — não é
-- spa, e escrever spa numa proposta seria vender o que não existe.
--
-- A Deluxe tem metragem, cama e ocupação publicadas, ao contrário do
-- Poggio Paradiso: cama 160×190, 2 adultos, 22 a 24 m². Então a
-- Acomodação sai completa e não fica nada em branco para ela.
--
-- O site só publica em italiano. O texto em português e o em inglês
-- são tradução do que está lá, e não invenção: história do quarto
-- (celeiro de grãos do borgo), materiais (cotto feito à mão, vigas
-- aparentes), banho reformado, vista para a praça e para as colinas.
--
-- Sem preço. Valor é desta venda, e o catálogo só guarda preço de
-- referência quando ela lança um — não é o caso deste.
--
-- Só toca em objetos ops_. Nada fora desse prefixo.
-- =====================================================================

insert into ops_catalog
  (id, kind, name, region, website, accommodation, accommodation_en,
   facilities, facilities_en, descr, descr_en, photos, cover_img, internal_notes)
values ('c0000000-0000-0000-0000-000000000004', 'stay',
  'Borgo Vescine', 'Toscana · Chianti Classico · Radda in Chianti',
  'https://www.vescine.it/',

  E'Camera Deluxe\nCama de casal 160×190 cm · 2 adultos\n22 a 24 m²\nBanheiro com piso de cotto e acabamento tradicional em madeira\nVista para a praça do borgo e para as colinas do Chianti',
  E'Deluxe Room\nDouble bed 160×190 cm · 2 adults\n22 to 24 sqm\nBathroom with terracotta floors and traditional wood detailing\nViews over the borgo square and the Chianti hills',

  E'Cinco estrelas\nBorgo do século XIII, 42 hectares de vinhas, oliveiras e bosque\nAdega secular com degustação dos vinhos da casa\nRestaurantes\nPiscina com jardim italiano\nJantar na praça, jantar no olival e piquenique\nTrekking, ioga, equitação e passeio de carro de época',
  E'Five stars\n13th-century hamlet set in 42 hectares of vineyards, olive groves and woodland\nCenturies-old cellar with tastings of the estate wines\nRestaurants\nPool set in an Italian garden\nDinner in the square, dinner in the olive grove and picnics\nTrekking, yoga, horse riding and vintage car outings',

  E'Relais cinco estrelas instalado num borgo do século XIII em Radda in Chianti, no coração do Chianti Classico, a 20 km de Siena e 42 de Florença. A propriedade tem 42 hectares de vinhas, oliveiras seculares e bosque, com trilhas dentro dela.\nAs Camere Deluxe eram os celeiros do borgo, onde se guardavam o grão e os cereais que sustentavam a vida ali entre uma estação e outra. Foram restauradas mantendo as proporções e os materiais originais — piso de cotto feito à mão, vigas de madeira aparentes — e mobiliadas com peças desenhadas para a casa e feitas por artesãos da região.\nOs banheiros são novos, com roupão, chinelo e amenidades de produção local, sem plástico de uso único. As janelas dão para a praça de pedra do borgo ou para os crinais do Chianti.\nA adega secular recebe as degustações dos vinhos da casa. Ao anoitecer, o jardim italiano à beira da piscina vira sala de jantar ao ar livre.',
  E'Five-star relais set in a 13th-century hamlet at Radda in Chianti, in the heart of Chianti Classico, 20 km from Siena and 42 from Florence. The estate covers 42 hectares of vineyards, centuries-old olive groves and woodland, with walking trails throughout.\nThe Deluxe Rooms were the hamlet''s granaries, where the grain and cereals that carried the community from one season to the next were stored. They have been restored keeping the original proportions and materials — handmade terracotta floors, exposed wooden beams — and furnished with pieces designed for the house and made by local craftsmen.\nThe bathrooms are new, with robes, slippers and locally produced amenities, free of single-use plastic. Windows open onto the hamlet''s stone square or the vineyard ridges of Chianti.\nThe centuries-old cellar hosts tastings of the estate wines. At dusk, the Italian garden by the pool becomes an open-air dining room.',

  '["https://images.squarespace-cdn.com/content/v1/63fa5a875489c1006b8bcdd1/31e01f6f-8589-4a09-9eef-f42014ac2ea2/118_1IN7878-HDR-2.jpg", "https://images.squarespace-cdn.com/content/v1/63fa5a875489c1006b8bcdd1/312963c8-9224-426d-8779-aff318c6257a/108_INF2743-HDR.jpg", "https://images.squarespace-cdn.com/content/v1/63fa5a875489c1006b8bcdd1/4ec69a60-ba0c-4830-bd7f-b73afe541cd7/117_INF2764.jpg", "https://images.squarespace-cdn.com/content/v1/63fa5a875489c1006b8bcdd1/1838b108-b3a4-4bee-a889-584792353945/105_INF2737-HDR.jpg"]'::jsonb,
  'https://images.squarespace-cdn.com/content/v1/63fa5a875489c1006b8bcdd1/31e01f6f-8589-4a09-9eef-f42014ac2ea2/118_1IN7878-HDR-2.jpg',

  E'Camera Deluxe. Metragem, cama e ocupação são as publicadas na página do quarto em vescine.it/it/deluxe-room. As fotos são da própria página da Deluxe.\nO site não publica spa — não oferecer.\nContatos do hotel: reservations@vescine.it · +39 0577 741144.\nSem preço de referência: lançar quando ela tiver a tarifa net.')
on conflict (id) do update set
  accommodation = excluded.accommodation, accommodation_en = excluded.accommodation_en,
  facilities = excluded.facilities, facilities_en = excluded.facilities_en,
  descr = excluded.descr, descr_en = excluded.descr_en,
  photos = excluded.photos, cover_img = excluded.cover_img, updated_at = now();

insert into ops_migrations (id) values ('0033-borgo-vescine') on conflict (id) do nothing;
