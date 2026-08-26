# Tuscan Lands · Hub de Vendas e Operações

## O que é
Aplicação interna da Tuscan Lands Travel (DMC italiana, base em Pontassieve/FI, mercados
Brasil e América do Norte, operação de uma pessoa só). Substitui a produção manual de
documentos comerciais. Não substitui o CRM, que continua cuidando de pagamentos, margens
e faturamento.

## Estado atual
Entrar no hub cai no **Painel**: fundo sage, caixas em creme, uma por área. O número grande
de cada caixa é sempre o que espera por ela — não o total. Total não pede nada a ninguém, e
a queixa que originou a tela foi conferir a mesma coisa três, quatro vezes por medo de
esquecer.

A navegação lateral só aparece depois de entrar numa caixa, agrupada por área — Vendas,
Operações — com os grupos abrindo e fechando, e "← Painel" no topo. O plano proíbe lista
corrida de abas: o CRM sofre desse problema e não deve ser replicado.

Módulo **Oportunidade + Briefing** funcionando: lista com a etapa lida dos filhos, cadastro,
editor, e o briefing em campos com documento em PDF pelo Ctrl+P. O briefing é escrito em
colunas e não anexado como arquivo — decisão da seção 6 do plano, que dizia "estruturado
alimenta proposta e checklist sem redigitar". Sem Supabase Storage, sem upload.

**Order ainda não se liga à oportunidade pela tela.** A coluna `opportunity_id` existe e o
gatilho `tl_guard_order` bloqueia order de oportunidade sem proposta aceita. Ligar as duas
sem a etapa de proposta faria a gravação falhar com erro de banco na cara dela. Fica para
quando a proposta existir; até lá a order segue com `opportunity_code` como texto.

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
- `db/tl-hub-quote.sql` — proposta que o cliente escolhe, e a order gerada dela.
- `db/tl-hub-notify.sql` — aviso por e-mail quando a agência confirma.

Ordem de aplicação no SQL Editor: orders → opportunities → checkout → notify → quote.

**Daqui em diante, arquivo entregue não se reescreve.** Toda alteração de banco vira um
arquivo novo e numerado em `db/migrations/`, que se registra em `ops_migrations` ao rodar.
Foi instrução dela, em agosto/26, e o motivo é o histórico: reescrevendo o mesmo arquivo
não dá para saber o que já foi aplicado, e a única saída vira "roda tudo de novo" a cada
mudança. O hub lê `ops_migrations`, compara com a lista `MIGRACOES` do `index.html` e
avisa no Painel qual arquivo falta, com link — em vez de quebrar com nome de coluna na
tela de quem não programa. Errou numa migração, corrige na próxima; não edita a anterior.
`db/exemplo-quote-TL-039-26.sql` carrega a proposta real da Camila como dados de exemplo.

**Catálogo.** `ops_catalog` guarda hospedagem e experiência que se repetem entre propostas;
a proposta leva uma **cópia**, nunca uma referência viva. Já cadastrados: Villa Ghirlandaio
(`db/catalogo-villa-ghirlandaio.sql`) e Palazzo Ripetta, em Roma (migração 0012). Dado de
hotel se escreve do que está publicado, e não de memória: a metragem da Ghirlandaio veio da
planimetria, e a do Ripetta da ficha dele no Relais & Châteaux, porque o site do hotel
recusa leitura automatizada. Data e valor nunca vêm do catálogo — são desta venda.

**Quote simples.** É o modelo sem a proposta "bonita": serve para hospedagem mais
serviços terrestres, e para orçamento avulso de transfer. As linhas se agrupam em
**seções** (`ops_proposals.sections`, chave em `ops_proposal_items.section`), e cada seção
vira uma tabela própria com título e instrução — "Selected Stays", "Ground Services".
Linha sem seção cai numa tabela final sem título: transfer avulso não precisa de seção.

O preço aparece em **toda** linha, inclusive na que não foi escolhida — apagado, porque
não está somando. Traço no lugar do valor escondia do cliente o preço do que ele não levou.

**Toda linha tem caixinha.** Não existe serviço que entre sozinho: a proposta manda duas
hospedagens na Umbria, duas em Florença e os serviços terrestres, e quem monta a viagem é o
cliente. Envio sem nenhum serviço marcado é recusado na tela e no banco (`missing_items`) —
viraria order vazia depois. `choice_group` continua existindo para o caso de "uma destas
duas e só uma", mas não é mais o normal. O extra é subitem de uma linha — assistente em
português, contratação fora do horário — e só conta se a linha dele foi escolhida.

**A parte fixa depois das tabelas, em duas camadas.** É fixa no sentido de que toda proposta
tem de ter, e variável no sentido de que o texto muda de uma para outra. `ops_text_defaults`
guarda o padrão da casa, de onde toda proposta nova nasce preenchida; `ops_proposals`
guarda a cópia daquela proposta, que ela edita sem mexer nas outras. Sem a primeira camada
ela redigita tudo toda vez; sem a segunda, corrigir uma proposta mudaria o texto de
propostas já enviadas. O padrão em português veio da TL-039-26 palavra por palavra — é
texto comercial da casa, não se reescreve. O inglês nasce em branco de propósito: cláusula
comercial não se traduz por conta própria.

