-- =====================================================================
-- 0059 · A PROPOSTA DA EMILY, MONTADA
--
-- Pedido dela, outubro/26: "eu acho que você mesmo podia colocar para
-- montar já para mim. Eu posso te colocar o link da proposta que eu
-- estou trabalhando e você altera em cima". O link veio, e é esta:
--   TL-053-26 · Tuscany and Venice 2027 · Destinations by Dani
--   ops_proposals.id = b59090ad-14dc-45d3-87f5-9f7206834668
--
-- ESTE ARQUIVO MEXE EM LINHA QUE JÁ EXISTE, e por isso é arquivo próprio
-- e numerado, e só roda depois do sim dela. O que ele toca, item a item:
--
--   · INSERE as NOVE linhas de hospedagem — três por base — nas três
--     seções que ela já criou. Nenhuma linha dela é reescrita;
--   · LIGA o modo de valor indicativo (rate_mode) e DESLIGA a folha de
--     condições gerais (show_conditions), que foi o que ela pediu em
--     setembro: "nessa fase a gente não vai colocar aquela página";
--   · ESCREVE o aviso da tarifa em inglês (rate_note_en), adaptado do
--     parágrafo "About the rates" do briefing dela, palavra por palavra
--     onde dá. O par em português fica em branco: a proposta é inteira
--     em inglês, e bloco vazio não sai, o que é melhor que sair na
--     língua errada;
--   · ACRESCENTA as noites de cada base em sections — 4, 3 e 3 — pelo
--     merge de jsonb, de modo que título, instrução, foto e modo que ela
--     escreveu continuam exatamente como estão;
--   · APAGA a linha de serviço em branco que ficou de rascunho
--     (d6760666-04b3-43e3-8839-83aa579840b1). O delete é CONDICIONADO a
--     ela continuar vazia: se ela tiver digitado qualquer coisa ali
--     nesse meio-tempo, o comando não apaga nada.
--
-- O QUE ESTE ARQUIVO NÃO TOCA: título, capa, nome grande, a folha da
-- Curadoria (que é o overview, escrito por ela), sobre nós, respaldo,
-- contracapa, o texto das condições (só a chave que decide se a folha
-- sai), white label, modo de envio, idioma, janela de viagem, o token,
-- os títulos das seções. E não toca em nenhuma outra proposta.
--
-- OS VALORES ENTRAM EM BRANCO, de propósito. Cada hotel leva DUAS
-- categorias sugeridas, com o campo de valor vazio para ela lançar o
-- valor por noite; o hub multiplica pelas noites da base e mostra a
-- estimativa. Categoria sem valor lançado sai só com o nome, e não com
-- € 0,00 — isso foi acertado no index.html junto desta migração.
--
-- AS DATAS SÃO AS DO BRIEFING (0055): Cortona 20–25 de junho é a villa
-- deles e não tem opção de hotel; a segunda base 25–29 (4 noites),
-- Florença 29 de junho–2 de julho (3) e Veneza 2–5 de julho (3).
--
-- O TEXTO E O SITE DE CADA HOTEL VÊM DA FICHA, e não estão digitados
-- aqui: o insert é um select em ops_suppliers. É a mesma regra do
-- "puxar, não copiar e colar" — e o que desce é CÓPIA, então corrigir a
-- ficha em dezembro não muda esta proposta. O preço da ficha não desce:
-- ele é custo net, e o da linha é a venda.
--
-- Rodar depois da 0058, que é quem cria as fichas do Aman Venice e do
-- Hotel Cipriani. Sem ela, duas das nove linhas não entram — o select
-- não acha o fornecedor e insere zero linhas, sem erro.
--
-- Só toca objetos ops_. Nenhuma tabela do CRM é lida ou citada.
--
-- CONFERÊNCIA DA SEÇÃO 7, relida antes de entregar. Os objetos que este
-- arquivo toca, um a um: ops_proposal_items (insert e um delete condicionado),
-- ops_proposals (update em UMA linha, pelo id), ops_suppliers (apenas LEITURA,
-- no select que preenche as linhas) e ops_migrations (insert). Nenhum drop,
-- alter ou truncate. Nenhuma tabela do CRM é lida, escrita ou citada. Nenhum
-- comando percorre o schema. Nenhuma service_role key aparece aqui.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1 · AS NOVE LINHAS DE HOSPEDAGEM
-- ---------------------------------------------------------------------
insert into ops_proposal_items
  (id, proposal_id, sort, supplier_id, section, kind, service_date,
   title, title_en, details, details_en, facilities, facilities_en,
   website, photos, units, qty, unit_price, price, optional, extras, attachments, supplier)
