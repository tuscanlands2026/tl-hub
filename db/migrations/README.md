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

## Falta rodar

| # | arquivo | o que faz |
|---|---------|-----------|
| 0042 | [`0042-puxar-da-ficha.sql`](0042-puxar-da-ficha.sql) | a linha da proposta guarda de qual ficha de fornecedor ela foi puxada (procedência, não referência viva) |
| 0043 | [`0043-catalogo-vem-da-ficha.sql`](0043-catalogo-vem-da-ficha.sql) | a entrada do catálogo pode nascer da ficha, e um item da ficha tem no máximo uma entrada |
| 0044 | [`0044-itinerario-completo.sql`](0044-itinerario-completo.sql) | cabeçalho de fatos do itinerário: rota, duração e o "a partir de" que ela liga por proposta |
| 0045 | [`0045-dimora-ghirlandaio.sql`](0045-dimora-ghirlandaio.sql) | Dimora Ghirlandaio vira ficha de fornecedor, com as seis acomodações e as fotos de cada uma |
| 0046 | [`0046-borgo-vescine-ficha.sql`](0046-borgo-vescine-ficha.sql) | Borgo Vescine vira ficha, com as sete categorias de quarto; a linha de catálogo de agosto continua intacta |
| 0047 | [`0047-castelfalfi.sql`](0047-castelfalfi.sql) | Castelfalfi vira ficha, com as 24 categorias do fact sheet oficial; sem foto, porque o site recusa leitura |
| 0048 | [`0048-orient-express-venezia.sql`](0048-orient-express-venezia.sql) | Orient Express Venezia, no Palazzo Donà Giovannelli: dez categorias, com as seis Signature Suites e os afrescos de cada uma |
| 0049 | [`0049-collegio-alla-querce.sql`](0049-collegio-alla-querce.sql) | Collegio alla Querce, Auberge: 17 categorias com nome próprio; a Auberge não publica metragem |
| 0050 | [`0050-villa-san-michele.sql`](0050-villa-san-michele.sql) | Belmond Villa San Michele, Fiesole: as quatro famílias que a Belmond publica, com metragem e ocupação |
| 0051 | [`0051-four-seasons-firenze-e-danieli.sql`](0051-four-seasons-firenze-e-danieli.sql) | Four Seasons Firenze e Danieli Venezia, só a ficha do hotel: fourseasons.com é bloqueado e o press kit não traz os quartos |
| 0052 | [`0052-four-seasons-firenze.sql`](0052-four-seasons-firenze.sql) | Four Seasons Firenze em arquivo próprio, do fact sheet oficial em Word, com os cinco pontos de comida, a spa, o parque e 11 fotos do press kit |
| 0053 | [`0053-danieli-venezia.sql`](0053-danieli-venezia.sql) | Danieli Venezia em arquivo próprio, do comunicado oficial de reabertura, com 8 fotos do press kit |
| 0054 | [`0054-briefing-da-advisor.sql`](0054-briefing-da-advisor.sql) | briefing que a advisor responde por link próprio: quatro tabelas, versão a cada envio, prazo conferido no banco e aviso por e-mail |
| 0055 | [`0055-briefing-da-emily.sql`](0055-briefing-da-emily.sql) | o briefing da Emily carregado palavra por palavra, com as nove perguntas e validade em 15/11/2026 |
| 0056 | [`0056-proposta-sem-conta.sql`](0056-proposta-sem-conta.sql) | o valor da linha pode ser referência por noite em vez de total (sem somas e sem total na proposta), e a folha de pagamento e condições gerais vira escolha por proposta |
| 0057 | [`0057-valores-por-noite.sql`](0057-valores-por-noite.sql) | as noites de cada base entram na seção, o hub faz a estimativa da categoria para aquela estadia, e o aviso da tarifa dinâmica sai uma vez por folha |
| 0058 | [`0058-aman-cipriani-e-fotos-do-castelfalfi.sql`](0058-aman-cipriani-e-fotos-do-castelfalfi.sql) | fichas do Aman Venice (11 categorias) e do Belmond Hotel Cipriani (4 faixas, com o Palazzo Vendramin), e as fotos oficiais do Castelfalfi, que a 0047 não conseguiu ler |
| 0059 | [`0059-proposta-da-emily.sql`](0059-proposta-da-emily.sql) | **mexe em linha que já existe — só rodar depois do sim dela.** Monta a proposta TL-053-26 (`b59090ad-…`): nove hospedagens, três por base, com as noites de cada uma, valor indicativo ligado, folha de condições desligada, o aviso da tarifa em inglês, e apaga a linha de rascunho em branco (só se ela continuar vazia) |

Rodada, a linha desce para a tabela de baixo. Enquanto não roda, a proposta salva
normalmente e avisa que a procedência não foi gravada.

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
| 0030 | `0030-tipos-e-iva-do-crm.sql` | tipos de serviço e regimes de IVA iguais aos do CRM, inclusive o 12% que faltava |
| 0031 | `0031-agencia-e-advisor.sql` | agência e advisor na proposta e na order |
| 0032 | `0032-a-agencia-nao-e-destinatario.sql` | a agência deixa de ser destinatária do e-mail do cliente |
| 0033 | `0033-borgo-vescine.sql` | Borgo Vescine no catálogo |
| 0034 | `0034-conserta-as-fotos-da-v2.sql` | conserta as fotos da v2 do catálogo |
| 0035 | `0035-idioma-da-venda.sql` | a venda em inglês chega inteira: título resolvido no e-mail e na order, e-mail no idioma da proposta, tipo de quarto no lugar do texto de venda, unidades viram linha |
| 0036 | `0036-modelos-de-proposta.sql` | folha da curadoria (uma ou mais opções), modo de exibição por seção, tarifa net com link separado de valores, e a volta do "selecione a opção aprovada" |
| 0037 | `0037-proforma-invoice.sql` | proforma invoice da order: número próprio a partir de 159/26, gravado na order, e o texto de pagamento/dados bancários |
| 0038 | `0038-relatorio-em-ingles.sql` | versão inglesa inteira em inglês: instruções de emissão e dados em inglês, e o "Inclusos" com campo próprio (`commission_basis_en`) |
| 0039 | `0039-proforma-para-baixar.sql` | a proforma sai em PDF pelo servidor, com o link de pagamento clicável: leitura pública pelo token da order, só depois de emitida |
| 0040 | `0040-fornecedores.sql` | módulo de fornecedores: ficha, serviços com net/gross, faixas por pax, quartos e tarifas, contatos, fotos e anexos; listas fechadas por check e ligação opcional com o cadastro do CRM |
| 0041 | `0041-business-suite-do-crm.sql` | business suite passa a ser a lista do CRM (seis linhas, sem Consultoria) e converte as fichas já gravadas |
