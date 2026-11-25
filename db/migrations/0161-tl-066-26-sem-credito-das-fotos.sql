-- =====================================================================
-- 0161 · TL-066-26: SEM CRÉDITO DAS FOTOS
--
-- Instrução dela, 25/11/26: o crédito das fotos não sai na peça. As duas
-- fotos de Assis da 0159 eram CC BY-SA, que obriga o crédito; para tirar
-- o crédito sem descumprir licença, elas trocam por fotos de DOMÍNIO
-- PÚBLICO, que não pedem atribuição:
--   · faixa: "Panorama (Assisi) 09 05 2026 03.jpg", Effems, CC0;
--   · o dia: "Assisi San Francesco BW 2.JPG", Berthold Werner, domínio
--     público.
-- O vinhedo e as duas da vinícola continuam.
--
-- Seção 7: update em UMA proposta, a TL-066-26 (0157), sem envio e sem
-- resposta, por instrução dela nesta conversa.
-- =====================================================================

do $$
declare
  prop uuid := 'e0660000-0000-0000-0000-000000000001';
  n int;
begin
  if exists (select 1 from ops_proposals where id = prop and responded_at is not null) then
    raise exception '0161: a TL-066-26 já foi respondida, nada muda';
  end if;

  update ops_proposals
     set cover_img = 'fotos/tl066/assisi-vista.jpg',
         labels = labels - 'j_cover_credit'
   where id = prop;

  update ops_proposal_items
     set photos = '["fotos/tl066/assisi-sao-francisco.jpg","fotos/tl066/vinicola-vinhedo.jpg"]'::jsonb
   where proposal_id = prop and 'Assisi, and lunch at a family winery' in (title, title_en);
  get diagnostics n = row_count;
  if n <> 1 then raise exception '0161: linha do dia não encontrada'; end if;
end $$;

insert into ops_migrations (id) values ('0161-tl-066-26-sem-credito-das-fotos') on conflict (id) do nothing;
