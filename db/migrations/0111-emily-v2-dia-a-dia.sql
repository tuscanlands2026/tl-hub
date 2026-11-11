-- =====================================================================
-- 0111 · EMILY (TL-053-26, v2): "YOUR PROPOSAL" DIA A DIA
--
-- Instrução dela, nov/26, olhando a tabela em grupos da 0110: "não fica
-- mais claro uma visualização por dia para o cliente? Primeiro só
-- hospedagem, aí só o car rental. Todas as outras coisas, dia tal e as
-- experiências; se tiver transfer no dia coloca, se tiver meet and greet
-- coloca. O dia 23 você coloca pending por hora."
--
-- O desenho novo é do código (o bloco "Day by day", ordenado pela data).
-- O que muda aqui é o texto das linhas que passam a ficar embaixo de uma
-- data e não devem repeti-la — os dois transfers e o meet and greet —, e
-- a linha de Arezzo, que entra como "Pending": tem texto de linha e não
-- tem valor, então não tem caixinha e não soma.
--
-- Mira por proposal_id + seção + título. Só roda com a v2 sem resposta.
--
-- Seção 7: update em ops_proposal_items (quatro linhas da v2), com o sim
-- dela, que é a própria instrução.
-- =====================================================================

do $mig$
declare
  v uuid := 'e0530000-0000-0000-0000-000000000002';
begin
  if not exists (select 1 from ops_proposals where id = v and responded_at is null) then
    raise notice '0111: v2 já respondida ou inexistente — nada feito';
    return;
  end if;

  update ops_proposal_items set row_en = 'Private transfer · Florence airport to the palace in Cortona'
   where proposal_id = v and section = 'around' and title_en = 'Arrival';

  update ops_proposal_items set row_en = 'Private transfer · Hotel to Fiumicino, Terminal 3'
   where proposal_id = v and section = 'around' and title_en = 'Departure';

  update ops_proposal_items set row_en = 'VIP meet and greet at Fiumicino, departure'
   where proposal_id = v and section = 'around' and title_en = 'VIP meet and greet at Fiumicino';

  update ops_proposal_items set row_en = 'Arezzo · The goldsmith experience'
   where proposal_id = v and section = 'cortona' and title_en = 'Arezzo';
end $mig$;

insert into ops_migrations (id) values ('0111-emily-v2-dia-a-dia') on conflict (id) do nothing;
