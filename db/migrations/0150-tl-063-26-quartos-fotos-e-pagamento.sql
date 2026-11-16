-- =====================================================================
-- 0150 · TL-063-26: QUARTOS EM SEPARADO, FOTOS DA TRUFA E PAGAMENTO
--
-- Instrução dela, 16/11/26:
--   · "página de hotel primeiro fala do hotel, e depois dos 2 quartos
--     separadamente, não mais que 2 fotos em cada parte". O Borgo Vescine
--     vira cabeçalho (sem preço e sem unidades, que o hub já desenha como
--     apresentação, sem caixinha e sem € 0,00), e cada quarto vira linha
--     própria com duas fotos, o texto dele e o valor net — Deluxe Plus
--     € 1.260 e Superior € 1.728, os mesmos da 0149, que saem das unidades
--     e passam para a linha;
--   · fotos da caça às trufas da pasta "Caccia a tartufo" do Drive dela
--     (fotos ilustrativas, nas palavras dela), baixadas em 1600 px para
--     fotos/tl063/. Sai a foto da Wikimedia e o crédito dela;
--   · "de segunda a sexta-feira" também no texto da experiência;
--   · pagamento: sinal de 40% e saldo 45 dias antes da viagem; abaixo de
--     € 1.000, 100% (como já estava); Pix e cartão com 3%; Wise ou
--     transferência sem taxa adicional.
--
-- O SAVE DAS 08:12 DESFEZ A 0148 E A 0149. Ela salvou o editor com a tela
-- aberta desde antes delas, e o salvarQuote regravou o texto e os valores
-- da 0146. A única mudança dela nesse save foi a capa ("Toscana 2027"),
-- que fica. Por isso este arquivo regrava também o que as duas faziam:
-- não inclusos, Estrutura do hotel, título e Incluso da experiência.
--
-- MEXE EM LINHA QUE JÁ EXISTE, a pedido dela: a proposta e0630000-…-0001
-- (sections, conditions_pt) e as duas linhas dela, miradas por
-- proposal_id + título. INSERE as duas linhas dos quartos. Para se a
-- proposta já tiver resposta, e roda uma vez só (para se o quarto já
-- existe como linha).
-- =====================================================================

do $$
declare
  prop uuid := 'e0630000-0000-0000-0000-000000000001';
  vesc uuid := 'b0000000-0000-0000-0000-000000000000';
  sq   text := 'https://images.squarespace-cdn.com/content/v1/63fa5a875489c1006b8bcdd1/';
  n int;
begin
  if exists (select 1 from ops_proposals where id = prop and responded_at is not null) then
    raise exception '0150: a TL-063-26 já foi respondida, nada muda';
  end if;
  if exists (select 1 from ops_proposal_items where proposal_id = prop and title in ('Deluxe Plus','Superior')) then
    raise exception '0150: os quartos já estão em linhas próprias';
  end if;

  -- a faixa da folha da experiência
  update ops_proposals set sections = (
      select jsonb_agg(case s->>'key'
               when 'experiencia' then s || jsonb_build_object('photo','fotos/tl063/trufa-faixa.jpg')
               else s end order by ord)
        from jsonb_array_elements(sections) with ordinality as e(s, ord)),
    excluded_pt = $x$- Aluguel do carro, combustível e pedágios
- Refeições e bebidas que não aparecem nesta proposta$x$,
    conditions_pt = $c$**FORMA DE PAGAMENTO**
Os valores estão em euros e já incluem IVA.
Sinal de 40% na confirmação e saldo até 45 dias antes da viagem. Para valores abaixo de € 1.000, o pagamento é integral na confirmação.
Transferência bancária internacional ou Wise, sem taxas adicionais.
Cartão de crédito ou Pix, com acréscimo de 3% sobre o valor final. O cartão pode ser pago pela Stripe ou pelo PayPal, e o Pix pela Stripe.
O pagamento é sempre em euros, com a conversão feita no momento em que ele acontece. Por ser uma transação internacional, taxas como o IOF ficam por conta do cliente.
Nossa equipe envia o link de pagamento com as instruções. Quando houver sinal e saldo, cada link segue em separado.

