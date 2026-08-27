-- =====================================================================
-- 0023 · A FOLHA DE ABERTURA É SÓ A CHAMADA E O DESTINO
--
-- Correção do texto entregue em 0022. Lá a folha já era a peça
-- aprovada, mas o parágrafo sobre a Tuscan Lands ser DMC licenciada
-- vinha grudado no fim, sem escolha. Ela disse: a folha é a chamada e o
-- parágrafo do destino; o parágrafo da DMC ela inclui ou não, conforme
-- a agência.
--
-- Então a folha nasce com as duas partes, e o parágrafo da DMC vira
-- texto guardado à parte (assurance_note), que ela traz para dentro da
-- folha por um botão no editor. Incluir é um clique, tirar é apagar.
--
-- Ficou fora da folha e não virou coluna nova de propósito: é um
-- pedaço de texto, e texto dela mora em ops_text_defaults como todo o
-- resto. Coluna só se ele tivesse lugar próprio no desenho da folha, e
-- não tem — ele entra no fim do mesmo parágrafo corrido.
--
-- Erro de 0022 se corrige aqui, e não editando 0022.
--
-- A troca só alcança a proposta que ainda está com o texto de 0022
-- palavra por palavra. Proposta em que ela mexeu fica como está.
--
-- Só toca em objetos ops_. Nada fora desse prefixo.
-- =====================================================================

do $$
declare
  velho_pt text := (select pt from ops_text_defaults where key = 'assurance');
  velho_en text := (select en from ops_text_defaults where key = 'assurance');
  novo_pt  text := E'**Transformando a Itália em histórias inesquecíveis.**\nNa Toscana, Umbria e Lazio, há uma Itália que poucos conhecem. É aquela dos pequenos momentos, das descobertas inesperadas, do tempo que corre no ritmo certo. Uma Itália que se revela para quem sabe onde e quando procurar.';
  novo_en  text := E'**Turning Italy into stories worth remembering.**\nIn Tuscany, Umbria, and Lazio, there''s an Italy most people never find. It lives in small moments, unexpected discoveries, and days that move at just the right pace.\nAn Italy that reveals itself to those who know where — and when — to look.';
  nota_pt  text := E'Esta viagem foi desenhada por {agencia}. A Tuscan Lands Travel é a DMC licenciada na Itália que opera os serviços em colaboração com {agencia}, cuidando da reconfirmação com os fornecedores e da assistência local durante toda a estadia.';
  nota_en  text := E'This journey was designed by {agencia}. Tuscan Lands Travel is the licensed Italian DMC operating the services in collaboration with {agencia}, handling supplier reconfirmation and local assistance throughout the stay.';
begin
  insert into ops_text_defaults (key, pt, en) values ('assurance', novo_pt, novo_en)
  on conflict (key) do update set pt = excluded.pt, en = excluded.en, updated_at = now();

  insert into ops_text_defaults (key, pt, en) values ('assurance_note', nota_pt, nota_en)
  on conflict (key) do update set pt = excluded.pt, en = excluded.en, updated_at = now();

  if velho_pt is not null then
    update ops_proposals set assurance_pt = novo_pt, updated_at = now()
     where assurance_pt = velho_pt;
  end if;
  if velho_en is not null then
    update ops_proposals set assurance_en = novo_en, updated_at = now()
     where assurance_en = velho_en;
  end if;
end $$;

comment on table ops_text_defaults is
  'Texto padrão da casa, de onde toda proposta nova nasce preenchida. '
  'assurance é a folha de abertura da proposta da agência; assurance_note '
  'é o parágrafo da DMC licenciada, que ela inclui nessa folha quando quiser.';

insert into ops_migrations (id) values ('0023-folha-em-duas-partes') on conflict (id) do nothing;
