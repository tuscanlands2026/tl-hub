-- =====================================================================
-- 0085 · EMILY (TL-053-26, v2): VIRA PROPOSTA COMERCIAL
--
-- Instrução dela, nov/26, sobre a v2 criada na 0083:
--
--   · "Em cada um dos hotéis ela vai escolher uma das categorias" e o que
--     ela escolher soma no total: total de hospedagem = categoria do
--     Castelfalfi + categoria do Bulgari. Cada card ganha um choice_group
--     próprio (castelfalfi, bulgari): marcar uma categoria desmarca a outra
--     DENTRO do card, como no Frascati da Danielle (0081). Grupos
--     diferentes, porque os dois hotéis não se excluem entre si.
--   · O valor passa a ser o TOTAL das 4 noites: rate_mode sai de
--     'indicativo' (que não soma) e vai para 'total'.
--   · "Agora é uma proposta comercial, completa, com condições
--     comerciais" e "tem que ter um contratinho": liga a folha comercial
--     (resumo, caixinha de aprovar, envio), liga a folha de condições, e o
--     envio passa a 'full' — nome, e-mail, pagamento e o aceite das
--     condições comerciais, que o banco exige (missing_ack).
--   · O aviso "indicative rates, per night", herdado do estudo, sai: no
--     modo total ele nem é exibido, e deixar o texto gravado é deixar uma
--     afirmação errada esperando alguém religar o indicativo.
--   · Bulgari ganha a foto da Junior Suite. O bulgarihotels.com recusa
--     leitura (403); a foto vem do privateupgrades.com, a mesma fonte das
--     fotos do Bulgari que já estavam no estudo, e a página dele confirma
--     549 sq ft e 1 King Bed na Junior Suite, 527 sq ft e 1 King Bed na
--     Premium. Respondeu 200 antes de entrar. Sem CORS: não encolhe no PDF,
--     mas tem 55 KB.
--
-- O TEXTO das condições não muda: é o padrão da casa, e ela vai editar.
-- Os valores continuam em branco até ela mandar.
--
-- Mexe só na v2 (e0530000-…-0002), criada nesta conversa, sem link
-- enviado e sem resposta. A v1 (o estudo) não é tocada. Guardado por
-- responded_at nulo.
--
-- Seção 7: ops_proposals e ops_proposal_items (updates na v2),
-- ops_migrations (insert). Sem delete. Nenhuma tabela do CRM.
-- =====================================================================

update ops_proposals set
  rate_mode       = 'total',
  show_summary    = true,
  show_conditions = true,
  confirm_mode    = 'full',
  rate_note       = null,
  rate_note_en    = null
 where id = 'e0530000-0000-0000-0000-000000000002'
   and responded_at is null;

update ops_proposal_items set choice_group = 'castelfalfi'
 where proposal_id = 'e0530000-0000-0000-0000-000000000002'
   and 'Castelfalfi' in (coalesce(title,''), coalesce(title_en,''))
   and exists (select 1 from ops_proposals p
                where p.id = 'e0530000-0000-0000-0000-000000000002' and p.responded_at is null);

update ops_proposal_items set
  choice_group = 'bulgari',
  photos = case when photos::text like '%junior-suite-bulgari-hotel-roma%' then photos
                else photos || E'["https://media.privateupgrades.com/_data/default-room_image/21/109649/junior-suite-bulgari-hotel-roma1_800x800_auto.jpg"]'::jsonb end
 where proposal_id = 'e0530000-0000-0000-0000-000000000002'
   and 'Bulgari Hotel Roma' in (coalesce(title,''), coalesce(title_en,''))
   and exists (select 1 from ops_proposals p
                where p.id = 'e0530000-0000-0000-0000-000000000002' and p.responded_at is null);

insert into ops_migrations (id) values ('0085-emily-v2-proposta-comercial') on conflict (id) do nothing;
