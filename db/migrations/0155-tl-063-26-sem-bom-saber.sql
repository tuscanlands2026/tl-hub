-- =====================================================================
-- 0155 · TL-063-26: SAI O "BOM SABER" DA CAÇA ÀS TRUFAS
--
-- Instrução dela, 16/11/26: "tira essa parte da proposta" — o bloco
-- "Bom saber" (distância, roupa, opções vegetarianas, idioma) da
-- descrição da caça às trufas.
--
-- MEXE EM LINHA QUE JÁ EXISTE, a pedido dela: details da linha "Caça às
-- trufas no Chianti" da proposta e0630000-…-0001 (mirada por proposal_id
-- + título). A troca se prende ao próprio bloco: se ela já o tiver
-- mexido à mão, nada muda. Para se a proposta já tiver resposta.
-- =====================================================================

do $$
declare
  prop uuid := 'e0630000-0000-0000-0000-000000000001';
  bloco text := E'\n\n**Bom saber**\nA vinícola fica a cerca de 11 km do Borgo Vescine, uns 20 minutos de carro. Vale ir com roupa confortável para caminhar ao ar livre. Há opções vegetarianas e veganas, sob pedido. A experiência é conduzida em inglês.';
  n int;
begin
  if exists (select 1 from ops_proposals where id = prop and responded_at is not null) then
    raise exception '0155: a TL-063-26 já foi respondida, nada muda';
  end if;
  update ops_proposal_items set details = replace(details, bloco, '')
   where proposal_id = prop and title = 'Caça às trufas no Chianti'
     and position(bloco in details) > 0;
  get diagnostics n = row_count;
  if n <> 1 then raise exception '0155: bloco "Bom saber" não encontrado (%)', n; end if;
end $$;

insert into ops_migrations (id) values ('0155-tl-063-26-sem-bom-saber') on conflict (id) do nothing;
