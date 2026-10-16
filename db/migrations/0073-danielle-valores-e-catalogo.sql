-- =====================================================================
-- 0073 · DANIELLE (TL-055-26): VALORES, FOTO DO SHOPPING, FORMA DE
--        PAGAMENTO, E O CATÁLOGO COM PREÇO DE REFERÊNCIA + COMISSÃO
--
-- Ela mandou os valores (out/26). Duas coisas de uma vez: lançar na
-- PROPOSTA da Danielle, e registrar no CATÁLOGO para facilitar as próximas.
--
-- PARTE A — na proposta (por proposal_id + título; guardado contra o que
-- ela já tenha lançado: só preenche onde o valor ainda está zerado):
--
--   Hotel Palazzo Ripetta (os dois períodos, por categoria):
--     Deluxe   · 7–10 maio 2.944 · 14–15 maio   988
--     Prestige · 7–10 maio 3.214 · 14–15 maio 1.078
--     Inclui impostos, tarifa flexível e café da manhã. Extras e a taxa de
--     soggiorno são pagos no hotel.
--   Transfers: aeroporto 205 (chegada e partida), estação 145 (ida e volta).
--   Meet & greet (chegada): 275 (2 pax).
--   Experiências: food tour 595 · Colosseum 730 · shopping 700 · barco 780.
--   Frascati: com cooking class 1.999 · sem cooking 1.560.
--   Foto do Luxury Shopping (ela mandou o link).
--
--   FICOU SEM PREÇO, DE PROPÓSITO: a "VIP assistance · Fiumicino
--   (departure)". Ela só mandou o meet & greet da chegada (275); o da
--   partida não veio, e não se inventa. Preencher quando ela disser.
--
-- PARTE B — forma de pagamento: 35% de sinal e o restante 45 a 50 dias
--   antes da viagem (troca o "100% upfront" do texto). CONFIRA o texto
--   depois de rodar: se ela tiver reescrito as condições, a troca não
--   acha a frase e nada muda (aí me avise).
--
-- PARTE C — catálogo (reutilizável): preço de referência com a data, e a
--   comissão padrão que ela definiu — 10% hotel/transfer/meet, 12% nas
--   experiências. A comissão é SÓ interna: não existe em ops_proposal_items
--   e não sai em tl_get_quote; mora no catálogo como referência, e vira
--   valor na order quando a venda fechar. Cria a coluna commission_pct no
--   catálogo e as fichas de transfer/meet que faltavam.
--
-- ESTE ARQUIVO MEXE EM LINHA QUE JÁ EXISTE — confira e rode você. Rodar
-- depois da 0072. Seção 7: toca ops_proposal_items e ops_proposals
-- (update guardado), ops_catalog (add column + update/insert guardado),
-- ops_migrations (insert). Sem drop/truncate/delete. Nenhuma tabela do CRM.
-- =====================================================================

-- Proposta: f1d3d719-5142-43e7-9359-e2b7249a25d6

-- =========================== PARTE A · VALORES NA PROPOSTA =============

-- Hotel · Deluxe (os dois períodos como unidades), só se ainda zerado
update ops_proposal_items set
  units = E'[{"key":"p1","label":"May 7 to 10, 2027 · 3 nights","label_en":"May 7 to 10, 2027 · 3 nights","price":2944,"optional":false},{"key":"p2","label":"May 14 to 15, 2027 · 1 night","label_en":"May 14 to 15, 2027 · 1 night","price":988,"optional":false}]'::jsonb,
  included_en = E'Taxes, flexible rate and breakfast included. Extras and the city tax (tassa di soggiorno) are paid at the hotel.'
 where proposal_id = 'f1d3d719-5142-43e7-9359-e2b7249a25d6'
   and 'Palazzo Ripetta · Deluxe room' in (coalesce(title,''), coalesce(title_en,''))
   and not exists (select 1 from jsonb_array_elements(coalesce(units,'[]'::jsonb)) u
                    where coalesce((u->>'price')::numeric,0) <> 0);

-- Hotel · Prestige
update ops_proposal_items set
  units = E'[{"key":"p1","label":"May 7 to 10, 2027 · 3 nights","label_en":"May 7 to 10, 2027 · 3 nights","price":3214,"optional":false},{"key":"p2","label":"May 14 to 15, 2027 · 1 night","label_en":"May 14 to 15, 2027 · 1 night","price":1078,"optional":false}]'::jsonb,
  included_en = E'Taxes, flexible rate and breakfast included. Extras and the city tax (tassa di soggiorno) are paid at the hotel.'
 where proposal_id = 'f1d3d719-5142-43e7-9359-e2b7249a25d6'
   and 'Palazzo Ripetta · Prestige room' in (coalesce(title,''), coalesce(title_en,''))
   and not exists (select 1 from jsonb_array_elements(coalesce(units,'[]'::jsonb)) u
                    where coalesce((u->>'price')::numeric,0) <> 0);

