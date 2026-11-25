-- =====================================================================
-- 0159 · TL-066-26: FOTOS NOVAS DE ASSIS E DA VINÍCOLA
--
-- Instrução dela, 25/11/26: "pega uma foto bonita de Assis" e, da
-- vinícola, "talvez valha a pena colocar 2 fotinhos".
--
--   · faixa do alto: Assis vista de cima, com a planície no fim da tarde
--     (Wikimedia Commons, "Assisi Plains South Perugia Italy Sep19 D72
--     12040.jpg", Timothy A. Gonsalves, CC BY-SA 4.0);
--   · o dia: a Basílica de São Francisco de manhã cedo (Commons,
--     Terragio67, CC BY-SA 4.0) e o vinhedo da vinícola;
--   · o cartão do preço: a adega antiga e o prédio novo, lado a lado — é
--     a mistura de antigo e contemporâneo que ela avisou à Katie;
--   · as fotos da vinícola são do site dela, sem marca à vista. O crédito
--     das duas do Commons sai no canto da faixa, como pede a licença.
--
-- Seção 7: update em UMA proposta, a TL-066-26 (0157), sem envio e sem
-- resposta, por instrução dela nesta conversa. Linhas miradas por
-- proposta + título.
-- =====================================================================

do $$
declare
  prop uuid := 'e0660000-0000-0000-0000-000000000001';
  n int;
begin
  if exists (select 1 from ops_proposals where id = prop and responded_at is not null) then
    raise exception '0159: a TL-066-26 já foi respondida, nada muda';
  end if;

  update ops_proposals
     set cover_img = 'fotos/tl066/assisi-planicie.jpg',
         labels = labels || jsonb_build_object('j_cover_credit', jsonb_build_object('en',
           'Photos: Timothy A. Gonsalves, Terragio67 · CC BY-SA 4.0'))
   where id = prop;

  update ops_proposal_items
     set photos = '["fotos/tl066/assisi-basilica.jpg","fotos/tl066/vinicola-vinhedo.jpg"]'::jsonb
   where proposal_id = prop and 'Assisi, and lunch at a family winery' in (title, title_en);
  get diagnostics n = row_count;
  if n <> 1 then raise exception '0159: linha do dia não encontrada'; end if;

  update ops_proposal_items
     set photos = '["fotos/tl066/vinicola-adega.jpg","fotos/tl066/vinicola-predio-novo.jpg"]'::jsonb
   where proposal_id = prop and 'Price for the day' in (title, title_en);
  get diagnostics n = row_count;
  if n <> 1 then raise exception '0159: cartão do preço não encontrado'; end if;
end $$;

insert into ops_migrations (id) values ('0159-tl-066-26-fotos') on conflict (id) do nothing;
