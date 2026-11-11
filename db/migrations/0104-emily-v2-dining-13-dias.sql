-- =====================================================================
-- 0104 · EMILY (TL-053-26, v2): DINING CONCIERGE EM 13 DIAS, E NÃO 6
--
-- Instrução dela, nov/26: "não são só 6 dias — veja o dia que chegam e
-- o dia que vão embora". Chegam a Florença em 20 de junho, 11:30, com
-- jantar no primeiro dia. Saem de Roma em 3 de julho às 12:20, deixando
-- o hotel às 9:00, sem refeição. Ficam 13 dias, de 20/6 a 2/7.
--
-- Muda só a quantidade e o total da linha: 13 × € 70 = € 910. O valor
-- unitário fica. O texto das condições diz "€70 per night", sem número
-- de dias, e não muda.
--
-- Mira por proposal_id + título (o id da linha não é estável), e só troca
-- se a linha ainda for 6 × 70 e a proposta não tiver resposta.
--
-- Seção 7: update de uma linha de ops_proposal_items, com o sim dela.
-- =====================================================================

update ops_proposal_items i
   set qty = 13, price = 910
  from ops_proposals p
 where p.id = i.proposal_id
   and p.id = 'e0530000-0000-0000-0000-000000000002'
   and p.responded_at is null
   and coalesce(i.title_en, i.title) = 'Dining concierge'
   and i.qty = 6 and i.unit_price = 70;

insert into ops_migrations (id) values ('0104-emily-v2-dining-13-dias') on conflict (id) do nothing;
