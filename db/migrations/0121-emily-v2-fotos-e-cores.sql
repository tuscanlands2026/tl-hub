-- =====================================================================
-- 0121 · EMILY (TL-053-26, v2): CORES NÃO GARANTIDAS, FOTOS DO BULGARI
--        E DOS QUARTOS DO CASTELFALFI
--
-- Instrução dela, 12/11/26:
--   · "coloca que as cores não são garantidas. Isso é muito importante"
--     — entra na nota embaixo dos dois cartões de carro;
--   · Bulgari: uma foto por quarto (já era) e mais fotos do hotel. O
--     mosaico leva três: o terraço, a sala com vista de Roma e o spa;
--   · Castelfalfi: as fotos da galeria oficial de cada quarto
--     (castelfalfi.com/rooms-suites/junior-suite-terrace e /suite-terrace).
--     Sai a foto do terraço da Junior Suite Terrace, que era a mesma do
--     mosaico do hotel, repetida duas telas depois.
--
-- A linha de crédito das fotos de carro saiu da folha, a pedido dela; o
-- autor e a licença ficam no próprio <img> (title), sem ocupar espaço.
--
-- Fotos não entram na base de fornecedores: instrução dela, "por agora".
--
-- Seção 7: update de três linhas de ops_proposal_items da v2, com o sim
-- dela. Só enquanto a proposta não foi respondida.
-- =====================================================================

-- 1 · carros: cores não garantidas
update ops_proposal_items set
  options_note_en = 'Models are subject to availability at the time of booking. Colors are not guaranteed.'
 where proposal_id = 'e0530000-0000-0000-0000-000000000002'
   and section = 'around' and title_en = 'Your car in Tuscany'
   and exists (select 1 from ops_proposals
                where id = 'e0530000-0000-0000-0000-000000000002' and responded_at is null);

-- 2 · Bulgari: três fotos do hotel
update ops_proposal_items set
  photos = '["fotos/tl053/bulgari-terraco.jpg","fotos/tl053/bulgari-sala-vista.jpg","fotos/tl053/bulgari-spa.jpg"]'::jsonb
 where proposal_id = 'e0530000-0000-0000-0000-000000000002'
   and section = 'stays' and title_en = 'Bulgari Hotel Roma'
   and exists (select 1 from ops_proposals
                where id = 'e0530000-0000-0000-0000-000000000002' and responded_at is null);

-- 3 · Castelfalfi: fotos oficiais de cada quarto
update ops_proposal_items i set
  units = (select jsonb_agg(
             case u->>'key'
               when 'u1' then u || jsonb_build_object('photos', '["fotos/tl053/junior-suite-terrace-01.jpg","fotos/tl053/junior-suite-terrace-03.jpg","fotos/tl053/junior-suite-terrace-quarto.jpg"]'::jsonb)
               when 'u2' then u || jsonb_build_object('photos', '["fotos/tl053/suite-terrace-01.jpg","fotos/tl053/suite-terrace-03.jpg","fotos/tl053/suite-terrace-quarto.jpg"]'::jsonb)
               else u end order by o)
             from jsonb_array_elements(i.units) with ordinality t(u, o))
 where proposal_id = 'e0530000-0000-0000-0000-000000000002'
   and section = 'stays' and title_en = 'Castelfalfi'
   and exists (select 1 from ops_proposals
                where id = 'e0530000-0000-0000-0000-000000000002' and responded_at is null);

insert into ops_migrations (id) values ('0121-emily-v2-fotos-e-cores') on conflict (id) do nothing;
