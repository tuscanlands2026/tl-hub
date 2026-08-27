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

**Catálogo.** `ops_catalog` guarda hospedagem, transfer e experiência que se repetem entre
propostas; a proposta leva uma **cópia**, nunca uma referência viva. **O cadastro é dela**:
tela Operações → Catálogo, com busca, filtro por tipo e edição. Até agosto/26 só se
cadastrava por SQL, o que na prática queria dizer que só eu cadastrava — e ela pediu para
montar o banco dos transfers e dos extras que voltam sempre. Apagar do catálogo não mexe em
proposta nenhuma, porque a linha é cópia.

**O catálogo guarda preço de referência, e diz de quando é.** Pedido dela em agosto/26 para a
quote simples: transfer e tour se repetem, e redigitar nome, descrição e valor a cada proposta
é onde o erro entra. `ops_catalog.price` desce para a linha como **ponto de partida**, com
`price_unit` (por veículo, pessoa, grupo ou dia — sem isso 450 não quer dizer nada),
`price_note` ("até 3 pax") e `price_updated_at`. A data não é enfeite: preço velho puxado em
silêncio é o risco real, e ela aparece no cadastro e no aviso ao puxar. A data só se move
quando o valor se move — salvar o cadastro para corrigir uma vírgula não pode fazer um preço
de três meses atrás parecer conferido hoje.

Isto **não** revoga "valor é desta venda": o preço continua sendo dela na linha, e mudar a
linha não volta para o cadastro. O que mudou é que conferir um número na tela erra menos que
digitar de cabeça.

**A linha tem quantidade e valor unitário, mas quem soma é `price`.** `qty × unit_price`
alimenta `price`, que continua sendo o **total da linha** e a única coisa que soma no hub
inteiro — total da proposta, e-mail, order gerada, relatório de comissão. Se a quantidade
virasse um segundo fator a multiplicar em cada um desses lugares, bastaria esquecer de um para
a proposta e a order divergirem. Mexeu na quantidade ou no unitário, o total recalcula; mexeu
no total, o total é dela. Sem unitário lançado a quantidade não multiplica nada — a linha é um
valor fechado, como sempre foi. No documento sai "2 × € 480,00" embaixo do título, só com
quantidade acima de um e só quando a proposta leva valores.

Já cadastrados: Villa Ghirlandaio (`db/catalogo-villa-ghirlandaio.sql`), Palazzo Ripetta em
Roma (migração 0012) e Poggio Paradiso Resort & Spa na Val d'Orcia (0017). Dado de hotel se
escreve do que está publicado, e não de memória: a metragem da Ghirlandaio veio da
planimetria, e a do Ripetta da ficha dele no Relais & Châteaux, porque o site do hotel
recusa leitura automatizada. O site do Poggio Paradiso não publica metragem nem ocupação das
suítes — ficou em branco para ela preencher. Data e valor nunca vêm do catálogo — são desta
venda.

**Quote simples.** É o modelo sem a proposta "bonita": serve para hospedagem mais
serviços terrestres, e para orçamento avulso de transfer. As linhas se agrupam em
**seções** (`ops_proposals.sections`, chave em `ops_proposal_items.section`), e cada seção
vira uma tabela própria com título e instrução — "Selected Stays", "Ground Services".
Linha sem seção cai numa tabela final sem título: transfer avulso não precisa de seção.

O preço aparece em **toda** linha, inclusive na que não foi escolhida — apagado, porque
não está somando. Traço no lugar do valor escondia do cliente o preço do que ele não levou.

**Toda linha tem uma caixinha quadrada, e nenhuma exclui outra.** Instrução dela em
agosto/26, em duas etapas. Primeiro o rádio saiu, porque rádio não desmarca — ela clicava sem
querer e ficava presa com o serviço dentro da proposta. Depois acabou a própria exclusividade:
na venda real o cliente aprova este serviço **e** aqueles outros, e cada linha tem de ficar
aberta. A etiqueta "escolha uma opção" e o grupo saíram das duas pontas — da tela e da
conferência do banco. Deixar só a do banco seria o pior dos mundos: a tela não fala de grupo
nenhum, e o cliente levaria um "falta escolher em: hotel_umbria" sem ter como entender.

`choice_group` continua na tabela e nas respostas já gravadas, sem uso — resposta antiga não
se reescreve. O campo saiu do editor, e o total do editor voltou a ser soma reta: antes o grupo
entrava só com a linha mais cara dele, o que agora esconderia linha da conta.

