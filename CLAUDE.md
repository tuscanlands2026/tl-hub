# Tuscan Lands · Hub de Vendas e Operações

## O que é
Aplicação interna da Tuscan Lands Travel (DMC italiana, base em Pontassieve/FI, mercados
Brasil e América do Norte, operação de uma pessoa só). Substitui a produção manual de
documentos comerciais. Não substitui o CRM, que continua cuidando de pagamentos, margens
e faturamento.

## Estado atual
Módulo **Order** funcionando: login, lista de orders, editor, e página pública onde o
cliente ou a agência confere os serviços, informa os viajantes e aceita os termos. Ao
enviar, a order vira `confirmed` e os dados aparecem no editor. Order pode ser duplicada:
a cópia leva cabeçalho, serviços, parcelas e configuração do checkout, e não leva o link
nem a confirmação recebida.

O checkout é configurável por order: dentro do editor se escolhe quais campos aparecem
para a agência, quais são obrigatórios e quais já vão preenchidos para ela só confirmar.
Ao receber a confirmação, o banco manda o conteúdo inteiro por e-mail, e o editor abre um
resumo em PDF (Ctrl+P) para encaminhar à agência.

Arquivo único, sem build, sem framework. Vanilla JS + supabase-js via CDN.

## Arquitetura
- `index.html` — aplicação inteira. Roteamento por hash:
  - sem hash → app interno, exige login Supabase Auth
  - `#/confirm/TOKEN` → documento público do cliente, sem login
- `db/tl-hub-orders.sql` — schema, RLS e funções.
- `db/tl-hub-opportunities.sql` — oportunidade, briefing e proposta.
- `db/tl-hub-checkout.sql` — checkout configurável e link dos termos.
- `db/tl-hub-notify.sql` — aviso por e-mail quando a agência confirma.

Ordem de aplicação no SQL Editor: orders → opportunities → checkout → notify.

### Decisão de infraestrutura (tomada, não reabrir sem motivo)
As tabelas vivem **dentro do projeto Supabase do CRM**, não em projeto separado.
Motivo: o plano free dá duas vagas de projeto ativo, ambas ocupadas, e projeto free
é pausado após 7 dias sem requisições — um projeto só de orders ficaria dormindo
justamente entre uma venda e outra, e o link chegaria quebrado ao cliente.
Isolamento é feito por prefixo `ops_` e por RLS. Auditado antes de subir: nenhuma
tabela do CRM sem RLS, nenhuma policy para `anon` ou `public`.
Separar depois, se justificar: `pg_dump` filtrando `ops_*`.

### Tabelas
`ops_orders` · `ops_order_items` · `ops_order_payments` · `ops_order_confirmations` ·
`ops_order_fields` · `ops_notify_config` · `ops_notifications`

`ops_order_fields` são os campos variáveis daquele checkout. Os três estados da
especificação: **não aparece** é a linha não existir, **aparece vazio** é `mode='blank'`,
**aparece preenchido** é `mode='prefilled'` com `prefill_value`. Os blocos fixos —
contato, adultos, crianças, aceite de veículo, observações — moram em
`ops_orders.checkout_config`, junto com a quantidade de viajantes e o aviso de passaporte.
O aceite dos termos não é configurável: sem ele o banco recusa o envio.

O que a agência respondeu fica em `ops_order_confirmations.fields`, como retrato: rótulo,
estado e valor juntos, montado pelo banco a partir da configuração, nunca do que o
navegador mandou. Campo que não foi configurado não entra mesmo que venha no payload.

`opportunity_code` é texto livre, o número gerado no CRM. Sem foreign key para
`ops_opportunities` de propósito, para não acoplar aos objetos já existentes.

### Segurança
Tabelas fechadas para `authenticated`. O cliente nunca fala com elas: passa por duas
funções `security definer` que só enxergam a order do token recebido.
- `tl_get_order(p_token)` → devolve order + itens + pagamentos + campos do checkout
- `tl_submit_confirmation(p_token, p_payload)` → confere os obrigatórios, grava a
  confirmação e muda status. A conferência vive aqui, não só na tela: tela se contorna
  com o console aberto. Aponta qual linha de viajante está incompleta, não só que falta.

A chave da Resend fica em `ops_notify_config`, com RLS ligada e **nenhuma policy** — nem
`anon` nem `authenticated` leem. Se o e-mail falhar, a confirmação é gravada assim mesmo.

Token: 32 caracteres hex, gerado no banco. Nunca usar o código TL no link.
Campo `token_expires_at` existe e está sem uso por enquanto.

## Identidade visual — obrigatória em qualquer tela nova
Vale a seção 8 do `PLANO-HUB.md`, que substituiu a regra antiga deste arquivo.
A versão anterior pedia Sorts Mill Goudy nos títulos; não é mais assim, e as duas
instruções não podem conviver.

**Uma fonte só: Libre Franklin.** Variação por peso, tamanho e cor. Sem serifada.
300 para texto de documento, 400 para interface, 500 para labels, botões e títulos.

