# Modelos de proposta — o desenho fechado

Decidido com a Maria Fernanda em setembro/26. Este arquivo é a especificação: o que
existe, o que entra, e o que cada escolha dela significa na tela. Nada aqui se
implementa "picado" — o conjunto fecha primeiro, depois se constrói.

---

## Os dois modelos

**Tabela** — cotação rápida. Sem fotos, descritivo curto e preço. Linhas agrupadas em
seções, caixinha de aprovação por linha. **Existe hoje** (`ops_proposals.layout = 'tabela'`).

**Completo** — o visual, para programa montado: hotéis, ground services e experiências,
em qualquer combinação. Ela monta como quiser. **Existe hoje**
(`layout = 'apresentada'`), e é o que ganha as peças novas abaixo.

---

## O Completo, aba por aba

1. **Capa** — foto, logo de quem assina, chamada, janela de viagem, código TL. *Existe.*
2. **Primeira página** — o convite/abertura. *Existe.*
3. **Curadoria de viagem e serviços propostos** — **nova**. Folha inteira colorida, sem
   foto, no desenho da peça que ela já usa:
   - fundo **verde sage** (`#595e49`) ou **terracota** (`#772f25`), escolha dela, **liso**:
     a marca d'água de telhados saiu a pedido dela — a folha respira melhor sem ela;
   - rótulo `Opção N` acima do título;
   - título editável, com o texto dela como padrão;
   - **dois campos grandes e livres**: *destinos e datas* (as linhas de cidade + noites)
     e o *dia a dia*, aceitando marcador e sub-marcador. Livre para escrever — não é
     uma linha por data, é texto;
   - PT e EN;
   - código TL no pé;
   - **mais de uma folha por proposta**: Opção 1, Opção 2… é uma lista, não uma folha só.
4. **Uma aba por seção** — Selected Stays, Ground Services, Experiences, na ordem dela.
   Fica como está hoje: os hotéis numa aba, os ground services em outra, cada serviço
   como bloco dentro. Decisão dela: "para hotel e ground services está ok, deixamos assim".
   - **Cada seção escolhe como se exibe**, e são três modos:
     - `blocos` — todos os serviços numa aba, um bloco cada. É o de hoje, e o que fica
       para hospedagem e ground services;
     - `dias` — programa cronológico, **uma foto por dia** (a foto do próprio item, que
       ali representa o dia). Serve quando o briefing pede roteiro em vez de vitrine;
     - `abas` — **uma aba por serviço**, em submenu por baixo da seção no índice. É para
       quando cada opção tem informação demais para caber num bloco — a MICE de setembro,
       com quatro experiências caras, é esse caso.
   - **Índice agrupado por seção**, com cada item clicável por baixo do título dela.
   - **Extras e opcionais por serviço já existem** (migração 0014): cada linha carrega a
     sua própria lista de extras com preço, e o cliente marca o que quer. Vale nos três
     modos — nada a construir aqui, é campo que já está na tela.
5. **Resumo da proposta** — tabelas por tipo e total. Sai sem valores quando a tarifa é net.
6. **Sobre nós, formas de pagamento, contracapa.** *Existem.*

---

## Net × comissionado

Campo novo na proposta: **tipo de tarifa**.

**Comissionado** — como hoje. Preço em toda linha, total no fim, caixinha de aprovação
para o cliente final marcar. O valor mostrado é o com a comissão dentro.

**"Selecione a opção aprovada"** volta, e só no comissionado. Em agosto/26 o grupo de
escolha foi removido porque o rádio prendia: ela clicava sem querer e não conseguia
desmarcar, e na venda real o cliente aprova este serviço **e** aqueles outros. Volta com
três travas: é **opcional por conjunto** (ela marca quais linhas formam a escolha, o resto
segue livre), **desmarca** clicando de novo, e conjunto sem nada escolhido não entra na
order em vez de barrar o envio. O rótulo é o dela: *Selecione a opção aprovada*. Caso de
uso: as três opções de jantar da MICE, onde uma exclui as outras.

**Net** — a proposta sai **completa e sem valores**, e **sem** as caixinhas: ela é peça de
apresentação, para a agência mandar ao cliente dela. A aprovação é **do lado da agência**.
Os valores vão num **link separado**, no formato **Tabela**:
- só para a agência;
- valor **net** por serviço e total — número diferente do comissionado, e é ali que a
  agência aplica a margem dela;
- mesmo prazo de validade do link da proposta;
- é nesse link que a aprovação acontece.