A caixinha diz **"Selecione para aprovar este serviço"**, rótulo dela, editável em `ROTULOS`
pela chave `approve`.

**Não existe serviço que entre sozinho.** A proposta manda duas hospedagens na Umbria, duas em
Florença e os serviços terrestres, e quem monta a viagem é o cliente. Envio sem nenhum serviço
marcado é recusado na tela e no banco (`missing_items`) — viraria order vazia depois. O extra é
subitem de uma linha — assistente em português, contratação fora do horário — e só conta se a
linha dele foi aprovada.

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

**A acomodação pode ter valor por unidade.** `ops_proposal_items.units` é do que a
hospedagem é feita, com preço em cada linha: no Palazzo Ripetta são 1 quarto Prestige e
2 apartamentos Luxury, e o valor sai separado, não como um número fechado. `optional=true`
na unidade dá caixinha ao cliente — é o caso de oferecer duas opções de quarto no mesmo
hotel; `optional=false` faz parte da hospedagem e entra sempre. Sem unidade nenhuma a
linha continua com um valor só. **Unidade não é extra**: extra é o que se soma por fora,
unidade é do que a hospedagem é feita. Havendo unidades, o campo Acomodação some do card —
as duas coisas juntas repetiriam a mesma informação.

**A capa da folha da hospedagem tem plano B.** É a foto da seção; não tendo, vale a primeira
foto da primeira hospedagem daquela folha. Melhor a foto do hotel do que uma faixa vazia, e
tira a dependência de colar o mesmo link em dois lugares. Escolhendo uma na seção, a dela
ganha.

**"Sobre nós" vem logo depois da capa**, e não no fim — instrução dela em agosto/26: o
cliente sabe com quem está falando antes de ver o que está sendo proposto.

**A página da proposta agrupa por tipo, não por seção.** `ops_proposal_items.kind` vale
`stay` ou `extra`, e a página sai em "Hospedagens" e "Extras e opcionais (válidos para a
contratação da hospedagem)" — os dois títulos editáveis por ela. Seção é a etapa da
apresentação: "10 a 13 out" e "13 a 17 out" são folhas do documento, não categorias de
venda, e uma coisa não serve para a outra. O `extra` **não vira etapa da apresentação**:
uma folha inteira de capítulo para um transfer é folha que ninguém pediu.

**A proposta pode sair assinada pela agência.** Instrução dela em agosto/26, depois de uma
agência reclamar que a peça estava personalizada demais da Tuscan Lands. Numa venda em que a
agência é a dona do cliente, quem assina é a agência: `ops_proposals.white_label` liga, e com
ele o logo da capa é o de `agency_logo` (com `agency_logo_bg` para o fundo branco atrás do logo
escuro), a folha de abertura passa a ser o texto de respaldo em vez do "Sobre nós", a contracapa
de contato da Tuscan Lands não sai, e o envio pede **travel agent** e **travel designer**.

**É uma chave só, e não cinco.** As cinco peças se movem juntas — deixar cada uma com a sua
chave seria deixar uma para ela esquecer de virar, e proposta meio white label é pior que
nenhuma. Nasce desligada: proposta que já existe não muda de cara.

**As credenciais não saem na proposta apresentada.** Instrução dela em agosto/26, olhando a
proposta da agência: a lista de números de registro no meio de uma folha que fala da Itália é
ruído, e reivindica a venda justamente na página em que quem assina é a agência. Antes ficavam
embaixo do "Sobre nós" e da folha do convite. As colunas `credentials_pt/_en` continuam na
proposta e no padrão da casa — o que saiu foi a exibição, e o campo saiu do editor junto.
**Não repor sem instrução dela.**

**A folha de abertura é a peça que as agências já aprovaram.** A primeira versão explicava a
divisão de trabalho — quem desenha, quem opera. Ela apontou a proposta real: a folha que já
rodou e foi aprovada é a "Transformando a Itália em histórias inesquecíveis", que fala da
Itália e não de quem vende. Então é essa, palavra por palavra como está no texto da casa: a
chamada e o parágrafo do destino, e mais nada. O que sai é a parte em que a Tuscan Lands se
apresenta — oito anos, rede de parceiros, curadoria — que é o que tirava o foco da agência. As credenciais saíram junto, por instrução dela.

