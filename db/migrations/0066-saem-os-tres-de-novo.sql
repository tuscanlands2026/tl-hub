-- =====================================================================
-- 0066 · OS TRÊS HOTÉIS SAEM, DE NOVO — AGORA À PROVA DE TUDO
--
-- Ela rodou a 0063 e me disse "foi". Olhando o banco pelo link da
-- proposta, não saiu nada: os nove hotéis continuam lá e a Curadoria
-- ainda cita o Palazzo Vendramin.
--
-- POR QUE NADA APLICOU. O SQL Editor do Supabase manda o arquivo inteiro
-- como UMA consulta, e o Postgres põe isso numa transação implícita: um
-- erro em QUALQUER comando desfaz TODOS os outros. Reproduzi aqui — com
-- um único comando falhando, os três delete que já tinham passado voltam
-- atrás sem deixar rastro. Foi isso que aconteceu, e por isso ela viu o
-- arquivo rodar sem ver efeito nenhum.
--
-- DUAS COISAS NA 0063 PODIAM DERRUBAR O ARQUIVO INTEIRO:
--
--   1. as três perguntas do briefing consultam `ops_advisor_answers`. Se
--      o módulo do briefing da advisor (0054) não estiver no banco, essa
--      linha não é "não faz nada": é ERRO de tabela inexistente, e leva
--      o arquivo junto;
--   2. a Curadoria tinha guarda no parágrafo da Ghirlandaio. ELA JÁ TINHA
--      APAGADO ESSE PARÁGRAFO À MÃO, e também o do Villa San Michele — e
--      reescreveu "The first option sits on the hills" sozinha. Com o
--      texto mudado, a guarda não casava e aquele bloco não fazia nada.
--      Isso não derruba, mas explica o Vendramin continuar lá.
--
-- O QUE MUDA AQUI:
--   · NADA depende das tabelas do briefing. O que mexe nelas está dentro
--     de um bloco que confere se a tabela existe antes de tocar. Sem o
--     módulo instalado, pula em silêncio e o resto roda;
--   · os três delete são por ID, e a conferência de nome aceita o título
--     em qualquer um dos dois idiomas — ela edita o editor em português,
--     e isso escreve em `title`, não em `title_en`;
--   · a Curadoria é guardada SÓ pelo parágrafo do Vendramin, que é o
--     único que sobrou. O texto que ela reescreveu não é tocado.
--
-- RODA MESMO SE A 0063 TIVER APLICADO EM PARTE: cada comando confere o
-- estado antes. Rodando duas vezes, a segunda não faz nada.
--
-- CONFERÊNCIA DA SEÇÃO 7, relida antes de entregar. Os objetos que este
-- arquivo toca, um a um: ops_proposal_items (delete de até TRÊS linhas,
-- por id), ops_proposals (update de curations em UMA linha, por id),
-- ops_advisor_briefings e ops_advisor_questions (update, só se as tabelas
-- existirem) e ops_migrations (insert). Nenhum drop, alter ou truncate.
-- Nenhuma tabela do CRM é lida, escrita ou citada. Nenhum comando
-- percorre o schema. Nenhuma service_role key aparece aqui.
-- =====================================================================

-- 1 · AS TRÊS LINHAS DA PROPOSTA ----------------------------------------
-- Por id, e o nome conferido no idioma que estiver preenchido.
delete from ops_proposal_items
 where proposal_id = 'b59090ad-14dc-45d3-87f5-9f7206834668'
   and id in ('53260000-0000-0000-0000-000000000001',
              '53260000-0000-0000-0000-000000000004',
              '53260000-0000-0000-0000-000000000009')
   and coalesce(nullif(title_en,''), title, '') in
       ('Dimora Ghirlandaio',
        'Belmond Villa San Michele',
        'Palazzo Vendramin at Hotel Cipriani');

-- 2 · O PARÁGRAFO DO VENDRAMIN NA CURADORIA ------------------------------
-- Guardado só por ele. O que ela reescreveu à mão fica como está.
update ops_proposals p
   set curations = jsonb_set(p.curations, s.caminho, to_jsonb(
         replace(replace(s.txt,
           E'Palazzo Vendramin at Hotel Cipriani. A residence on Giudecca beside the Cipriani and connected to it, so its pool and gardens are yours too.\n\n',
           E''),
           E'Palazzo Vendramin at Hotel Cipriani. Seventeen rooms in a 15th-century residence on Giudecca, connected to the Cipriani, so its pool and gardens are yours too.\n\n',
           E''))),
       updated_at = now()
  from (select
          case when coalesce(curations->0->>'dias_en','') <> ''
               then '{0,dias_en}' else '{0,dias_pt}' end::text[] as caminho,
          coalesce(nullif(curations->0->>'dias_en',''), curations->0->>'dias_pt') as txt
          from ops_proposals where id = 'b59090ad-14dc-45d3-87f5-9f7206834668') s
 where p.id = 'b59090ad-14dc-45d3-87f5-9f7206834668'
   and s.txt like '%Palazzo Vendramin at Hotel Cipriani.%';

