-- =====================================================================
-- 0062 · SAI A PROMESSA, FICA O FATO
--
-- Instrução dela, outubro/26: "cuidado que você escreve coisas que
-- depois eu não consigo prometer, isso é muito complicado... dá uma
-- revisada e tira essas coisas."
--
-- Ela está certa, e o padrão é meu: eu escrevo o que a TL VAI fazer
-- antes de alguém ter cotado, confirmado ou combinado nada. Varri tudo
-- que a advisor e a cliente leem. As descrições dos hotéis e a estrutura
-- estão limpas — são fato, e vêm da ficha de cada um. O que sobrou são
-- CINCO frases: quatro no briefing e uma na proposta.
--
-- O que NÃO foi tocado, de propósito: as frases de flexibilidade
-- ("we can replace one of the hill options", "we can also skip the
-- second move") e o escopo ("We will handle Venice as well"). Essas são
-- oferta e alcance, não promessa de execução, e são dela.
--
-- AS CINCO TROCAS, antes → depois:
--
-- 1. briefing
--    ANTES:  The Danieli reopened as a Four Seasons in July 2026 and is still restoring its Excelsior wing in 2027, so we will ask for a room away from any work and confirm the spa is open.
--    DEPOIS: The Danieli reopened as a Four Seasons in July 2026 and is still restoring its Excelsior wing in 2027.
--
-- 2. briefing
--    ANTES:  That is where we concentrate the experiences and the private access for them: estate kitchens, wine producers, artisan workshops.
--    DEPOIS: That is also where the experiences are: estate kitchens, wine producers, artisan workshops.
--
-- 3. briefing
--    ANTES:  and dinners in private palazzi we can open for them.
--    DEPOIS: and the dining that goes with them.
--
-- 4. briefing
--    ANTES:  With them confirmed, we prepare the full program: local coordination, VIP reception at the airport, every transfer, and a study of whether each leg works best with a rental car, a driver at their disposal or a mix.
--    DEPOIS: With them confirmed, the full program follows: local coordination, arrival and transfers, and a look at whether each leg works best with a rental car, a driver at their disposal or a mix.
--
-- 5. aviso da tarifa, que sai no pé de TODA folha da proposta
--    ANTES:  ...so the figures will move. Once the hotels are chosen we
--            request firm rates, with the bed configuration confirmed in
--            writing, and move to the formal proposal.
--    DEPOIS: ...so the figures will move.   (a frase inteira sai)
--
-- Todas são TROCA DE FRASE com guarda, e não reescrita do bloco: nada
-- mais do texto é tocado, e rodar duas vezes não faz nada na segunda.
-- Roda em qualquer ordem em relação à 0061 — são frases diferentes.
-- Se a 0055 ainda não tiver rodado, as quatro do briefing não acham nada.
--
-- CONFERÊNCIA DA SEÇÃO 7, relida antes de entregar. Os objetos que este
-- arquivo toca, um a um: ops_advisor_briefings (update de UMA coluna de
-- texto, por id), ops_proposals (update de UMA coluna de texto, por id)
-- e ops_migrations (insert). Nenhum drop, alter, truncate ou delete.
-- Nenhuma tabela do CRM é lida, escrita ou citada. Nenhum comando
-- percorre o schema. Nenhuma service_role key aparece aqui.
-- =====================================================================

-- 1 · O briefing da Emily -----------------------------------------------
update ops_advisor_briefings set content =
  replace(replace(replace(replace(content,
         E'The Danieli reopened as a Four Seasons in July 2026 and is still restoring its Excelsior wing in 2027, so we will ask for a room away from any work and confirm the spa is open.',
         E'The Danieli reopened as a Four Seasons in July 2026 and is still restoring its Excelsior wing in 2027.'),
         E'That is where we concentrate the experiences and the private access for them: estate kitchens, wine producers, artisan workshops.',
         E'That is also where the experiences are: estate kitchens, wine producers, artisan workshops.'),
         E'and dinners in private palazzi we can open for them.',
         E'and the dining that goes with them.'),
         E'With them confirmed, we prepare the full program: local coordination, VIP reception at the airport, every transfer, and a study of whether each leg works best with a rental car, a driver at their disposal or a mix.',
         E'With them confirmed, the full program follows: local coordination, arrival and transfers, and a look at whether each leg works best with a rental car, a driver at their disposal or a mix.'),
  updated_at = now()
 where id = 'b0000001-0000-0000-0000-000000000001'
   and content like '%confirm the spa is open%';

-- 2 · O aviso da tarifa da proposta -------------------------------------
update ops_proposals
   set rate_note_en = E'**These are indicative rates, not a quotation.** They are per night, before city tax, and reflect current pricing. Most of these hotels price 2027 dynamically, so the figures will move.',
       updated_at = now()
 where id = 'b59090ad-14dc-45d3-87f5-9f7206834668'
   and rate_note_en like '%confirmed in writing%';

insert into ops_migrations (id) values ('0062-sai-a-promessa') on conflict (id) do nothing;
