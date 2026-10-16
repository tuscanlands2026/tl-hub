-- =====================================================================
-- 0071 · DANIELLE (TL-055-26): FOTOS, HOTEL POR TIPO DE QUARTO E AJUSTES
--
-- Depois de ver a proposta montada (0070, já aplicada), ela pediu, out/26:
--
--   A · FOTOS em cada dia e guardadas no catálogo (reutilizáveis). As que
--       ela mandou, conferidas (todas abriram 200/imagem):
--         food tour, Colosseum, Frascati (duas: cooking + wine),
--         passeio de barco (duas), transfer (uma, serve os quatro),
--         meet & greet (uma, serve chegada e saída).
--       A experiência de SHOPPING ficou SEM foto: ela ainda não mandou, e
--       foto não se inventa. Entra quando ela mandar.
--
--   B · HOTEL POR TIPO DE QUARTO (não mais por período). Dois blocos —
--       Deluxe e Prestige —, cada um com a SUA foto, e dentro de cada um
--       os dois períodos (7–10 e 14–15 de maio) como valor separado, para
--       ela lançar os quatro preços. O Prestige leva as fotos de quarto
--       Prestige da ficha; o Deluxe fica SEM foto até ela mandar a do
--       Deluxe (a ficha só tem Prestige e o apartamento).
--
--   C · JANTARES DO CONCIERGE: FORA. Instrução dela: "nem cita, tira". A
--       menção ao jantar continua no texto da Curadoria (é parte do dia),
--       mas sai a linha de serviço dos dois jantares.
--
--   D · A FRASE FINAL DA CURADORIA SAI: o "For a future return… vintage
--       car / Ferrari / Vatican behind closed doors". O resto fica.
--
--   E · NOMES DAS SEÇÕES: "Your Hotel in Rome" e "Your Days in Rome".
--
-- O VÍDEO DO BARCO (youtube shorts) fica GUARDADO no catálogo
-- (internal_notes), não na página do cliente: no modo "dia a dia" o card
-- não mostra link, e link cru de shorts destoa da peça.
--
-- COMO AS LINHAS SÃO MIRADAS: por `proposal_id` + TÍTULO, nunca por id.
-- Salvar a proposta no editor apaga e recria todas as linhas com id novo
-- (regra da 0067), então id não é estável; o título é o que ela vê e o
-- que sobrevive ao save. Confere nos dois campos (title e title_en),
-- porque o editor escreve no `title`.
--
-- ESTE ARQUIVO MEXE EM LINHA QUE JÁ EXISTE — confira e rode você. Tudo é
-- GUARDADO contra o que ela já mexeu:
--   · o hotel só é refeito se os dois períodos antigos ainda estiverem com
--     TODOS os valores zerados (conferido no banco: estão). Lançou preço,
--     o delete não roda, e os blocos novos também não entram (guard), para
--     o hotel não duplicar;
--   · cada foto só entra onde o item ainda está SEM foto;
--   · a frase da curadoria só sai se ainda estiver lá;
--   · o nome da seção só muda se ainda for o rótulo do hub.
-- Nenhuma informação dela é sobrescrita.
--
-- CONFERÊNCIA DA SEÇÃO 7: toca ops_catalog (update de photos das
-- experiências, por id — id de catálogo é estável), ops_proposal_items
-- (update de photos e delete por proposal_id+título, condicionados; insert
-- dos dois blocos novos de quarto), ops_proposals (update guardado em
-- seções e curadoria, por id — id de proposta é estável), ops_migrations
-- (insert). Sem drop/alter/truncate. Nenhuma tabela do CRM. Nenhuma
-- service_role key.
-- =====================================================================

-- Proposta: f1d3d719-5142-43e7-9359-e2b7249a25d6

-- ---------------------------------------------------------------------
-- A1 · FOTOS GUARDADAS NO CATÁLOGO (reutilizáveis; catálogo é id estável)
-- ---------------------------------------------------------------------
update ops_catalog set photos = E'["https://i.postimg.cc/h4pVH0t2/Food-Tour-Florence.png"]'::jsonb, updated_at = now()
 where id = 'e7000000-0000-0000-0000-000000000001' and coalesce(jsonb_array_length(photos),0) = 0;

