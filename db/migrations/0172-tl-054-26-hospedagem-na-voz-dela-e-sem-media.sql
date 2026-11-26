-- 0172 · TL-054-26 (Bocelli Experience, Facility Turismo) · 26/11/26
--
-- Dois pedidos dela, depois de atualizar os preços no editor (16h43):
--   1. no link dos valores, sai o "€ … por noite, por quarto" de cada
--      quarto: com os preços novos a média ficou errada, e ela não quer
--      média nenhuma ali;
--   2. o texto da hospedagem, no tom do texto do concerto que ela escreveu
--      (0171): hora e movimento, o lugar numa frase, a possibilidade, e o
--      fim seco. Sem fato novo: tudo já estava na 0169.
--
-- UPDATE em linha que já existe, pedido por ela. Guardas presas às frases
-- que mudam. Antes de rodar: recarregar o editor, senão o save desfaz.

do $$
declare
  prop uuid := 'e0540000-0000-0000-0000-000000000001';
  n int;
begin
  if exists (select 1 from ops_proposals where id = prop and responded_at is not null) then
    raise exception '0172: a TL-054-26 já foi respondida, nada muda';
  end if;

  update ops_proposal_items
     set row_desc_pt = regexp_replace(row_desc_pt, ' · € [0-9.,]+ por noite, por quarto', '')
   where proposal_id = prop and section = 'v_hotel'
     and row_desc_pt ~ ' · € [0-9.,]+ por noite, por quarto';
  get diagnostics n = row_count;
  if n <> 3 then raise exception '0172: esperava 3 quartos com a média, achou %', n; end if;

  update ops_proposal_items set details =
$t$No dia 23, vocês chegarão ao Castelfalfi, no alto de uma colina em Montaione, entre Florença e Pisa. O hotel ocupa um borgo medieval inteiro, com o castelo, a igreja de San Floriano e o jardim dos Medici, cercado por cerca de 1.100 hectares de campo, de onde vêm o vinho e o azeite orgânicos servidos à mesa.

O teatro fica a cerca de 40 minutos. Depois da noite do concerto, o domingo será livre para o spa, a piscina ou o campo de golfe, e o jantar poderá ser no próprio borgo. Se o mau tempo transferir o concerto para o dia 25, vocês continuarão hospedados.

A saída será no dia 26.

City tax e extras não estão incluídos.$t$
  where proposal_id = prop and section = 'castelfalfi' and 'Castelfalfi' in (title, title_en)
    and position('A chegada é na sexta, 23 de julho. O Castelfalfi fica no alto' in details) = 1;
  get diagnostics n = row_count;
  if n <> 1 then raise exception '0172: o texto do hotel não é mais o da 0169'; end if;
end $$;

insert into ops_migrations (id) values ('0172-tl-054-26-hospedagem-na-voz-dela-e-sem-media') on conflict (id) do nothing;
