-- =====================================================================
-- 0131 · EMILY (TL-053-26): ORDER DOS QUARTOS E DO CARRO, E A V3 PARA AS
--        EXPERIÊNCIAS
--
-- A agência respondeu por e-mail, 13/11/26: "We would like to do the Suite
-- Terrace at Castelfalfi and the Junior Suite in Rome. We'd also like to
-- select Category 1 for vehicle." Instrução dela:
--
--   1 · gerar uma order SÓ com esses três itens. A v2 fica em aberto e
--       NÃO é marcada como aceita — ela ainda tem acesso a ela. Por isso a
--       order nasce sem ligar à oportunidade (opportunity_id nulo), só com o
--       código TL-053-26 em texto: ligar exige proposta aceita (gatilho
--       tl_guard_order). Número TL-053-26.1; a 0130 faz a próxima ser .2.
--       O checkout pede o nome completo dos dois, como no passaporte, com a
--       data de nascimento, e como preferem passar o cartão de garantia —
--       "para eles acharem a melhor forma". Cartão NÃO se digita no
--       formulário: a pergunta é só a forma, e a ajuda diz isso.
--       Documento: "por agora é o nome, o cartão".
--   2 · a v3 é cópia idêntica da v2, como o botão "Nova versão" faria
--       (tudo menos identidade, link, resposta e aceite; e o net_token,
--       que é único). Nela os quartos e o carro aprovados ficam marcados
--       como já aprovados (approved, 0130): só o quarto e a categoria
--       escolhidos, com valor, sem caixinha e fora do total. A agência
--       escolhe só as experiências, e dessa resposta nasce a segunda order.
--
-- O briefing (#/b/aa1224ef…) só tem os primeiros nomes, Emily e Nathan, e a
-- advisor, Danielle Robb. Sobrenome e nascimento vêm pelo checkout.
--
-- Seção 7: só INSERT — uma order com três linhas e uma pergunta, e uma
-- proposta nova com as linhas copiadas; depois, update só nas linhas da
-- PRÓPRIA v3, que acabaram de nascer. Nada na v2, na v1 nem em order que
-- já existia. Roda uma vez: se a order ou a v3 já existem, para.
-- =====================================================================

do $$
declare
  v2   uuid := 'e0530000-0000-0000-0000-000000000002';
  v3   uuid := 'e0530000-0000-0000-0000-000000000003';
  ord  uuid;
  cols text;
  pp   ops_proposals%rowtype;
begin
  select * into pp from ops_proposals where id = v2;
  if not found then raise exception '0131: v2 não encontrada'; end if;
  if exists (select 1 from ops_orders where order_ref = 'TL-053-26.1') then
    raise exception '0131: a order TL-053-26.1 já existe';
  end if;
  if exists (select 1 from ops_proposals where id = v3
             or (opportunity_id = pp.opportunity_id and version = 3)) then
    raise exception '0131: a v3 já existe';
  end if;

  -- 1 · a order
  insert into ops_orders
    (opportunity_code, order_ref, lang, status, agency, agency_contact, final_client,
     pax_summary, travel_window, terms_url, proposal_ref, internal_notes, checkout_config)
  values ('TL-053-26', 'TL-053-26.1', 'en', 'draft', 'Destinations by Dani', 'Danielle Robb',
     'Emily and Nathan', '2', pp.travel_window, pp.terms_url,
     coalesce(pp.title,'') || ' · v2',
     'Quartos e carro aprovados pela agência por e-mail em 13/11/26. A v2 continua em aberto; as experiências seguem na v3, e delas nasce a segunda order.',
     '{"dob":"required","lead":"blank","prefill":{},"remarks":true,"travellers":"blank","ack_vehicle":false,"passport_names":true,"travellers_count":2}'::jsonb)
  returning id into ord;

  insert into ops_order_items (order_id, sort, service_date, title, details, price, supplier, op_tipo)
  select ord, 0, 'June 21 to 28, 2027', 'Rental car · Category 1',
         'Mercedes GLE, Maserati Grecale Modena or Audi Q8, subject to availability · 1,400 km included · fuel not included',
         4845, null, 'self_drive'
  union all
  select ord, 1, 'June 25 to 29, 2027', 'Castelfalfi · Suite Terrace · 4 nights', i.included_en, 14160, i.supplier, 'hotel'
    from ops_proposal_items i where i.proposal_id = v2 and i.title_en = 'Castelfalfi'
  union all
  select ord, 2, 'June 29 to July 3, 2027', 'Bulgari Hotel Roma · Junior Suite · 4 nights', i.included_en, 15480, i.supplier, 'hotel'
    from ops_proposal_items i where i.proposal_id = v2 and i.title_en = 'Bulgari Hotel Roma';
  if (select count(*) from ops_order_items where order_id = ord) <> 3 then
    raise exception '0131: a order não ficou com as três linhas';
  end if;

  insert into ops_order_fields
    (order_id, sort, group_key, field_key, label_pt, label_en, input_type, options, required, mode, help_pt, help_en)
  values (ord, 0, 'custom', 'custom.card_guarantee',
    'Garantia em cartão de crédito para as reservas dos hotéis e do carro: como preferem enviar?',
    'Credit card guarantee for the hotel and car reservations: how would you prefer to provide it?',
    'select',
    '["Secure link sent to the agency","Secure link sent directly to the travellers","Other (please explain in the remarks)"]'::jsonb,
    true, 'blank',
    'Não escreva dados de cartão neste formulário. Nossa equipe envia um link seguro para isso.',
    'Please do not write any card details in this form. Our team will send a secure link for it.');

  -- 2 · a v3, cópia da v2
  select string_agg(quote_ident(column_name), ', ' order by ordinal_position) into cols
    from information_schema.columns
   where table_schema = 'public' and table_name = 'ops_proposals'
     and column_name not in ('id','version','token','created_at','updated_at','sent_at','decided_at',
                             'outcome','acceptance_mode','refusal_reason','responded_at','net_token');
  execute format('insert into ops_proposals (id, version, %s) select %L::uuid, 3, %s from ops_proposals where id = %L::uuid',
                 cols, v3, cols, v2);

  -- o gatilho tl_proposal_defaults preenche texto VAZIO com o padrão da casa;
  -- na v2 eles estão todos preenchidos, e a cópia tem de sair igual
  if exists (select 1 from ops_proposals a, ops_proposals b where a.id = v2 and b.id = v3
             and (a.about_en, a.assurance_en, a.backcover_en, a.conditions_en, a.credentials_en)
                 is distinct from (b.about_en, b.assurance_en, b.backcover_en, b.conditions_en, b.credentials_en)) then
    raise exception '0131: a v3 não saiu com os mesmos textos da v2';
  end if;

  select string_agg(quote_ident(column_name), ', ' order by ordinal_position) into cols
    from information_schema.columns
   where table_schema = 'public' and table_name = 'ops_proposal_items'
     and column_name not in ('id','proposal_id');
  execute format('insert into ops_proposal_items (proposal_id, %s) select %L::uuid, %s from ops_proposal_items where proposal_id = %L::uuid',
                 cols, v3, cols, v2);

  -- na v3, o que já foi aprovado: só a opção escolhida, marcada como aprovada
  update ops_proposal_items i set approved = true,
    units = (select jsonb_agg(u order by o) from jsonb_array_elements(i.units) with ordinality t(u, o) where u->>'key' = 'u2')
   where proposal_id = v3 and title_en in ('Castelfalfi', 'Bulgari Hotel Roma');
  update ops_proposal_items i set approved = true,
    units = (select jsonb_agg(u order by o) from jsonb_array_elements(i.units) with ordinality t(u, o) where u->>'key' = 'c1')
   where proposal_id = v3 and title_en = 'Your car in Tuscany';
  if (select count(*) from ops_proposal_items where proposal_id = v3 and approved) <> 3 then
    raise exception '0131: a v3 não ficou com os três itens aprovados';
  end if;
end $$;

insert into ops_migrations (id) values ('0131-emily-order-1-e-v3') on conflict (id) do nothing;
