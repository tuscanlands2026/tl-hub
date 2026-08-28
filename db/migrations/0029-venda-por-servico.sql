-- =====================================================================
-- 0029 · A LINHA DA ORDER GANHA O QUE O CRM PEDE
--
-- A aba "Vendas e Serviços" do CRM é uma linha por serviço, com estas
-- colunas: Projeto · Agência · Tipo de serviço · Serviço · Regime IVA ·
-- Receita (c/ IVA) · Custo previsto · Comissão · Trim. faturamento.
--
-- O hub já tem receita (price) e comissão (commission_pct). Faltam
-- quatro coisas, e são estas.
--
-- REGIME IVA NÃO SE DEDUZ DO TIPO. Nas vendas de 2026 dela, Signature
-- Experiences aparece com TRÊS regimes diferentes: visita guiada
-- isenta, balão a 10%, tour guiado a 22%. Então o campo é dela e fica
-- em branco até ela lançar — nada de padrão silencioso, que aqui
-- viraria imposto errado.
--
-- NOME CURTO DE SERVIÇO, porque o elo entre a venda e o custo no CRM é
-- "Projeto + Serviço" em TEXTO. Se a venda for lançada como o título
-- inteiro da linha — "Transfer privativo FCO - Hotel Calimala, veículo
-- sedan, stopover em Orvieto" — e a fatura do fornecedor entrar como
-- "Transfer Orvieto", o custo não encontra a venda e o projeto nunca
-- fecha. O nome curto existe para ser digitado igual nos dois lados.
--
-- Nada disto sai para o cliente: tl_get_order monta o objeto campo a
-- campo e nenhum destes entra.
--
-- Só toca em objetos ops_. Nada fora desse prefixo.
-- =====================================================================

alter table ops_orders add column if not exists crm_project text;
comment on column ops_orders.crm_project is
  'Nome do projeto como ele existe no CRM. É a chave do lado esquerdo do elo.';

alter table ops_order_items add column if not exists crm_type text;
alter table ops_order_items add column if not exists crm_service text;
alter table ops_order_items add column if not exists vat_regime text;
alter table ops_order_items add column if not exists cost_estimate numeric(12,2);

comment on column ops_order_items.crm_type is
  'Tipo de serviço do CRM: ground, stay, experience, journey, consulting.';
comment on column ops_order_items.crm_service is
  'Nome CURTO e estável do serviço. É por ele que a fatura do fornecedor '
  'reencontra a venda no CRM — tem de ser digitado igual dos dois lados.';
comment on column ops_order_items.vat_regime is
  'Regime de IVA da linha: 0, 10, 22 ou 74ter. Em branco até ela lançar: '
  'o regime não se deduz do tipo, e chutar aqui é errar imposto.';
comment on column ops_order_items.cost_estimate is
  'Custo previsto da linha. Alimenta a coluna Custo previsto do CRM.';

alter table ops_order_items drop constraint if exists ops_order_items_vat_regime_check;
alter table ops_order_items add constraint ops_order_items_vat_regime_check
  check (vat_regime is null or vat_regime in ('0','10','22','74ter'));

alter table ops_order_items drop constraint if exists ops_order_items_crm_type_check;
alter table ops_order_items add constraint ops_order_items_crm_type_check
  check (crm_type is null or crm_type in ('ground','stay','experience','journey','consulting'));

insert into ops_migrations (id) values ('0029-venda-por-servico') on conflict (id) do nothing;
