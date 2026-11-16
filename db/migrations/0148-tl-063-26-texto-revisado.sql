-- =====================================================================
-- 0148 · TL-063-26: TEXTO REVISADO
--
-- Instrução dela, 16/11/26: "precisa dar uma refinada no texto da proposta,
-- não está elegante e refinado, sem usar palavras difíceis", com revisão
-- também da forma de pagamento e dos termos, no desenho das condições em
-- inglês da TL-055-26. Mais três pedidos:
--   · condições sujeitas a disponibilidade e a alteração de preços sem
--     aviso prévio;
--   · hotel com tarifa flexível e café da manhã;
--   · caça às trufas no estilo do texto italiano que ela mandou (o do
--     Castelfalfi), com as informações da experiência desta proposta:
--     visita à adega, almoço, horário, duração.
--
-- MEXE EM LINHA QUE JÁ EXISTE, com o pedido dela nesta conversa:
--   · ops_proposals e0630000-…-0001: conditions_pt e excluded_pt;
--   · ops_proposal_items da mesma proposta, miradas por proposal_id +
--     título (o id muda a cada save): details, facilities e included_pt
--     do Borgo Vescine; título, details e included_pt da experiência.
-- Conferido antes: ela salvou a proposta em 16/11 às 07:56 sem mudar
-- texto nenhum (o que estava gravado era o da 0146, palavra por palavra).
-- Para se a proposta já tiver resposta.
-- =====================================================================

do $$
declare
  prop uuid := 'e0630000-0000-0000-0000-000000000001';
  n int;
begin
  if exists (select 1 from ops_proposals where id = prop and responded_at is not null) then
    raise exception '0148: a TL-063-26 já foi respondida, nada muda';
  end if;

  update ops_proposals set
    excluded_pt = $x$- Aluguel do carro, combustível e pedágios
- Refeições e bebidas que não aparecem nesta proposta$x$,
    conditions_pt = $c$**FORMA DE PAGAMENTO**
Os valores estão em euros e já incluem IVA.
Sinal de 40% na confirmação e saldo até 35 dias antes da viagem. Para valores abaixo de € 1.000, o pagamento é integral na confirmação.
Os valores desta proposta são para pagamento por transferência bancária internacional ou Wise. No cartão de crédito, o valor final tem acréscimo de 3%, e o pagamento pode ser feito pela Stripe, que também aceita Pix, ou pelo PayPal.
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
  if n <> 1 then raise exception '0148: TL-063-26 não encontrada'; end if;

  update ops_proposal_items set
    details = $t$Um borgo do século XIII, em Radda in Chianti, que virou hotel cinco estrelas sem perder a alma de vilarejo. Cada quarto ocupa um canto que um dia teve seu ofício: o celeiro, o depósito de azeitonas, a sala onde se prensava a uva. O restauro guardou as paredes de pedra, o piso de cotto e as vigas de madeira.
Em volta, são 42 hectares de vinhedos, oliveiras e bosque, com trilhas para caminhar sem sair da propriedade. Há piscina no jardim e uma adega antiga, onde se provam os vinhos feitos ali mesmo. Siena fica a 20 km, e Florença, a 42.

**Deluxe Plus** · 22 a 24 m², cama queen e um pequeno pátio privativo
Fica onde antes se prensava e fermentava a uva. O pátio é um cantinho ao ar livre, só do quarto.

**Superior** · cerca de 35 m², cama king, vista para as colinas ou para a praça do borgo
Era o depósito de azeitonas do vilarejo. Mais espaçoso, com móveis feitos sob medida por artesãos da região.

**Tarifa flexível, com café da manhã incluído.**$t$,
    facilities = $t$- Piso de cotto e vigas originais do borgo
- Móveis desenhados para o hotel e feitos à mão na região
- Roupão e chinelos
- Produtos de banho locais, sem plástico descartável
- Minibar reposto todos os dias$t$,
    included_pt = $t$- Café da manhã
- Tarifa flexível$t$
  where proposal_id = prop and title = 'Borgo Vescine';
  get diagnostics n = row_count;
  if n <> 1 then raise exception '0148: linha do Borgo Vescine não encontrada (%)', n; end if;

  update ops_proposal_items set
    title = 'Caça às trufas no Chianti',
    details = $t$**Uma manhã no bosque, à procura das trufas**
Um passeio pela natureza em busca de uma das joias desta terra. Caminhando pelos bosques de uma vinícola do Chianti Classico, um trufeiro da região conta o que a trufa representa para a Toscana e mostra a diferença entre os tipos que nascem por aqui. Os grandes mestres da busca são os cães: com o faro apurado, eles encontram a trufa escondida debaixo da terra e são treinados para deixar que vocês mesmos a tirem do chão.
Depois do bosque, uma visita à adega histórica da propriedade. O almoço é servido na villa, com a trufa à mesa num cardápio toscano tradicional e os vinhos da casa.
Saída às 10h, com cerca de 4 horas de duração, sem pressa. A busca acompanha o ritmo da estação.

**À tarde, vinho no Borgo Vescine**
De volta ao hotel, uma degustação dos vinhos do borgo, na adega antiga.

**Bom saber**
A vinícola fica a cerca de 11 km do Borgo Vescine, uns 20 minutos de carro. Vale ir com roupa confortável para caminhar ao ar livre. Há opções vegetarianas e veganas, sob pedido. O passeio é conduzido em italiano ou em inglês.

Foto da caça às trufas: Sahgdg / Wikimedia Commons (CC BY-SA 4.0).$t$,
    included_pt = $t$- Caça às trufas privativa, com trufeiro e cães treinados
- Visita à adega histórica
- Almoço com trufa, acompanhado dos vinhos da propriedade
- Degustação de vinhos no Borgo Vescine, à tarde$t$
  where proposal_id = prop and title in ('Caça às trufas e vinhos do Chianti', 'Caça às trufas no Chianti');
  get diagnostics n = row_count;
  if n <> 1 then raise exception '0148: linha da caça às trufas não encontrada (%)', n; end if;
end $$;

insert into ops_migrations (id) values ('0148-tl-063-26-texto-revisado') on conflict (id) do nothing;
