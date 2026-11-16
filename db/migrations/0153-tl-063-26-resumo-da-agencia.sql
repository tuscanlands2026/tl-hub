-- =====================================================================
-- 0153 · TL-063-26: O LINK DA AGÊNCIA VIRA RESUMO DOS SERVIÇOS
--
-- Revisão dela no link dos valores NET, 16/11/26:
--   · "não é Leo e Bruno, é Touristique" — o "Para" do link net passa a
--     ser a agência (index.html, só com net_view);
--   · "trufeira não existe em português... mestre tartufaio, deixa em
--     italiano";
--   · "é um resumo dos serviços": no link net as seções se chamam
--     "Stays" e "TL Signature Experiences" (rótulos net_sec_<chave>, que a
--     apresentação não lê), e a experiência leva uma descrição curta
--     (row_desc_pt) no lugar do texto inteiro, com a data sugerida de
--     7 de maio, segunda a sexta, a degustação no Borgo Vescine, a
--     experiência em inglês e o número da proposta;
--   · não inclusos: transporte;
--   · forma de pagamento em tópicos, escrita como proposta comercial;
--   · disponibilidade "antes da aprovação formal e do pagamento do
--     sinal", e validade "enquanto as tarifas e os serviços estiverem
--     disponíveis".
--
-- MEXE EM LINHA QUE JÁ EXISTE, a pedido dela: a proposta e0630000-…-0001
-- (labels, sections, excluded_pt, conditions_pt) e a linha da caça às
-- trufas (service_date, row_desc_pt, details, included_pt), mirada por
-- proposal_id + título. Conferido antes: o último save foi o da 0150,
-- sem edição dela depois. Para se a proposta já tiver resposta.
-- =====================================================================

do $$
declare
  prop uuid := 'e0630000-0000-0000-0000-000000000001';
  n int;
begin
  if exists (select 1 from ops_proposals where id = prop and responded_at is not null) then
    raise exception '0153: a TL-063-26 já foi respondida, nada muda';
  end if;

  update ops_proposals set
    labels = coalesce(labels, '{}'::jsonb) || jsonb_build_object(
      'net_sec_estadia',      jsonb_build_object('pt','Stays'),
      'net_note_estadia',     jsonb_build_object('pt','Borgo Vescine · 6 a 8 de maio · 2 noites em Radda in Chianti'),
      'net_sec_experiencia',  jsonb_build_object('pt','TL Signature Experiences')),
    sections = (
      select jsonb_agg(case s->>'key'
               when 'experiencia' then s || jsonb_build_object('note','Data sugerida: 7 de maio · disponível de segunda a sexta-feira')
               else s end order by ord)
        from jsonb_array_elements(sections) with ordinality as e(s, ord)),
    excluded_pt = $x$- Transporte
- Refeições e bebidas que não aparecem nesta proposta$x$,
    conditions_pt = $c$**FORMA DE PAGAMENTO**
Os valores estão em euros e já incluem IVA.
- Sinal de 40% na confirmação e saldo até 45 dias antes da viagem
- Valores abaixo de € 1.000: pagamento integral na confirmação
- Transferência bancária internacional ou Wise: sem taxas adicionais
- Cartão de crédito (Stripe ou PayPal) ou Pix (Stripe): acréscimo de 3% sobre o valor final
- Pagamento sempre em euros, com conversão pela cotação do dia do pagamento
- Por se tratar de transação internacional, eventuais taxas como o IOF ficam a cargo do cliente
- O link de pagamento é enviado pela nossa equipe, um para o sinal e outro para o saldo

**TERMOS E CONDIÇÕES**
Ao aprovar esta proposta, o cliente declara estar de acordo com os termos e condições descritos aqui.
**Disponibilidade e valores:** todos os serviços estão sujeitos à disponibilidade, e os valores podem ser alterados sem aviso prévio até a confirmação da reserva. Esta proposta não bloqueia nem reserva nenhum serviço antes da aprovação formal e do pagamento do sinal.
**Validade:** as condições desta proposta valem por 30 dias a partir do envio, ou enquanto as tarifas e os serviços estiverem disponíveis.
**Confirmação:** depois da aprovação, a contratação se formaliza com o aceite dos termos e condições dos serviços escolhidos. Só então as reservas são feitas e confirmadas.
**Hospedagem:** tarifa flexível, com café da manhã incluído.
**Clima:** as experiências acontecem com sol ou chuva, salvo em casos de força maior. Se o mau tempo impedir a experiência e não houver como remarcar, o valor do serviço é devolvido integralmente à agência.
**Pedidos de última hora:** de junho a setembro, e nas festas de fim de ano (Natal e Ano-Novo), a Tuscan Lands Travel não aceita novos pedidos depois que o cliente já chegou ao destino.
**Seguro:** a Tuscan Lands Travel tem todos os seguros de responsabilidade profissional exigidos pela lei italiana. Eles não substituem o seguro-viagem pessoal, que cada viajante deve ter.
**Objetos pessoais:** a Tuscan Lands Travel e seus parceiros não se responsabilizam por perda, roubo ou dano de objetos pessoais durante os serviços.$c$
  where id = prop;
  get diagnostics n = row_count;
  if n <> 1 then raise exception '0153: TL-063-26 não encontrada'; end if;

  update ops_proposal_items set
    service_date = '7 de maio (data sugerida)',
    row_desc_pt = $r$Experiência disponível de segunda a sexta-feira.
Caça às trufas no Chianti, com almoço, e degustação de vinhos na estrutura do Hotel Borgo Vescine.
Experiência conduzida em inglês.
Descrição completa e condições conforme a proposta TL-063-26.$r$,
    details = replace(replace(details,
      'um trufeiro da região conta', 'um mestre tartufaio da região conta'),
      'O passeio é conduzido em italiano ou em inglês.', 'A experiência é conduzida em inglês.'),
    included_pt = replace(included_pt, 'com trufeiro e cães treinados', 'com mestre tartufaio e cães treinados')
  where proposal_id = prop and title = 'Caça às trufas no Chianti';
  get diagnostics n = row_count;
  if n <> 1 then raise exception '0153: linha da caça às trufas não encontrada (%)', n; end if;
end $$;

insert into ops_migrations (id) values ('0153-tl-063-26-resumo-da-agencia') on conflict (id) do nothing;
