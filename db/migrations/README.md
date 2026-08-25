# Migrações

Os arquivos em `db/` são o **schema atual**: servem para montar o banco do zero,
na ordem orders → opportunities → checkout → notify → quote.

Deste ponto em diante, **toda alteração vira um arquivo novo e numerado aqui**,
e nenhum arquivo já entregue é reescrito. O motivo é o histórico: reescrevendo o
mesmo arquivo não dá para saber o que já foi aplicado, e a única saída vira
"roda tudo de novo" a cada mudança.

## Regras

1. Um arquivo por alteração, numerado em sequência: `0003-...`, `0004-...`.
2. O arquivo termina se registrando em `ops_migrations`. É assim que o hub sabe
   o que falta rodar e avisa na tela, em vez de quebrar com erro de coluna.
3. Arquivo entregue não se edita. Errou, corrige no próximo número.
4. Só objetos com prefixo `ops_` e funções `tl_`. Vale a seção 7 do plano.
5. Rodar em ordem crescente, no SQL Editor do Supabase.

## Aplicadas

| # | arquivo | o que faz |
|---|---------|-----------|
| 0001 | `0001-controle-de-migracoes.sql` | cria `ops_migrations` e registra o que já estava no ar |
| 0002 | `0002-comissao-de-agencia.sql` | comissão por linha e o relatório para a agência |
| 0003 | `0003-inclusos-na-comissao.sql` | coluna do que a linha inclui, que justifica a alíquota |
| 0004 | `0004-destaque-no-texto-da-nota.sql` | sublinha o parágrafo da emissão para o exterior |
| 0005 | `0005-proposta-apresentada.sql` | capa, índice, hotel com site/quarto/fotos/anexo e itinerário |
| 0006 | `0006-catalogo.sql` | catálogo de hospedagens e experiências, copiado para a proposta |
