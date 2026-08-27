-- =====================================================================
-- 0022 · A FOLHA DE ABERTURA DA PROPOSTA DA AGÊNCIA
--
-- Correção do texto entregue em 0021. Lá a folha explicava a divisão de
-- trabalho entre a agência e a DMC — quem desenha, quem opera. Ela
-- apontou a peça real: a folha de abertura que as agências já
-- aprovaram é a "Transformando a Itália em histórias inesquecíveis",
-- que fala da Itália e não de quem vende.
--
-- Então a folha da agência passa a ser essa mesma: a chamada e o
-- parágrafo do destino, palavra por palavra como estão no texto da
-- casa, e no fim um parágrafo curto dizendo que a Tuscan Lands é DMC
-- licenciada e opera em colaboração com a agência. O que sai é a parte
-- em que a Tuscan Lands se apresenta — oito anos, rede de parceiros,
-- curadoria — que é justamente o que tirava o foco da agência.
--
-- Erro de 0021 se corrige aqui, e não editando 0021: quem já rodou a
-- 0021 recebe o texto novo por este arquivo.
--
-- A troca só alcança a proposta que ainda está com o texto de 0021
-- palavra por palavra. Proposta em que ela mexeu fica como está —
-- texto da proposta é cópia, e ganha do padrão.
--
-- Só toca em objetos ops_. Nada fora desse prefixo.
-- =====================================================================

do $$
declare
  velho_pt text := (select pt from ops_text_defaults where key = 'assurance');
  velho_en text := (select en from ops_text_defaults where key = 'assurance');
  novo_pt  text := E'**Transformando a Itália em histórias inesquecíveis.**\nNa Toscana, Umbria e Lazio, há uma Itália que poucos conhecem. É aquela dos pequenos momentos, das descobertas inesperadas, do tempo que corre no ritmo certo. Uma Itália que se revela para quem sabe onde e quando procurar.\nEsta viagem foi desenhada por {agencia}. A Tuscan Lands Travel é a DMC licenciada na Itália que opera os serviços em colaboração com {agencia}, cuidando da reconfirmação com os fornecedores e da assistência local durante toda a estadia.';
  novo_en  text := E'**Turning Italy into stories worth remembering.**\nIn Tuscany, Umbria, and Lazio, there''s an Italy most people never find. It lives in small moments, unexpected discoveries, and days that move at just the right pace.\nAn Italy that reveals itself to those who know where — and when — to look.\nThis journey was designed by {agencia}. Tuscan Lands Travel is the licensed Italian DMC operating the services in collaboration with {agencia}, handling supplier reconfirmation and local assistance throughout the stay.';
begin
  insert into ops_text_defaults (key, pt, en) values ('assurance', novo_pt, novo_en)
  on conflict (key) do update set pt = excluded.pt, en = excluded.en, updated_at = now();

  -- Só onde ainda está o texto de 0021 inteiro. Onde ela escreveu o
  -- dela, não se mexe.
  if velho_pt is not null then
    update ops_proposals set assurance_pt = novo_pt, updated_at = now()
     where assurance_pt = velho_pt;
  end if;
  if velho_en is not null then
    update ops_proposals set assurance_en = novo_en, updated_at = now()
     where assurance_en = velho_en;
  end if;
end $$;

insert into ops_migrations (id) values ('0022-abertura-da-agencia') on conflict (id) do nothing;
