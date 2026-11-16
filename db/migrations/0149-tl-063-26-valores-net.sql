-- =====================================================================
-- 0149 · TL-063-26: VALORES NET
--
-- Instrução dela, 16/11/26: "preços net — experiência 340 euros por pessoa
-- (põe preço total); hotel deluxe plus 1260, superior 1728".
--   · Deluxe Plus € 1.260 e Superior € 1.728: total das 2 noites, como ela
--     mandou, nas unidades do Borgo Vescine;
--   · caça às trufas: 2 × € 340 = € 680, gravado como total da linha, sem
--     quantidade × unitário, porque ela pediu o preço total.
--
-- MEXE EM LINHA QUE JÁ EXISTE, a pedido dela: só o valor das duas linhas
-- da proposta e0630000-…-0001, miradas por proposal_id + título. As
-- unidades são trocadas pela chave (deluxe_plus, superior), sem tocar em
-- rótulo nem em mais nada. Para se a proposta já tiver resposta.
-- =====================================================================

do $$
declare
  prop uuid := 'e0630000-0000-0000-0000-000000000001';
  n int;
begin
  if exists (select 1 from ops_proposals where id = prop and responded_at is not null) then
    raise exception '0149: a TL-063-26 já foi respondida, nada muda';
  end if;

  update ops_proposal_items i set units = (
      select jsonb_agg(case u->>'key'
               when 'deluxe_plus' then jsonb_set(u, '{price}', '1260'::jsonb)
               when 'superior'    then jsonb_set(u, '{price}', '1728'::jsonb)
               else u end order by ord)
        from jsonb_array_elements(i.units) with ordinality as e(u, ord))
   where proposal_id = prop and title = 'Borgo Vescine';
  get diagnostics n = row_count;
  if n <> 1 then raise exception '0149: linha do Borgo Vescine não encontrada (%)', n; end if;

  update ops_proposal_items set price = 680
   where proposal_id = prop and title = 'Caça às trufas no Chianti';
  get diagnostics n = row_count;
  if n <> 1 then raise exception '0149: linha da caça às trufas não encontrada (%)', n; end if;
end $$;

insert into ops_migrations (id) values ('0149-tl-063-26-valores-net') on conflict (id) do nothing;
