-- =====================================================================
-- 0085 · TL-050-26 · PICK-UP DO HOTEL COMO EXTRA DO VATICANO
--
-- Instrução dela, 11/11/26: "para cada uma dessas experiências, Coliseu,
-- Vaticano, coloca também um serviço de pick-up do hotel, ida ... coloca
-- sempre €80".
--
-- Entra só no VATICANO. O Coliseu fica de fora até ela responder: na v2
-- o tour do Coliseu (€ 895) já traz "One-way transfer from the hotel" no
-- incluído, e um extra de pick-up na mesma linha cobraria o trecho duas
-- vezes aos olhos do cliente.
--
-- MEXE EM LINHA QUE JÁ EXISTE (a do Vaticano, da 0083, nunca enviada):
-- acrescenta o extra em `extras`. O sim é a instrução dela acima. Mira
-- por proposta + título (o id muda quando a proposta é salva no editor),
-- e só acrescenta se o extra ainda não estiver lá.
--
-- CONFERÊNCIA DA SEÇÃO 7: ops_proposal_items (update em uma linha) e
-- ops_migrations (insert). Nenhuma tabela do CRM.
-- =====================================================================

update ops_proposal_items
   set extras = coalesce(extras,'[]'::jsonb) || '[{"key":"pickup","label_pt":"Pick-up no hotel (ida)","label_en":"Hotel pick-up (one way)","price":80}]'::jsonb
 where proposal_id = '50262600-0000-0000-0000-0000000000b2'
   and (title_en = 'Private Vatican Breakfast Tour (early access)' or title = 'Private Vatican Breakfast Tour (early access)')
   and not coalesce(extras,'[]'::jsonb) @> '[{"key":"pickup"}]'::jsonb;

insert into ops_migrations (id) values ('0085-tl050-pickup-vaticano') on conflict (id) do nothing;
