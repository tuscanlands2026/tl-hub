# Tuscan Lands · Hub de Vendas e Operações

## O que é
Aplicação interna da Tuscan Lands Travel (DMC italiana, base em Pontassieve/FI, mercados
Brasil e América do Norte, operação de uma pessoa só). Substitui a produção manual de
documentos comerciais. Não substitui o CRM, que continua cuidando de pagamentos, margens
e faturamento.

## Estado atual
Módulo **Order** funcionando: login, lista de orders, editor, e página pública onde o
cliente ou a agência confere os serviços, preenche nomes e idades, aceita os termos e
assina digitando o nome. Ao enviar, a order vira `confirmed` e os dados aparecem no editor.

Arquivo único, sem build, sem framework. Vanilla JS + supabase-js via CDN.

## Arquitetura
- `index.html` — aplicação inteira. Roteamento por hash:
  - sem hash → app interno, exige login Supabase Auth
  - `#/confirm/TOKEN` → documento público do cliente, sem login
- `db/tl-hub-orders.sql` — schema, RLS e funções.

### Decisão de infraestrutura (tomada, não reabrir sem motivo)
As tabelas vivem **dentro do projeto Supabase do CRM**, não em projeto separado.
Motivo: o plano free dá duas vagas de projeto ativo, ambas ocupadas, e projeto free
é pausado após 7 dias sem requisições — um projeto só de orders ficaria dormindo
justamente entre uma venda e outra, e o link chegaria quebrado ao cliente.
Isolamento é feito por prefixo `ops_` e por RLS. Auditado antes de subir: nenhuma
tabela do CRM sem RLS, nenhuma policy para `anon` ou `public`.
Separar depois, se justificar: `pg_dump` filtrando `ops_*`.

### Tabelas
`ops_orders` · `ops_order_items` · `ops_order_payments` · `ops_order_confirmations`

`opportunity_code` é texto livre, o número gerado no CRM. Sem foreign key para
`ops_opportunities` de propósito, para não acoplar aos objetos já existentes.

### Segurança
Tabelas fechadas para `authenticated`. O cliente nunca fala com elas: passa por duas
funções `security definer` que só enxergam a order do token recebido.
- `tl_get_order(p_token)` → devolve order + itens + pagamentos
- `tl_submit_confirmation(p_token, p_payload)` → grava confirmação e muda status

Token: 32 caracteres hex, gerado no banco. Nunca usar o código TL no link.
Campo `token_expires_at` existe e está sem uso por enquanto.

## Identidade visual — obrigatória em qualquer tela nova
Fontes: Sorts Mill Goudy (títulos) + Libre Franklin 300/400/500 (corpo, labels, botões).
Paleta: cream-light `#f6f3f0` · cream `#eae4db` · terracotta `#772f25` · sage `#595e49` ·
brown `#a2564c` · copper `#a56850` · ink `#2a2a28` · muted `#6b6860`.
**border-radius: 0 em tudo, sempre.** Sem exceção.
Overline em caixa alta, Libre Franklin 500, letter-spacing .18–.22em.
Régua de 30px em sage ou copper como acento, nunca linha de largura total.

## Regras de conteúdo
- Linhas de serviço são secas: data, serviço, condição. Sem narrativa, sem segunda pessoa.
- Nunca insinuar furar fila em serviço de aeroporto. A linguagem é orientação e assistência.
- Termos e condições em PT e EN estão no código, em `TERMS`. São texto jurídico da casa:
  não reescrever, não "melhorar", não resumir. Alterar só sob instrução explícita.
- Documento do cliente sai em PT ou EN conforme o campo `lang` da order.

## Pendente
- Notificação por e-mail quando o cliente confirma (Edge Function ou webhook).
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
