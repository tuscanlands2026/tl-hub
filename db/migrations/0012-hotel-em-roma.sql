-- =====================================================================
-- 0012 · PALAZZO RIPETTA NO CATÁLOGO, E A SEGUNDA HOSPEDAGEM DA TL-045-26
--
-- Ela pediu o segundo hotel da proposta da Flavia: Palazzo Ripetta, em
-- Roma, com 1 quarto Prestige para 2 pessoas e 2 apartamentos Luxury
-- para 4 pessoas cada — as mesmas dez pessoas da villa na Toscana —,
-- tarifa flexível com café da manhã.
--
-- O site do hotel recusa acesso automatizado: devolve uma casca vazia
-- a qualquer requisição que não venha de um navegador de gente. A
-- descrição, a metragem e a estrutura vieram então da ficha do hotel no
-- Relais & Châteaux, de onde saíram também as fotos — que são do
-- quarto Prestige e do apartamento Luxury, e não de categoria qualquer.
-- O que NÃO veio de lugar nenhum é a DATA em Roma e o VALOR: ela não
-- mandou, e não se inventa nem uma nem outra numa proposta com preço.
-- Ficam em branco e em zero, para ela preencher.
--
-- A linha entra como opcional: em Roma existe uma sugestão só, e o
-- cliente pode não querer Roma. Se ela decidir que Roma é parte fechada
-- da viagem, é só desmarcar "opcional" no editor.
--
-- Só toca em objetos ops_. Nada fora desse prefixo.
-- =====================================================================

-- ------------------------------------------------------ 1 · CATÁLOGO
insert into ops_catalog
  (id, kind, name, region, website, accommodation, accommodation_en,
   facilities, facilities_en, descr, descr_en, photos, internal_notes)
values ('c0000000-0000-0000-0000-000000000002', 'stay',
  'Palazzo Ripetta', 'Roma · Tridente',
  'https://www.palazzoripetta.com/it/',
  E'Quarto Prestige · 30 m² · 2 pessoas · cama king (twin sob pedido)\nApartamento Luxury · 67 m² · até 4 pessoas · quarto principal, sala com mezanino, cozinha americana',
  E'Prestige room · 30 sqm · 2 guests · king bed (twins on request)\nLuxury Apartment · 67 sqm · up to 4 guests · master bedroom, living room with mezzanine, kitchenette',
  E'Restaurante San Baylon · Baylon Cocktail Bar · rooftop Etere · pátio interno com fonte · suítes wellness com sauna e banho turco · salas de reunião · estacionamento pago · aceita pets',
  E'San Baylon restaurant · Baylon Cocktail Bar · Etere rooftop · inner courtyard with fountain · wellness suites with sauna and Turkish bath · meeting rooms · paid parking · pet friendly',
  E'Cinco estrelas no Tridente, entre a Piazza del Popolo e a Piazza di Spagna, a poucos passos do Ara Pacis. O edifício é do século XVII e foi orfanato por mais de quatro séculos; é hotel na mesma família desde os anos 1960.\nO restauro manteve os detalhes históricos: o pátio interno, onde um sarcófago romano virou fonte, e as obras de arte distribuídas pelas áreas comuns, entre elas peças de Arnaldo Pomodoro. São 78 quartos e suítes, de 24 a 125 m².\nO quarto Prestige tem 30 m² e cama king. O apartamento Luxury tem 67 m², quarto principal, duas áreas de estar, cozinha americana e um mezanino sobre a sala. No térreo, o restaurante San Baylon; no alto, o rooftop Etere.\nMembro Relais & Châteaux.',
  E'Five stars in the Tridente, between Piazza del Popolo and Piazza di Spagna, steps from the Ara Pacis. The building is 17th-century and served as an orphanage for more than four centuries; it has been a hotel in the same family since the 1960s.\nThe restoration kept the historic detail: the inner courtyard, where a Roman sarcophagus became a fountain, and the artworks through the public rooms, among them pieces by Arnaldo Pomodoro. There are 78 rooms and suites, from 24 to 125 sqm.\nThe Prestige room is 30 sqm with a king bed. The Luxury Apartment is 67 sqm, with a master bedroom, two living areas, a kitchenette and a mezzanine above the living room. On the ground floor, the San Baylon restaurant; at the top, the Etere rooftop.\nRelais & Châteaux member.',
  '["https://storage.googleapis.com/webimages-p1nishrd/hotel/45130/images/room/luxuryapartment0001.jpg", "https://storage.googleapis.com/webimages-p1nishrd/hotel/45130/images/room/luxuryapartment0002.jpg", "https://storage.googleapis.com/webimages-p1nishrd/hotel/45130/images/room/prestigeroom00001.jpg", "https://storage.googleapis.com/webimages-p1nishrd/hotel/45130/images/room/prestigeroom00002.jpg", "https://storage.googleapis.com/webimages-p1nishrd/hotel/45130/images/room/luxurapp001.jpg"]'::jsonb,
  E'Fotos hospedadas no Relais & Châteaux, não no site do hotel — o site bloqueia leitura automatizada. Se alguma sumir, trocar pela que ela mandar.')
