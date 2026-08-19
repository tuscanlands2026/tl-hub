-- =====================================================================
-- 0003 · O QUE A LINHA INCLUI, NO RELATÓRIO DE COMISSÃO
--
-- A alíquota muda conforme o que o serviço leva dentro, e o título da
-- linha não conta isso. Na TL-034-26 as cinco linhas começam com
-- "transfer" ou "motorista", mas uma tem só parada em Orvieto, outra
-- leva visita a vinícola com degustação, outra leva almoço típico
-- incluso, e a última passa no outlet. Transfer puro é 10%; transfer
-- com serviço dentro é 12%.
--
-- Esta coluna é o texto curto que diz o que a linha inclui. Ela aparece
-- no relatório, ao lado do percentual, para a agência entender por que
-- uma linha é 10 e a outra 12 sem precisar perguntar. E serve de base
-- para o botão de comissão padrão chutar melhor.
--
-- Só toca em objetos ops_. Nada fora desse prefixo.
-- =====================================================================

alter table ops_order_items add column if not exists commission_basis text;
comment on column ops_order_items.commission_basis is
  'O que esta linha inclui, em poucas palavras. Sai no relatório de comissão, ao lado da alíquota.';

insert into ops_migrations (id) values ('0003-inclusos-na-comissao')
on conflict (id) do nothing;