**O parágrafo da DMC licenciada é dela incluir ou não.** Tem agência que pede o respaldo escrito
e tem agência que prefere sem. Fica em `ops_text_defaults` na chave `assurance_note` e entra na
folha por um botão no editor: incluir é um clique, tirar é apagar. Não virou coluna própria
porque não tem lugar próprio no desenho da folha — ele entra no fim do mesmo texto corrido.

Padrão da casa em `ops_text_defaults`, cópia em `ops_proposals.assurance_pt/_en`, como todo
texto daqui. Onde estiver `{agencia}` entra o nome da agência da oportunidade, **resolvido em
`tl_get_quote`** e não na tela, para valer igual na página, no PDF e no e-mail.

Três coisas que essa folha herdaria erradas se ninguém olhasse: a foto é a do retrato da
fundadora, que numa proposta da agência contradiz a própria página — sai a foto da primeira
hospedagem, e na falta dela a da capa; o negrito ali é a chamada grande, em bloco próprio, de
modo que `**` no meio da frase parte o parágrafo em três, e por isso o texto padrão só tem
negrito na primeira linha; e a faixa da foto não leva título, porque a chamada do texto já é o
título e dois títulos na mesma folha disputam a leitura.

`designer_name` fica em `ops_proposal_selections`, não é obrigatório — quem responde muitas
vezes é a mesma pessoa — e sai no e-mail e no editor quando vem preenchido.

**O bloco de envio tem dois tamanhos.** O completo é o de sempre. O simples é uma caixinha só —
"confirmo interesse nos serviços" — e mais nada: nem nome, nem e-mail, nem forma de pagamento.
`ops_proposals.confirm_mode` escolhe, por proposta. O que sustenta a tela mais curta é o aviso
que já estava logo acima dela, o de que enviar não bloqueia nem reserva nada.

No simples o nome deixa de ser exigido **no banco também**, e não só na tela: pedir nome numa
tela sem campo de nome travaria o envio. Quem respondeu continua sabido, porque o link é da
proposta e a proposta é da oportunidade, que tem a agência. A caixinha continua obrigatória nos
dois casos, e a resposta guarda em `ops_proposal_selections.confirm_mode` **o que foi
perguntado** — sem isso, confirmação de interesse ficaria gravada com a mesma cara de quem
aceitou as condições comerciais, e não é a mesma coisa.

**O nome grande da capa é texto dela.** Era sempre o cliente final, ou a agência. Agora é
`ops_proposals.cover_title`: ela escreve o que quiser, e apagando a capa sai sem nome — só a
tarja, as datas e o número. Nulo continua caindo no comportamento antigo, resolvido em
`tl_get_quote`, para proposta que já existe não mudar sozinha; vazio é vazio de propósito, e
por isso esse campo é o único que **não** vira `null` ao ser salvo em branco.

**A folha do convite tem foto própria**, `assurance_img`, e em branco sai sem faixa de foto —
a folha vira texto na largura inteira. Antes ela herdava a foto da primeira hospedagem, que
ela não tinha escolhido. Folha sem foto precisa de `.ap-sec.sem-foto`: sem isso a coluna da
foto continua reservada na grade e sobra um retângulo escuro ao lado do texto.

**Link dos termos e rodapé da empresa não saem na página da proposta.** A contracapa é a
página de contato, e repetir a mesma assinatura duas telas antes polui justamente a
página onde o cliente está escolhendo. Continuam saindo no documento da order e na quote
simples, onde não há contracapa.

**A descrição do serviço também passa por `fmtDoc`**, na apresentação e na tabela da
proposta: `**negrito**`, `__sublinhado__` e `-` virando lista funcionam nela como no resto
do texto dela. Antes só quebrava linha, e os asteriscos saíam impressos na proposta.

**Marcar um serviço não rola a página.** O redesenho passava por `apIr`, que ia para o
topo: ela marcava uma caixinha, a tela subia, e ela descia de novo para a seguinte. `apIr`
só rola quando a etapa muda, e o redesenho da escolha guarda e devolve a posição.

**Incluso e Estrutura saem uma informação por linha.** Passam por `fmtDoc`, como o resto
do texto que ela escreve: quebra de linha vale, `-` vira lista e `**negrito**` funciona.
Amontoados num parágrafo só ninguém acha nada — foi assim que ela viu e reclamou.

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
`token_expires_at` existe na order e na proposta, e é conferido nas duas pontas — na
função que lê e na que grava. Quem deixou a página aberta desde antes da data não passa a
poder enviar depois: tela se contorna com o console aberto, função não. Vazio é o normal.

