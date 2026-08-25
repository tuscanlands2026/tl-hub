-- =====================================================================
-- CATÁLOGO · Villa Ghirlandaio
--
-- Primeiro registro do catálogo, montado a partir do site da
-- propriedade e da planimetria que ela mandou. A metragem, a contagem
-- de quartos e banheiros vêm da planimetria — o site não traz número,
-- e número inventado numa proposta de villa a 12 mil euros é o tipo de
-- erro que custa a venda.
--
-- A planimetria está por link vazio de propósito: o arquivo é dela e
-- entra quando o Storage estiver ligado. Enquanto isso, ela cola o
-- endereço do PDF onde estiver hospedado.
-- =====================================================================

insert into ops_catalog
  (id, kind, name, region, website, accommodation, accommodation_en,
   facilities, facilities_en, descr, descr_en, photos, internal_notes)
values ('c0000000-0000-0000-0000-000000000001', 'stay',
  'Villa Ghirlandaio', 'Toscana · arredores de Florença',
  'https://dimoraghirlandaio.it/en/accommodations/villa-ghirlandaio/',
  E'Villa inteira · 288 m² · 5 quartos · 5 banheiros e 1 lavabo · 2 salas de estar · sala de jantar · cozinha', E'Entire villa · 288 sqm · 5 bedrooms · 5 bathrooms and 1 half-bath · 2 living rooms · dining room · kitchen', E'Piscina · jardim all''italiana · terraço com vista para Florença · estacionamento na propriedade · a villa é a construção principal da Dimora Ghirlandaio, que reúne seis villas', E'Pool · Italian garden · terrace overlooking Florence · parking on the estate · the villa is the main building of Dimora Ghirlandaio, an estate of six villas', E'Villa renascentista no coração da propriedade Dimora Ghirlandaio, na campanha toscana a poucos minutos de Florença. A fachada em pietra serena, a escadaria dupla que desce para o jardim all''italiana e a vista aberta sobre a cidade — da Certosa à cúpula de Brunelleschi — são o que distingue a casa.\nNo térreo, salão com lareira e teto de caixotões, sala de jantar, cozinha equipada com ilha e um quarto king. No andar superior, três quartos duplos, cada um com banheiro privativo em mármore. No terceiro nível, o antigo pombal, hoje o quarto mais exclusivo da villa, com vista panorâmica.\nRestauro que preservou a aparência original. A poucos minutos de Florença e a distância de carro de Pisa, Lucca, Siena e Arezzo.', E'Renaissance villa at the heart of the Dimora Ghirlandaio estate, in the Tuscan countryside minutes from Florence. The pietra serena façade, the double staircase down to the Italian garden and the open view over the city — from the Certosa to Brunelleschi''s dome — are what set the house apart.\nOn the ground floor, a hall with fireplace and coffered ceiling, dining room, fully equipped kitchen with island, and one king bedroom. On the top floor, three double bedrooms, each with a private marble bathroom. On the third level, the former dovecote, now the villa''s most exclusive room, with panoramic views.\nRestored preserving its original appearance. Minutes from Florence and a drive from Pisa, Lucca, Siena and Arezzo.',
  '["https://dimoraghirlandaio.it/wp-content/uploads/2023/08/dimora_ghirlandaio-main_villa_cover.jpg", "https://dimoraghirlandaio.it/wp-content/uploads/2023/08/dimora_ghirlandaio-Main_Living_Room_Main_Villa_3.jpg", "https://dimoraghirlandaio.it/wp-content/uploads/2023/08/dimora_ghirlandaio-Dining_Room_Main_Villa.jpg", "https://dimoraghirlandaio.it/wp-content/uploads/2024/07/DG_Aerial_Villas-overview.jpg", "https://dimoraghirlandaio.it/wp-content/uploads/2023/08/dimora_ghirlandaio-_Ridolfo_Room_Main_Villa.jpg"]'::jsonb,
  'Dimora Ghirlandaio · seis villas na propriedade. Conferir disponibilidade da villa principal.')
on conflict (id) do update set
  accommodation = excluded.accommodation, facilities = excluded.facilities,
  descr = excluded.descr, photos = excluded.photos, updated_at = now();