-- Transfers de aeroporto · 205 (chegada e partida)
update ops_proposal_items set price = 205
 where proposal_id = 'f1d3d719-5142-43e7-9359-e2b7249a25d6'
   and (coalesce(title,'') in ('Private arrival transfer · Fiumicino → Palazzo Ripetta','Private departure transfer · Palazzo Ripetta → Fiumicino')
     or coalesce(title_en,'') in ('Private arrival transfer · Fiumicino → Palazzo Ripetta','Private departure transfer · Palazzo Ripetta → Fiumicino'))
   and coalesce(price,0) = 0;

-- Transfers de estação · 145 (ida e volta)
update ops_proposal_items set price = 145
 where proposal_id = 'f1d3d719-5142-43e7-9359-e2b7249a25d6'
   and (coalesce(title,'') in ('Private transfer · Palazzo Ripetta → train station','Private transfer · train station → Palazzo Ripetta')
     or coalesce(title_en,'') in ('Private transfer · Palazzo Ripetta → train station','Private transfer · train station → Palazzo Ripetta'))
   and coalesce(price,0) = 0;

-- Meet & greet (chegada) · 275 para 2 pax
update ops_proposal_items set price = 275
 where proposal_id = 'f1d3d719-5142-43e7-9359-e2b7249a25d6'
   and 'VIP meet & greet · Fiumicino (arrival)' in (coalesce(title,''), coalesce(title_en,''))
   and coalesce(price,0) = 0;

-- Experiências de preço único
update ops_proposal_items set price = 595
 where proposal_id = 'f1d3d719-5142-43e7-9359-e2b7249a25d6'
   and 'Private Rome Food Tour' in (coalesce(title,''), coalesce(title_en,'')) and coalesce(price,0) = 0;
update ops_proposal_items set price = 730
 where proposal_id = 'f1d3d719-5142-43e7-9359-e2b7249a25d6'
   and 'Private Colosseum and Roman Forum Tour with Arena' in (coalesce(title,''), coalesce(title_en,'')) and coalesce(price,0) = 0;
update ops_proposal_items set price = 700
 where proposal_id = 'f1d3d719-5142-43e7-9359-e2b7249a25d6'
   and 'Luxury Shopping in Rome with a Personal Shopper' in (coalesce(title,''), coalesce(title_en,'')) and coalesce(price,0) = 0;
update ops_proposal_items set price = 780
 where proposal_id = 'f1d3d719-5142-43e7-9359-e2b7249a25d6'
   and 'Private Boat Experience on the Tiber' in (coalesce(title,''), coalesce(title_en,'')) and coalesce(price,0) = 0;

-- Frascati · as duas opções (unidades), só se ainda zerado
update ops_proposal_items set
  units = E'[{"key":"o1","label":"With a private cooking class · private driver, a hands-on cooking class, a winery visit, a guided tasting and lunch","label_en":"With a private cooking class · private driver, a hands-on cooking class, a winery visit, a guided tasting and lunch","price":1999,"optional":false},{"key":"o2","label":"Visit and tasting · private driver, a winery visit, a guided tasting and a regional lunch","label_en":"Visit and tasting · private driver, a winery visit, a guided tasting and a regional lunch","price":1560,"optional":false}]'::jsonb
 where proposal_id = 'f1d3d719-5142-43e7-9359-e2b7249a25d6'
   and 'Roman Countryside · Frascati Culinary Day' in (coalesce(title,''), coalesce(title_en,''))
   and not exists (select 1 from jsonb_array_elements(coalesce(units,'[]'::jsonb)) u
                    where coalesce((u->>'price')::numeric,0) <> 0);

-- Foto do Luxury Shopping (só onde ainda sem foto)
update ops_proposal_items set photos = E'["https://i.postimg.cc/DZtYQr6f/images.jpg"]'::jsonb
 where proposal_id = 'f1d3d719-5142-43e7-9359-e2b7249a25d6'
   and 'Luxury Shopping in Rome with a Personal Shopper' in (coalesce(title,''), coalesce(title_en,''))
   and coalesce(jsonb_array_length(photos),0) = 0;

