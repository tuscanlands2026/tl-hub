-- =====================================================================
-- 0137 · LORINI GIOIELLI COM FOTOS DE PEÇAS DISCRETAS (TL-064-26)
--
-- Instrução dela, 13/11/26: "se ela quer uma coisa para o dia a dia, não
-- adianta colocar essas pedras gigantes... a gente pode deixar duas fotos
-- só". Saem o anel de citrino, a pulseira de safiras e o pingente de
-- pérola cinza; entram as duas peças que ela escolheu no site da Lorini:
--   · pendente perla australiana
--     (lorinigioielli.com/product/pendente-perla-australiana)
--   · braccialetto perle akoya
--     (lorinigioielli.com/product/braccialetto-perle-akoya)
-- Hospedadas em fotos/tl053/.
--
-- Seção 7: update no dia de Arezzo da proposta da TL-064-26, com o sim
-- dela. Só enquanto a proposta não foi respondida.
-- =====================================================================

do $$
declare n int; prop uuid := 'e0530000-0000-0000-0000-000000000003';
begin
  if exists (select 1 from ops_proposals where id = prop and responded_at is not null) then
    raise exception '0137: a proposta já foi respondida, nada muda';
  end if;
  update ops_proposal_items i set units = (
      select jsonb_agg(case when u->>'key' = 'lorini_visit' then u
          || jsonb_build_object('photos', jsonb_build_array(
               'fotos/tl053/lorini-perola-australiana.jpg', 'fotos/tl053/lorini-pulseira-akoya.jpg'))
        else u end order by o)
      from jsonb_array_elements(i.units) with ordinality t(u, o))
   where proposal_id = prop and title_en = 'Arezzo and its goldsmiths'
     and units @> '[{"key":"lorini_visit"}]';
  get diagnostics n = row_count;
  if n <> 1 then raise exception '0137: a visita da Lorini não foi encontrada'; end if;
end $$;

insert into ops_migrations (id) values ('0137-lorini-fotos-discretas') on conflict (id) do nothing;