select E'53260000-0000-0000-0000-000000000001', E'b59090ad-14dc-45d3-87f5-9f7206834668', 0, s.id, E'stays', 'stay', E'June 25 to 29, 2027',
  E'Dimora Ghirlandaio', E'Dimora Ghirlandaio', null, s.summary, null, s.accommodation_notes,
  s.website, E'["https://dimoraghirlandaio.it/wp-content/uploads/2024/07/DG_Aerial_Villas-overview.jpg", "https://dimoraghirlandaio.it/wp-content/uploads/2024/10/dimora_ghirlandaio-La_Limonaia-bedroom-1024x683.jpg", "https://dimoraghirlandaio.it/wp-content/uploads/2024/08/DG_Lo-Studio_Living-Room_June2024.jpg"]'::jsonb, E'[{"key": "u1", "label": "Suite La Limonaia", "label_en": "Suite La Limonaia", "price": 0, "optional": false}, {"key": "u2", "label": "Villa Lo Studio", "label_en": "Villa Lo Studio", "price": 0, "optional": false}]'::jsonb, 1, null, 0, true, '[]'::jsonb, '[]'::jsonb, s.name
  from ops_suppliers s where s.id = E'd0000000-0000-0000-0000-000000000000'
on conflict (id) do nothing;

insert into ops_proposal_items
  (id, proposal_id, sort, supplier_id, section, kind, service_date,
   title, title_en, details, details_en, facilities, facilities_en,
   website, photos, units, qty, unit_price, price, optional, extras, attachments, supplier)
select E'53260000-0000-0000-0000-000000000002', E'b59090ad-14dc-45d3-87f5-9f7206834668', 1, s.id, E'stays', 'stay', E'June 25 to 29, 2027',
  E'Castelfalfi', E'Castelfalfi', null, s.summary, null, s.accommodation_notes,
  s.website, E'["https://www.castelfalfi.com/assets/img/transform/_1400xAUTO_crop_center-center_90_none/15388/Castelfalfi-hero.webp", "https://www.castelfalfi.com/assets/img/transform/_1500x1000_crop_center-center_90_none/30900/carosello-castelfalfi-suite-01.webp", "https://www.castelfalfi.com/assets/img/transform/_1400xAUTO_crop_center-center_90_none/15366/Infinity-pool-1.webp"]'::jsonb, E'[{"key": "u1", "label": "Suite · 50 m² / 538 sq ft", "label_en": "Suite · 50 m² / 538 sq ft", "price": 0, "optional": false}, {"key": "u2", "label": "Castelfalfi Suite · 63 m² / 678 sq ft", "label_en": "Castelfalfi Suite · 63 m² / 678 sq ft", "price": 0, "optional": false}]'::jsonb, 1, null, 0, true, '[]'::jsonb, '[]'::jsonb, s.name
  from ops_suppliers s where s.id = E'c1000000-0000-0000-0000-000000000000'
on conflict (id) do nothing;

insert into ops_proposal_items
  (id, proposal_id, sort, supplier_id, section, kind, service_date,
   title, title_en, details, details_en, facilities, facilities_en,
   website, photos, units, qty, unit_price, price, optional, extras, attachments, supplier)
select E'53260000-0000-0000-0000-000000000003', E'b59090ad-14dc-45d3-87f5-9f7206834668', 2, s.id, E'stays', 'stay', E'June 25 to 29, 2027',
  E'Borgo Vescine', E'Borgo Vescine', null, s.summary, null, s.accommodation_notes,
  s.website, E'["https://images.squarespace-cdn.com/content/v1/63fa5a875489c1006b8bcdd1/112165a3-4bf7-410a-a0af-0cacf50287fa/_1IN6814-HDR.jpg", "https://images.squarespace-cdn.com/content/v1/63fa5a875489c1006b8bcdd1/e5a01f65-8adf-4e44-ac49-2b42252d9240/12-_1IN6375-HDR.jpg", "https://images.squarespace-cdn.com/content/v1/63fa5a875489c1006b8bcdd1/e9432ce3-26b0-4895-9255-773606483787/063-_1IN4714-HDR.jpg"]'::jsonb, E'[{"key": "u1", "label": "Suite · around 40 m² / 431 sq ft", "label_en": "Suite · around 40 m² / 431 sq ft", "price": 0, "optional": false}, {"key": "u2", "label": "Suite Superior with Patio · around 55 m² / 592 sq ft", "label_en": "Suite Superior with Patio · around 55 m² / 592 sq ft", "price": 0, "optional": false}]'::jsonb, 1, null, 0, true, '[]'::jsonb, '[]'::jsonb, s.name
  from ops_suppliers s where s.id = E'b0000000-0000-0000-0000-000000000000'