**Quem decide a etapa da oportunidade é o "aceita" da proposta**, não a resposta do
cliente: `tl_opportunity_stage` olha `ops_proposals.outcome`. Por isso apagar a resposta
também desmarca a aceitação — sem isso a oportunidade ficava presa na etapa Order depois
de um teste. E por isso existe o botão de **desmarcar como aceita**, que aparece quando a
proposta consta aceita sem resposta; ele confere antes se já nasceu order da oportunidade
e se recusa quando nasceu: ali a aceitação deixou de ser rascunho.

**Apagar a resposta do cliente** devolve a proposta ao estado de não respondida e o link
volta a aceitar envio. Serve para o teste que ela faz antes de mandar e para a agência que
respondeu errado. Some depois que a order foi gerada: ali a resposta deixou de ser
rascunho e virou o documento que originou uma venda.

**Anexo é arquivo, e não link.** O campo era "nome | endereço", e o PDF da planimetria está
no computador dela, não hospedado em lugar nenhum — o anexo nunca aparecia na proposta do
cliente. O arquivo sobe pelo hub para o Storage do Supabase, balde **`ops-anexos`**, e o que
fica gravado em `ops_proposal_items.attachments` continua sendo `{name, url}`: nada mudou
para quem lê. Colar um link continua existindo, para o arquivo que já mora em outro lugar.
Limite de 10 MB, e a chave do arquivo é higienizada — Storage não aceita acento nem espaço.

O balde é **público de leitura**, como o link da proposta: quem tem o endereço abre, sem
login. É a mesma exposição do documento que o anexo acompanha. O balde se cria uma vez no
painel do Supabase (Storage → New bucket → `ops-anexos` → Public); se não existir, o hub
explica o passo em vez de mostrar erro cru.

**Baixar a proposta é DOWNLOAD, e não a caixa de impressão.** Instrução dela em agosto/26,
apontando o voucher do CRM, que já faz assim. A função `netlify/functions/proposta-pdf.js`
abre a própria página pública num Chromium sem tela e devolve o arquivo. O texto sai
vetorial e o desenho é o da folha de impressão que já está aprovada: **não existe um
segundo layout para manter**, e nada vira imagem. Biblioteca de PDF no navegador foi
descartada por ela — rasteriza o texto.

**O arquivo não passa por dentro da página.** Buscar o PDF por `fetch` e entregar por blob
faz o Chrome abrir o visualizador e só depois oferecer salvar — que é justamente o que ela
não quer. Quem baixa é o NAVEGADOR indo ao endereço: a função responde
`Content-Disposition: attachment` com o nome do arquivo, e o navegador faz o que faz com
qualquer arquivo da internet.

**O botão nunca abre a caixa de impressão.** Instrução dela, depois de a impressão voltar a
aparecer: falhando, ele diz o que aconteceu, e não abre a impressão no lugar — cair na
impressão escondia o problema. No celular, quando o navegador ignora o atributo `download`
em blob, o arquivo vai para o menu de compartilhar do sistema; não havendo, abre em aba
nova e o navegador oferece salvar.

Três tropeços na hora de pôr a função de pé, todos só visíveis contra o site no ar:
o pacote `@sparticuz/chromium-min` sobe o binário sem as bibliotecas dele; o formato antigo
de função devolve o corpo em base64 e estoura no limite de 6 MB — a proposta com fotos tem
quase 17; e o runtime precisa ser fixado, senão o binário procura as libs no lugar errado.

O `netlify.toml` e o `package.json` existem **só** para essa função. O hub continua sendo
um arquivo só, servido da raiz, sem build.

**A proposta apresentada sai em uma folha A4 por etapa.** Capa e contracapa sangram até a
borda; cada hospedagem tem a sua folha, com a faixa da foto da seção e o card inteiro;
uma folha para os serviços com o total; uma para "não inclusos" e as condições. O corpo
do texto encolhe no papel — é o que faz caber em vez de cortar.

Três coisas quebravam isso e ficam registradas porque voltam fácil:
- O bloco `@media (max-width:900px)` não dizia `screen and`. Uma folha A4 a 96dpi tem
  794px, então **toda a versão de celular entrava na impressão**: a fita de fotos virava
  uma coluna e comia meia folha, e a tabela de serviços saía empilhada em blocos.
