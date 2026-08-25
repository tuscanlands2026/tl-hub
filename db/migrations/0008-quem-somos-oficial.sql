-- =====================================================================
-- 0008 · O TEXTO OFICIAL DO "QUEM SOMOS"
--
-- A 0007 entrou com um texto que eu escrevi. Ela mandou a apresentação
-- corporativa (workingwithtl.netlify.app), e o texto de lá é o da casa:
-- DMC boutique com base em Florença, fundada em 2018, B2B e white-label,
-- licenciada com Direttore Tecnico. O que ela já escreveu vale mais do
-- que o que eu redigiria.
--
-- Arquivo novo em vez de editar a 0007, que já pode ter rodado.
-- O update só troca o que ainda for exatamente o que a 0007 gravou: se
-- ela já editou, fica como está.
--
-- Só toca em objetos ops_. Nada fora desse prefixo.
-- =====================================================================

update ops_text_defaults
   set pt = E'Uma DMC boutique, com base em Florença. Fundada em 2018.\n- Trabalhamos exclusivamente no Centro da Itália, sempre por meio de agências e travel advisors: modelo 100% B2B e white-label.\n- DMC licenciada na Itália, com certificação de Direttore Tecnico.\n- Equipe multicultural, com foco nas Américas.\n- Atendimento e propostas em português, inglês e italiano.', en = E'A boutique DMC based in Florence. Founded in 2018.\n- We work only in Central Italy, and always through agencies and travel advisors: fully B2B and white-label.\n- Licensed Italian DMC, with Direttore Tecnico certification.\n- Multicultural team, focused on the Americas.\n- Service and proposals in English, Portuguese and Italian.', updated_at = now()
 where key = 'about'
   and pt like 'A Tuscan Lands é um DMC boutique com base em Pontassieve%';

insert into ops_migrations (id) values ('0008-quem-somos-oficial')
on conflict (id) do nothing;
