-- =====================================================================
-- 0165 · TL-054-26: BOCELLI EXPERIENCE, FACILITY TURISMO
--
-- Instrução dela, 26/11/26. Programa de viagem em português, no desenho
-- da TL-064-26 (modelo jornada), entregue como a da Touristique: uma peça
-- SEM valores, que vai ao cliente final e vende o conceito, e o link dos
-- valores NET para a Caroline Giglio, da Facility, que é quem aprova.
--
--   · o concerto primeiro (é o motivo da compra), o hotel depois;
--   · Andrea Bocelli no Teatro del Silenzio, sábado 24/7/2027, 20h30;
--     bilhetes Executive VIP de 1ª categoria, lounge com open bar e bufê,
--     transfer privativo do hotel ao teatro e de volta;
--   · jantar antes do concerto é opcional;
--   · Castelfalfi de 23 a 26/7, três quartos para 2 pessoas cada: com 4
--     pessoas, dois quartos, iguais ou diferentes (instrução dela);
--   · bilhetes e jantar valem para o mesmo número de pessoas: no link dos
--     valores, 2 OU 4 (choice_group), e a regra escrita na nota da seção;
--   · white label com o logo da Facility, em branco sobre a foto;
--   · capa: "Bocelli Experience", sem nome de cliente final (ela não tem).
--
-- A peça do cliente é feita de linhas sem valor (o concerto contado, o
-- hotel com os quartos). Os valores moram nas seções 'v_bilhetes' e
-- 'v_hotel', de tipo 'valores', que a peça jornada não desenha; o link dos
-- valores de proposta jornada mostra só as linhas com valor (index.html).
--
-- VALORES NET (dela, 26/11/26):
--   bilhetes, transporte incluso, sem jantar: 2 pessoas 4.520 · 4 pessoas 7.380
--   jantar antes do concerto: 2 pessoas 120 · 4 pessoas 240
--   Castelfalfi, por noite, tarifa do hotel com 8% de desconto (opção B):
--     Tabaccaia Classic 1.930 → 1.775,60 · 3 noites 5.326,80
--     Deluxe            2.010 → 1.849,20 · 3 noites 5.547,60
--     Deluxe Dolcevita  2.170 → 1.996,40 · 3 noites 5.989,20
--
-- Seção 7: só insert (oportunidade, proposta e linhas novas) e o ajuste da
-- própria proposta recém-criada. Nada que já existia muda. Roda uma vez:
-- se a TL-054-26 já existe no hub, para. O CRM não é tocado.
-- =====================================================================

do $$
declare
  opp  uuid;
  prop uuid := 'e0540000-0000-0000-0000-000000000001';
  cf   uuid := 'c1000000-0000-0000-0000-000000000000';
