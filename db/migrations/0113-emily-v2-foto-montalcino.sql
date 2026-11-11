-- =====================================================================
-- 0113 · EMILY (TL-053-26, v2): MONTALCINO COM A PROPRIEDADE E UMA ADEGA
--
-- Instrução dela, nov/26: "no dia de Montalcino deixa uma foto só, porque
-- são duas fotos da mesma coisa. Ou substitui por uma da vinícola, da
-- vila, que tem naquela pasta, e deixa uma daquelas duas".
--
-- Fica a vista da propriedade entre as vinhas (a foto profissional da
-- pasta da Argiano, que já estava no repositório como montalcino.jpg) e a
-- adega iluminada. Sai a adega em espiral.
--
-- Seção 7: update de uma linha de ops_proposal_items da v2, com o sim
-- dela, que é a própria instrução.
-- =====================================================================

update ops_proposal_items set
  photos = '["fotos/tl053/montalcino.jpg","fotos/tl053/montalcino-adega.jpg"]'::jsonb
 where proposal_id = 'e0530000-0000-0000-0000-000000000002'
   and section = 'cortona' and title_en = 'Montalcino'
   and exists (select 1 from ops_proposals
                where id = 'e0530000-0000-0000-0000-000000000002' and responded_at is null);

insert into ops_migrations (id) values ('0113-emily-v2-foto-montalcino') on conflict (id) do nothing;
