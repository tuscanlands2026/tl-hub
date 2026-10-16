-- =====================================================================
-- 0080 · DANIELLE (TL-055-26): TRANSFER DE TERMINI E A ESCOLHA DO FRASCATI
--
-- Dois pedidos dela (out/26):
--
--   1 · Os transfers da ESTAÇÃO (Termini) sobem para 160 (eram 145). Os
--       do aeroporto (205) ficam.
--
--   2 · No dia do Frascati, o cliente escolhe UMA das duas: a com cooking
--       class OU a de visita + degustação. Hoje as duas entram como
--       unidades que SOMAM — ela viu que estava "escolhendo tudo". Vira
--       duas linhas num mesmo `choice_group`: no resumo, marcar uma
--       desmarca a outra (mecanismo que já existe no comissionado).
--
-- A linha atual do Frascati vira a OPÇÃO COM COOKING (1.999); entra uma
-- segunda linha, a de VISITA + DEGUSTAÇÃO (1.560). As duas no mesmo dia,
-- com a mesma foto, e no resumo saem como "Select the approved option".
--
-- Miro por proposal_id + título; guardado: o Frascati só é convertido se
-- ainda for a linha única de antes (choice_group nulo e com as unidades);
-- a segunda linha só entra se ainda não existir; o transfer só muda se
-- ainda estiver 145. Rodar depois da 0073.
--
-- Seção 7: ops_proposal_items (update e insert, guardados) e ops_migrations
-- (insert). Sem drop/truncate/delete. Nenhuma tabela do CRM.
-- =====================================================================

-- Proposta: f1d3d719-5142-43e7-9359-e2b7249a25d6

-- ---------------------------------------------------------------------
-- 1 · TRANSFERS DA ESTAÇÃO (Termini): 145 → 160
-- ---------------------------------------------------------------------
update ops_proposal_items set price = 160
 where proposal_id = 'f1d3d719-5142-43e7-9359-e2b7249a25d6'
   and (coalesce(title,'') in ('Private transfer · Palazzo Ripetta → train station','Private transfer · train station → Palazzo Ripetta')
     or coalesce(title_en,'') in ('Private transfer · Palazzo Ripetta → train station','Private transfer · train station → Palazzo Ripetta'))
   and coalesce(price,0) = 145;

-- ---------------------------------------------------------------------
-- 2 · FRASCATI · a linha única vira a OPÇÃO COM COOKING CLASS (choice_group)
-- Tira as unidades (o preço passa a ser da linha), põe o choice_group e o
-- texto da opção com cooking.
-- ---------------------------------------------------------------------
update ops_proposal_items set
  title = E'Roman Countryside · Frascati with a private cooking class',
  title_en = E'Roman Countryside · Frascati with a private cooking class',
  choice_group = E'frascati', optional = true, price = 1999, units = '[]'::jsonb, sort = 15,
  details_en = E'The day begins at your hotel in Rome, where your private driver is waiting for the drive into the hills of the Castelli Romani — about an hour south, to the historic wine region of Frascati. Volcanic terroir, ancient estates and an intimate glimpse of rural Italian life. You are welcomed at a family-owned winery for a private, hands-on cooking class, followed by a guided tasting of the estate''s wines and a regional lunch. Your driver stays with you throughout, for an unhurried return to Rome by mid-afternoon.',
  included_en = E'Private driver from your Rome hotel (about 6 hours) · hands-on cooking class · winery visit · guided tasting · lunch.'
 where proposal_id = 'f1d3d719-5142-43e7-9359-e2b7249a25d6'
   and 'Roman Countryside · Frascati Culinary Day' in (coalesce(title,''), coalesce(title_en,''))
   and coalesce(choice_group,'') = '';

-- A segunda opção: VISITA + DEGUSTAÇÃO (sem cooking), mesmo choice_group.
insert into ops_proposal_items
  (id, proposal_id, sort, section, kind, service_date, choice_group,
   title, title_en, details, details_en, included_pt, included_en,
   photos, units, qty, unit_price, price, optional, extras, attachments)
select E'55260000-0000-0000-0000-000000000006', E'f1d3d719-5142-43e7-9359-e2b7249a25d6',
  16, E'ground', 'experience', E'Sunday, May 9 · Frascati', E'frascati',
  E'Roman Countryside · Frascati · visit, tasting & lunch', E'Roman Countryside · Frascati · visit, tasting & lunch',
  null, E'The same day in Frascati, this time without the cooking class. Your private driver takes you into the hills of the Castelli Romani for a visit to a family-owned winery, a guided tasting of the estate''s wines and a regional lunch, with the same unhurried return to Rome by mid-afternoon.',
  null, E'Private driver from your Rome hotel (about 6 hours) · winery visit · guided tasting · regional lunch.',
  E'["https://i.postimg.cc/fTyMqBT4/Fontenille-Pieve-Aldina-octobre-2024-Yann-Deret-2693.jpg"]'::jsonb,
  '[]'::jsonb, 1, null, 1560, true, '[]'::jsonb, '[]'::jsonb
where exists (select 1 from ops_proposal_items x
               where x.proposal_id = 'f1d3d719-5142-43e7-9359-e2b7249a25d6'
                 and x.choice_group = 'frascati')
  and not exists (select 1 from ops_proposal_items x
               where x.proposal_id = 'f1d3d719-5142-43e7-9359-e2b7249a25d6'
                 and 'Roman Countryside · Frascati · visit, tasting & lunch' in (coalesce(x.title,''), coalesce(x.title_en,'')))
on conflict (id) do nothing;

-- ---------------------------------------------------------------------
-- 3 · FOOD TOUR · foto nova (a de Florença saía deslocada). Na linha e no
-- catálogo. Só troca se ainda for a foto antiga.
-- ---------------------------------------------------------------------
update ops_proposal_items set photos = E'["https://i.postimg.cc/MTBBhV0W/images.jpg"]'::jsonb
 where proposal_id = 'f1d3d719-5142-43e7-9359-e2b7249a25d6'
   and 'Private Rome Food Tour' in (coalesce(title,''), coalesce(title_en,''))
   and photos @> '["https://i.postimg.cc/h4pVH0t2/Food-Tour-Florence.png"]'::jsonb;

update ops_catalog set photos = E'["https://i.postimg.cc/MTBBhV0W/images.jpg"]'::jsonb, updated_at = now()
 where id = 'e7000000-0000-0000-0000-000000000001'
   and photos @> '["https://i.postimg.cc/h4pVH0t2/Food-Tour-Florence.png"]'::jsonb;

insert into ops_migrations (id) values ('0080-danielle-termini-e-frascati-escolha') on conflict (id) do nothing;
