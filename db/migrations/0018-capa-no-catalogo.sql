-- =====================================================================
-- 0018 · FOTO DE CAPA NO CATÁLOGO
--
-- O cadastro tinha a lista de fotos do card, mas não a foto de capa —
-- a que ocupa a folha inteira da seção daquela hospedagem. Ela
-- procurou e não achou: só dava para colar o link na tabela de seções,
-- proposta por proposta, toda vez.
--
-- Agora a capa é do cadastro. Ao puxar o hotel do catálogo, se a seção
-- escolhida ainda estiver sem foto, ela entra sozinha; se a seção já
-- tiver uma, a dela ganha — foto escolhida à mão não se sobrescreve.
--
-- Só toca em objetos ops_. Nada fora desse prefixo.
-- =====================================================================

alter table ops_catalog add column if not exists cover_img text;
comment on column ops_catalog.cover_img is
  'Foto de capa da seção desta hospedagem. A lista photos é a fita de fotos do card.';

update ops_catalog set cover_img = 'https://irp.cdn-website.com/d736fd45/dms3rep/multi/DJI_0188.jpg',
       updated_at = now()
 where id = 'c0000000-0000-0000-0000-000000000003' and coalesce(cover_img,'') = '';

update ops_catalog set cover_img = 'https://dimoraghirlandaio.it/wp-content/uploads/2023/08/dimora_ghirlandaio-main_villa_cover.jpg',
       updated_at = now()
 where id = 'c0000000-0000-0000-0000-000000000001' and coalesce(cover_img,'') = '';

update ops_catalog set cover_img = 'https://storage.googleapis.com/webimages-p1nishrd/hotel/45130/images/room/luxuryapartment0001.jpg',
       updated_at = now()
 where id = 'c0000000-0000-0000-0000-000000000002' and coalesce(cover_img,'') = '';

insert into ops_migrations (id) values ('0018-capa-no-catalogo') on conflict (id) do nothing;