on conflict (id) do nothing;

insert into ops_proposal_items
  (id, proposal_id, sort, supplier_id, section, kind, service_date,
   title, title_en, details, details_en, facilities, facilities_en,
   website, photos, units, qty, unit_price, price, optional, extras, attachments, supplier)
select E'53260000-0000-0000-0000-000000000004', E'b59090ad-14dc-45d3-87f5-9f7206834668', 3, s.id, E'sec1', 'stay', E'June 29 to July 2, 2027',
  E'Belmond Villa San Michele', E'Belmond Villa San Michele', null, s.summary, null, s.accommodation_notes,
  s.website, E'["https://img.belmond.com/f_auto/t_1080_ar_4_5/photos/vsm/vsm-ext-florence-view11.jpg", "https://img.belmond.com/f_auto/t_1080_ar_5_4/photos/vsm/vsm-acc-suite-garden-suite04.jpg", "https://img.belmond.com/f_auto/t_1080_ar_5_4/photos/vsm/vsm-gst-garden15.jpg"]'::jsonb, E'[{"key": "u1", "label": "Garden Suite · from 60 m² / 646 sq ft", "label_en": "Garden Suite · from 60 m² / 646 sq ft", "price": 0, "optional": false}, {"key": "u2", "label": "Signature Suite · from 109 m² / 1,173 sq ft", "label_en": "Signature Suite · from 109 m² / 1,173 sq ft", "price": 0, "optional": false}]'::jsonb, 1, null, 0, true, '[]'::jsonb, '[]'::jsonb, s.name
  from ops_suppliers s where s.id = E'f0000000-0000-0000-0000-000000000000'
on conflict (id) do nothing;

insert into ops_proposal_items
  (id, proposal_id, sort, supplier_id, section, kind, service_date,
   title, title_en, details, details_en, facilities, facilities_en,
   website, photos, units, qty, unit_price, price, optional, extras, attachments, supplier)
select E'53260000-0000-0000-0000-000000000005', E'b59090ad-14dc-45d3-87f5-9f7206834668', 4, s.id, E'sec1', 'stay', E'June 29 to July 2, 2027',
  E'Collegio alla Querce, Auberge Resorts Collection', E'Collegio alla Querce, Auberge Resorts Collection', null, s.summary, null, s.accommodation_notes,
  s.website, E'["https://dreffui1gbt6t.cloudfront.net/images/caq/CAQ-stay-suites-feature-category.jpg", "https://dreffui1gbt6t.cloudfront.net/images/caq/CAQ-stay-principeking-feature.jpg", "https://dreffui1gbt6t.cloudfront.net/images/caq/CAQ-stay-suitegiardino-featuredimage-1.jpg"]'::jsonb, E'[{"key": "u1", "label": "Principe Junior Suite", "label_en": "Principe Junior Suite", "price": 0, "optional": false}, {"key": "u2", "label": "Suite Giardino", "label_en": "Suite Giardino", "price": 0, "optional": false}]'::jsonb, 1, null, 0, true, '[]'::jsonb, '[]'::jsonb, s.name
  from ops_suppliers s where s.id = E'a0000000-0000-0000-0000-000000000000'
on conflict (id) do nothing;

insert into ops_proposal_items
  (id, proposal_id, sort, supplier_id, section, kind, service_date,
   title, title_en, details, details_en, facilities, facilities_en,
   website, photos, units, qty, unit_price, price, optional, extras, attachments, supplier)
