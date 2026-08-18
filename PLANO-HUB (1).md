# Hub de Vendas e Operações — especificação e plano de ação

Documento de passagem para o Claude Code. Contém tudo que foi decidido, o que já existe,
o que falta, e em que ordem construir. Ler junto com o CLAUDE.md, que está na mesma pasta.

---

## 1. O que é este sistema

Ferramenta interna da Tuscan Lands Travel. Consolida e armazena as informações de cada
venda, do pedido da agência até a confirmação assinada pelo cliente. Operação de uma
pessoa só, mercado B2B, agências e advisors.

Não substitui o CRM. O CRM continua com pagamentos, margens e faturamento. O hub cuida
do fluxo comercial e operacional: briefing, proposta, order, checklist.

---

## 2. O fluxo, em etapas travadas

Cada oportunidade percorre estas etapas, e uma etapa só abre quando a anterior está
completa. Nunca pré-popular tarefa como se a aprovação já tivesse acontecido.

**Etapa 1 — Briefing.** A agência manda o pedido por WhatsApp, e-mail ou como for. A
Maria Fernanda alimenta as informações no sistema. O briefing é discutido no chat do
Claude e vira um PDF, que sobe no hub e fica anexado à oportunidade. É o documento que
sempre vai para a agência antes da proposta.

**Etapa 2 — Proposta.** Construída em cima do briefing aprovado.

**Etapa 3 — Aprovação da agência.**

**Etapa 4 — Order / checkout.** Documento de confirmação de serviços que a agência ou o
cliente final assina. É o que formaliza a venda.

**Etapa 5 — Checklist operacional.** Gerado só depois do checkout concluído, e só com os
serviços que o cliente efetivamente selecionou.

---

## 3. Estrutura de dados

**A oportunidade é o objeto central.** Ela nasce com o número gerado no CRM e tudo
pendura nela: briefing, proposta, order, checklist. Hoje isso está invertido — o número
da oportunidade é um campo de texto dentro da order. Precisa ser corrigido.

**Vinculação com o CRM.** O hub vive no mesmo banco Supabase do CRM, então pode LER as
tabelas dele. Decisão: na tela de nova oportunidade, a agência vem de uma lista suspensa
alimentada pela tabela `agencias` do CRM, trazendo junto contato, e-mail, idioma e
comissão padrão. **Somente leitura. O hub nunca escreve em tabela do CRM.**

Tabelas do CRM já mapeadas e relevantes: `agencias`, `fornecedores`, `anexos`.
A listagem completa do schema ainda não foi obtida (a consulta voltou cortada no
`fornecedores`) — rodar de novo antes de escrever a tela de oportunidade.

---

## 3.1 Navegação — decisão tomada

**O hub e o CRM permanecem separados**, em endereços distintos. O hub não é embutido no
CRM e o arquivo do CRM não é aberto, editado nem lido por este projeto. Não propor fusão,
lateral compartilhada ou tela de entrada com módulos enquanto o hub não estiver com
oportunidade, briefing e checkout funcionando. Revisitar só depois disso.

Dentro do hub, a navegação lateral nasce já agrupada por área — Vendas, Operações — com
os grupos abrindo e fechando, e não como lista corrida de abas. O CRM sofre do problema
oposto e não deve ser replicado.

---

## 4. O checkout — como precisa ser

Este é o ponto mais importante e o que está mais incompleto.

**Os campos do checkout são variáveis por venda.** Dependendo do que está sendo vendido,
uns campos são necessários e outros não. E há campos que a Maria Fernanda já preenche,
cabendo à agência apenas confirmar.

**Desenho a construir:** dentro da order, ela monta os campos daquele checkout a partir de
uma biblioteca de campos disponíveis. Cada campo escolhido tem três estados possíveis:

- não aparece
- aparece vazio, para a agência preencher
- aparece já preenchido por ela, e a agência só confirma

A biblioteca de campos é organizada por tipo de serviço (transfer, tour, hotel, jantar,
experiência). A relação exata dos campos de cada tipo será fornecida pela Maria Fernanda.

**O que já existe hoje, fixo:** nomes dos adultos, idade das crianças (nunca o nome),
contato responsável com e-mail e WhatsApp, aceite de veículo e bagagem, aceite dos termos,
assinatura digitada e campo livre de observações.

**Regra de armazenamento:** tudo que a agência envia fica gravado no banco, visível na
order, com data e hora. Ao enviar, a order muda para `confirmed` sozinha e o link para de
aceitar alteração.

---

## 5. O que já está construído e funcionando

Arquivo único `index.html`, vanilla JS, supabase-js por CDN, sem build.

- Login por Supabase Auth, mesmo usuário do CRM
- Lista de orders
- Editor da order: cabeçalho, passageiros, período, serviços linha a linha com data,
  descrição e valor, total somando sozinho, parcelas com vencimento e situação, notas
  internas que nunca aparecem para o cliente
- Página pública do cliente em `#/confirm/TOKEN`, com o documento na identidade da casa,
  termos e condições em PT e EN, e o formulário de confirmação
- Quatro tabelas `ops_order*` com RLS, e duas funções `security definer` que dão ao
  cliente acesso apenas à order do token dele