---

## As perguntas antes de começar

Hoje ela cria a proposta e sai caçando campo — e campo que ela não lembra de mexer sai
errado. A proposta nova passa a começar por um punhado de perguntas, e nasce montada a
partir das respostas:

| Pergunta | O que a resposta decide |
|---|---|
| Modelo: Tabela ou Completo | o `layout` |
| Idioma: português ou inglês | `lang`, e qual coluna de texto a peça usa |
| Tarifa: comissionada ou net | preço na proposta × link separado de valores |
| O que compõe: hospedagem · ground services · experiências | quais seções nascem |
| Cada seção: blocos, dia a dia ou uma aba por serviço | o modo daquela seção |
| Folha de Curadoria: não · uma · mais de uma | quantas folhas, e a cor de cada |
| Assinada pela agência (white label)? | logo e folha de respaldo |
| Validade do link | `token_expires_at` |

---

## Regras de estilo que valem para tudo

**Texto corrido é justificado**, inclusive no celular, com hifenização (`hyphens:auto` e
`lang` na página) para não abrir rios entre as palavras.

**Celular não é versão pobre.** Uma coluna, margens menores, título menor, e a folha da
Curadoria mantém o fundo e o marcador. Tudo que é testado no desktop se testa a 390 px.

**Identidade:** Sorts Mill Goudy nos títulos, Libre Franklin no corpo (300), canto reto
em tudo, foto sempre full-bleed. Ver a skill `visual-identity-tuscan-lands`.

---

## Pendências conhecidas

- O PDF da apresentada ainda sai com ~8,5 MB: sobram fotos de 1257 e 1353 px que o
  encolhimento não pega.
- ~~No modo dia a dia, definir se cada dia leva foto própria~~ — decidido: **uma foto por dia**.

---

## Itinerário completo (setembro/26)

Ela pediu "um novo tipo de proposta: Itinerário completo", com a página do La Dolce Vita
Orient Express como referência de **arquitetura**, não de texto.

**Não virou um terceiro `layout`, e a razão é esta:** o que ela descreveu é o **Completo**
com a seção em **`modo='dias'`** — programa cronológico, uma foto por dia —, que é o
desenho fechado com ela em setembro e já está em pé desde a 0036. Um `layout` novo seria
um segundo desenho desembocando na mesma folha, e nasceria sem a Curadoria, sem o net e
sem a escolha de opção. O dia de cada linha também já existe: é o `service_date` da
própria linha, que é o que o renderizador lê. Uma coluna `day` seria um segundo campo
dizendo a mesma coisa, livre para divergir dele.

**"Proposta só de experiências, sem hotel" não se constrói:** é ela não criar a seção de
hospedagem. Chave para desligar hotel seria chave para ela lembrar de virar.

**As três abas do Orient Express saíram**, por instrução dela: "a gente já coloca tudo
junto, só não pode ficar enrolando muita linguiça". Programa, rota e experiências são a
mesma leitura corrida.

### O que a 0044 acrescenta

O **cabeçalho de fatos**, que abre a peça antes de qualquer parágrafo:

| campo | o que é |
|---|---|
| `route` | "Roma · Val d'Orcia · Florença" — texto dela, com o separador que ela quiser |
| `duration` | "5 dias · 4 noites" — texto |
| `from_price` | o "a partir de" |
| `from_price_show` | se ele aparece. **Nasce desligado** |

Rota e duração são texto, e não montagem: a ordem de apresentação das seções não é
necessariamente a ordem do trajeto, e contar dias a partir das datas erraria em toda
viagem que começa à noite ou termina de manhã.

Passageiros e período **não** entram aqui: são `pax_summary` e `travel_window`, que já
existem e já saem em `tl_get_quote`.

O `from_price` **não sai na peça de uma proposta net** — pela mesma regra que já esconde
todo valor ali: a peça bonita do net vai ao cliente final. Ele aparece no link dos
valores, e por isso `tl_get_net_quote` o devolve.

### O que ainda falta

- **Etapa 2** — a página pública: a folha do cabeçalho de fatos e o **subtotal ao fim de
  cada dia**, somado das linhas daquele dia e **nunca gravado**, pelo mesmo motivo que
  nenhum total de proposta é gravado.
- **Etapa 3** — a seleção, que é a que já existe: caixinha em toda linha, nada exclui nada.
- O resumo de preços ao fim, que é a página de resumo da escolha que já existe.