update ops_catalog set photos = E'["https://i.postimg.cc/dt3JN4QH/Geral-Coliseu-underground.png"]'::jsonb, updated_at = now()
 where id = 'e7000000-0000-0000-0000-000000000002' and coalesce(jsonb_array_length(photos),0) = 0;

update ops_catalog set photos = E'["https://i.postimg.cc/Y2Q6jGQQ/1-570x572-cooking-class-experience-farm-lucca.jpg", "https://i.postimg.cc/fTyMqBT4/Fontenille-Pieve-Aldina-octobre-2024-Yann-Deret-2693.jpg"]'::jsonb, updated_at = now()
 where id = 'e7000000-0000-0000-0000-000000000003' and coalesce(jsonb_array_length(photos),0) = 0;

update ops_catalog set photos = E'["https://i.postimg.cc/qMqpDjBj/GFL0681-Modifica.jpg", "https://i.postimg.cc/28yC92jw/image.png"]'::jsonb, updated_at = now()
 where id = 'e7000000-0000-0000-0000-000000000005' and coalesce(jsonb_array_length(photos),0) = 0;

-- ---------------------------------------------------------------------
-- A2 · FOTOS EM CADA DIA DA PROPOSTA (por título; só onde ainda sem foto)
-- ---------------------------------------------------------------------
update ops_proposal_items set photos = E'["https://i.postimg.cc/h4pVH0t2/Food-Tour-Florence.png"]'::jsonb
 where proposal_id = 'f1d3d719-5142-43e7-9359-e2b7249a25d6'
   and 'Private Rome Food Tour' in (coalesce(title,''), coalesce(title_en,''))
   and coalesce(jsonb_array_length(photos),0) = 0;

update ops_proposal_items set photos = E'["https://i.postimg.cc/dt3JN4QH/Geral-Coliseu-underground.png"]'::jsonb
 where proposal_id = 'f1d3d719-5142-43e7-9359-e2b7249a25d6'
   and 'Private Colosseum and Roman Forum Tour with Arena' in (coalesce(title,''), coalesce(title_en,''))
   and coalesce(jsonb_array_length(photos),0) = 0;

update ops_proposal_items set photos = E'["https://i.postimg.cc/Y2Q6jGQQ/1-570x572-cooking-class-experience-farm-lucca.jpg", "https://i.postimg.cc/fTyMqBT4/Fontenille-Pieve-Aldina-octobre-2024-Yann-Deret-2693.jpg"]'::jsonb
 where proposal_id = 'f1d3d719-5142-43e7-9359-e2b7249a25d6'
   and 'Roman Countryside · Frascati Culinary Day' in (coalesce(title,''), coalesce(title_en,''))
   and coalesce(jsonb_array_length(photos),0) = 0;

update ops_proposal_items set photos = E'["https://i.postimg.cc/qMqpDjBj/GFL0681-Modifica.jpg", "https://i.postimg.cc/28yC92jw/image.png"]'::jsonb
 where proposal_id = 'f1d3d719-5142-43e7-9359-e2b7249a25d6'
   and 'Private Boat Experience on the Tiber' in (coalesce(title,''), coalesce(title_en,''))
   and coalesce(jsonb_array_length(photos),0) = 0;

-- Transfers (os quatro, a mesma foto)
update ops_proposal_items set photos = E'["https://i.postimg.cc/X7Kk7y3z/4-(1).png"]'::jsonb
 where proposal_id = 'f1d3d719-5142-43e7-9359-e2b7249a25d6'
   and (coalesce(title,'') in (
         'Private arrival transfer · Fiumicino → Palazzo Ripetta',
         'Private transfer · Palazzo Ripetta → train station',
         'Private transfer · train station → Palazzo Ripetta',
         'Private departure transfer · Palazzo Ripetta → Fiumicino')
     or coalesce(title_en,'') in (
         'Private arrival transfer · Fiumicino → Palazzo Ripetta',
         'Private transfer · Palazzo Ripetta → train station',
         'Private transfer · train station → Palazzo Ripetta',
         'Private departure transfer · Palazzo Ripetta → Fiumicino'))
   and coalesce(jsonb_array_length(photos),0) = 0;

