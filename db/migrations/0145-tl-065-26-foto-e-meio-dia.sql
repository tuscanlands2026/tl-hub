-- =====================================================================
-- 0145 · TL-065-26: A FOTO DO ALTO E O "3½ HOURS"
--
-- Instrução dela, 13/11/26, vendo a página única no ar:
--   · a foto do alto cortava a cabeça das pessoas e não mostrava nada.
--     Entra uma foto dos Faraglioni vista do alto, sem gente, em 1920 px
--     (Wikimedia Commons, "Faraglioni (52215154472).jpg", Alessio Maffeis,
--     CC BY 2.0). A licença pede crédito: vai no rótulo j_cover_credit, que
--     sai pequeno no canto da faixa;
--   · "3 hours 30" dava a impressão de 3,5 horas de outro jeito. Passa a
--     "3½ hours" no cartão e no resumo.
--
-- Seção 7: update em UMA proposta, a TL-065-26 (0142), ainda sem resposta,
-- por instrução dela nesta conversa. As linhas são miradas por proposta, e
-- o texto trocado é só o "3 hours 30" das opções de meio dia.
-- =====================================================================

do $$
declare
  prop uuid := 'e0650000-0000-0000-0000-000000000001';
  n int;
begin
  if exists (select 1 from ops_proposals where id = prop and responded_at is not null) then
    raise exception '0145: a TL-065-26 já foi respondida, nada muda';
  end if;

  update ops_proposals
     set cover_img = 'fotos/tl065/capri-faraglioni-alto.jpg',
         labels = coalesce(labels, '{}'::jsonb)
                  || jsonb_build_object('j_cover_credit', jsonb_build_object('en',
                       'Photo: Alessio Maffeis · CC BY 2.0'))
   where id = prop;
  get diagnostics n = row_count;
  if n <> 1 then raise exception '0145: TL-065-26 não encontrada'; end if;

  update ops_proposal_items
     set units = replace(units::text, '3 hours 30', '3½ hours')::jsonb
   where proposal_id = prop and units::text like '%3 hours 30%';
end $$;

insert into ops_migrations (id) values ('0145-tl-065-26-foto-e-meio-dia') on conflict (id) do nothing;
