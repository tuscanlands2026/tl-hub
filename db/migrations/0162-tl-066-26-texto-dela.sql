-- =====================================================================
-- 0162 · TL-066-26: O TEXTO DO DIA, ESCRITO POR ELA
--
-- Instrução dela, 25/11/26: "ajusta este texto na cotação". O texto do
-- dia, o Included e o Good to know passam a ser os dela, palavra por
-- palavra. Sai a lista dos pratos com cada vinho, que ela resumiu em
-- "from whites to reds".
--
-- Seção 7: update em UMA linha da TL-066-26 (0157), sem envio e sem
-- resposta, por instrução dela nesta conversa. Mirada por proposta +
-- título.
-- =====================================================================

do $$
declare
  prop uuid := 'e0660000-0000-0000-0000-000000000001';
  n int;
begin
  if exists (select 1 from ops_proposals where id = prop and responded_at is not null) then
    raise exception '0162: a TL-066-26 já foi respondida, nada muda';
  end if;

  update ops_proposal_items set
    details = $t$Assisi is the town of St. Francis. On this experience, a local guide leads you through his story and his importance for the region, along with the curiosities the town keeps along the way. One of the highlights is the Basilica of St. Francis, in a morning of discovery with a specialized local guide.
The experience continues at a family-run winery near Umbertide, with a long tradition in the area, where an 18th-century cellar and a contemporary building sit side by side. In the cellar you discover the story of local winemaking and what makes the estate's wines so distinctive, and lunch is then served in the new space, with dishes paired with the house wines, from whites to reds.$t$,
    included_pt = $t$- Private vehicle with driver, about 7 hours including travel time
- Local guide in Assisi, about 2 hours
- Winery visit and lunch paired with the estate's wines$t$,
    good_pt = $t$Pick-up at the hotel between 8:30 and 9:00 am. Date and time are subject to confirmation.
The menu may vary according to seasonal ingredients.$t$
  where proposal_id = prop and 'Assisi, and lunch at a family winery' in (title, title_en);
  get diagnostics n = row_count;
  if n <> 1 then raise exception '0162: linha do dia não encontrada'; end if;

  update ops_proposal_items set details_en = details, included_en = included_pt, good_en = good_pt
   where proposal_id = prop and 'Assisi, and lunch at a family winery' in (title, title_en);
end $$;

insert into ops_migrations (id) values ('0162-tl-066-26-texto-dela') on conflict (id) do nothing;