**Cor — corrigido em agosto/26, por instrução da Maria Fernanda.**
**Este módulo é todo sage `#595e49`**: interface, documento do cliente, resumo em PDF e
o e-mail de aviso. Sem exceção.

A seção 8 do plano reservava terracota para "confirmação e fechamento" e mandava o
documento do cliente sair nessa cor, para ele reconhecer a mesma cara da cotação. Não
vale mais: **terracota é do Booking, que é outro módulo.** Aqui não entra. A variável
`--terracotta` continua na paleta e está sem uso — não reintroduzir sem instrução dela.

Copper `#a56850` é o acento quente que sobrou: réguas, overlines de documento, marcação
de campo pré-preenchido.

Paleta de apoio: cream-light `#f6f3f0` · cream `#eae4db` · brown `#a2564c` ·
copper `#a56850` · ink `#2a2a28` · muted `#6b6860`.
**border-radius: 0 em tudo, sempre.** Sem exceção.
Overline em caixa alta, Libre Franklin 500, letter-spacing .18–.22em.
Régua de 30px em sage ou copper como acento, nunca linha de largura total.

**Densidade.** Interface é ferramenta usada horas por dia: peso 400, espaçamento apertado.
Documento que sai é outra coisa: peso 300, respiração ampla, texto justificado.

**Caixa alta só em rótulo curto.** Título de seção e label de uma ou duas palavras vão em
overline maiúsculo. Pergunta inteira ao cliente, não: em caixa alta parece grito. As
perguntas do checkout saem em caixa normal, peso 400, na cor do texto.

**Impressão.** Toda página de documento sai limpa em PDF pelo Ctrl+P. A regra de impressão
esconde interface, navegação e formulário, e deixa só o documento. É assim que o resumo
da confirmação vai para a agência — sem biblioteca de PDF, sem serviço novo.

## Regras de conteúdo
- Linhas de serviço são secas: data, serviço, condição. Sem narrativa, sem segunda pessoa.
- Nunca insinuar furar fila em serviço de aeroporto. A linguagem é orientação e assistência.
- Termos e condições em PT e EN estão no código, em `TERMS`. São texto jurídico da casa:
  não reescrever, não "melhorar", não resumir. Alterar só sob instrução explícita.
  O campo `terms_url` da order sai como link clicável no fim do documento, **em acréscimo**
  ao texto integral, nunca no lugar dele: o que o cliente assinou tem de estar no papel
  que ele assinou, e link é promessa que pode quebrar.
- Documento do cliente sai em PT ou EN conforme o campo `lang` da order.
- Depois da lista de serviços sai sempre: "Detalhes de horários e meeting point serão
  enviados no voucher de confirmação."
- `payment_note` é o que a agência informou sobre pagamento, ou "aguardando confirmação
  da agência". Sai embaixo das parcelas.

### Duas regras que mudaram em agosto/26, por instrução da Maria Fernanda
Substituem o que está escrito na seção 9 do `PLANO-HUB.md`. Não reverter sem instrução
explícita dela.

**Nome e data de nascimento de todos os viajantes, criança inclusive.** A regra anterior
era "idade de criança sim, nome de criança não". O motivo da mudança é operacional:
bilhete de monumento é nominal, e a data de nascimento é o que decide meia-entrada ou
gratuidade. Sem os dois a compra não sai. Quando `passport_names` está ligado, o
documento avisa que o nome precisa bater com o passaporte.

**A assinatura digitada saiu.** Ela repetia o nome do contato responsável, que já vem no
bloco de contato, e duas caixas para o mesmo nome só produzem divergência entre elas. O
ato que vale continua sendo o aceite dos termos, gravado com data e hora do envio. O
resumo em PDF diz "Confirmado por", com o nome do contato. As colunas `signature_name`
das confirmações antigas continuam onde estão e continuam sendo exibidas.

## Pendente
- A relação dos campos por tipo de serviço em `FIELD_LIB` (`index.html`). Os marcados
  `std:true` entram sozinhos em toda order nova e voltam pelo botão "Campos padrão":
  restrições alimentares, mobilidade e saúde, voo de chegada e voo de retorno. O resto da
  biblioteca é ponto de partida. Mexer nela não exige mexer no banco: rótulo, tipo e
  opções viajam junto com o campo escolhido.
- Módulo Briefing (etapa 1) e Proposta (etapa 2), travados em sequência: etapa posterior
  só abre quando a anterior estiver completa. Nunca pré-popular tarefa como se a
  aprovação já tivesse acontecido.
- Checklist operacional, gerado só após o checkout e só com os serviços que o cliente
  efetivamente selecionou.
- Busca, histórico e filtro por data, cliente e tipo de serviço.
- Exportação para alimentar o faturamento no CRM, com o hub como fonte de verdade.

## Como trabalhar aqui
Pensar a implicação lógica antes de escrever código ou texto. Não produzir e depois
descobrir a contradição. Decisão parcial se guarda e se espera a especificação fechada.
