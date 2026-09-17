-- =====================================================================
-- 0043 · O CATÁLOGO PODE NASCER DA FICHA DO FORNECEDOR
--
-- Pergunta dela, setembro/26: "mas eu posso copiar da ficha para o
-- catálogo com um clique? ele vira catálogo quando o fornecedor está
-- ativo ou quando vou usá-lo em um orçamento?"
--
-- A RESPOSTA QUE O DESENHO DÁ: não é o status. Status "Active" quer dizer
-- que ela trabalha com o fornecedor, não que o texto está pronto para um
-- cliente ler. O momento em que a entrada do catálogo passa a valer é o
-- momento em que ela usa o item — é aí que o texto foi revisado e o preço
-- de venda foi decidido. Então são dois gatilhos, os dois de um clique:
--   · na ficha, quando ela quer deixar pronto antes (depois de traduzir);
--   · na linha da proposta, que leva o texto que ela já ajustou E o valor
--     que ela cobrou — que é justamente o que o catálogo guarda e a ficha
--     não tem.
--
-- ONDE CADA PREÇO MORA, agora sem ambiguidade:
--   ficha      → CUSTO net do fornecedor, com as condições dele;
--   catálogo   → VENDA de referência, com a data em que foi conferida;
--   proposta   → a venda desta vez, que é cópia e não muda depois.
--
-- OS ÍNDICES ÚNICOS PARCIAIS SÃO A REGRA, não um detalhe de performance:
-- um item da ficha tem no máximo UMA entrada no catálogo. Sem isso, dois
-- cliques no mesmo botão viram dois cadastros do mesmo quarto, e ela
-- descobre na hora de montar a proposta.
-- =====================================================================

alter table ops_catalog add column if not exists supplier_id uuid
  references ops_suppliers(id) on delete set null;
alter table ops_catalog add column if not exists supplier_service_id uuid
  references ops_supplier_services(id) on delete set null;
alter table ops_catalog add column if not exists supplier_room_type_id uuid
  references ops_room_types(id) on delete set null;

comment on column ops_catalog.supplier_id is
  'De qual ficha de fornecedor esta entrada nasceu. A entrada segue sendo cópia: '
  'apagar a ficha não apaga o catálogo nem as propostas.';

create unique index if not exists ops_catalog_do_servico_idx
  on ops_catalog (supplier_service_id) where supplier_service_id is not null;
create unique index if not exists ops_catalog_do_quarto_idx
  on ops_catalog (supplier_room_type_id) where supplier_room_type_id is not null;
create index if not exists ops_catalog_supplier_idx on ops_catalog (supplier_id);

insert into ops_migrations (id) values ('0043-catalogo-vem-da-ficha') on conflict (id) do nothing;
