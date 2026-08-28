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
| 0007 | `0007-quem-somos.sql` | quem somos e credenciais, na página antes do resumo |
| 0008 | `0008-quem-somos-oficial.sql` | troca pelo texto da apresentação corporativa dela |
| 0009 | `0009-textos-da-casa.sql` | as páginas que ela diagramou e a contracapa com os contatos |
| 0010 | `0010-ajustes-da-proposta.sql` | incluso por linha, forma de pagamento e a foto do sobre nós |
| 0011 | `0011-textos-editaveis.sql` | títulos e chamadas da proposta editáveis por ela |
| 0012 | `0012-hotel-em-roma.sql` | Palazzo Ripetta no catálogo e a hospedagem de Roma na TL-045-26 |
| 0013 | `0013-contracapa-com-foto.sql` | contracapa com foto de fundo do tamanho da tela |
| 0014 | `0014-unidades-e-extras.sql` | valor por acomodação, extras em grupo próprio, aviso no booking |
| 0015 | `0015-proposta-nasce-preenchida.sql` | proposta nova nasce com o texto e as fotos da casa |
| 0016 | `0016-prazo-do-link.sql` | prazo de validade do link da proposta, conferido nas duas pontas |
| 0017 | `0017-poggio-paradiso.sql` | Poggio Paradiso Resort & Spa no catálogo |
| 0018 | `0018-capa-no-catalogo.sql` | foto de capa no cadastro do catálogo |
| 0019 | `0019-capa-do-poggio.sql` | grava a capa sem depender da ordem das migrações |
| 0020 | `0020-poggio-completo.sql` | o Poggio com a capa, em um arquivo só |
| 0021 | `0021-proposta-da-agencia.sql` | proposta assinada pela agência: logo dela, página de respaldo, travel agent e travel designer no envio |
| 0022 | `0022-abertura-da-agencia.sql` | a folha de abertura da proposta da agência passa a ser a peça que as agências já aprovaram |
| 0023 | `0023-folha-em-duas-partes.sql` | a folha de abertura fica só com a chamada e o destino; o parágrafo da DMC vira texto à parte, incluído por botão |
| 0024 | `0024-escolhas-da-capa-e-do-envio.sql` | nome da capa escrito por ela, foto própria na folha do convite, bloco de envio simples e a foto institucional no "Sobre nós" |
| 0025 | `0025-conserta-a-folha-do-convite.sql` | preenche o inglês e a foto da folha do convite nas propostas que já existiam |
| 0026 | `0026-preco-no-catalogo-e-quantidade.sql` | valor de referência no catálogo, qtd × valor unitário na linha, e os transfers e tours padrão |
| 0027 | `0027-acaba-o-grupo-de-escolha.sql` | acaba o "escolha uma opção": toda linha fica aberta, e sai a conferência do grupo no banco |
| 0028 | `0028-nascimento-opcional.sql` | a data de nascimento do viajante vira escolha por order: exige, pede sem exigir, ou não pergunta |
| 0029 | `0029-venda-por-servico.sql` | tipo de serviço, nome curto, regime de IVA e custo previsto por linha da order |