-- 3 · O BRIEFING DA ADVISOR, SE ELE EXISTIR -------------------------------
-- Tudo que toca essas tabelas vai por `execute` com o comando em texto.
-- Sem isso não adianta conferir antes: o plpgsql PLANEJA a instrução
-- inteira ao avaliar o `if`, e tabela inexistente derruba na hora de
-- planejar, mesmo com a condição falsa. Medido aqui, falhando.
do $$
begin
  if to_regclass('public.ops_advisor_briefings') is not null then
    execute $q$
      update ops_advisor_briefings set content =
        replace(replace(replace(replace(replace(replace(replace(content,
          E'| [Dimora Ghirlandaio](https://dimoraghirlandaio.it/en/accommodations/il-frantoio/) · Impruneta, 15 min from Florence | La Limonaia or Villa Lo Studio, for the couple alone |\n', E''),
          E'Dimora Ghirlandaio is the one we would lead with for Emily''s privacy: the estate rents its houses individually, so the couple has a home of their own with the hotel''s restaurant, breakfast, pool and spa around it. ', E''),
          E'Villa San Michele and Collegio alla Querce sit outside the centre, on the hills above the city, and both run a shuttle into town. We chose them so the couple does not need to sleep in the city. If staying in the centre matters to Emily, the Four Seasons is there, and we can replace one of the hill options with another central hotel. Florence has other good ones.\n',
          E'Collegio alla Querce sits outside the centre, on the hill above the city, and runs a shuttle into town. We chose it so the couple does not need to sleep in the city. If staying in the centre matters to Emily, the Four Seasons is there, and we can replace the hill option with another central hotel. Florence has other good ones.\n'),
          E'| Villa San Michele, A Belmond Hotel · Fiesole | Garden Suite |\n', E''),
          E'At Villa San Michele the entry rooms are the weaker part of the house, so we suggest going straight to a garden suite.\n\n', E''),
          E'| Palazzo Vendramin at Hotel Cipriani · Giudecca | Vendramin Suite |\n', E''),
          E'Villa San Michele, Collegio alla Querce and Dimora Ghirlandaio all work as that base.',
          E'Collegio alla Querce works as that base.'),
        updated_at = now()
       where id = 'b0000001-0000-0000-0000-000000000001'
         and content like '%Dimora Ghirlandaio is the one%'
    $q$;

    execute $q$
      update ops_advisor_briefings set content =
        replace(replace(content,
          E'We kept the Marriott properties out, as they are very large, and looked for smaller scale instead: Aman has 24 rooms, Palazzo Vendramin 17, with the Cipriani''s pool and gardens next door.',
          E'We kept the Marriott properties out, as they are very large, and looked for smaller scale instead: Aman occupies a single palazzo on the Grand Canal.'),
          E'We kept the Marriott properties out, as they are very large, and looked for smaller scale instead: Aman occupies a single palazzo on the Grand Canal, and Palazzo Vendramin is a residence beside the Cipriani, with its pool and gardens next door.',
          E'We kept the Marriott properties out, as they are very large, and looked for smaller scale instead: Aman occupies a single palazzo on the Grand Canal.'),
        updated_at = now()
       where id = 'b0000001-0000-0000-0000-000000000001'
         and content like '%Palazzo Vendramin%'
    $q$;
  end if;

  -- As opções das três perguntas, e só se ninguém tiver respondido.
  if to_regclass('public.ops_advisor_questions') is not null
     and to_regclass('public.ops_advisor_answers') is not null then
    execute $q$
      update ops_advisor_questions q set options = x.ops
        from (values
          ('b0000001-0000-0000-0000-000000010001'::uuid, '["Castelfalfi", "Borgo Vescine"]'::jsonb),
          ('b0000001-0000-0000-0000-000000010002'::uuid, '["Collegio alla Querce", "Four Seasons Hotel Firenze", "Another hotel in the centre"]'::jsonb),
          ('b0000001-0000-0000-0000-000000010003'::uuid, '["Danieli, A Four Seasons Hotel", "Aman Venice"]'::jsonb)
        ) as x(id, ops)
       where q.id = x.id
         and not exists (select 1 from ops_advisor_answers a
                          where a.briefing_id = 'b0000001-0000-0000-0000-000000000001')
    $q$;
  end if;
end $$;

insert into ops_migrations (id) values ('0066-saem-os-tres-de-novo') on conflict (id) do nothing;
