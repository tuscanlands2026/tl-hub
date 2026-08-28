-- =====================================================================
-- 0030 · OS TIPOS E OS REGIMES SÃO OS DO CRM, E NÃO OS QUE EU SUPUS
--
-- A 0029 travou os dois campos numa lista que eu deduzi da planilha.
-- Lendo o código do CRM (repositório Claude-Finance-TL, tabelas
-- public.tipos_servico e public.vendas) as duas listas estão erradas:
--
-- TIPO DE SERVIÇO — o CRM tem SETE, com prefixo "TL" onde ele põe:
--   Consultoria · TL Selected Stays · TL Signature Experiences ·
--   TL Signature Programs · Concierge · Ground Services ·
--   MICE e Exclusive Events
-- Eu tinha cinco, sem prefixo, com "Signature Journeys" onde o CRM diz
-- "TL Signature Programs", e sem Concierge nem MICE. O elo entre venda
-- e custo é TEXTO: nome diferente é linha que não reencontra a venda.
--
-- REGIME DE IVA — public.vendas.regime_iva aceita CINCO:
--   0% (isento) · 10% · 12% · 22% · 74-ter
-- Faltava o 12%. Ele existe nas vendas dela, e a trava da 0029 recusava
-- a linha inteira.
--
-- Nada aqui calcula imposto. Continua sendo etiqueta que ela escolhe, e
-- continua nascendo em branco: o regime não se deduz do tipo — em
-- Signature Experiences ela já usou três diferentes.
--
-- Nenhuma linha existente é alterada: as colunas nasceram vazias na
-- 0029 e as travas novas são mais largas que as antigas, então nada que
-- já está gravado deixa de passar.
--
-- Só toca em objetos ops_. Nada fora desse prefixo. Nenhuma tabela do
-- CRM é nomeada — o CRM foi lido, não escrito.
-- =====================================================================

alter table ops_order_items drop constraint if exists ops_order_items_crm_type_check;
alter table ops_order_items add constraint ops_order_items_crm_type_check
  check (crm_type is null or crm_type in
    ('consultoria','stay','experience','program','concierge','ground','mice'));

alter table ops_order_items drop constraint if exists ops_order_items_vat_regime_check;
alter table ops_order_items add constraint ops_order_items_vat_regime_check
  check (vat_regime is null or vat_regime in ('0','10','12','22','74ter'));

comment on column ops_order_items.crm_type is
  'Tipo de serviço do CRM (public.tipos_servico): consultoria, stay, '
  'experience, program, concierge, ground, mice. O rótulo que sai no CSV '
  'é a grafia do CRM, com prefixo TL onde ele põe.';
comment on column ops_order_items.vat_regime is
  'Regime de IVA da linha: 0, 10, 12, 22 ou 74ter, na grafia de '
  'public.vendas.regime_iva do CRM. Em branco até ela lançar: o regime '
  'não se deduz do tipo, e chutar aqui é errar imposto.';

insert into ops_migrations (id) values ('0030-tipos-e-iva-do-crm') on conflict (id) do nothing;