select E'53260000-0000-0000-0000-000000000006', E'b59090ad-14dc-45d3-87f5-9f7206834668', 5, s.id, E'sec1', 'stay', E'June 29 to July 2, 2027',
  E'Four Seasons Hotel Firenze', E'Four Seasons Hotel Firenze', null, s.summary, null, s.accommodation_notes,
  s.website, E'["https://press.fourseasons.com/content/dam/fourseasons/images/web/FLO/FLO_3014_original.jpg/jcr:content/renditions/cq5dam.web.press.722.keepaspectratio.jpeg", "https://press.fourseasons.com/content/dam/fourseasons/images/web/FLO/FLO_3031_aspect16x9.jpg/jcr:content/renditions/cq5dam.web.press.722.keepaspectratio.jpeg", "https://press.fourseasons.com/content/dam/fourseasons/images/web/FLO/FLO_3190_aspect16x9.jpg/jcr:content/renditions/cq5dam.web.press.722.keepaspectratio.jpeg"]'::jsonb, E'[{"key": "u1", "label": "Premier Room", "label_en": "Premier Room", "price": 0, "optional": false}, {"key": "u2", "label": "Suite", "label_en": "Suite", "price": 0, "optional": false}]'::jsonb, 1, null, 0, true, '[]'::jsonb, '[]'::jsonb, s.name
  from ops_suppliers s where s.id = E'19000000-0000-0000-0000-000000000000'
on conflict (id) do nothing;

insert into ops_proposal_items
  (id, proposal_id, sort, supplier_id, section, kind, service_date,
   title, title_en, details, details_en, facilities, facilities_en,
   website, photos, units, qty, unit_price, price, optional, extras, attachments, supplier)
select E'53260000-0000-0000-0000-000000000007', E'b59090ad-14dc-45d3-87f5-9f7206834668', 6, s.id, E'sec2', 'stay', E'July 2 to 5, 2027',
  E'Danieli, Venezia, A Four Seasons Hotel', E'Danieli, Venezia, A Four Seasons Hotel', null, s.summary, null, s.accommodation_notes,
  s.website, E'["https://press.fourseasons.com/content/dam/fourseasons/images/web/DAN/DAN_261_aspect16x9.jpg/jcr:content/renditions/cq5dam.web.press.722.keepaspectratio.jpeg", "https://press.fourseasons.com/content/dam/fourseasons/images/web/DAN/DAN_263_aspect16x9.jpg/jcr:content/renditions/cq5dam.web.press.722.keepaspectratio.jpeg", "https://press.fourseasons.com/content/dam/fourseasons/images/web/DAN/DAN_265_aspect16x9.jpg/jcr:content/renditions/cq5dam.web.press.722.keepaspectratio.jpeg"]'::jsonb, E'[{"key": "u1", "label": "Premium Lagoon-View Room", "label_en": "Premium Lagoon-View Room", "price": 0, "optional": false}, {"key": "u2", "label": "Lagoon-View Suite", "label_en": "Lagoon-View Suite", "price": 0, "optional": false}]'::jsonb, 1, null, 0, true, '[]'::jsonb, '[]'::jsonb, s.name
  from ops_suppliers s where s.id = E'29000000-0000-0000-0000-000000000000'
on conflict (id) do nothing;

insert into ops_proposal_items
  (id, proposal_id, sort, supplier_id, section, kind, service_date,
   title, title_en, details, details_en, facilities, facilities_en,
   website, photos, units, qty, unit_price, price, optional, extras, attachments, supplier)
select E'53260000-0000-0000-0000-000000000008', E'b59090ad-14dc-45d3-87f5-9f7206834668', 7, s.id, E'sec2', 'stay', E'July 2 to 5, 2027',
  E'Aman Venice', E'Aman Venice', null, s.summary, null, s.accommodation_notes,
  s.website, E'["https://www.aman.com/sites/default/files/styles/full_size_extra_large/public/2024-07/aman_venice_italy_-_exterior_grand_canal_2.webp?itok=FqpOzWPR", "https://www.aman.com/sites/default/files/styles/full_size_extra_large/public/2023-04/aman-venice-accommodation-alcova-tiepolo-suite-bedroom_3.webp?itok=KX5xZlzK", "https://www.aman.com/sites/default/files/styles/full_size_extra_large/public/2022-07/Aman%20Venice.-%20Garden%20-%20Landscape.webp?itok=y45-hx37"]'::jsonb, E'[{"key": "u1", "label": "Palazzo Stanza Canal Grande · 57 to 89 m² / 613 to 957 sq ft", "label_en": "Palazzo Stanza Canal Grande · 57 to 89 m² / 613 to 957 sq ft", "price": 0, "optional": false}, {"key": "u2", "label": "Grand Canal Suite · 97 m² / 1,044 sq ft", "label_en": "Grand Canal Suite · 97 m² / 1,044 sq ft", "price": 0, "optional": false}]'::jsonb, 1, null, 0, true, '[]'::jsonb, '[]'::jsonb, s.name
  from ops_suppliers s where s.id = E'39000000-0000-0000-0000-000000000000'