- `@page` não aceita seletor. A margem zero da apresentação é um `<style>` que a própria
  tela injeta ao desenhar, e por isso não afeta o documento da order nem o relatório de
  comissão. Página nomeada (`@page sangrada`) foi tentada antes: o Chrome inseria folha em
  branco na troca de grupo. **A margem das folhas de texto é `padding` da etapa**, e não
  margem de página — com a margem zerada e sem esse padding, o documento sai colado na
  borda. No computador passava despercebido porque a caixa de impressão do Chrome ainda
  aplicava a margem dela; no celular, não.
- Fundo em CSS dentro de etapa escondida **nunca é buscado**: `display:none` não carrega
  `background-image`, e na impressão as etapas aparecem todas de uma vez. A foto do
  "Sobre nós" saía em branco. As fotos são pré-carregadas ao desenhar, e as do card
  perderam o `loading="lazy"` pelo mesmo motivo.

Contêiner flex com altura de folha inteira fragmenta: a contracapa abria uma folha em
branco antes dela até virar bloco. `break-inside: avoid` na etapa inteira tem o mesmo
efeito perverso — quando não cabe, o navegador joga adiante e deixa a folha anterior
vazia. Quem se protege é o miolo: a fita de fotos, o bloco do Incluso, a linha da tabela.

## Identidade visual — obrigatória em qualquer tela nova
Vale a seção 8 do `PLANO-HUB.md`, com as correções registradas aqui, que são dela e são
posteriores. Onde as duas divergirem, vale o que está escrito abaixo.

**Libre Franklin em tudo, com uma exceção.** 300 para texto de documento, 400 para
interface, 500 para labels, botões e títulos.

**A exceção é Sorts Mill Goudy nas linhas de exibição da proposta apresentada** — instrução
dela em agosto/26: a serifada dá o ar de sonho que a Libre Franklin não dá, e é a fonte de
exibição da marca. Vale em quatro lugares, todos dentro de `.apres`: o nome grande da capa, a
chamada da folha de abertura, o título sobre a faixa de foto e o nome da hospedagem. Corpo de
texto, rótulo, tabela, overline, botão, e **a interface inteira**, continuam em Libre Franklin:
serifada em texto miúdo cansa, e interface é ferramenta. A família só tem peso 400.

Isto reverte, e só nesses quatro seletores, a regra que a seção 8 do plano tinha posto no lugar
da instrução antiga de Sorts Mill Goudy. Não estender para o documento da order nem para o
relatório de comissão sem instrução dela.

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

**Proposta nova nasce preenchida, e o preenchimento vive no banco.** O gatilho
`tl_proposal_defaults` copia de `ops_text_defaults` para a proposta, no insert, o que veio
vazio: sobre nós, credenciais, contracapa, condições e as duas fotos fixas. É no banco
porque a tela é um caminho entre vários — o exemplo em SQL, a duplicação, uma correção no
painel. **Só no insert e sempre cópia**: mudar o padrão depois não reescreve proposta já
enviada, e o que ela escreveu na proposta ganha do padrão.

**As fotos do "Sobre nós" e da contracapa são fixas** — instrução dela em agosto/26,
"sempre essa foto". A do "Sobre nós" é a peça institucional
(`i.postimg.cc/HsV7Z2fq`), e não mais o retrato da fundadora. Ficam no padrão da casa e descem para toda proposta nova. O campo
continua no editor para o caso de uma proposta pedir outra, e a troca vale só ali.

**Capa e contracapa são as duas peças de foto cheia.** A última página — a de contato — é
o fechamento da proposta, e sai com foto de fundo do tamanho da tela, como a capa. Instrução
dela em agosto/26. A foto mora em `ops_proposals.backcover_img`, com padrão da casa em
`ops_text_defaults`, pelo mesmo motivo do `about_img`: trocar a foto de fechamento não pode
mudar proposta já enviada. Proposta sem foto continua saindo em creme com o logo terracota.

**A folha de abertura leva a foto no alto, e não na coluna lateral** (`.ap-sec.faixa-topo`).
A peça que ela escolheu é deitada, e a coluna de 38% por folha inteira recorta uma foto 4:3 até
sobrar o meio. Faixa no alto é o mesmo corte que essa folha já ganha no papel e no celular — o
desenho fica um só nas três saídas. E sem texto por cima a camada escura sai (`.sem-tarja`):
ela existe para segurar texto branco, e sozinha só suja a foto.

