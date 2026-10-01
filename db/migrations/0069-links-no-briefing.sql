-- =====================================================================
-- 0069 · OS SEIS HOTÉIS DO BRIEFING GANHAM LINK
--
-- Ela, olhando o briefing depois da 0068: "vc tirou os links do briefing".
--
-- Os links não saíram — mas só DOIS hotéis tinham link, os dois da
-- Toscana, e assim foi desde a 0055. Florença e Veneza nunca tiveram.
-- Com a tabela em uma coluna só isso ficou à vista, e ela tem razão no
-- fundo da questão: numa tabela que é só o nome do hotel, o nome sem
-- link não leva a lugar nenhum.
--
-- Então os quatro que faltavam ganham link, e o do Castelfalfi passa a
-- apontar para a raiz do site em vez da página /stay — é a página do
-- hotel, e é o que os outros cinco apontam.
--
-- Os seis endereços são os das fichas do hub, e os seis responderam 200
-- na conferência feita antes de escrever este arquivo.
--
-- COBRE A LINHA DE UMA COLUNA E A DE DUAS, então roda tendo a 0068 sido
-- rodada ou não. Vai por `execute` atrás de `to_regclass`: sem o módulo
-- do briefing no banco, não faz nada e não dá erro.
--
-- CONFERÊNCIA DA SEÇÃO 7, relida antes de entregar. Os objetos que este
-- arquivo toca, um a um: ops_advisor_briefings (update de UMA coluna de
-- texto, por id, e só se a tabela existir) e ops_migrations (insert).
-- Nenhum drop, alter, truncate ou delete. Nenhuma tabela do CRM é lida,
-- escrita ou citada. Nenhum comando percorre o schema. Nenhuma
-- service_role key aparece aqui.
-- =====================================================================

do $$
begin
  if to_regclass('public.ops_advisor_briefings') is null then return; end if;
  execute $q$
    update ops_advisor_briefings set content =
      replace(replace(replace(replace(replace(replace(replace(replace(replace(content,
        E'| Collegio alla Querce, Auberge Collection · below Fiesole | Junior Suite or Suite |\n',
        E'| [Collegio alla Querce, Auberge Collection](https://auberge.com/collegio-alla-querce/) · below Fiesole |\n'),
        E'| Collegio alla Querce, Auberge Collection · below Fiesole |\n',
        E'| [Collegio alla Querce, Auberge Collection](https://auberge.com/collegio-alla-querce/) · below Fiesole |\n'),
        E'| Four Seasons Hotel Firenze · city centre | Premier Room or Suite |\n',
        E'| [Four Seasons Hotel Firenze](https://www.fourseasons.com/florence/) · city centre |\n'),
        E'| Four Seasons Hotel Firenze · city centre |\n',
        E'| [Four Seasons Hotel Firenze](https://www.fourseasons.com/florence/) · city centre |\n'),
        E'| Danieli, Venezia, A Four Seasons Hotel · Riva degli Schiavoni | Premium Lagoon-View Room or Lagoon-View Suite |\n',
        E'| [Danieli, Venezia, A Four Seasons Hotel](https://www.fourseasons.com/venice/) · Riva degli Schiavoni |\n'),
        E'| Danieli, Venezia, A Four Seasons Hotel · Riva degli Schiavoni |\n',
        E'| [Danieli, Venezia, A Four Seasons Hotel](https://www.fourseasons.com/venice/) · Riva degli Schiavoni |\n'),
        E'| Aman Venice · Grand Canal | Palazzo Room or Suite |\n',
        E'| [Aman Venice](https://www.aman.com/hotels/aman-venice) · Grand Canal |\n'),
        E'| Aman Venice · Grand Canal |\n',
        E'| [Aman Venice](https://www.aman.com/hotels/aman-venice) · Grand Canal |\n'),
        E'[Castelfalfi](https://www.castelfalfi.com/stay)',
        E'[Castelfalfi](https://www.castelfalfi.com/)'),
      updated_at = now()
     where id = 'b0000001-0000-0000-0000-000000000001'
  $q$;
end $$;

insert into ops_migrations (id) values ('0069-links-no-briefing') on conflict (id) do nothing;