-- VIP (chegada e saída, a mesma foto)
update ops_proposal_items set photos = E'["https://i.postimg.cc/Dz3hQDRg/Allways-Global-1067-Female-Meet-Greet-with-Porter-Service.jpg"]'::jsonb
 where proposal_id = 'f1d3d719-5142-43e7-9359-e2b7249a25d6'
   and (coalesce(title,'') in ('VIP meet & greet · Fiumicino (arrival)','VIP assistance · Fiumicino (departure)')
     or coalesce(title_en,'') in ('VIP meet & greet · Fiumicino (arrival)','VIP assistance · Fiumicino (departure)'))
   and coalesce(jsonb_array_length(photos),0) = 0;

-- ---------------------------------------------------------------------
-- C · OS DOIS JANTARES DO CONCIERGE SAEM (por título; só se sem preço)
-- ---------------------------------------------------------------------
delete from ops_proposal_items
 where proposal_id = 'f1d3d719-5142-43e7-9359-e2b7249a25d6'
   and (coalesce(title,'') in ('Anniversary dinner · arranged by our concierge','Farewell dinner · arranged by our concierge')
     or coalesce(title_en,'') in ('Anniversary dinner · arranged by our concierge','Farewell dinner · arranged by our concierge'))
   and coalesce(price,0) = 0;

-- ---------------------------------------------------------------------
-- B1 · SAEM OS DOIS PERÍODOS ANTIGOS DO HOTEL (título = 'Palazzo Ripetta')
-- Só se continuarem com tudo zerado (nenhum preço, nenhuma unidade com valor).
-- ---------------------------------------------------------------------
delete from ops_proposal_items i
 where i.proposal_id = 'f1d3d719-5142-43e7-9359-e2b7249a25d6'
   and (coalesce(i.title,'') = 'Palazzo Ripetta' or coalesce(i.title_en,'') = 'Palazzo Ripetta')
   and coalesce(i.price,0) = 0
   and not exists (
     select 1 from jsonb_array_elements(coalesce(i.units,'[]'::jsonb)) u
      where coalesce((u->>'price')::numeric,0) <> 0);

-- ---------------------------------------------------------------------
-- B2 · ENTRAM OS DOIS BLOCOS POR TIPO DE QUARTO
-- Só entram se os períodos antigos tiverem saído (guard pelo título
-- 'Palazzo Ripetta'), para o hotel não duplicar. Texto/descr vêm da ficha
-- (0012); foto e unidades (os dois períodos) são desta venda.
-- ---------------------------------------------------------------------
insert into ops_proposal_items
  (id, proposal_id, sort, catalog_id, section, kind, service_date,
   title, title_en, details, details_en, facilities, facilities_en,
   included_pt, included_en, website, photos, units, qty, unit_price,
   price, optional, extras, attachments, supplier)
select E'55260000-0000-0000-0000-000000000003', E'f1d3d719-5142-43e7-9359-e2b7249a25d6',
  0, c.id, E'stays', 'stay', null,
  E'Palazzo Ripetta · Deluxe room', E'Palazzo Ripetta · Deluxe room',
  null, c.descr_en, null, c.facilities_en,
  null, E'Breakfast · flexible rate',
  c.website,
  '[]'::jsonb,   -- foto do Deluxe: ela manda (a ficha só tem Prestige)
  E'[{"key":"p1","label":"May 7 to 10, 2027 · 3 nights","label_en":"May 7 to 10, 2027 · 3 nights","price":0,"optional":false},{"key":"p2","label":"May 14 to 15, 2027 · 1 night","label_en":"May 14 to 15, 2027 · 1 night","price":0,"optional":false}]'::jsonb,
  1, null, 0, true, '[]'::jsonb, '[]'::jsonb, c.name
from ops_catalog c
where c.id = E'c0000000-0000-0000-0000-000000000002'
  and not exists (select 1 from ops_proposal_items x
                   where x.proposal_id = 'f1d3d719-5142-43e7-9359-e2b7249a25d6'
                     and (coalesce(x.title,'') = 'Palazzo Ripetta' or coalesce(x.title_en,'') = 'Palazzo Ripetta'))
  and not exists (select 1 from ops_proposal_items x
                   where x.proposal_id = 'f1d3d719-5142-43e7-9359-e2b7249a25d6'
                     and (coalesce(x.title,'') = 'Palazzo Ripetta · Deluxe room' or coalesce(x.title_en,'') = 'Palazzo Ripetta · Deluxe room'));

