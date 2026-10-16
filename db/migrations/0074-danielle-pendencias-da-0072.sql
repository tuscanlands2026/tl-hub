-- =====================================================================
-- 0074 · DANIELLE (TL-055-26): O QUE FICOU PENDENTE, E O CONSERTO DO
--        NOME DAS SEÇÕES
--
-- Conferido pelo link no ar (out/26): rodaram a 0070, a 0071 e a 0073. A
-- 0072 NÃO rodou — faltam a foto do Deluxe, o vídeo do barco, a troca da
-- foto do Frascati e a descrição mais rica do Frascati.
--
-- POR QUE NÃO BASTA RODAR A 0072 AGORA: a 0073 já lançou o preço nas duas
-- opções do Frascati, e o update de descrição da 0072 vinha amarrado às
-- unidades (guard "nenhuma unidade com preço") — ia ser pulado. Esta
-- migração refaz os efeitos da 0072 DESACOPLADOS do preço, para o estado
-- atual. **A 0072 fica marcada como NÃO RODAR** (substituída por esta).
--
-- E CONSERTA UM BUG MEU: o nome das seções não trocou porque o guard
-- procurava em `title`, e a proposta guarda o título em `title_en`. Aqui
-- o guard olha os dois, e escreve nos dois.
--
-- Miro por proposal_id + TÍTULO (id de linha não é estável — 0067). Tudo
-- guardado: a descrição do Frascati só muda se ainda for a original (0070);
-- a foto do Frascati só troca se ainda tiver a foto da cooking; foto do
-- Deluxe e vídeo do barco só entram onde o campo está vazio; o nome da
-- seção só muda se ainda for o rótulo do hub. Não toca em preço nenhum.
--
-- Seção 7: ops_proposal_items (update guardado), ops_proposals (update
-- guardado em seções), ops_catalog (update guardado), ops_migrations
-- (insert). Sem drop/truncate/delete. Nenhuma tabela do CRM.
-- =====================================================================

-- Proposta: f1d3d719-5142-43e7-9359-e2b7249a25d6

-- ---------------------------------------------------------------------
-- 1 · FRASCATI · descrição mais rica (desacoplada do preço) + troca a foto
-- Não toca nas unidades: a 0073 já pôs os preços (1999 / 1560).
-- ---------------------------------------------------------------------
update ops_proposal_items set
  details_en = E'The day begins at your hotel in Rome, where your private driver is waiting for the drive into the hills of the Castelli Romani — about an hour south, to the historic wine region of Frascati. Volcanic terroir, ancient estates and an intimate glimpse of rural Italian life, far from the city. Your driver stays with you throughout, for an unhurried return to Rome by mid-afternoon. You choose how to spend the day:',
  included_en = E'Private driver from your Rome hotel, at your disposal throughout (about 6 hours).\nSuggested start: 9:30 am (to be confirmed).'
 where proposal_id = 'f1d3d719-5142-43e7-9359-e2b7249a25d6'
   and 'Roman Countryside · Frascati Culinary Day' in (coalesce(title,''), coalesce(title_en,''))
   and coalesce(details_en,'') like '%A half day into the hills%';

update ops_proposal_items set
  photos = E'["https://i.postimg.cc/fTyMqBT4/Fontenille-Pieve-Aldina-octobre-2024-Yann-Deret-2693.jpg"]'::jsonb
 where proposal_id = 'f1d3d719-5142-43e7-9359-e2b7249a25d6'
   and 'Roman Countryside · Frascati Culinary Day' in (coalesce(title,''), coalesce(title_en,''))
   and photos @> '["https://i.postimg.cc/Y2Q6jGQQ/1-570x572-cooking-class-experience-farm-lucca.jpg"]'::jsonb;

-- ---------------------------------------------------------------------
-- 2 · BARCO · link do vídeo (só se ainda sem link)
-- ---------------------------------------------------------------------
update ops_proposal_items set
  website = E'https://youtube.com/shorts/DU_-fkN3VHU?si=NtEeY5A4mc-nRn7z'
 where proposal_id = 'f1d3d719-5142-43e7-9359-e2b7249a25d6'
   and 'Private Boat Experience on the Tiber' in (coalesce(title,''), coalesce(title_en,''))
   and coalesce(website,'') = '';

-- ---------------------------------------------------------------------
-- 3 · DELUXE · foto do quarto, do site oficial (só se sem foto)
-- ---------------------------------------------------------------------
update ops_proposal_items set
  photos = E'["https://euakl5xd.cdn.imgeng.in/assets/uploads/Camere&Suites/Deluxe/Deluxe_Room_15.jpg"]'::jsonb
 where proposal_id = 'f1d3d719-5142-43e7-9359-e2b7249a25d6'
   and 'Palazzo Ripetta · Deluxe room' in (coalesce(title,''), coalesce(title_en,''))
   and coalesce(jsonb_array_length(photos),0) = 0;

-- ---------------------------------------------------------------------
-- 4 · NOME DAS SEÇÕES (guard olha title E title_en; escreve nos dois)
-- ---------------------------------------------------------------------
update ops_proposals set sections = (
  select jsonb_agg(
           case
             when s->>'key' = 'stays'
                  and coalesce(nullif(s->>'title_en',''), s->>'title') = 'Selected Stays'
               then s || jsonb_build_object('title','Your Hotel in Rome','title_en','Your Hotel in Rome',
                                            'note','Palazzo Ripetta — your base for every night in the city.',
                                            'note_en','Palazzo Ripetta — your base for every night in the city.')
             when s->>'key' = 'ground'
                  and coalesce(nullif(s->>'title_en',''), s->>'title') = 'Ground Services'
               then s || jsonb_build_object('title','Your Days in Rome','title_en','Your Days in Rome',
                                            'note','Your experiences and private services, day by day.',
                                            'note_en','Your experiences and private services, day by day.')
             else s
           end order by ord)
    from jsonb_array_elements(sections) with ordinality t(s, ord)),
  updated_at = now()
 where id = 'f1d3d719-5142-43e7-9359-e2b7249a25d6'
   and sections is not null and jsonb_array_length(sections) > 0;

-- ---------------------------------------------------------------------
-- 5 · CATÁLOGO (reúso): Frascati mais rico + foto, e o vídeo no barco
-- ---------------------------------------------------------------------
update ops_catalog set
  descr_en = E'The day begins at your hotel in Rome, where your private driver is waiting for the drive into the hills of the Castelli Romani — about an hour south, to the historic wine region of Frascati. Volcanic terroir, ancient estates and an intimate glimpse of rural Italian life, far from the city. Your driver stays with you throughout, for an unhurried return to Rome by mid-afternoon.',
  photos = E'["https://i.postimg.cc/fTyMqBT4/Fontenille-Pieve-Aldina-octobre-2024-Yann-Deret-2693.jpg", "https://i.postimg.cc/Y2Q6jGQQ/1-570x572-cooking-class-experience-farm-lucca.jpg"]'::jsonb,
  updated_at = now()
 where id = 'e7000000-0000-0000-0000-000000000003'
   and coalesce(descr_en,'') like '%A half day into the hills%';

update ops_catalog set
  website = E'https://youtube.com/shorts/DU_-fkN3VHU?si=NtEeY5A4mc-nRn7z',
  updated_at = now()
 where id = 'e7000000-0000-0000-0000-000000000005'
   and coalesce(website,'') = '';

insert into ops_migrations (id) values ('0074-danielle-pendencias-da-0072') on conflict (id) do nothing;
