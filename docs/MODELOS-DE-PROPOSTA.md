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
   - **Cada seção escolhe como se exibe**: `blocos` (hoje) ou `dia a dia` (alternativo).
     O dia a dia serve quando o briefing pede programa cronológico em vez de vitrine de
     serviços. É por seção, não por proposta — a de experiências pode ser dia a dia
     enquanto a de hotéis segue em blocos.
   - **Índice agrupado por seção**, com cada item clicável por baixo do título dela.
5. **Resumo da proposta** — tabelas por tipo e total. Sai sem valores quando a tarifa é net.
6. **Sobre nós, formas de pagamento, contracapa.** *Existem.*

---

## Net × comissionado

Campo novo na proposta: **tipo de tarifa**.

**Comissionado** — como hoje. Preço em toda linha, total no fim, caixinha de aprovação
para o cliente final marcar. O valor mostrado é o com a comissão dentro.

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
| Experiências em blocos ou dia a dia | o modo daquela seção |
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
- No modo dia a dia, definir se cada dia leva foto própria ou se a seção tem uma só.
