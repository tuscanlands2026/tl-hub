-- =====================================================================
-- 0122 · EMILY (TL-053-26, v2): MENU LATERAL, CANCELAMENTOS DA FERRARI E
--        DO CARRO, CONCIERGE, FOTOS NOVAS DOS CARROS, SEM "A JOURNEY WITH"
--
-- Instrução dela, 12/11/26, com o sim por escrito:
--   · menu lateral falando como a experiência do cliente: Cover, Opening,
--     Your journey in Italy, Cortona, Tuscany, Castelfalfi, Tuscany, From
--     Castelfalfi to Rome, Rome, Your selected stays, Ground services and
--     concierge, Your proposal. É nome de MENU (rótulo j_menu_<chave>), e
--     o título de cada folha não muda;
--   · "A journey with Destinations by Dani sai mesmo. Não vai para nenhum
--     outro lugar" — closing_en fica vazio, e a etapa some. O texto que
--     estava lá, para não se perder:
--       **A journey with Destinations by Dani**
--       Tuscan Lands Travel is the ground partner of Destinations by Dani
--       in Italy. Our team coordinates the trip locally, from the stays to
--       every transfer and experience, in direct contact with Danielle at
--       every step.
--       Before the trip, our concierge can take care of your restaurant
--       reservations, as described in Ground Services & Concierge, and
--       prepares a suggested route for the self-drive days with nothing
--       scheduled, so those days have a direction whenever you want one.
--       During the trip, the concierge remains available through Danielle
--       for whatever comes up along the way, always on request and subject
--       to availability. Our team on the ground follows each day together
--       with Danielle.
--   · cancelamentos todos nas General Conditions: a política da Ferrari e
--     a do aluguel de carro, como ela mandou;
--   · concierge: "60 euros por dia não é pouco… é uma personal selection
--     com base num alinhamento do perfil do cliente… e reservas,
--     confirmações e reconfirmações nas datas que antecedem o dia";
--   · fotos dos carros substituídas pelas que ela subiu
--     (postimg.cc/gallery/C5d9Wd4), hospedadas em fotos/tl053/carro-v2-*.
--     Sem crédito: não são mais as da Wikimedia.
--
-- Cada troca de texto se prende à frase que troca: se ela já editou, a
-- troca não acontece e o arquivo para com o nome do trecho.
--
-- Seção 7: update de linhas da v2 (ops_proposals e ops_proposal_items),
-- com o sim dela. Só enquanto a proposta não foi respondida.
-- =====================================================================

do $$
declare
  pid uuid := 'e0530000-0000-0000-0000-000000000002';
  c text; d text; n int;
begin
  if exists (select 1 from ops_proposals where id = pid and responded_at is not null) then
    raise exception '0122: a proposta já foi respondida, nada muda';
  end if;

  -- 1 · menu lateral, e sem a etapa "A journey with…"
  update ops_proposals set
    labels = coalesce(labels, '{}'::jsonb)
      || '{"j_menu_glance":{"en":"Your journey in Italy"},
           "j_menu_cortona":{"en":"Cortona, Tuscany"},
           "j_menu_castelfalfi":{"en":"Castelfalfi, Tuscany"},
           "j_menu_aroma":{"en":"From Castelfalfi to Rome"},
           "j_menu_stay":{"en":"Your selected stays"},
           "j_menu_around":{"en":"Ground services and concierge"}}'::jsonb,
    closing_en = null
   where id = pid;

  -- 2 · cancelamentos nas condições
  select conditions_en into c from ops_proposals where id = pid;
  d := c;
  c := replace(c,
    E'- Fuel is not included.\n**Ferrari experience:**',
    E'- Fuel is not included.\n- Cancellation: 20% of the rental amount is paid on confirmation and is non-refundable in case of cancellation; the balance is paid 30 days before the start of the rental and is non-refundable in case of cancellation.\n**Ferrari experience:**');
  if c = d then raise exception '0122: trecho do aluguel de carro não encontrado'; end if;
  d := c;
  c := replace(c,
    E'and a damage deductible of €15,000 applies.\n',
    E'and a damage deductible of €15,000 applies.\n**Ferrari experience · cancellation policy:**\n- 60 days or more prior to arrival: penalty of 30% of the total amount.\n- 59 to 31 days prior to arrival: penalty of 50% of the total amount.\n- 30 to 16 days prior to arrival: penalty of 75% of the total amount.\n- Within 15 days prior to arrival: penalty of 100% of the total amount.\n- No-show or early departure: penalty of 100% of the total amount.\n');
  if c = d then raise exception '0122: trecho da Ferrari não encontrado'; end if;
  update ops_proposals set conditions_en = c where id = pid;

  -- 3 · concierge
  update ops_proposal_items set
    details_en = replace(replace(details_en,
      'Before you travel, our concierge service takes care of the planning around your days, starting with the restaurants. The tables worth planning a day around are often booked months ahead: our team prepares a shortlist for each day, chosen around your route, and once you approve it we make the reservations, always subject to availability.',
      'Before you travel, our concierge prepares a personal selection for your days, starting with the restaurants, built on an alignment with you about your profile and your preferences. Once you approve it, we take care of the reservations, confirming and reconfirming each one in the days before the date, always subject to availability.'),
      '€60 per day for this service: the restaurant selection and reservations before the trip.',
      '€60 per day for this service: a personal selection aligned with your preferences, with reservations, confirmations and reconfirmations in the days before each date.'),
    row_en = 'Concierge · personal selection for your days',
    row_desc_en = E'A selection aligned with your preferences, with reservations, confirmations and reconfirmations in the days before each date.\n13 days × €60'
   where proposal_id = pid and section = 'around' and title_en = 'Concierge services · optional'
     and details_en like 'Before you travel, our concierge service takes care of the planning around your days%'
     and details_en like '%€60 per day for this service: the restaurant selection and reservations before the trip.%';
  get diagnostics n = row_count;
  if n <> 1 then raise exception '0122: texto do concierge não encontrado'; end if;

  -- 4 · fotos dos carros, as dela
  update ops_proposal_items i set
    units = (select jsonb_agg(
               case u->>'key'
                 when 'c1' then u || jsonb_build_object('models', '[
                   {"name":"Mercedes GLE","photo":"fotos/tl053/carro-v2-mercedes-gle.jpg"},
                   {"name":"Maserati Grecale Modena","photo":"fotos/tl053/carro-v2-maserati-grecale.jpg"},
                   {"name":"Audi Q8","photo":"fotos/tl053/carro-v2-audi-q8.jpg"}]'::jsonb)
                 when 'c2' then u || jsonb_build_object('models', '[
                   {"name":"Land Rover Defender 110","photo":"fotos/tl053/carro-v2-land-rover-defender.jpg"},
                   {"name":"BMW X7","photo":"fotos/tl053/carro-v2-bmw-x7.jpg"},
                   {"name":"Range Rover Sport","photo":"fotos/tl053/carro-v2-range-rover-sport.jpg"}]'::jsonb)
                 else u end order by o)
               from jsonb_array_elements(i.units) with ordinality t(u, o))
   where proposal_id = pid and section = 'around' and title_en = 'Your car in Tuscany';
  get diagnostics n = row_count;
  if n <> 1 then raise exception '0122: linha dos carros não encontrada'; end if;
end $$;

insert into ops_migrations (id) values ('0122-emily-v2-menu-cancelamentos-concierge') on conflict (id) do nothing;
