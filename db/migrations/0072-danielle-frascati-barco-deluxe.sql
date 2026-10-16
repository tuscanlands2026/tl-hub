-- =====================================================================
-- 0072 · DANIELLE (TL-055-26): FRASCATI COM DUAS OPÇÕES, VÍDEO DO BARCO,
--        FOTO DO DELUXE
--
-- Pedidos dela, out/26, vendo o preview do dia a dia:
--
--   1 · FRASCATI — descrição mais rica (é experiência cara) e DUAS OPÇÕES
--       de preço, que ela vai cotar: (a) com cooking class — motorista,
--       aula prática, visita à vinícola, degustação e almoço; (b) sem a
--       cooking — motorista, visita, degustação e almoço. Sempre com
--       motorista privado saindo do hotel em Roma. A foto troca para a do
--       vinhedo (sai a segunda fotinha da cooking).
--
--   2 · BARCO — entra o link do vídeo que ela mandou (YouTube). No card do
--       dia ele sai como "Watch a short film".
--
--   3 · DELUXE — a foto do quarto Deluxe, do site oficial do Palazzo
--       Ripetta (palazzoripetta.com), que é de onde ela disse que vem.
--
-- As opções de Frascati entram como UNIDADES da linha (como as categorias
-- do hotel), cada uma com o preço em branco para ela lançar as duas.
--
-- O catálogo também é enriquecido (descrição do Frascati e vídeo do
-- barco), para a próxima proposta já nascer assim.
--
-- Miro por proposal_id + TÍTULO (id de linha não é estável — 0067). Tudo
-- guardado: a descrição só muda se ainda for a minha (contém "Castelli
-- Romani"); a foto do Frascati só troca se ainda for a que a 0071 pôs; o
-- vídeo e a foto do Deluxe só entram onde o campo está vazio. Nada que ela
-- tenha digitado é sobrescrito.
--
-- CONFERÊNCIA DA SEÇÃO 7: toca ops_proposal_items (update, guardado) e
-- ops_catalog (update, guardado) e ops_migrations (insert). Sem
-- drop/alter/truncate/delete. Nenhuma tabela do CRM. Nenhuma service_role.
-- Rodar DEPOIS da 0070 e da 0071.
-- =====================================================================

-- Proposta: f1d3d719-5142-43e7-9359-e2b7249a25d6
-- Frascati (catálogo e7…003), Barco (catálogo e7…005)

-- ---------------------------------------------------------------------
-- 1 · FRASCATI · descrição rica + duas opções + foto do vinhedo
-- ---------------------------------------------------------------------
update ops_proposal_items set
  details_en = E'The day begins at your hotel in Rome, where your private driver is waiting for the drive into the hills of the Castelli Romani — about an hour south, to the historic wine region of Frascati. Volcanic terroir, ancient estates and an intimate glimpse of rural Italian life, far from the city. Your driver stays with you throughout, for an unhurried return to Rome by mid-afternoon. You choose how to spend the day:',
  included_en = E'Private driver from your Rome hotel, at your disposal throughout (about 6 hours).\nSuggested start: 9:30 am (to be confirmed).',
  units = E'[{"key":"o1","label":"With a private cooking class · private driver, a hands-on cooking class, a winery visit, a guided tasting and lunch","label_en":"With a private cooking class · private driver, a hands-on cooking class, a winery visit, a guided tasting and lunch","price":0,"optional":false},{"key":"o2","label":"Visit and tasting · private driver, a winery visit, a guided tasting and a regional lunch","label_en":"Visit and tasting · private driver, a winery visit, a guided tasting and a regional lunch","price":0,"optional":false}]'::jsonb
 where proposal_id = 'f1d3d719-5142-43e7-9359-e2b7249a25d6'
   and 'Roman Countryside · Frascati Culinary Day' in (coalesce(title,''), coalesce(title_en,''))
   and coalesce(details_en,'') like '%Castelli Romani%'
   and coalesce(jsonb_array_length(units),0) = 0;

update ops_proposal_items set
  photos = E'["https://i.postimg.cc/fTyMqBT4/Fontenille-Pieve-Aldina-octobre-2024-Yann-Deret-2693.jpg"]'::jsonb
 where proposal_id = 'f1d3d719-5142-43e7-9359-e2b7249a25d6'
   and 'Roman Countryside · Frascati Culinary Day' in (coalesce(title,''), coalesce(title_en,''))
   and (coalesce(jsonb_array_length(photos),0) = 0
        or photos @> '["https://i.postimg.cc/Y2Q6jGQQ/1-570x572-cooking-class-experience-farm-lucca.jpg"]'::jsonb);

-- ---------------------------------------------------------------------
-- 2 · BARCO · link do vídeo (só se ainda não tiver link)
-- ---------------------------------------------------------------------
update ops_proposal_items set
  website = E'https://youtube.com/shorts/DU_-fkN3VHU?si=NtEeY5A4mc-nRn7z'
 where proposal_id = 'f1d3d719-5142-43e7-9359-e2b7249a25d6'
   and 'Private Boat Experience on the Tiber' in (coalesce(title,''), coalesce(title_en,''))
   and coalesce(website,'') = '';

-- ---------------------------------------------------------------------
-- 3 · DELUXE · foto do quarto, do site oficial (só se o bloco está sem foto)
-- ---------------------------------------------------------------------
update ops_proposal_items set
  photos = E'["https://euakl5xd.cdn.imgeng.in/assets/uploads/Camere&Suites/Deluxe/Deluxe_Room_15.jpg"]'::jsonb
 where proposal_id = 'f1d3d719-5142-43e7-9359-e2b7249a25d6'
   and 'Palazzo Ripetta · Deluxe room' in (coalesce(title,''), coalesce(title_en,''))
   and coalesce(jsonb_array_length(photos),0) = 0;

-- ---------------------------------------------------------------------
-- 4 · CATÁLOGO (reutilizável): Frascati mais rico e o vídeo no barco
-- ---------------------------------------------------------------------
update ops_catalog set
  descr_en = E'The day begins at your hotel in Rome, where your private driver is waiting for the drive into the hills of the Castelli Romani — about an hour south, to the historic wine region of Frascati. Volcanic terroir, ancient estates and an intimate glimpse of rural Italian life, far from the city. Your driver stays with you throughout, for an unhurried return to Rome by mid-afternoon.',
  photos = E'["https://i.postimg.cc/fTyMqBT4/Fontenille-Pieve-Aldina-octobre-2024-Yann-Deret-2693.jpg", "https://i.postimg.cc/Y2Q6jGQQ/1-570x572-cooking-class-experience-farm-lucca.jpg"]'::jsonb,
  updated_at = now()
 where id = 'e7000000-0000-0000-0000-000000000003'
   and coalesce(descr_en,'') like '%Castelli Romani%';

update ops_catalog set
  website = E'https://youtube.com/shorts/DU_-fkN3VHU?si=NtEeY5A4mc-nRn7z',
  updated_at = now()
 where id = 'e7000000-0000-0000-0000-000000000005'
   and coalesce(website,'') = '';

insert into ops_migrations (id) values ('0072-danielle-frascati-barco-deluxe') on conflict (id) do nothing;
