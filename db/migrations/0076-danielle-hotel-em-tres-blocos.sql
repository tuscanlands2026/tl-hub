-- =====================================================================
-- 0076 · DANIELLE (TL-055-26): O HOTEL EM TRÊS BLOCOS
--
-- Pedido dela, out/26: quando o hotel tem mais de uma opção de quarto, não
-- repetir a descrição do hotel em cada quarto. Primeiro o HOTEL (com uma
-- foto), depois cada TIPO DE QUARTO só com o que muda, duas fotos cada.
--
-- Antes: duas linhas ("Deluxe room" e "Prestige room"), cada uma repetindo
-- a descrição inteira do hotel, com 1 e 2 fotos (desigual).
--
-- Agora, três blocos na seção do hotel:
--   1 · "Palazzo Ripetta" — a descrição do hotel (da ficha), uma foto (o
--       rooftop Etere), a estrutura, e a linha de impostos/soggiorno.
--       SEM preço: é apresentação. (O index.html já não mostra € 0,00 numa
--       linha sem preço e sem unidades — ajuste do mesmo PR.)
--   2 · "Deluxe room" — só a descrição do quarto (24 sqm, 2 hóspedes), duas
--       fotos do site oficial, e os dois períodos com os valores que ela já
--       lançou (não toco no preço).
--   3 · "Prestige room" — idem (27–30 sqm, cama king, twins sob pedido),
--       duas fotos do site oficial.
--
-- Textos e metragem vêm do site oficial do Palazzo Ripetta (páginas de cada
-- categoria). As fotos são do site oficial e responderam 200 antes de entrar.
--
-- NÃO TOCA EM PREÇO: as unidades (períodos e valores) das duas linhas de
-- quarto ficam como estão. Miro por proposal_id + título; guardado: as
-- linhas de quarto só mudam se ainda tiverem a descrição do hotel (marca
-- "Five stars in the Tridente"), o bloco do hotel só entra se ainda não
-- existir. Rodar depois da 0074.
--
-- Seção 7: ops_proposal_items (insert do bloco do hotel; update das duas
-- linhas de quarto, sem tocar em units/price) e ops_migrations (insert).
-- Sem drop/truncate/delete. Nenhuma tabela do CRM.
-- =====================================================================

-- Proposta: f1d3d719-5142-43e7-9359-e2b7249a25d6
-- Ficha do hotel no catálogo: c0000000-0000-0000-0000-000000000002

-- ---------------------------------------------------------------------
-- 1 · O BLOCO DO HOTEL (descrição da ficha, uma foto, sem preço)
-- ---------------------------------------------------------------------
insert into ops_proposal_items
  (id, proposal_id, sort, catalog_id, section, kind, service_date,
   title, title_en, details, details_en, facilities, facilities_en,
   included_pt, included_en, website, photos, units, qty, unit_price,
   price, optional, extras, attachments, supplier)
select E'55260000-0000-0000-0000-000000000005', E'f1d3d719-5142-43e7-9359-e2b7249a25d6',
  0, c.id, E'stays', 'stay', null,
  E'Palazzo Ripetta', E'Palazzo Ripetta',
  null, c.descr_en, null, c.facilities_en,
  null, E'Taxes, flexible rate and breakfast included. Extras and the city tax (tassa di soggiorno) are paid at the hotel.',
  c.website,
  E'["https://euakl5xd.cdn.imgeng.in/assets/uploads/Dining/EtereRooftop/PalazzoRipetta2025-52.jpg"]'::jsonb,
  '[]'::jsonb, 1, null, 0, false, '[]'::jsonb, '[]'::jsonb, c.name
from ops_catalog c
where c.id = E'c0000000-0000-0000-0000-000000000002'
  and not exists (select 1 from ops_proposal_items x
                   where x.proposal_id = 'f1d3d719-5142-43e7-9359-e2b7249a25d6'
                     and (coalesce(x.title,'') = 'Palazzo Ripetta' or coalesce(x.title_en,'') = 'Palazzo Ripetta'))
on conflict (id) do nothing;

-- ---------------------------------------------------------------------
-- 2 · DELUXE — só o quarto (descrição própria, duas fotos). Preço intacto.
-- ---------------------------------------------------------------------
update ops_proposal_items set
  title = E'Deluxe room', title_en = E'Deluxe room', sort = 1,
  details_en = E'24 sqm / 258 sqft · up to 2 guests.\nThe hotel''s opening category and a sleek snapshot of Palazzo Ripetta''s style — from the moment you step in, quiet luxury meets a contemporary spirit.',
  facilities_en = null, included_en = null,
  photos = E'["https://euakl5xd.cdn.imgeng.in/assets/uploads/Camere&Suites/Deluxe/Deluxe_Room_15.jpg", "https://euakl5xd.cdn.imgeng.in/assets/uploads/Camere&Suites/Deluxe/Deluxe_Room_4.jpg"]'::jsonb
 where proposal_id = 'f1d3d719-5142-43e7-9359-e2b7249a25d6'
   and 'Palazzo Ripetta · Deluxe room' in (coalesce(title,''), coalesce(title_en,''))
   and coalesce(details_en,'') like '%Five stars in the Tridente%';

-- ---------------------------------------------------------------------
-- 3 · PRESTIGE — só o quarto. Preço intacto.
-- ---------------------------------------------------------------------
update ops_proposal_items set
  title = E'Prestige room', title_en = E'Prestige room', sort = 2,
  details_en = E'27–30 sqm / 291–323 sqft · up to 2 guests · king bed (twins on request).\nUnswerving style for the global traveller — Italian creativity from Venetian glass chandeliers to satin-smooth linens, with light through the tall 18th-century windows.',
  facilities_en = null, included_en = null,
  photos = E'["https://euakl5xd.cdn.imgeng.in/assets/uploads/Camere&Suites/Prestige%20Room/304-prestige-room.jpeg", "https://euakl5xd.cdn.imgeng.in/assets/uploads/Camere&Suites/Prestige%20Room/prestige-2-302.jpeg"]'::jsonb
 where proposal_id = 'f1d3d719-5142-43e7-9359-e2b7249a25d6'
   and 'Palazzo Ripetta · Prestige room' in (coalesce(title,''), coalesce(title_en,''))
   and coalesce(details_en,'') like '%Five stars in the Tridente%';

insert into ops_migrations (id) values ('0076-danielle-hotel-em-tres-blocos') on conflict (id) do nothing;
