-- =====================================================================
-- 0077 · DANIELLE (TL-055-26): A FOTO DO BLOCO DO HOTEL É DO HOTEL
--
-- Erro meu na 0076: a foto que pus no bloco "Palazzo Ripetta" era do BAR
-- (San Baylon / rooftop Etere), não do hotel. Ela apontou. Troco pela do
-- FOYER (a sala de estar / lobby), do site oficial — a cara do hotel.
--
-- A 0076 já foi entregue, então o conserto vem no próximo número. Guardado:
-- só troca se a foto ainda for a do bar que a 0076 pôs; se ela já tiver
-- escolhido outra, não mexe.
--
-- Seção 7: ops_proposal_items (update guardado) e ops_migrations (insert).
-- Sem drop/truncate/delete. Nenhuma tabela do CRM. Rodar depois da 0076.
-- =====================================================================

update ops_proposal_items set
  photos = E'["https://euakl5xd.cdn.imgeng.in/assets/uploads/AreeComuni/FOYER_2025.jpg"]'::jsonb
 where proposal_id = 'f1d3d719-5142-43e7-9359-e2b7249a25d6'
   and section = 'stays'
   and 'Palazzo Ripetta' in (coalesce(title,''), coalesce(title_en,''))
   and photos @> '["https://euakl5xd.cdn.imgeng.in/assets/uploads/Dining/EtereRooftop/PalazzoRipetta2025-52.jpg"]'::jsonb;

insert into ops_migrations (id) values ('0077-danielle-foto-do-hotel') on conflict (id) do nothing;
