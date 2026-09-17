-- =====================================================================
-- 0042 · A LINHA DA PROPOSTA SABE DE QUAL FICHA VEIO
--
-- Pedido dela em setembro/26, com todas as letras: "eu não quero copiar
-- e colar, quero puxar algo e dali eu altero se quiser". Era o que o
-- catálogo já fazia e a ficha de fornecedor não: o único caminho entre
-- a ficha e a proposta era o botão de copiar, e a área de transferência
-- no meio.
--
-- A REGRA QUE NÃO MUDA: a proposta leva CÓPIA, nunca referência viva.
-- É o que protege proposta de março de mudar de texto e de preço porque
-- o fornecedor mandou tarifa nova em setembro. Estas três colunas são
-- procedência, e nada mais: guardam de onde a linha veio, para ela
-- poder conferir cancelamento e prazo antes de mandar. Se a ficha for
-- apagada, a linha continua inteira — on delete set null, igual ao
-- catalog_id da 0006.
--
-- O PREÇO NÃO DESCE. O preço da ficha é NET, o que o fornecedor cobra
-- dela; o valor da linha é o que o cliente paga. São números de
-- naturezas diferentes, e empurrar um no outro põe o custo do
-- fornecedor impresso na proposta. A tela mostra o custo ao lado, na
-- hora de puxar, e o valor continua sendo dela.
--
-- Só toca em objetos ops_. Nada fora desse prefixo.
-- =====================================================================

alter table ops_proposal_items add column if not exists supplier_id uuid
  references ops_suppliers(id) on delete set null;
alter table ops_proposal_items add column if not exists supplier_service_id uuid
  references ops_supplier_services(id) on delete set null;
alter table ops_proposal_items add column if not exists supplier_room_type_id uuid
  references ops_room_types(id) on delete set null;

comment on column ops_proposal_items.supplier_id is
  'De qual ficha de fornecedor esta linha foi puxada. Procedência, não referência viva: '
  'o que a proposta mostra é a cópia que está aqui.';
comment on column ops_proposal_items.supplier_service_id is
  'O serviço da ficha que virou esta linha, quando foi um serviço.';
comment on column ops_proposal_items.supplier_room_type_id is
  'O tipo de quarto da ficha que virou esta linha, quando foi hospedagem.';

create index if not exists ops_proposal_items_supplier_idx
  on ops_proposal_items (supplier_id);

insert into ops_migrations (id) values ('0042-puxar-da-ficha') on conflict (id) do nothing;