on conflict (id) do update set
  accommodation = excluded.accommodation, accommodation_en = excluded.accommodation_en,
  facilities = excluded.facilities, facilities_en = excluded.facilities_en,
  descr = excluded.descr, descr_en = excluded.descr_en,
  photos = excluded.photos, updated_at = now();


-- ------------------------------- 2 · A SEÇÃO DE ROMA NA PROPOSTA TL-045-26
-- Com dois hotéis, "Hospedagem" sozinha não diz mais qual. Só renomeia
-- se o título ainda for o que foi semeado: se ela já escreveu o dela,
-- o dela fica.
update ops_proposals
   set sections = (
     select jsonb_agg(
       case when s->>'key' = 'stays' and s->>'title' = 'Hospedagem'
            then s || jsonb_build_object('title','Hospedagem na Toscana',
                                         'title_en','Where you stay in Tuscany')
            else s end order by ord)
     from jsonb_array_elements(sections) with ordinality as t(s, ord)),
       updated_at = now()
 where id = '9126ac00-0000-0000-0000-0000000000a1'
   and sections @> '[{"key":"stays"}]'::jsonb;

-- A seção de Roma entra no fim; a ordem ela ajusta no menu do editor.
update ops_proposals
   set sections = sections || jsonb_build_array(jsonb_build_object(
         'key','rome',
         'title','Hospedagem em Roma',
         'title_en','Where you stay in Rome',
         'note','Uma sugestão em Roma, para as mesmas dez pessoas.',
         'note_en','One suggestion in Rome, for the same ten guests.',
         'photo','https://storage.googleapis.com/webimages-p1nishrd/hotel/45130/images/room/luxuryapartment0001.jpg')),
       updated_at = now()
 where id = '9126ac00-0000-0000-0000-0000000000a1'
   and not sections @> '[{"key":"rome"}]'::jsonb;


-- ------------------------------------------- 3 · A LINHA, COPIADA DO CATÁLOGO
-- Nome, site, estrutura, descrição e fotos vêm do catálogo. O tipo de
-- quarto é o desta venda, escrito aqui: o catálogo descreve as
-- categorias do hotel, a linha diz quantas unidades desta proposta.
insert into ops_proposal_items
  (proposal_id, sort, catalog_id, service_date, title, title_en,
   details, details_en, room_type, room_type_en, facilities, facilities_en,
   included_pt, included_en, website, photos, price, optional, section, supplier)
select '9126ac00-0000-0000-0000-0000000000a1', 1, c.id,
  null,                                  -- data em Roma: ela preenche
  c.name, c.name,
  c.descr, c.descr_en,
  E'1 quarto Prestige · 2 pessoas\n2 apartamentos Luxury · 4 pessoas cada',
  E'1 Prestige room · 2 guests\n2 Luxury Apartments · 4 guests each',
  c.facilities, c.facilities_en,
  'Café da manhã · tarifa flexível',
  'Breakfast · flexible rate',
  c.website, c.photos,
  0,                                     -- valor: ela preenche
  true, 'rome', 'Palazzo Ripetta'
from ops_catalog c
where c.id = 'c0000000-0000-0000-0000-000000000002'
  and exists (select 1 from ops_proposals p where p.id = '9126ac00-0000-0000-0000-0000000000a1')
  and not exists (select 1 from ops_proposal_items i
                   where i.proposal_id = '9126ac00-0000-0000-0000-0000000000a1'
                     and i.catalog_id  = 'c0000000-0000-0000-0000-000000000002');

insert into ops_migrations (id) values ('0012-hotel-em-roma') on conflict (id) do nothing;
