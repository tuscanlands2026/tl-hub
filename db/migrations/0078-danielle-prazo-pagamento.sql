-- =====================================================================
-- 0078 · DANIELLE (TL-055-26): O PRAZO DO SALDO
--
-- Ela ajustou (out/26): o saldo é "up to 45 days before travel" (até 45
-- dias antes), e não "45 to 50 days". O sinal de 35% e o pagamento por
-- cartão ou transferência já estão no texto (0073). Também pediu "não diga
-- 65%, diga the balance" — o texto já diz "the balance", então não muda.
-- Em inglês, que é a língua desta proposta.
--
-- Troca só a frase do prazo, nas colunas de condições onde ela estiver.
-- Guardado: não acha a frase (ela reescreveu) → não muda nada.
--
-- Seção 7: ops_proposals (update guardado) e ops_migrations (insert).
-- Sem drop/truncate/delete. Nenhuma tabela do CRM. Rodar depois da 0073.
-- =====================================================================

update ops_proposals set conditions = replace(conditions,
    'the balance is due 45 to 50 days before travel',
    'the balance is due up to 45 days before travel')
 where id = 'f1d3d719-5142-43e7-9359-e2b7249a25d6'
   and position('the balance is due 45 to 50 days before travel' in coalesce(conditions,'')) > 0;

update ops_proposals set conditions_en = replace(conditions_en,
    'the balance is due 45 to 50 days before travel',
    'the balance is due up to 45 days before travel')
 where id = 'f1d3d719-5142-43e7-9359-e2b7249a25d6'
   and position('the balance is due 45 to 50 days before travel' in coalesce(conditions_en,'')) > 0;

update ops_proposals set conditions_pt = replace(conditions_pt,
    'the balance is due 45 to 50 days before travel',
    'the balance is due up to 45 days before travel')
 where id = 'f1d3d719-5142-43e7-9359-e2b7249a25d6'
   and position('the balance is due 45 to 50 days before travel' in coalesce(conditions_pt,'')) > 0;

insert into ops_migrations (id) values ('0078-danielle-prazo-pagamento') on conflict (id) do nothing;