insert into ops_proposal_items
  (id, proposal_id, sort, catalog_id, section, kind, service_date,
   title, title_en, details, details_en, facilities, facilities_en,
   included_pt, included_en, website, photos, units, qty, unit_price,
   price, optional, extras, attachments, supplier)
select E'55260000-0000-0000-0000-000000000004', E'f1d3d719-5142-43e7-9359-e2b7249a25d6',
  1, c.id, E'stays', 'stay', null,
  E'Palazzo Ripetta · Prestige room', E'Palazzo Ripetta · Prestige room',
  null, c.descr_en, null, c.facilities_en,
  null, E'Breakfast · flexible rate',
  c.website,
  E'["https://storage.googleapis.com/webimages-p1nishrd/hotel/45130/images/room/prestigeroom00001.jpg", "https://storage.googleapis.com/webimages-p1nishrd/hotel/45130/images/room/prestigeroom00002.jpg"]'::jsonb,
  E'[{"key":"p1","label":"May 7 to 10, 2027 · 3 nights","label_en":"May 7 to 10, 2027 · 3 nights","price":0,"optional":false},{"key":"p2","label":"May 14 to 15, 2027 · 1 night","label_en":"May 14 to 15, 2027 · 1 night","price":0,"optional":false}]'::jsonb,
  1, null, 0, true, '[]'::jsonb, '[]'::jsonb, c.name
from ops_catalog c
where c.id = E'c0000000-0000-0000-0000-000000000002'
  and not exists (select 1 from ops_proposal_items x
                   where x.proposal_id = 'f1d3d719-5142-43e7-9359-e2b7249a25d6'
                     and (coalesce(x.title,'') = 'Palazzo Ripetta' or coalesce(x.title_en,'') = 'Palazzo Ripetta'))
  and not exists (select 1 from ops_proposal_items x
                   where x.proposal_id = 'f1d3d719-5142-43e7-9359-e2b7249a25d6'
                     and (coalesce(x.title,'') = 'Palazzo Ripetta · Prestige room' or coalesce(x.title_en,'') = 'Palazzo Ripetta · Prestige room'));

-- ---------------------------------------------------------------------
-- E · NOMES DAS SEÇÕES (proposta é id estável; só muda rótulo do hub)
-- ---------------------------------------------------------------------
update ops_proposals set sections = (
  select jsonb_agg(
           case
             when s->>'key' = 'stays' and s->>'title' = 'Selected Stays'
               then s || jsonb_build_object('title','Your Hotel in Rome',
                                            'note','Palazzo Ripetta — your base for every night in the city.')
             when s->>'key' = 'ground' and s->>'title' = 'Ground Services'
               then (s || '{"modo":"dias"}'::jsonb) || jsonb_build_object(
                      'title','Your Days in Rome',
                      'note','Your experiences and private services, day by day.')
             else s
           end order by ord)
    from jsonb_array_elements(sections) with ordinality t(s, ord)),
  updated_at = now()
 where id = 'f1d3d719-5142-43e7-9359-e2b7249a25d6'
   and sections is not null and jsonb_array_length(sections) > 0;

-- ---------------------------------------------------------------------
-- D · SAI A FRASE FINAL DA CURADORIA (só se ainda estiver lá; preserva o resto)
-- ---------------------------------------------------------------------
update ops_proposals set
  curations = jsonb_set(curations, '{0,dias_en}',
    to_jsonb(replace(
      curations->0->>'dias_en',
      E'\nFor a future return, there is a lot more we would love to share: a drive through the countryside near Rome in a vintage car or a Ferrari, or the Vatican behind closed doors.',
      ''))),
  updated_at = now()
 where id = 'f1d3d719-5142-43e7-9359-e2b7249a25d6'
   and coalesce(jsonb_array_length(curations),0) > 0
   and (curations->0->>'dias_en') like '%For a future return%';

insert into ops_migrations (id) values ('0071-danielle-fotos-hotel-e-ajustes') on conflict (id) do nothing;