on conflict (id) do nothing;

insert into ops_proposal_items
  (id, proposal_id, sort, supplier_id, section, kind, service_date,
   title, title_en, details, details_en, facilities, facilities_en,
   website, photos, units, qty, unit_price, price, optional, extras, attachments, supplier)
select E'53260000-0000-0000-0000-000000000009', E'b59090ad-14dc-45d3-87f5-9f7206834668', 8, s.id, E'sec2', 'stay', E'July 2 to 5, 2027',
  E'Palazzo Vendramin at Hotel Cipriani', E'Palazzo Vendramin at Hotel Cipriani', null, s.summary, null, s.accommodation_notes,
  s.website, E'["https://img.belmond.com/f_auto/t_1080_ar_5_4/photos/cip/cip-ext30.jpg", "https://img.belmond.com/f_auto/t_1080_ar_5_4/photos/cip/cip-acc-suite-jrsuite-private-garden-palazzo-vendramin01.jpg", "https://img.belmond.com/f_auto/t_1080_ar_5_4/photos/cip/cip-gst-pool20.jpg"]'::jsonb, E'[{"key": "u1", "label": "Junior Suite · 33 to 65 m² / 355 to 700 sq ft", "label_en": "Junior Suite · 33 to 65 m² / 355 to 700 sq ft", "price": 0, "optional": false}, {"key": "u2", "label": "Suite · 50 to 80 m² / 538 to 861 sq ft", "label_en": "Suite · 50 to 80 m² / 538 to 861 sq ft", "price": 0, "optional": false}]'::jsonb, 1, null, 0, true, '[]'::jsonb, '[]'::jsonb, s.name
  from ops_suppliers s where s.id = E'49000000-0000-0000-0000-000000000000'
on conflict (id) do nothing;

-- ---------------------------------------------------------------------
-- 2 · AS NOITES DE CADA BASE
-- O merge de jsonb (||) acrescenta a chave e preserva tudo que ela
-- escreveu na seção. Reescrever o array inteiro aqui apagaria o título
-- e a instrução dela no dia em que ela mudasse uma palavra.
-- ---------------------------------------------------------------------
update ops_proposals set sections = (
  select jsonb_agg(
           case s->>'key'
             when 'stays' then s || '{"nights":4}'::jsonb
             when 'sec1'  then s || '{"nights":3}'::jsonb
             when 'sec2'  then s || '{"nights":3}'::jsonb
             else s
           end order by ord)
    from jsonb_array_elements(sections) with ordinality t(s, ord))
 where id = 'b59090ad-14dc-45d3-87f5-9f7206834668'
   and sections is not null and jsonb_array_length(sections) > 0;

-- ---------------------------------------------------------------------
-- 3 · VALOR INDICATIVO, SEM A FOLHA DE CONDIÇÕES, COM O AVISO DA TARIFA
--
-- rate_label fica em branco de propósito: vazio cai no padrão do hub
-- ("average per night" em inglês), e afirmação comercial é dela.
-- show_conditions = false não apaga o texto das condições: ele continua
-- gravado e volta no dia em que ela religar a folha.
-- ---------------------------------------------------------------------
update ops_proposals set
  rate_mode       = 'indicativo',
  show_conditions = false,
  rate_note_en    = E'**These are indicative rates, not a quotation.** They are per night, before city tax, and reflect current pricing. Most of these hotels price 2027 dynamically, so the figures will move. Once the hotels are chosen we request firm rates, with the bed configuration confirmed in writing, and move to the formal proposal.',
  updated_at      = now()
 where id = 'b59090ad-14dc-45d3-87f5-9f7206834668';

-- ---------------------------------------------------------------------
-- 4 · A LINHA EM BRANCO DO RASCUNHO
-- Condicionada a continuar vazia. Digitou algo nela? Nada é apagado.
-- ---------------------------------------------------------------------
delete from ops_proposal_items
 where id = 'd6760666-04b3-43e3-8839-83aa579840b1'
   and proposal_id = 'b59090ad-14dc-45d3-87f5-9f7206834668'
   and coalesce(title,'') = '' and coalesce(title_en,'') = ''
   and coalesce(details,'') = '' and coalesce(details_en,'') = ''
   and coalesce(price,0) = 0
   and coalesce(jsonb_array_length(units), 0) = 0
   and coalesce(jsonb_array_length(photos), 0) = 0;

insert into ops_migrations (id) values ('0059-proposta-da-emily') on conflict (id) do nothing;
