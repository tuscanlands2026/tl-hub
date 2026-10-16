-- =====================================================================
-- 0079 · DANIELLE (TL-055-26): SAI A FOTO PERDIDA DO BARCO
--
-- Ela viu: no dia do Luxury Boat tinha uma segunda foto solta no fim
-- (image.png, que nem é do barco). Tira. Fica só a foto do barco no Tibre
-- (GFL0681). Vale na linha da proposta e no catálogo (reúso).
--
-- Miro por proposal_id + título; guardado: só tira se a foto perdida ainda
-- estiver lá. Rodar depois da 0074.
--
-- Seção 7: ops_proposal_items e ops_catalog (update guardado), ops_migrations
-- (insert). Sem drop/truncate/delete. Nenhuma tabela do CRM.
-- =====================================================================

update ops_proposal_items set
  photos = E'["https://i.postimg.cc/qMqpDjBj/GFL0681-Modifica.jpg"]'::jsonb
 where proposal_id = 'f1d3d719-5142-43e7-9359-e2b7249a25d6'
   and 'Private Boat Experience on the Tiber' in (coalesce(title,''), coalesce(title_en,''))
   and photos @> '["https://i.postimg.cc/28yC92jw/image.png"]'::jsonb;

update ops_catalog set
  photos = E'["https://i.postimg.cc/qMqpDjBj/GFL0681-Modifica.jpg"]'::jsonb, updated_at = now()
 where id = 'e7000000-0000-0000-0000-000000000005'
   and photos @> '["https://i.postimg.cc/28yC92jw/image.png"]'::jsonb;

insert into ops_migrations (id) values ('0079-danielle-foto-perdida-barco') on conflict (id) do nothing;
