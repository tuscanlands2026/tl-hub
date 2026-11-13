-- =====================================================================
-- 0138 · AS VISITAS PRIVADAS DE AREZZO SOMAM € 300 (TL-064-26)
--
-- Instrução dela, 13/11/26: "soma sim. Tudo que ela marcar, soma. Se tiver
-- alguma diferença, eu vou ajustar." As duas visitas privadas (Steli d'oro
-- e Lorini Gioielli) ganham price = 300 e entram no total; o texto "From
-- € 300" continua na linha, porque o valor final ainda vem do orçamento.
--
-- Seção 7: update no dia de Arezzo da proposta da TL-064-26, com o sim
-- dela. Só enquanto a proposta não foi respondida.
-- =====================================================================

do $$
declare n int; prop uuid := 'e0530000-0000-0000-0000-000000000003';
begin
  if exists (select 1 from ops_proposals where id = prop and responded_at is not null) then
    raise exception '0138: a proposta já foi respondida, nada muda';
  end if;
  update ops_proposal_items i set units = (
      select jsonb_agg(case when u->>'key' in ('steli_visit','lorini_visit')
                            then u || jsonb_build_object('price', 300)
                            else u end order by o)
      from jsonb_array_elements(i.units) with ordinality t(u, o))
   where proposal_id = prop and title_en = 'Arezzo and its goldsmiths'
     and units @> '[{"key":"steli_visit"},{"key":"lorini_visit"}]';
  get diagnostics n = row_count;
  if n <> 1 then raise exception '0138: as visitas não foram encontradas'; end if;
end $$;

insert into ops_migrations (id) values ('0138-visitas-somam-300') on conflict (id) do nothing;