-- =========================== PARTE B · FORMA DE PAGAMENTO =============
-- Troca "100% upfront" por 35% de sinal + saldo 45–50 dias antes. A troca
-- é literal (replace), em qualquer das três colunas de condições onde a
-- frase estiver. Não acha a frase (ela reescreveu) → não muda nada.
update ops_proposals set conditions = replace(conditions,
    'full payment (100%) is required upfront at the time of booking',
    'a deposit of 35% confirms the booking, and the balance is due 45 to 50 days before travel')
 where id = 'f1d3d719-5142-43e7-9359-e2b7249a25d6' and position('full payment (100%)' in coalesce(conditions,'')) > 0;
update ops_proposals set conditions_en = replace(conditions_en,
    'full payment (100%) is required upfront at the time of booking',
    'a deposit of 35% confirms the booking, and the balance is due 45 to 50 days before travel')
 where id = 'f1d3d719-5142-43e7-9359-e2b7249a25d6' and position('full payment (100%)' in coalesce(conditions_en,'')) > 0;
update ops_proposals set conditions_pt = replace(conditions_pt,
    'full payment (100%) is required upfront at the time of booking',
    'a deposit of 35% confirms the booking, and the balance is due 45 to 50 days before travel')
 where id = 'f1d3d719-5142-43e7-9359-e2b7249a25d6' and position('full payment (100%)' in coalesce(conditions_pt,'')) > 0;

-- =========================== PARTE C · CATÁLOGO ======================
-- Comissão padrão vira coluna do catálogo (referência interna).
alter table ops_catalog add column if not exists commission_pct numeric(5,2);
comment on column ops_catalog.commission_pct is
  'Comissão de referência (%). Interna: não sai em tl_get_quote. Vira valor na order.';

-- Experiências: preço de referência (2 pax), data de hoje, comissão 12%.
-- Só preenche onde o preço ainda não foi lançado.
update ops_catalog set price = 595, price_unit = 'total · 2 pax', commission_pct = 12,
    price_updated_at = now(), updated_at = now()
 where id = 'e7000000-0000-0000-0000-000000000001' and price is null;
update ops_catalog set price = 730, price_unit = 'total · 2 pax', price_note = '4 hours, ticket included', commission_pct = 12,
    price_updated_at = now(), updated_at = now()
 where id = 'e7000000-0000-0000-0000-000000000002' and price is null;
update ops_catalog set price = 1999, price_unit = 'total · 2 pax', price_note = 'with private cooking class; without cooking 1560', commission_pct = 12,
    price_updated_at = now(), updated_at = now()
 where id = 'e7000000-0000-0000-0000-000000000003' and price is null;
update ops_catalog set price = 700, price_unit = 'total · 2 pax', commission_pct = 12,
    price_updated_at = now(), updated_at = now()
 where id = 'e7000000-0000-0000-0000-000000000004' and price is null;
update ops_catalog set price = 780, price_unit = 'total · 2 pax', commission_pct = 12,
    price_updated_at = now(), updated_at = now()
 where id = 'e7000000-0000-0000-0000-000000000005' and price is null;

-- Foto do shopping também no catálogo (reúso)
update ops_catalog set photos = E'["https://i.postimg.cc/DZtYQr6f/images.jpg"]'::jsonb, updated_at = now()
 where id = 'e7000000-0000-0000-0000-000000000004' and coalesce(jsonb_array_length(photos),0) = 0;

-- Palazzo Ripetta: comissão 10% (preço varia por período/categoria, fica em branco)
update ops_catalog set commission_pct = 10, updated_at = now()
 where id = 'c0000000-0000-0000-0000-000000000002' and commission_pct is null;

-- Fichas de transfer e meet & greet que faltavam no catálogo (reutilizáveis).
insert into ops_catalog (id, kind, name, region, descr_en, price, price_unit, commission_pct, internal_notes) values
 ('e7000000-0000-0000-0000-0000000000a1','transfer','Private transfer · airport ↔ Rome hotel','Roma',
  E'Private transfer between the airport and the hotel in Rome, with assistance on arrival.',
  205,'per transfer · 2 pax',10,'Referência da TL-055-26 (Danielle).'),
 ('e7000000-0000-0000-0000-0000000000a2','transfer','Private transfer · Rome hotel ↔ train station','Roma',
  E'Private transfer between the hotel in Rome and the train station.',
  145,'per transfer · 2 pax',10,'Referência da TL-055-26 (Danielle).'),
 ('e7000000-0000-0000-0000-0000000000a3','transfer','VIP meet & greet · airport','Roma',
  E'A dedicated greeter waits at the gate and escorts you through immigration, baggage claim and customs, to your driver.',
  275,'total · 2 pax',10,'Referência da TL-055-26 (Danielle).')
on conflict (id) do nothing;

insert into ops_migrations (id) values ('0073-danielle-valores-e-catalogo') on conflict (id) do nothing;
