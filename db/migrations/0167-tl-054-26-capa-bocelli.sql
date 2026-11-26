-- =====================================================================
-- 0167 · TL-054-26: A CAPA É O BOCELLI NO PALCO
--
-- Instrução dela, 26/11/26: a capa do anoitecer (0166) "tá horrível,
-- troca". Ela escolheu, entre três montadas na própria capa, a do Bocelli
-- no palco com a orquestra (City Sound, 1500 px). A mesma foto saía na
-- folha do concerto; ali ela troca pela do Bocelli no palco das edições
-- anteriores, para não repetir.
--
-- Seção 7: update em UMA proposta, a TL-054-26, sem envio e sem resposta,
-- por instrução dela nesta conversa. Linha mirada por proposta + título.
-- =====================================================================

do $$
declare
  prop uuid := 'e0540000-0000-0000-0000-000000000001';
  n int;
begin
  if exists (select 1 from ops_proposals where id = prop and responded_at is not null) then
    raise exception '0167: a TL-054-26 já foi respondida, nada muda';
  end if;

  update ops_proposals set cover_img = 'fotos/tl054/concerto-bocelli-orquestra.jpg' where id = prop;
  get diagnostics n = row_count;
  if n <> 1 then raise exception '0167: TL-054-26 não encontrada'; end if;

  update ops_proposal_items
     set photos = '["fotos/tl054/concerto-bocelli.jpg","fotos/tl054/concerto-fogo.jpg"]'::jsonb
   where proposal_id = prop and 'Bocelli no Teatro del Silenzio' in (title, title_en);
  get diagnostics n = row_count;
  if n <> 1 then raise exception '0167: linha do concerto não encontrada'; end if;
end $$;

insert into ops_migrations (id) values ('0167-tl-054-26-capa-bocelli') on conflict (id) do nothing;