---

## 6. O que falta, em ordem de construção

1. **Tabela e telas de oportunidade.** Oportunidade como objeto central, com a agência
   puxada da tabela `agencias` do CRM. A order passa a ser filha da oportunidade. As
   orders já cadastradas se ligam pelo campo `opportunity_code`, que já guarda o número.
2. **Etapa 1, briefing.** Upload do PDF anexado à oportunidade, via Supabase Storage.
   Decidir se os campos do briefing também ficam estruturados em colunas, ou se o PDF
   basta. Estruturado alimenta proposta e checklist sem redigitar.
3. **Checkout configurável.** Biblioteca de campos por tipo de serviço, com os três
   estados descritos na seção 4.
4. **Travas de sequência entre as etapas.**
5. **Notificação por e-mail quando a agência confirma.**
6. **Cor.** Interface interna em sage `#595e49`, o verde da casa. O documento do cliente
   permanece no terracota `#772f25` da cotação, para o cliente reconhecer a mesma cara
   que viu na proposta.
7. **Checklist operacional**, gerado após o checkout.
8. Busca, histórico e filtro por data, cliente e tipo de serviço.
9. Exportação para alimentar o faturamento no CRM, com o hub como fonte de verdade.

---

## 7. Limite absoluto — vale para toda sessão

O banco Supabase é compartilhado com um CRM em produção que contém o histórico inteiro do
negócio.

- Só criar, ler, alterar ou apagar objetos cujo nome comece com `ops_`.
- Nenhum `drop`, `alter`, `delete`, `truncate` ou `update` fora desse prefixo, em nenhuma
  hipótese, nem para corrigir, limpar, padronizar ou migrar.
- Leitura de tabelas do CRM é permitida. Escrita, nunca.
- Nunca gerar SQL que percorra todas as tabelas de um schema.
- Nunca usar a service_role key.
- Antes de entregar qualquer SQL, reler e confirmar por escrito que ele só toca em `ops_`.
- Quem executa SQL no painel do Supabase é sempre a Maria Fernanda, nunca o agente.

---

## 8. Identidade visual — cor carrega informação

**Uma fonte só: Libre Franklin.** Variação por peso (300 para texto de documento, 400 para
interface, 500 para labels, botões e títulos), tamanho e cor. Sem serifada. Mesmo caminho
do voucher de tours.

**Lógica de cor, e ela significa alguma coisa:**
- **Sage `#595e49`** é a cor da casa no dia a dia. Interface interna inteira, e também os
  documentos internos e de trabalho — briefing, listas, editores.
- **Terracota `#772f25`** fica reservado para confirmação e fechamento: a order, o
  checkout do cliente, o que sai assinado. Ver terracota na tela deve significar que
  aquilo está fechado ou prestes a fechar.

Paleta de apoio: cream-light `#f6f3f0` · cream `#eae4db` · brown `#a2564c` ·
copper `#a56850` · ink `#2a2a28` · muted `#6b6860`.
**border-radius zero em tudo, sempre.**

**Densidade.** Interface interna é ferramenta usada horas por dia: peso 400, espaçamento
apertado, muita informação por tela. Documento que sai é outra coisa: peso 300, respiração
ampla, texto justificado.

**Impressão.** Toda página de documento sai limpa em PDF pelo Ctrl+P: regra de impressão
escondendo interface, navegação e formulários, deixando só o documento. É assim que o
briefing vai para o cliente.

## 8.1 Infraestrutura — sem custo adicional

Netlify gratuito comporta vários sites e GitHub gratuito comporta vários repositórios.
Site separado para o hub não gera assinatura nova. O único serviço com limite relevante é
o Supabase, e a decisão está tomada: um projeto só, o mesmo do CRM, com isolamento por
prefixo `ops_` e RLS. Não propor serviço pago em nenhuma etapa.

---

## 9. Regras de escrita

- Linha de serviço é seca: data, serviço, condição. Sem narrativa, sem segunda pessoa.
- Nunca insinuar furar fila em serviço de aeroporto. A linguagem é orientação e assistência.
- Termos e condições em PT e EN estão no código, na constante `TERMS`. É texto jurídico
  da casa: não reescrever, não resumir, não "melhorar".
- Idade de criança sim, nome de criança não.
- Sempre distinguir o que o cliente pediu do que a advisor sugeriu.

---

## 10. Estado da instalação

- Repositório GitHub `tuscanlands2026/tl-hub`, privado, com `index.html`, `CLAUDE.md` e
  `db/tl-hub-orders.sql`
- Publicado no Netlify
- Projeto Supabase: o mesmo do CRM
- **Pendente:** rodar o `db/tl-hub-orders.sql` no SQL Editor do projeto correto. Sem isso
  o sistema abre mas não grava, com o erro "Could not find the table public.ops_orders".
- **Pendente:** colar `SUPABASE_URL` e `SUPABASE_ANON_KEY` nas duas constantes do topo do
  script em `index.html`, para não pedir na tela toda vez.
- **Pendente:** trocar o nome aleatório do site no Netlify por `tl-hub`.