**Tudo bilíngue**: `conditions_pt`/`conditions_en`, `excluded_pt`/`excluded_en`, e
`title`/`title_en` · `note`/`note_en` em cada seção. `tl_get_quote` resolve pelo idioma da
proposta e cai no português quando a tradução não foi escrita.

**A proposta fecha com o resumo da escolha.** Página própria, com só o que o cliente
marcou, os extras dele e o total — depois das tabelas e antes das condições. É a página que
ela confere antes de gerar a order, e é o que o cliente aprova. Decisão dela em agosto/26:
um documento só, com valores, em vez de uma peça bonita sem preço mais um orçamento à
parte. Dois cadastros para a mesma venda divergem, e aí o cliente aprova uma coisa e a
agência outra. `show_prices` continua sendo a chave para o caso de mandar sem valor.

**"Não inclusos" não é da parte fixa.** Muda de opção para opção — na opção com transfer
exclui aluguel de carro, na opção com carro alugado exclui combustível e pedágio. Por isso
mora na proposta e sai junto das tabelas, na mesma folha se couber. A página separada é só
a de forma de pagamento e condições gerais.

`ops_proposals.conditions` é a forma de pagamento e as condições gerais, em texto simples:
linha começando com `-` vira item de lista, `**texto**` vira negrito, `__texto__` vira
sublinhado. Sai em **página
separada depois das tabelas**. O negrito tem peso declarado em 500 no CSS: o `bolder` do
navegador é relativo e, contra o peso 300 do documento, resolve para 400 e some.

O **aceite das condições comerciais** é obrigatório e conferido no banco, não só na tela —
`tl_submit_quote` devolve `missing_ack` sem ele.

**Dois campos que o cliente nunca vê.** `ops_proposals.internal_notes` (valor net, margem)
e `ops_proposal_items.supplier` (qual fornecedor opera a linha). Nenhum dos dois sai em
`tl_get_quote`, e `supplier` também não sai em `tl_get_order`: as duas funções montam o
objeto **campo a campo**, justamente para que coluna nova não vaze sozinha por ter sido
adicionada à tabela. O fornecedor desce para `ops_order_items.supplier` quando a proposta
vira venda — é na operação, ao reconfirmar e pagar, que o dado serve.

**Quote.** A proposta vira documento com token próprio. Linha `optional=false` é inclusa e não
se desmarca; `true` o cliente escolhe. Cada linha carrega seus extras em jsonb — transporte,
anfitrião, visita guiada — cada um com preço próprio e caixa à parte. `show_prices=false`
manda a proposta sem valor nenhum.

Responder **não é aceitar**: `tl_submit_quote` grava o retrato da escolha, marca
`responded_at`, manda e-mail e não cria order. Entre o pedido do cliente e o compromisso
existe a reconfirmação dos serviços com os fornecedores. A order nasce quando ela chama
`tl_order_from_quote`, que marca a proposta como aceita antes de inserir a order, na mesma
transação — é o caminho que o gatilho `tl_guard_order` exige, e é por isso que a order
finalmente se liga à oportunidade. Extra marcado vira linha própria na order.

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
`ops_order_fields` · `ops_notify_config` · `ops_notifications` · `ops_text_defaults` ·
`ops_migrations`

`ops_order_fields` são os campos variáveis daquele checkout. Os três estados da
especificação: **não aparece** é a linha não existir, **aparece vazio** é `mode='blank'`,
**aparece preenchido** é `mode='prefilled'` com `prefill_value`. Os blocos fixos —
contato, adultos, crianças, aceite de veículo, observações — moram em
`ops_orders.checkout_config`, junto com a quantidade de viajantes e o aviso de passaporte.

Dois aceites não são opcionais. O dos **termos** não é configurável de jeito nenhum: sem
ele aquilo não é confirmação. O de **bagagem** é configurável em aparecer ou não, mas não
em ser opcional — aparecendo, o banco exige que seja marcado. Bagagem além do previsto
significa veículo maior no dia, com custo que ninguém combinou.

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

**Duas versões do logo, escolhidas pelo fundo e não por gosto.** Terracota
(`i.postimg.cc/k45xbsK4/grosseto.png`) nas peças claras — documento, PDF, papel. Branco
(`i.postimg.cc/CMnPydqx/white.png`) sobre sage e sobre foto — capa e índice da proposta
apresentada. Testado sobre os quatro fundos: terracota some no sage e branco some no creme.
Existe uma terceira, verde (`livorno`), sem uso: sobre creme ela é mais fraca que a
terracota e sobre sage não aparece.