**TERMOS E CONDIÇÕES**
Ao aprovar esta proposta, o cliente declara estar de acordo com os termos e condições descritos aqui.
**Disponibilidade e valores:** todos os serviços estão sujeitos à disponibilidade, e os valores podem ser alterados sem aviso prévio até a confirmação da reserva. Esta proposta não bloqueia nem reserva nenhum serviço antes da aprovação formal e do pagamento.
**Validade:** as condições desta proposta valem por 30 dias a partir do envio, ou enquanto as tarifas estiverem disponíveis.
**Confirmação:** depois da aprovação, a contratação se formaliza com o aceite dos termos e condições dos serviços escolhidos. Só então as reservas são feitas e confirmadas.
**Hospedagem:** tarifa flexível, com café da manhã incluído.
**Clima:** as experiências acontecem com sol ou chuva, salvo em casos de força maior. Se o mau tempo impedir a experiência e não houver como remarcar, o valor do serviço é devolvido integralmente à agência.
**Pedidos de última hora:** de junho a setembro, e nas festas de fim de ano (Natal e Ano-Novo), a Tuscan Lands Travel não aceita novos pedidos depois que o cliente já chegou ao destino.
**Seguro:** a Tuscan Lands Travel tem todos os seguros de responsabilidade profissional exigidos pela lei italiana. Eles não substituem o seguro-viagem pessoal, que cada viajante deve ter.
**Objetos pessoais:** a Tuscan Lands Travel e seus parceiros não se responsabilizam por perda, roubo ou dano de objetos pessoais durante os serviços.$c$
  where id = prop;
  get diagnostics n = row_count;
  if n <> 1 then raise exception '0150: TL-063-26 não encontrada'; end if;

  -- 1 · o hotel vira cabeçalho: só o hotel, duas fotos, sem preço e sem unidades
  update ops_proposal_items set price = 680
   where proposal_id = prop and title in ('Caça às trufas no Chianti', 'Caça às trufas e vinhos do Chianti');

  update ops_proposal_items set
    price = 0, units = '[]'::jsonb, included_pt = null,
    facilities = $t$- Piso de cotto e vigas originais do borgo
- Móveis desenhados para o hotel e feitos à mão na região
- Roupão e chinelos
- Produtos de banho locais, sem plástico descartável
- Minibar reposto todos os dias$t$,
    photos = jsonb_build_array(
      sq||'ed5b9ad5-ca6b-4c60-8900-29174fd4ed5d/_GIU0426+copia_11zon.jpg?format=1500w',
      sq||'71cab61a-dcb2-4302-a968-d9b94a7f6627/DSC04375.jpg?format=1500w'),
    details = $t$Um borgo do século XIII, em Radda in Chianti, que virou hotel cinco estrelas sem perder a alma de vilarejo. Cada quarto ocupa um canto que um dia teve seu ofício: o celeiro, o depósito de azeitonas, a sala onde se prensava a uva. O restauro guardou as paredes de pedra, o piso de cotto e as vigas de madeira.