**Toda foto grande da apresentação é `<img>`, e não fundo em CSS.** Capa, faixa de seção,
"Sobre nós" e contracapa. Fundo em CSS só sai no papel se a pessoa marcar "gráficos de
fundo" na caixa de impressão, e ninguém marca: a capa e a contracapa saíam vazias no PDF.
`<img>` sai sempre. O `<img>` é absoluto dentro da peça, que por isso precisa ser
`position:relative` **em toda regra que a redefine** — no celular e na impressão. Em
`static` ele mede 100% da tela, não da faixa: a foto da seção saiu com 844px de altura
numa faixa de 230, passando por cima do resto, enquanto a camada escura ficava do tamanho
certo. Na impressão o efeito é o oposto — ele escapa da faixa e some da folha.

Pela mesma razão, **a camada escura sobre a foto não segura a leitura no papel**: ela é
fundo de pseudo-elemento e some junto. Quem segura o texto branco sobre foto clara na
impressão é a sombra do texto, que é pintada sempre.

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

**Obrigatório é um `*`, e opcional não se escreve.** Instrução dela em agosto/26. Campo
obrigatório leva um asterisco em brown ao lado do rótulo — a palavra "obrigatório" repetida
em cada linha do formulário pesa mais que o formulário. E "opcional" não se escreve em
lugar nenhum: com caixinha em toda linha da proposta, a etiqueta OPCIONAL não distinguia
mais nada. A etiqueta de escolha — "uma destas" — também saiu, junto com o grupo.

**Texto justificado em toda a proposta, na tela e no papel, e sem hifenização em lugar
nenhum.** A hifenização estava ligada no corpo de texto para justificar sem abrir rios de
espaço em coluna estreita; ela viu "small mo-ments" partido na folha do convite e mandou tirar,
em agosto/26. Palavra que não cabe desce inteira para a linha de baixo, e o rio de espaço é o
preço — é ela que escolhe. A contracapa é exceção do justificado: é bloco de contato centrado,
não texto corrido.

**Título não se parte.** Justificar e hifenizar valem para texto corrido; numa linha de
título a palavra quebrada no meio salta aos olhos. Título, chamada e rótulo saem inteiros
e à esquerda — `hyphens:none`. Foi instrução dela em agosto/26, vendo o "Sobre nós".

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

**Nome de todos os viajantes, criança inclusive.** A regra anterior era "idade de criança
sim, nome de criança não". O motivo da mudança é operacional: bilhete de monumento é nominal.
Quando `passport_names` está ligado, o documento avisa que o nome precisa bater com o
passaporte. O nome é obrigatório sempre — sem ele não há reserva em fornecedor nenhum.

**A data de nascimento é escolha dela, por order** (`checkout_config.dob`): `required` pede e
exige, `optional` pede e aceita em branco, `off` não pergunta. Ela decide a data porque é ela
que sabe se a venda tem bilhete nominal — aí o nascimento decide meia-entrada ou gratuidade e
sem ele a compra não sai — ou se é só transfer, e aí é dado pessoal que ninguém vai usar e uma
linha a mais para a agência travar. Instrução dela em agosto/26. O padrão é `required`: order
que já existe não muda, e esquecer de configurar erra para o lado seguro. Com `off` a linha do
viajante perde a coluna, senão sobraria um buraco ao lado do nome.

**Data que o hub formata sai em `en-US` no documento em inglês**, e não em `en-GB`: o público
é americano, e o britânico escreve 03/11 para 3 de novembro, igual ao português — o formato
mudava de nome mas não de ordem. Vale para nascimento, data e hora do envio e prazo do link.
**A data do serviço é texto que ela digita** e sai como ela escreveu: o hub não adivinha se
"03/11" é 3 de novembro ou 11 de março.

**A assinatura digitada saiu.** Ela repetia o nome do contato responsável, que já vem no
bloco de contato, e duas caixas para o mesmo nome só produzem divergência entre elas. O
ato que vale continua sendo o aceite dos termos, gravado com data e hora do envio. O
resumo em PDF diz "Confirmado por", com o nome do contato. As colunas `signature_name`
das confirmações antigas continuam onde estão e continuam sendo exibidas.

## Pendente
- **Duas caras de proposta da agência**, pedido dela em agosto/26: a de **colaboração**, em que
  as duas marcas aparecem, e a **100% white label**, em que só a agência aparece. Hoje existe
  uma chave só, `white_label`, que é o segundo caso. Falta a especificação do primeiro — onde
  entra cada logo, e o que o texto de respaldo diz quando as duas assinam.
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
