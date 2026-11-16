-- =====================================================================
-- 0154 · TL-063-26: QUARTOS SEM A HISTÓRIA, PAGAMENTO ORGANIZADO
--
-- Instrução dela, 16/11/26:
--   · tirar dos quartos "Fica onde antes se prensava e fermentava a uva. O
--     pátio é um cantinho ao ar livre, só do quarto." e "Era o depósito de
--     azeitonas do vilarejo. Mais espaçoso, com móveis feitos sob medida
--     por artesãos da região.";
--   · a forma de pagamento estava em tópicos que misturavam assuntos
--     diferentes ("bullet point é sempre para a mesma coisa"). Agora são
--     blocos com rótulo, como os termos: prazos, meios de pagamento (a
--     única lista, porque ali tudo é do mesmo tipo), câmbio e links.
--     Escrito como proposta comercial.
--
-- MEXE EM LINHA QUE JÁ EXISTE, a pedido dela: conditions_pt da proposta
-- e0630000-…-0001 e details das linhas Deluxe Plus e Superior (miradas
-- por proposal_id + título). Conferido antes: o save dela das 14:51
-- manteve o que a 0153 gravou. Para se a proposta já tiver resposta.
-- =====================================================================

do $$
declare
  prop uuid := 'e0630000-0000-0000-0000-000000000001';
  n int;
begin
  if exists (select 1 from ops_proposals where id = prop and responded_at is not null) then
    raise exception '0154: a TL-063-26 já foi respondida, nada muda';
  end if;

  update ops_proposal_items set details = $t$22 a 24 m², cama queen e um pequeno pátio privativo.
Tarifa flexível, com café da manhã incluído.$t$
   where proposal_id = prop and title = 'Deluxe Plus';
  get diagnostics n = row_count;
  if n <> 1 then raise exception '0154: Deluxe Plus não encontrada (%)', n; end if;

  update ops_proposal_items set details = $t$Cerca de 35 m², cama king e vista para as colinas ou para a praça do borgo.
Tarifa flexível, com café da manhã incluído.$t$
   where proposal_id = prop and title = 'Superior';
  get diagnostics n = row_count;
  if n <> 1 then raise exception '0154: Superior não encontrada (%)', n; end if;

  update ops_proposals set conditions_pt = $c$**FORMA DE PAGAMENTO**
Os valores estão em euros e já incluem IVA.
**Prazos:** sinal de 40% na confirmação da reserva e saldo até 45 dias antes da viagem. Para valores abaixo de € 1.000, o pagamento é feito integralmente na confirmação.
**Meios de pagamento:**
- Transferência bancária internacional ou Wise, sem taxas adicionais
- Cartão de crédito, pela Stripe ou pelo PayPal, com acréscimo de 3% sobre o valor total
- Pix, pela Stripe, com acréscimo de 3% sobre o valor total
**Câmbio:** o pagamento é sempre efetuado em euros, pela cotação do dia em que é realizado. Por se tratar de transação internacional, eventuais taxas, como o IOF, ficam a cargo do cliente.
**Links de pagamento:** nossa equipe envia o link com as instruções, um para o sinal e outro para o saldo.

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
  if n <> 1 then raise exception '0154: TL-063-26 não encontrada'; end if;
end $$;

insert into ops_migrations (id) values ('0154-tl-063-26-quartos-e-pagamento') on conflict (id) do nothing;