Em volta, são 42 hectares de vinhedos, oliveiras e bosque, com trilhas para caminhar sem sair da propriedade. Há piscina no jardim e uma adega antiga, onde se provam os vinhos feitos ali mesmo. Siena fica a 20 km, e Florença, a 42.$t$
  where proposal_id = prop and title = 'Borgo Vescine';
  get diagnostics n = row_count;
  if n <> 1 then raise exception '0150: linha do Borgo Vescine não encontrada (%)', n; end if;

  -- 2 · os dois quartos, cada um com duas fotos e o valor net
  insert into ops_proposal_items (proposal_id, sort, section, kind, optional, price, supplier,
    supplier_id, supplier_room_type_id, service_date, title, title_en, details, included_pt,
    photos, units, extras, attachments)
  values
  (prop, 1, 'estadia', 'stay', true, 1260, 'Borgo Vescine', vesc, 'b0000000-0000-0000-0000-000000030000',
   '6 a 8 de maio de 2027 · 2 noites', 'Deluxe Plus', 'Deluxe Plus Room',
$t$22 a 24 m², cama queen e um pequeno pátio privativo.
Fica onde antes se prensava e fermentava a uva. O pátio é um cantinho ao ar livre, só do quarto.
Tarifa flexível, com café da manhã incluído.$t$,
$t$- Café da manhã
- Tarifa flexível$t$,
   jsonb_build_array(
     sq||'8b0630a5-c9ea-4c1f-ba93-f88166d8a0d4/030_1IN7570-HDR.jpg?format=1500w',
     sq||'737e927e-6698-4b2a-b1be-874537312e5c/036_INF2623-HDR.jpg?format=1500w'),
   '[]'::jsonb, '[]'::jsonb, '[]'::jsonb),
  (prop, 2, 'estadia', 'stay', true, 1728, 'Borgo Vescine', vesc, 'b0000000-0000-0000-0000-000000040000',
   '6 a 8 de maio de 2027 · 2 noites', 'Superior', 'Superior Room',
$t$Cerca de 35 m², cama king e vista para as colinas ou para a praça do borgo.
Era o depósito de azeitonas do vilarejo. Mais espaçoso, com móveis feitos sob medida por artesãos da região.
Tarifa flexível, com café da manhã incluído.$t$,
$t$- Café da manhã
- Tarifa flexível$t$,
   jsonb_build_array(
     sq||'cea8897f-aa28-4f28-87a5-0c57b2b9123c/071-_1IN4762-HDR-Modifica.jpg?format=1500w',
     sq||'d03db0f3-fb66-4b91-adc7-d57f83908885/044_1IN7619-HDR-2-2.jpg?format=1500w'),
   '[]'::jsonb, '[]'::jsonb, '[]'::jsonb);

  -- 3 · a experiência: fotos do Drive dela, segunda a sexta no texto
  update ops_proposal_items set
    sort = 3, title = 'Caça às trufas no Chianti',
    included_pt = $t$- Caça às trufas privativa, com trufeiro e cães treinados
- Visita à adega histórica
- Almoço com trufa, acompanhado dos vinhos da propriedade
- Degustação de vinhos no Borgo Vescine, à tarde$t$,
    photos = jsonb_build_array('fotos/tl063/trufa-busca.jpg', 'fotos/tl063/trufa-caes.jpg'),
    details = $t$**Uma manhã no bosque, à procura das trufas**
Um passeio pela natureza em busca de uma das joias desta terra. Caminhando pelos bosques de uma vinícola do Chianti Classico, um trufeiro da região conta o que a trufa representa para a Toscana e mostra a diferença entre os tipos que nascem por aqui. Os grandes mestres da busca são os cães: com o faro apurado, eles encontram a trufa escondida debaixo da terra e são treinados para deixar que vocês mesmos a tirem do chão.
Depois do bosque, uma visita à adega histórica da propriedade. O almoço é servido na villa, com a trufa à mesa num cardápio toscano tradicional e os vinhos da casa.
De segunda a sexta-feira, com saída às 10h e cerca de 4 horas de duração, sem pressa. A busca acompanha o ritmo da estação.

**À tarde, vinho no Borgo Vescine**
De volta ao hotel, uma degustação dos vinhos do borgo, na adega antiga.

**Bom saber**
A vinícola fica a cerca de 11 km do Borgo Vescine, uns 20 minutos de carro. Vale ir com roupa confortável para caminhar ao ar livre. Há opções vegetarianas e veganas, sob pedido. O passeio é conduzido em italiano ou em inglês.

Fotos ilustrativas.$t$
  where proposal_id = prop and title in ('Caça às trufas no Chianti', 'Caça às trufas e vinhos do Chianti');
  get diagnostics n = row_count;
  if n <> 1 then raise exception '0150: linha da caça às trufas não encontrada (%)', n; end if;
end $$;

insert into ops_migrations (id) values ('0150-tl-063-26-quartos-fotos-e-pagamento') on conflict (id) do nothing;
