-- =====================================================================
-- 0146 · TL-063-26: LEO E BRUNO NO CHIANTI (TOURISTIQUE)
--
-- Pedido dela, 14/11/26: proposta pequena, em português, para a agência
-- Touristique (Bruno). Casal em lua de mel, de carro alugado, 6 a 8 de
-- maio de 2027. Um hotel e uma experiência.
--
--   · Borgo Vescine, duas categorias (Deluxe Plus e Superior). Texto da
--     ficha da 0046 (supplier b0000000-…), em português. Valor em branco:
--     ela manda o net na segunda;
--   · caça às trufas de manhã, com almoço, e degustação de vinhos no
--     Vescine à tarde. Data a definir, de segunda a sexta-feira. UMA
--     linha com o preço da experiência inteira. O fornecedor da trufa NÃO
--     aparece (nem o nome da villa do almoço, que leva a ele no Google);
--     fica em internal_notes;
--   · TARIFA NET: a Touristique trabalha net. A peça de apresentação sai
--     sem valores, com a marca dela (white label), para ela repassar ao
--     casal; os valores e a aprovação vão no link #/valores/<net_token>,
--     em tabela, assinado pela Tuscan Lands. É o desenho que ela descreveu
--     ("apresentação do hotel sem valor, e uma proposta simples com os
--     valores") e é o que rate_type='net' já faz. Primeira proposta net
--     do banco;
--   · sem folha comercial na apresentação (show_summary=false): a peça
--     acaba na experiência. As condições ficam ligadas, e saem só no link
--     dos valores, que é onde mora o resumo;
--   · condições de pagamento da regra nova dela para proposta abaixo de
--     € 3.000: transferência internacional ou Wise; cartão com 3%, por
--     Stripe (que aceita Pix) ou PayPal; sempre em euros. As condições
--     gerais são as da casa, palavra por palavra;
--   · sem folha de abertura (assurance vazio), como na TL-065-26.
--
-- Seção 7: só insert (oportunidade, proposta e duas linhas novas) e o
-- ajuste da própria proposta recém-criada. Nada que já existia muda.
-- Lê ops_suppliers (b0000000-…). Roda uma vez: se a TL-063-26 já existe
-- no hub, para.
-- =====================================================================

do $$
declare
  opp  uuid;
  prop uuid := 'e0630000-0000-0000-0000-000000000001';
  vesc uuid := 'b0000000-0000-0000-0000-000000000000';
  sq   text := 'https://images.squarespace-cdn.com/content/v1/63fa5a875489c1006b8bcdd1/';
begin
  if exists (select 1 from ops_opportunities where crm_code = 'TL-063-26') then
    raise exception '0146: a TL-063-26 já existe no hub';
  end if;
  if not exists (select 1 from ops_suppliers where id = vesc) then
    raise exception '0146: ficha do Borgo Vescine (0046) não encontrada';
  end if;

  insert into ops_opportunities (crm_code, title, lang, agency, agency_contact, final_client, outcome, internal_notes)
  values ('TL-063-26', 'Leo e Bruno · lua de mel no Chianti', 'pt', 'Touristique', 'Bruno', 'Leo e Bruno', 'open',
          'Casal em lua de mel, de carro alugado na Toscana. Pedido: degustação de vinhos, caça às trufas e hospedagem em borgo ou hotel vinícola no Chianti, 6 a 8/5/2027. Agência trabalha net.')
  returning id into opp;

  insert into ops_proposals (
    id, opportunity_id, version, title, lang, layout, modelo, rate_type,
    white_label, agency_logo, agency_logo_bg,
    cover_img, cover_tag_pt, cover_title, travel_window, pax_summary,
    show_prices, confirm_mode, show_summary, show_conditions, preselect, payment_options,
    sections, excluded_pt, conditions_pt, internal_notes)
  values (
    prop, opp, 1, 'Lua de mel no Chianti', 'pt', 'apresentada', null, 'net',
    true, 'fotos/tl063/logo-touristique.png', false,
    sq||'2bd64383-1583-4f90-8c4c-260a6d4f059c/DJI_20250704213434_0154_D-HDR_11zon.jpg?format=2500w',
    'Lua de mel · Chianti Classico', 'Leo e Bruno', '6 a 8 de maio de 2027', '2 adultos',
    true, 'full', false, true, false, '[]'::jsonb,
    jsonb_build_array(
      jsonb_build_object('key','estadia', 'modo','blocos',
        'title','Borgo Vescine', 'title_en','Borgo Vescine',
        'note','6 a 8 de maio · 2 noites em Radda in Chianti',
        'photo', sq||'b4d8a974-9538-4649-8a67-a03fa8b8669f/17-DJI_20260721155004_0473_D-HDR.jpg?format=2500w'),
      jsonb_build_object('key','experiencia', 'modo','blocos',
        'title','Trufas e vinho', 'title_en','Truffles and wine',
        'note','Data a definir, de segunda a sexta-feira',
        'photo','fotos/tl063/trufa.jpg')),
$x$- Aluguel do carro, combustível e pedágios
- Refeições e bebidas que não estão descritas nesta proposta$x$,
$c$**FORMA DE PAGAMENTO**
40% na aprovação e saldo em até 35 dias antes da viagem.
Para valores inferiores a 1.000 euros, pagamento 100% na aprovação.

Os valores desta proposta são para pagamento por transferência bancária internacional ou Wise.
Para pagamento com cartão de crédito, o valor final tem acréscimo de 3%. O cartão pode ser processado pela Stripe, que aceita também Pix, ou pelo PayPal.
O pagamento é sempre em euros, e a conversão é feita no momento do pagamento. Se tratando de uma transação internacional, eventuais taxas como o IOF serão de responsabilidade do cliente.

Nossa equipe fornecerá um link de pagamento com as instruções necessárias, e para os casos de pagamentos parcelados (sinal + saldo), os links de pagamento serão enviados manualmente pela nossa equipe.

**CONDIÇÕES GERAIS:**
- Ao aceitar as condições desta proposta, a contratação dos serviços será formalizada mediante aceite dos termos e condições dos serviços aprovados. Somente após esta etapa, as reservas serão realizadas e confirmadas.
- Validade das condições comerciais previstas nesta proposta: 30 dias da data de envio (ou enquanto houver disponibilidade das tarifas). Após esta data, os valores propostos poderão ser revistos.
- Esta proposta não contempla pré-bloqueios ou reservas, salvo se expresso no descritivo.
- A Tuscan Lands Travel não efetua tais serviços na modalidade last minute (após chegada do cliente ao destino) no período de junho a setembro, bem como durante festas de final de ano (Natal e Ano Novo), salvo exceções.
- A Tuscan Lands Travel e seus parceiros envolvidos na realização dos passeios não se responsabilizam por perda/roubo ou furto de bens e objetos pessoais, que possam ocorrer durante a execução do roteiro, cabendo ao viajante a responsabilidade por zelar e cuidar de seus pertences pessoais.$c$,
    'Net a lançar (ela manda na segunda). Hotel e degustação da tarde: Borgo Vescine. Caça às trufas com almoço: Castello Monterinaldi, almoço na Villa Pesanella (Lucarelli, Radda) — nome não sai na proposta. Distância Vescine → Pesanella: ~11 km, ~20 min de carro (OSRM). Foto da trufa provisória: Wikimedia Commons, Sahgdg, CC BY-SA 4.0.');

  -- O gatilho de padrões encheu a folha de abertura; nesta peça ela não sai.
  update ops_proposals set assurance_pt = '', assurance_en = '' where id = prop;

  -- 1 · o hotel, com as duas categorias como unidades (valor em branco)
  insert into ops_proposal_items (proposal_id, sort, section, kind, optional, price, supplier, supplier_id,
    service_date, title, title_en, details, facilities, website, photos, units, extras, attachments)
  select prop, 0, 'estadia', 'stay', true, 0, 'Borgo Vescine', s.id,
    '6 a 8 de maio de 2027 · 2 noites', 'Borgo Vescine', 'Borgo Vescine',
$t$Relais cinco estrelas num borgo do século XIII em Radda in Chianti, no coração do Chianti Classico. Cada categoria de quarto ocupa uma parte do borgo que tinha função própria, do celeiro à prensa da uva, e o restauro manteve as proporções e os materiais de cada uma. São 42 hectares de vinhedos, oliveiras e bosque, com trilhas dentro da propriedade, piscina num jardim italiano e uma adega centenária onde se provam os vinhos da casa.
Siena fica a 20 km, Florença a 42.

**Deluxe Plus** · 22 a 24 m², cama queen (160 × 190 cm) e um pequeno pátio privativo
Era onde se prensava e fermentava a uva. Mesmos materiais e mesmo restauro das Deluxe, com um canto ao ar livre só do quarto.

**Superior** · cerca de 35 m², cama king (180 × 190 cm), vista para as colinas e para a praça do borgo
Era o depósito das azeitonas, onde o fruto esperava a prensagem. Piso de cotto queimado à lenha, vigas aparentes e móveis feitos sob medida por artesãos da região.$t$,
$t$- Piso de cotto queimado à lenha e vigas originais do borgo
- Móveis desenhados para a casa e feitos à mão na região
- Banheiros reformados, com roupão e chinelos
- Produtos de banho feitos na região, sem plástico descartável
- Minibar reposto todos os dias$t$,
    s.website,
    jsonb_build_array(
      sq||'ed5b9ad5-ca6b-4c60-8900-29174fd4ed5d/_GIU0426+copia_11zon.jpg?format=1500w',
      sq||'8b0630a5-c9ea-4c1f-ba93-f88166d8a0d4/030_1IN7570-HDR.jpg?format=1500w',
      sq||'cea8897f-aa28-4f28-87a5-0c57b2b9123c/071-_1IN4762-HDR-Modifica.jpg?format=1500w'),
    jsonb_build_array(
      jsonb_build_object('key','deluxe_plus', 'label','Deluxe Plus · com pátio privativo', 'label_en','Deluxe Plus Room', 'price',0, 'optional',true),
      jsonb_build_object('key','superior', 'label','Superior · cama king', 'label_en','Superior Room', 'price',0, 'optional',true)),
    '[]'::jsonb, '[]'::jsonb
  from ops_suppliers s where s.id = vesc;

  -- 2 · a experiência: trufa de manhã, vinho à tarde, um preço só
  insert into ops_proposal_items (proposal_id, sort, section, kind, optional, price, supplier,
    service_date, title, title_en, details, included_pt, photos, units, extras, attachments)
  values (prop, 1, 'experiencia', 'experience', true, 0, 'Castello Monterinaldi (trufa e almoço) + Borgo Vescine (degustação)',
    'Data a definir · de segunda a sexta-feira', 'Caça às trufas e vinhos do Chianti', 'Truffle hunting and Chianti wines',
$t$**Manhã · caça às trufas**
Saída às 10h, com um trufeiro da região e o cão treinado dele, nos bosques em volta de uma propriedade vinícola do Chianti Classico. Depois de uma breve introdução, o passeio segue pelo bosque e vocês acompanham a busca de perto, participando dela. Em seguida, visita à adega histórica da propriedade e almoço na villa, com trufa num cardápio toscano tradicional e os vinhos da casa.
Cerca de 4 horas, em ritmo tranquilo. A busca depende das condições da estação.

**Tarde · degustação no Borgo Vescine**
De volta ao hotel, degustação dos vinhos do borgo na adega centenária.

A propriedade da caça às trufas fica a cerca de 11 km do Borgo Vescine, uns 20 minutos de carro. Vale ir com roupa para caminhar ao ar livre. Opções vegetarianas e veganas sob pedido. Idiomas: italiano e inglês.

Foto da caça às trufas: Sahgdg, Wikimedia Commons, CC BY-SA 4.0.$t$,
$t$- Caça às trufas privativa, com trufeiro e cão treinado
- Visita à adega histórica da propriedade
- Almoço com trufa e vinhos da propriedade
- Degustação de vinhos no Borgo Vescine, à tarde$t$,
    jsonb_build_array('fotos/tl063/trufa.jpg',
      sq||'4a674b12-9bba-4999-9be0-71f4d20306d4/_GIU9617_HDR+copia.jpg?format=1500w',
      sq||'6d00bd45-367c-452e-9c64-4553940c6820/_GIU9687+copia.jpg?format=1500w'),
    '[]'::jsonb, '[]'::jsonb, '[]'::jsonb);
end $$;

insert into ops_migrations (id) values ('0146-tl-063-26-vescine-e-trufas') on conflict (id) do nothing;
