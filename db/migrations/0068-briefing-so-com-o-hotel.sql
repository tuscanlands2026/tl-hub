-- =====================================================================
-- 0068 · NO BRIEFING FICA SÓ O NOME DO HOTEL
--
-- Instrução dela, outubro/26: "coloca só o nome dos hotéis no briefing,
-- é melhor. O tipo de quarto deixa para a seleção mesmo."
--
-- As três tabelas do briefing tinham duas colunas, Hotel e Suggested
-- category. A segunda sai inteira: cabeçalho, separador e a célula de
-- cada linha. Sai junto a frase que recomendava categoria no Villa San
-- Michele, pelo mesmo motivo.
--
-- A categoria continua existindo onde ela decidiu que é o lugar: na
-- proposta, nas Acomodações de cada hospedagem, que é onde o valor por
-- noite mora. Duas listas de categoria em dois documentos divergem no
-- dia em que ela corrige uma e esquece a outra.
--
-- COBRE AS NOVE LINHAS ORIGINAIS, inclusive as três dos hotéis que
-- saíram. Se a limpeza dos três já tiver passado, essas três trocas não
-- acham nada e seguem em silêncio — e se não tiver, elas também ficam
-- com uma coluna só, o que é o certo de todo jeito.
--
-- VAI POR `execute` ATRÁS DE `to_regclass`: sem o módulo do briefing
-- (0054/0055) no banco, este arquivo não faz nada e NÃO DÁ ERRO. É a
-- lição da 0066 — tabela que pode não existir derruba o arquivo inteiro
-- no SQL Editor, porque lá tudo roda numa transação só.
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
      replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(content,
        E'| Hotel | Suggested category |\n| --- | --- |\n',
        E'| Hotel |\n| --- |\n'),
        E'| [Dimora Ghirlandaio](https://dimoraghirlandaio.it/en/accommodations/il-frantoio/) · Impruneta, 15 min from Florence | La Limonaia or Villa Lo Studio, for the couple alone |\n',
        E'| [Dimora Ghirlandaio](https://dimoraghirlandaio.it/en/accommodations/il-frantoio/) · Impruneta, 15 min from Florence |\n'),
        E'| [Castelfalfi](https://www.castelfalfi.com/stay) · Montaione | Suite or Castelfalfi Suite |\n',
        E'| [Castelfalfi](https://www.castelfalfi.com/stay) · Montaione |\n'),
        E'| [Borgo Vescine](https://www.vescine.it/) · Radda in Chianti | Superior Suite |\n',
        E'| [Borgo Vescine](https://www.vescine.it/) · Radda in Chianti |\n'),
        E'| Villa San Michele, A Belmond Hotel · Fiesole | Garden Suite |\n',
        E'| Villa San Michele, A Belmond Hotel · Fiesole |\n'),
        E'| Collegio alla Querce, Auberge Collection · below Fiesole | Junior Suite or Suite |\n',
        E'| Collegio alla Querce, Auberge Collection · below Fiesole |\n'),
        E'| Four Seasons Hotel Firenze · city centre | Premier Room or Suite |\n',
        E'| Four Seasons Hotel Firenze · city centre |\n'),
        E'| Danieli, Venezia, A Four Seasons Hotel · Riva degli Schiavoni | Premium Lagoon-View Room or Lagoon-View Suite |\n',
        E'| Danieli, Venezia, A Four Seasons Hotel · Riva degli Schiavoni |\n'),
        E'| Aman Venice · Grand Canal | Palazzo Room or Suite |\n',
        E'| Aman Venice · Grand Canal |\n'),
        E'| Palazzo Vendramin at Hotel Cipriani · Giudecca | Vendramin Suite |\n',
        E'| Palazzo Vendramin at Hotel Cipriani · Giudecca |\n'),
        E'At Villa San Michele the entry rooms are the weaker part of the house, so we suggest going straight to a garden suite.\n\n',
        E''),
      updated_at = now()
     where id = 'b0000001-0000-0000-0000-000000000001'
       and content like '%Suggested category%'
  $q$;
end $$;

insert into ops_migrations (id) values ('0068-briefing-so-com-o-hotel') on conflict (id) do nothing;
