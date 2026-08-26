-- =====================================================================
-- 0019 · A CAPA DO POGGIO, DE NOVO E SEM DEPENDER DA ORDEM
--
-- A 0018 gravava a capa dos três hotéis com um update condicionado à
-- linha existir. Rodando ANTES da 0017 — que é quem cria o Poggio —,
-- o update não achava nada, e o Poggio ficava sem capa. Foi erro meu:
-- migração não pode depender da ordem em que ela clica.
--
-- Este arquivo refaz a gravação. Continua só preenchendo o que está
-- vazio: capa que ela escolheu à mão não é sobrescrita.
--
-- Só toca em objetos ops_. Nada fora desse prefixo.
-- =====================================================================

update ops_catalog set cover_img = c.capa, updated_at = now()
  from (values
    ('c0000000-0000-0000-0000-000000000001'::uuid,
     'https://dimoraghirlandaio.it/wp-content/uploads/2023/08/dimora_ghirlandaio-main_villa_cover.jpg'),
    ('c0000000-0000-0000-0000-000000000002'::uuid,
     'https://storage.googleapis.com/webimages-p1nishrd/hotel/45130/images/room/luxuryapartment0001.jpg'),
    ('c0000000-0000-0000-0000-000000000003'::uuid,
     'https://irp.cdn-website.com/d736fd45/dms3rep/multi/DJI_0188.jpg')
  ) as c(id, capa)
 where ops_catalog.id = c.id and coalesce(ops_catalog.cover_img,'') = '';

insert into ops_migrations (id) values ('0019-capa-do-poggio') on conflict (id) do nothing;
