-- =====================================================================
-- 0114 · EMILY (TL-053-26, v2): AS FOTOS DOS QUARTOS DO BULGARI
--
-- Instrução dela, nov/26, em duas voltas. Primeiro: "você está cortando a
-- cama". O conserto foi mostrar a foto inteira, e ela voltou: "deixou a
-- foto do Bulgari gigante e as outras não". As duas coisas valem: a foto
-- fica na mesma altura das do Castelfalfi, e o corte vem do ponto focal,
-- puxado para baixo, onde está a cama (url#p=50,70, a convenção do
-- modelo jornada).
--
-- Seção 7: update de uma linha de ops_proposal_items da v2 (as fotos das
-- duas categorias do Bulgari), com o sim dela.
-- =====================================================================

update ops_proposal_items i set
  units = (select jsonb_agg(
             case when u->>'key' = 'u1' then u || '{"photos":["fotos/tl053/bulgari-premium.jpg#p=50,70"]}'::jsonb
                  when u->>'key' = 'u2' then u || '{"photos":["fotos/tl053/bulgari-junior-suite.jpg#p=50,72"]}'::jsonb
                  else u end order by o)
             from jsonb_array_elements(i.units) with ordinality t(u, o))
 where proposal_id = 'e0530000-0000-0000-0000-000000000002'
   and section = 'stays' and title_en = 'Bulgari Hotel Roma'
   and exists (select 1 from ops_proposals
                where id = 'e0530000-0000-0000-0000-000000000002' and responded_at is null);

insert into ops_migrations (id) values ('0114-emily-v2-foto-bulgari') on conflict (id) do nothing;