**Capa e contracapa são as duas peças de foto cheia.** A última página — a de contato — é
o fechamento da proposta, e sai com foto de fundo do tamanho da tela, como a capa. Instrução
dela em agosto/26. A foto mora em `ops_proposals.backcover_img`, com padrão da casa em
`ops_text_defaults`, pelo mesmo motivo do `about_img`: trocar a foto de fechamento não pode
mudar proposta já enviada. Proposta sem foto continua saindo em creme com o logo terracota.

**No papel, as três peças de foto saem com a foto.** Capa, foto de seção e contracapa levam
`print-color-adjust: exact`. A foto está no atributo `style` do elemento e regra de folha
não ganha de `style` — "apagar o fundo na impressão" nunca funcionou. O que a página tinha
era o pior dos dois: a foto saía se a pessoa marcasse "gráficos de fundo" na caixa de
impressão, e o texto já estava escuro para o caso de ela não marcar, então título de seção
branco caía sobre foto e sumia. Agora as três saem sempre com a foto e sempre com texto
branco. Onde a foto não carregar, o fundo é o sage, e branco sobre sage se lê.

**Uma exceção, pedida por ela em agosto/26: o relatório de comissão sai em copper**, não
em sage — título, cabeçalho da tabela, réguas e caixa do total. O motivo é que ele tinha
a mesma cara do pedido de serviços e os dois se confundiam: são documentos diferentes,
para pessoas diferentes. Continua dentro da paleta, e **terracota segue sem uso** — é do
Booking. Nenhum outro documento muda de cor sem instrução dela.

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

**Título de tela não se escreve no código.** "Sobre nós", "Proposta e condições comerciais",
o convite da capa, o aviso de que enviar não bloqueia — tudo isso tem padrão no hub e cópia
opcional em `ops_proposals.labels`. Campo vazio usa o padrão; preenchido, vale o dela e só
naquela proposta. Foi instrução dela em agosto/26: "não dá pra ficar pedindo pra alterar o
código toda vez". Rótulo novo entra na lista `ROTULOS` do `index.html` e passa por `rot()` —
rótulo que escapa desse caminho volta a ser texto que só eu consigo mudar.

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
- A capa e as páginas de apresentação da proposta — o material "bonito" que hoje ela monta
  fora do hub: capa, quem é a Tuscan Lands, descrição das hospedagens com foto e link,
  moodboard. A quote cobre a parte operacional, que é o que o cliente escolhe e quanto
  custa. Decidido em agosto/26 deixar para depois, não esquecido.
- Checklist operacional, gerado só após o checkout e só com os serviços que o cliente
  efetivamente selecionou. Especificação já dada por ela: resumo do cliente com telefone,
  agência e data; serviços dia por dia; o que está pendente de pagamento e de link;
  conferência dos nomes contra o passaporte; bilhete comprado ou não; e caixas para marcar
  agendado e reconfirmado. Falta ver a referência que ela quer mostrar.
**Comissão de agência.** Relatório interno que sai da order: por serviço, o percentual e
o valor da comissão, mais os dados para a agência emitir a nota e os dados da remessa.
A alíquota fica na **linha** (`ops_order_items.commission_pct`), não na order, e é número
livre: transfer puro costuma ser 10%, transfer com serviço dentro 12%, e **há fornecedor
que comissiona 15%** — ela vai lançando conforme o caso. Uma alíquota por order obrigaria
a errar em alguma linha.

`ops_order_items.commission_basis` é o texto curto do que a linha inclui. Sai como coluna
no relatório, ao lado da alíquota: é o que explica à agência por que uma linha é 10 e a
outra 12 sem ela ter de perguntar.

O que separa 10 de 12 não é o nome da linha, é o que ela leva dentro. Na TL-034-26 as cinco
começam com "transfer" ou "motorista": a de Orvieto tem só parada (10%), a do Chianti leva
vinícola com degustação (12%), a da Val d'Orcia leva almoço típico incluso (12%), e a do
outlet tem só parada (10%). **Parar em algum lugar não é serviço contratado**; por isso a
palavra "visita" sozinha não decide nada — as duas pontas têm "visita" no texto.

O botão "Comissão padrão" lê o campo Inclusos, e na falta dele o título com os detalhes.
**Só preenche linha em branco**, nunca sobrescreve o que ela já lançou, e é sugestão para
conferir. Linha sem percentual não entra no relatório: em branco significa "ainda não
decidi", e sair com zero afirmaria que não há comissão.
Os dois blocos de texto do relatório — dados fiscais e como emitir a nota — moram em
`ops_text_defaults`, editáveis sem mexer em código. `commission_pct` não sai em
`tl_get_order`.

- Busca, histórico e filtro por data, cliente e tipo de serviço.
- Exportação para alimentar o faturamento no CRM, com o hub como fonte de verdade.

## Como trabalhar aqui
Pensar a implicação lógica antes de escrever código ou texto. Não produzir e depois
descobrir a contradição. Decisão parcial se guarda e se espera a especificação fechada.