begin
  if exists (select 1 from ops_opportunities where crm_code = 'TL-054-26') then
    raise exception '0165: a TL-054-26 já existe no hub';
  end if;

  insert into ops_opportunities (crm_code, title, lang, agency, agency_contact, final_client, outcome, internal_notes)
  values ('TL-054-26', 'Bocelli Experience · Facility Turismo', 'pt',
          'Facility Turismo', 'Caroline Giglio', '', 'open',
          'No CRM a TL-054-26 (Facility Tour, Caroline) consta como Perdida; esta é a proposta refeita em 26/11/26, por instrução dela. Cliente final sem nome.')
  returning id into opp;

  insert into ops_proposals (
    id, opportunity_id, version, title, lang, layout, modelo, rate_type,
    white_label, agency_logo, agency_logo_bg,
    cover_img, cover_tag_pt, cover_tag_en, cover_title, travel_window, pax_summary,
    show_prices, confirm_mode, show_summary, show_conditions, preselect, payment_options,
    assurance_pt, assurance_img, curations, sections, labels,
    excluded_pt, conditions_pt, internal_notes)
  values (
    prop, opp, 1, 'Bocelli Experience', 'pt', 'apresentada', 'jornada', 'net',
    true, 'fotos/tl054/logo-facility-branco.png', false,
    'fotos/tl054/concerto-palco.jpg', 'Lajatico · Toscana', 'Lajatico · Tuscany', 'Bocelli Experience',
    '24 de julho de 2027', '2 ou 4 pessoas',
    false, 'full', true, true, false, '[]'::jsonb,
$a$**Uma noite na terra natal de Bocelli.**
Uma vez por ano, as colinas de Lajatico viram palco. No Teatro del Silenzio, um anfiteatro ao ar livre no meio do campo, a poucos quilômetros de onde nasceu, Andrea Bocelli volta todo verão para cantar diante de um público que chega do mundo inteiro.
Em 2027, o concerto é no sábado, 24 de julho, às 20h30.$a$,
    'fotos/tl054/concerto-plateia.jpg',
    jsonb_build_array(jsonb_build_object(
      'cor','verde', 'opcao','Em resumo',
      'title_pt','Bocelli Experience 2027',
      'dest_pt', E'Teatro del Silenzio · Lajatico\nCastelfalfi · Montaione, a cerca de 40 minutos do teatro',
      'dias_pt',
$d$A noite do concerto pode ser vivida de duas formas: só com os bilhetes, ou com três noites no Castelfalfi.
COM O CASTELFALFI
- Sexta, 23 de julho: chegada ao Castelfalfi
- Sábado, 24 de julho: Bocelli no Teatro del Silenzio, às 20h30
- Domingo, 25 de julho: dia livre no Castelfalfi. Com mau tempo no sábado, o concerto passa para esta noite
- Segunda, 26 de julho: saída$d$)),
    jsonb_build_array(
      jsonb_build_object('key','concerto', 'tipo','narrativa', 'modo','dias', 'nights', null,
        'title','Bocelli no Teatro del Silenzio · 24 de julho', 'title_en','Bocelli at Teatro del Silenzio · July 24'),
      jsonb_build_object('key','castelfalfi', 'tipo','hospedagem', 'modo','blocos', 'nights', 3,
        'title','Onde vocês vão ficar', 'title_en','Where you will stay',
        'photo','fotos/tl054/castelfalfi-verao.jpg',
        'intro','Três noites no Castelfalfi, de 23 a 26 de julho, a cerca de 40 minutos do teatro. Cada quarto recebe duas pessoas.'),
      jsonb_build_object('key','v_bilhetes', 'tipo','valores', 'modo','blocos', 'nights', null,
        'title','Bocelli Experience · 24 de julho de 2027', 'title_en','Bocelli Experience · July 24, 2027',
        'note','Bilhetes e jantar valem para o mesmo número de pessoas: 2 ou 4.'),
      jsonb_build_object('key','v_hotel', 'tipo','valores', 'modo','blocos', 'nights', null,
        'title','Castelfalfi · 23 a 26 de julho de 2027 · 3 noites', 'title_en','Castelfalfi · July 23 to 26, 2027 · 3 nights',
        'note','Cada quarto recebe 2 pessoas. Para 4 pessoas, dois quartos, do mesmo tipo ou de tipos diferentes.')),
    jsonb_build_object(
      'j_menu_glance',      jsonb_build_object('pt','Em resumo'),
      'j_menu_concerto',    jsonb_build_object('pt','Bocelli em Lajatico'),
      'j_menu_stay',        jsonb_build_object('pt','Onde vocês vão ficar'),
      'j_stay',             jsonb_build_object('pt','Onde vocês vão ficar'),
      'prop_menu',          jsonb_build_object('pt','Condições'),
      'prop_title',         jsonb_build_object('pt','Condições da proposta'),
      'net_sec_v_bilhetes', jsonb_build_object('pt','TL Signature Experiences'),
      'net_sec_v_hotel',    jsonb_build_object('pt','Stays')),
$x$- Passagens aéreas e transfers de chegada e saída
- Hospedagem, na opção só com os bilhetes
- Refeições e bebidas que não aparecem nesta proposta
- Gorjetas$x$,
$c$**PAGAMENTO**
**Prazos:** 35% na reserva e o restante em 3 parcelas iguais, em 20 de dezembro, 20 de fevereiro e 20 de abril.
**Meios de pagamento:** cartão de débito multimoeda, cartão de crédito internacional ou transferência bancária internacional. Para pagamento com Pix, os valores têm acréscimo de 1% de taxas da plataforma.
**Câmbio:** o pagamento é sempre feito em euros, pela cotação do dia de cada pagamento. Por se tratar de transação internacional, eventuais taxas, como o IOF, ficam a cargo do cliente.
**Links de pagamento:** nossa equipe envia o link com as instruções. No pagamento parcelado, os links de cada parcela são enviados pela nossa equipe.

**CONDIÇÕES GERAIS**
**Contratação:** ao aceitar esta proposta, a contratação se formaliza com o aceite dos termos e condições do pacote terrestre. Só depois dessa etapa e do pagamento do sinal os bilhetes e as reservas são feitos e confirmados.
**Sem reserva prévia:** esta proposta não faz reserva nem pré-bloqueio de bilhetes ou de quartos, e não garante disponibilidade.
**Parcelas:** no pagamento parcelado, depois de 3 dias úteis de atraso o serviço é considerado cancelado, assim como todas as confirmações feitas. Eventuais devoluções seguem os termos e condições gerais: https://tuscanlandstravel.com/terms-conditions-tours/
**Validade:** as condições desta proposta valem enquanto houver disponibilidade.
**Pessoas e quartos:** bilhetes e jantar são para o mesmo número de pessoas. Cada quarto recebe duas pessoas; com quatro, são dois quartos, do mesmo tipo ou de tipos diferentes.
**Fotos:** as fotos desta proposta são ilustrativas.

**INFORMAÇÕES IMPORTANTES SOBRE O CONCERTO**
As condições abaixo são definidas pela organização do Teatro del Silenzio e valem para todos os bilhetes do evento.
**Bilhetes:** depois de confirmados, não são reembolsáveis. A organização define os lugares dentro de cada setor, sem possibilidade de escolha.
**Chuva:** com mau tempo, o concerto de 24 de julho passa para 25 de julho. A mudança de data não dá direito a reembolso, mesmo que os viajantes não possam comparecer na nova data.
**Interrupção:** se o concerto for interrompido depois de pelo menos 40 minutos do início, não há reembolso.
**Greve e força maior:** em caso de greve anunciada pela organização do evento ou de força maior, como desastre natural ou doença do artista, é devolvido apenas o valor de face dos bilhetes. Não há responsabilidade por despesas, danos ou prejuízos decorrentes de cancelamento, adiamento ou alteração do evento.
**Crianças:** a partir de 6 anos, pagam bilhete inteiro. Abaixo de 6 anos não pagam, se ficarem no colo dos pais.
**Acessibilidade:** pessoas com mobilidade reduzida ou com deficiência assistem ao concerto na área reservada por lei, mediante pedido no momento da reserva e sujeito à disponibilidade de lugares. Com bilhete de outro setor, o acesso ao evento não é permitido, por segurança.
**O local:** o teatro fica ao ar livre, em área rural, com acesso por terreno irregular. Os banheiros são químicos e ficam na parte de trás da plateia. O evento não é recomendado para pessoas com dificuldade de locomoção ou que devam evitar esforço físico, e a participação é de responsabilidade de cada viajante.
**Mudanças depois da compra:** condições de saúde que surjam depois da compra não dão direito a troca, reembolso ou mudança de lugar.$c$,
    'Bilhetes: fornecedor Enjoylive Travel (oferta Bocelli 24/7/2027). Base Poltronissima 2ª cat. 1.395/pax (2) ou 1.095/pax (4) + upgrade Executive VIP 1ª cat. +350/pax → custo 3.490 (2) / 5.780 (4); venda net 4.520 / 7.380. Jantar: suplemento 55/pax → net 120 (2) / 240 (4). Castelfalfi: tarifa por noite 1.930 / 2.010 / 2.170, net = −8% (opção B, dela). Café da manhã e tarifa flexível vieram da proposta de outubro: confirmar com o hotel para 2027.');

  -- O concerto, contado: sem valor e sem opção. É a peça.
  insert into ops_proposal_items (proposal_id, sort, section, kind, optional, price, supplier,
    title, title_en, service_date, details, included_pt, good_pt, photos, units, extras)
  values (prop, 0, 'concerto', 'experience', false, 0, 'Enjoylive Travel',
    'Bocelli no Teatro del Silenzio', 'Bocelli at Teatro del Silenzio',
    'Sábado, 24 de julho de 2027 · 20h30',
$t$Os lugares são no setor Executive, de frente para o palco, com estacionamento e entrada próprios, a cerca de 100 metros do controle de acesso. Antes do show, o lounge Executive recebe os convidados com open bar e bufê até o início do concerto.
Um motorista busca vocês no hotel, leva ao teatro e traz de volta depois do concerto. Para quem prefere jantar sentado antes do show, há a opção de um jantar toscano num restaurante da região, a caminho do teatro.$t$,
$t$- Bilhete Executive VIP, 1ª categoria
- Estacionamento e entrada Executive
- Lounge Executive, com open bar e bufê até o início do concerto
- Presente do Teatro del Silenzio e programa da noite
- Transfer privativo do hotel ao teatro, e de volta depois do concerto
- Entrega dos bilhetes no hotel e assistência por telefone$t$,
$t$Esta proposta não faz reserva nem pré-bloqueio de bilhetes. Os lugares são confirmados depois da contratação, e a organização define os assentos dentro de cada setor.
Com mau tempo, o concerto passa para domingo, 25 de julho.
O teatro fica em área rural, com acesso por terreno irregular.$t$,
    '["fotos/tl054/concerto-bocelli.jpg","fotos/tl054/concerto-luzes.jpg"]'::jsonb, '[]'::jsonb, '[]'::jsonb);

  -- O hotel, com os três quartos: sem valor. É a peça.
  insert into ops_proposal_items (proposal_id, sort, section, kind, optional, price, supplier, supplier_id,
    title, title_en, service_date, details, included_pt, website, photos, units, extras)
  values (prop, 1, 'castelfalfi', 'stay', true, 0, 'Castelfalfi', cf,
    'Castelfalfi', 'Castelfalfi', '23 a 26 de julho de 2027 · 3 noites',
$t$No alto de uma colina em Montaione, entre Florença e Pisa, o Castelfalfi é um cinco estrelas construído em volta de um borgo medieval, com o castelo, a igreja de San Floriano e o jardim dos Medici. Em volta, são cerca de 1.100 hectares de campo, de onde vêm o vinho e o azeite orgânicos servidos à mesa.
O hotel tem spa, piscina ao ar livre e campo de golfe, e o jantar pode ser no próprio borgo. Fica a cerca de 40 minutos do Teatro del Silenzio.
Com o concerto na noite do meio, se o mau tempo levar o show para o domingo, vocês continuam hospedados.$t$,
$t$- Café da manhã
- Tarifa flexível$t$,
    'https://www.castelfalfi.com/',
    '["fotos/tl054/castelfalfi-borgo.jpg","fotos/tl054/castelfalfi-vinhedo.jpg","fotos/tl054/castelfalfi-verao.jpg"]'::jsonb,
    jsonb_build_array(
      jsonb_build_object('key','tabaccaia', 'optional',true, 'price',0,
        'label','Tabaccaia Classic', 'ficha','22 m² · no antigo armazém de tabaco do borgo',
        'desc','Os quartos Tabaccaia ocupam o antigo armazém de tabaco do borgo, do começo do século XX, restaurado em estilo toscano tradicional.',
        'photos', jsonb_build_array('fotos/tl054/tabaccaia-quarto.jpg','fotos/tl054/tabaccaia-armazem.jpg'),
        'links', jsonb_build_array(jsonb_build_object('name','Tour virtual 360°','url','https://my.matterport.com/show/?m=sYQsziGWgpS'))),
      jsonb_build_object('key','deluxe', 'optional',true, 'price',0,
        'label','Deluxe', 'ficha','30 m² · no edifício principal',
        'desc','No coração do edifício principal, com as cores quentes da paisagem toscana e design contemporâneo. Todos os serviços do hotel ficam a poucos passos.',
        'photos', jsonb_build_array('fotos/tl054/deluxe-quarto.jpg','fotos/tl054/deluxe-quarto-2.jpg'),
        'links', jsonb_build_array(jsonb_build_object('name','Tour virtual 360°','url','https://my.matterport.com/show/?m=npnBSsjV2Y1'))),
      jsonb_build_object('key','dolcevita', 'optional',true, 'price',0,
        'label','Deluxe Dolcevita com jardim', 'ficha','30 m² · no edifício principal · jardim privativo',
        'desc','A Deluxe que se abre para a paisagem, com jardim privativo e vista para as colinas.',
        'photos', jsonb_build_array('fotos/tl054/dolcevita-jardim.jpg','fotos/tl054/dolcevita-quarto.jpg'),
        'links', jsonb_build_array(jsonb_build_object('name','Tour virtual 360°','url','https://my.matterport.com/show/?m=UQ4WQoYFbZf')))),
    '[]'::jsonb);

  -- OS VALORES (link da agência). A peça não desenha a seção 'valores'.
  insert into ops_proposal_items (proposal_id, sort, section, kind, optional, price, supplier, choice_group,
    title, title_en, service_date, row_desc_pt, photos, units, extras)
  values
  (prop, 10, 'v_bilhetes', 'experience', true, 0, 'Enjoylive Travel', 'bilhetes',
    'Bilhetes Executive · Bocelli no Teatro del Silenzio', 'Executive tickets · Bocelli at Teatro del Silenzio',
    '24 de julho de 2027',
    E'Bilhete Executive VIP, 1ª categoria, com lounge Executive (open bar e bufê), presente e programa\nTransfer privativo do hotel ao teatro e de volta · entrega dos bilhetes no hotel · assistência por telefone',
    '[]'::jsonb,
    jsonb_build_array(
      jsonb_build_object('key','pax2', 'optional',true, 'price',4520, 'label','2 pessoas', 'label_en','2 guests'),
      jsonb_build_object('key','pax4', 'optional',true, 'price',7380, 'label','4 pessoas', 'label_en','4 guests')),
    '[]'::jsonb),
  (prop, 11, 'v_bilhetes', 'experience', true, 0, 'Enjoylive Travel', 'jantar',
    'Jantar antes do concerto (opcional)', 'Dinner before the concert (optional)',
    '24 de julho de 2027',
    E'Jantar toscano num restaurante da região, antes do concerto, com o transfer passando pelo restaurante a caminho do teatro\nMesmo número de pessoas dos bilhetes',
    '[]'::jsonb,
    jsonb_build_array(
      jsonb_build_object('key','pax2', 'optional',true, 'price',120, 'label','2 pessoas', 'label_en','2 guests'),
      jsonb_build_object('key','pax4', 'optional',true, 'price',240, 'label','4 pessoas', 'label_en','4 guests')),
    '[]'::jsonb);

  insert into ops_proposal_items (proposal_id, sort, section, kind, optional, price, supplier, supplier_id, supplier_room_type_id, choice_group,
    title, title_en, service_date, row_desc_pt, photos, units, extras)
  select prop, q.sort, 'v_hotel', 'stay', true, 0, 'Castelfalfi', cf, q.rt, q.grupo,
         q.nome, q.nome, '23 a 26 de julho de 2027 · 3 noites',
         '3 noites, de 23 a 26 de julho · café da manhã e tarifa flexível · € ' || q.noite || ' por noite, por quarto',
         '[]'::jsonb,
         jsonb_build_array(
           jsonb_build_object('key','q1', 'optional',true, 'price',q.um,   'label','1 quarto · 2 pessoas',  'label_en','1 room · 2 guests'),
           jsonb_build_object('key','q2', 'optional',true, 'price',q.um*2, 'label','2 quartos · 4 pessoas', 'label_en','2 rooms · 4 guests')),
         '[]'::jsonb
    from (values
      (20, 'c1000000-0000-0000-0000-000000010000'::uuid, 'q_tabaccaia', 'Castelfalfi · Tabaccaia Classic',          '1.775,60', 5326.80),
      (21, 'c1000000-0000-0000-0000-000000040000'::uuid, 'q_deluxe',    'Castelfalfi · Deluxe',                     '1.849,20', 5547.60),
      (22, 'c1000000-0000-0000-0000-000000060000'::uuid, 'q_dolcevita', 'Castelfalfi · Deluxe Dolcevita com jardim', '1.996,40', 5989.20)
    ) as q(sort, rt, grupo, nome, noite, um);

  -- O gatilho de padrões encheu o fechamento da casa; no white label ele
  -- não sai, e a peça termina nas condições.
  update ops_proposals set closing_pt = '' where id = prop;
end $$;

insert into ops_migrations (id) values ('0165-tl-054-26-bocelli-experience') on conflict (id) do nothing;
