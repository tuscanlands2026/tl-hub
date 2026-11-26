-- =====================================================================
-- 0166 · TL-054-26: CAPA NOTURNA, TEXTO REFINADO E PAGAMENTO NOVO
--
-- Instruções dela, 26/11/26, vendo a peça no ar:
--   · a capa estava sem definição: entra o teatro ao anoitecer, com a lua,
--     o palco aceso e a plateia (1920 px, site da City Sound, organizadora);
--     dentro, o Bocelli com a orquestra e o palco à noite;
--   · "Sua hospedagem", e não "Onde vocês vão ficar"; foto bonita do hotel
--     na faixa (a piscina de borda infinita); foto de hotel no hotel e foto
--     de quarto no quarto (sai o armazém por fora da Tabaccaia);
--   · quarto sem repetir: a ficha fica só com a metragem, porque a linha de
--     baixo já diz onde o quarto fica;
--   · "em caso de mau tempo, o concerto é transferido automaticamente para
--     o dia 25", em todos os lugares;
--   · transfer privativo, dito assim;
--   · o jantar antes do concerto NÃO está incluído: é opção à parte. Sai o
--     "bufê" do lounge, para não parecer jantar;
--   · o hotel inclui café da manhã; city tax e extras não estão incluídos.
--     Sai a "tarifa flexível", que ela não confirmou;
--   · pagamento: 40% na reserva e o restante em 20/2 e 20/4/2027; sai a
--     parcela de 20/12 e sai o Pix com 1%; transferência sem taxa, cartão
--     de crédito com 3% de taxas da plataforma.
--
-- Seção 7: update em UMA proposta, a TL-054-26 (0165), sem envio e sem
-- resposta, por instrução dela nesta conversa. Linhas miradas por
-- proposta + título; o texto das condições só é trocado se ainda for o
-- da 0165 (guarda presa à frase do pagamento antigo).
-- =====================================================================

do $$
declare
  prop uuid := 'e0540000-0000-0000-0000-000000000001';
  n int;
begin
  if exists (select 1 from ops_proposals where id = prop and responded_at is not null) then
    raise exception '0166: a TL-054-26 já foi respondida, nada muda';
  end if;
  if not exists (select 1 from ops_proposals where id = prop
                  and position('**Prazos:** 35% na reserva' in conditions_pt) > 0) then
    raise exception '0166: as condições da TL-054-26 não são mais as da 0165';
  end if;

  update ops_proposals set
    cover_img     = 'fotos/tl054/capa-anoitecer.jpg',
    assurance_img = 'fotos/tl054/concerto-palco-noite.jpg',
    sections = (select jsonb_agg(case s->>'key'
                  when 'castelfalfi' then s || jsonb_build_object(
                    'title','Sua hospedagem', 'title_en','Your stay',
                    'photo','fotos/tl054/castelfalfi-piscina-infinita.jpg')
                  else s end order by ord)
                from jsonb_array_elements(sections) with ordinality as e(s, ord)),
    labels = labels || jsonb_build_object(
      'j_menu_stay', jsonb_build_object('pt','Sua hospedagem'),
      'j_stay',      jsonb_build_object('pt','Sua hospedagem')),
    curations = jsonb_build_array(jsonb_build_object(
      'cor','verde', 'opcao','Em resumo',
      'title_pt','Bocelli Experience 2027',
      'dest_pt', E'Teatro del Silenzio · Lajatico\nCastelfalfi · Montaione, a cerca de 40 minutos do teatro',
      'dias_pt',
$d$A noite do concerto pode ser vivida de duas formas: só com os bilhetes, ou com três noites no Castelfalfi.
COM O CASTELFALFI
- Sexta, 23 de julho: chegada ao Castelfalfi
- Sábado, 24 de julho: Bocelli no Teatro del Silenzio, às 20h30
- Domingo, 25 de julho: dia livre no Castelfalfi. Em caso de mau tempo no sábado, o concerto é transferido automaticamente para esta noite
- Segunda, 26 de julho: saída$d$)),
    excluded_pt =
$x$- Passagens aéreas e transfers de chegada e saída
- Jantar antes do concerto, que é opcional e cobrado à parte
- Hospedagem, na opção só com os bilhetes
- City tax e extras no hotel
- Refeições e bebidas que não aparecem nesta proposta
- Gorjetas$x$,
    conditions_pt =
$c$**PAGAMENTO**
**Prazos:** 40% na reserva e o restante em 2 parcelas iguais, em 20 de fevereiro e 20 de abril de 2027.
**Meios de pagamento:** transferência bancária internacional, sem taxas adicionais, ou cartão de crédito, com acréscimo de 3% de taxas da plataforma.
**Câmbio:** o pagamento é sempre feito em euros, pela cotação do dia de cada pagamento. Por se tratar de transação internacional, eventuais taxas, como o IOF, ficam a cargo do cliente.
**Links de pagamento:** nossa equipe envia o link com as instruções. No pagamento parcelado, os links de cada parcela são enviados pela nossa equipe.

**CONDIÇÕES GERAIS**
**Contratação:** ao aceitar esta proposta, a contratação se formaliza com o aceite dos termos e condições do pacote terrestre. Só depois dessa etapa e do pagamento do sinal os bilhetes e as reservas são feitos e confirmados.
**Sem reserva prévia:** esta proposta não faz reserva nem pré-bloqueio de bilhetes ou de quartos, e não garante disponibilidade.
**Parcelas:** no pagamento parcelado, depois de 3 dias úteis de atraso o serviço é considerado cancelado, assim como todas as confirmações feitas. Eventuais devoluções seguem os termos e condições gerais: https://tuscanlandstravel.com/terms-conditions-tours/
**Validade:** as condições desta proposta valem enquanto houver disponibilidade.
**Pessoas e quartos:** bilhetes e jantar são para o mesmo número de pessoas. Cada quarto recebe duas pessoas; com quatro, são dois quartos, do mesmo tipo ou de tipos diferentes.
**Hospedagem:** a diária inclui café da manhã. City tax e extras não estão incluídos e são pagos diretamente no hotel.
**Fotos:** as fotos desta proposta são ilustrativas.

**INFORMAÇÕES IMPORTANTES SOBRE O CONCERTO**
As condições abaixo são definidas pela organização do Teatro del Silenzio e valem para todos os bilhetes do evento.
**Bilhetes:** depois de confirmados, não são reembolsáveis. A organização define os lugares dentro de cada setor, sem possibilidade de escolha.
**Mau tempo:** em caso de mau tempo, o concerto de 24 de julho é transferido automaticamente para 25 de julho. A mudança de data não dá direito a reembolso, mesmo que os viajantes não possam comparecer na nova data.
**Interrupção:** se o concerto for interrompido depois de pelo menos 40 minutos do início, não há reembolso.
**Greve e força maior:** em caso de greve anunciada pela organização do evento ou de força maior, como desastre natural ou doença do artista, é devolvido apenas o valor de face dos bilhetes. Não há responsabilidade por despesas, danos ou prejuízos decorrentes de cancelamento, adiamento ou alteração do evento.
**Crianças:** a partir de 6 anos, pagam bilhete inteiro. Abaixo de 6 anos não pagam, se ficarem no colo dos pais.
**Acessibilidade:** pessoas com mobilidade reduzida ou com deficiência assistem ao concerto na área reservada por lei, mediante pedido no momento da reserva e sujeito à disponibilidade de lugares. Com bilhete de outro setor, o acesso ao evento não é permitido, por segurança.
**O local:** o teatro fica ao ar livre, em área rural, com acesso por terreno irregular. Os banheiros são químicos e ficam na parte de trás da plateia. O evento não é recomendado para pessoas com dificuldade de locomoção ou que devam evitar esforço físico, e a participação é de responsabilidade de cada viajante.
**Mudanças depois da compra:** condições de saúde que surjam depois da compra não dão direito a troca, reembolso ou mudança de lugar.$c$
  where id = prop;

  -- o concerto
  update ops_proposal_items set
    photos = '["fotos/tl054/concerto-bocelli-orquestra.jpg","fotos/tl054/concerto-fogo.jpg"]'::jsonb,
    details =
$t$Os lugares são no setor Executive, de frente para o palco, com estacionamento e entrada próprios, a cerca de 100 metros do controle de acesso. Antes do show, o lounge Executive recebe os convidados com open bar até o início do concerto.
O transfer privativo busca vocês no hotel, leva ao teatro e traz de volta depois do concerto.
O jantar antes do concerto não está incluído. É uma opção à parte, num restaurante da região, a caminho do teatro.$t$,
    included_pt =
$t$- Bilhete Executive VIP, 1ª categoria
- Estacionamento e entrada Executive
- Lounge Executive, com open bar até o início do concerto
- Presente do Teatro del Silenzio e programa da noite
- Transfer privativo do hotel ao teatro e de volta
- Entrega dos bilhetes no hotel e assistência por telefone$t$,
    good_pt =
$t$Esta proposta não faz reserva nem pré-bloqueio de bilhetes. Os lugares são confirmados depois da contratação, e a organização define os assentos dentro de cada setor.
Em caso de mau tempo, o concerto é transferido automaticamente para domingo, 25 de julho.
O teatro fica em área rural, com acesso por terreno irregular.$t$
  where proposal_id = prop and 'Bocelli no Teatro del Silenzio' in (title, title_en);
  get diagnostics n = row_count;
  if n <> 1 then raise exception '0166: linha do concerto não encontrada'; end if;

  -- o hotel e os quartos
  update ops_proposal_items set
    photos = '["fotos/tl054/castelfalfi-gazebos.jpg","fotos/tl054/castelfalfi-borgo.jpg","fotos/tl054/castelfalfi-piscina-fonte.jpg"]'::jsonb,
    details =
$t$No alto de uma colina em Montaione, entre Florença e Pisa, o Castelfalfi é um cinco estrelas construído em volta de um borgo medieval, com o castelo, a igreja de San Floriano e o jardim dos Medici. Em volta, são cerca de 1.100 hectares de campo, de onde vêm o vinho e o azeite orgânicos servidos à mesa.
O hotel tem spa, piscina ao ar livre e campo de golfe, e o jantar pode ser no próprio borgo. Fica a cerca de 40 minutos do Teatro del Silenzio.
Com o concerto na noite do meio, se o mau tempo transferir o show para domingo, vocês continuam hospedados.
City tax e extras não estão incluídos.$t$,
    included_pt = '- Café da manhã',
    units = jsonb_build_array(
      jsonb_build_object('key','tabaccaia', 'optional',true, 'price',0,
        'label','Tabaccaia Classic', 'ficha','22 m²',
        'desc','Os quartos Tabaccaia ocupam o antigo armazém de tabaco do borgo, do começo do século XX, restaurado em estilo toscano tradicional.',
        'photos', jsonb_build_array('fotos/tl054/tabaccaia-quarto.jpg','fotos/tl054/tabaccaia-quarto-2.jpg'),
        'links', jsonb_build_array(jsonb_build_object('name','Tour virtual 360°','url','https://my.matterport.com/show/?m=sYQsziGWgpS'))),
      jsonb_build_object('key','deluxe', 'optional',true, 'price',0,
        'label','Deluxe', 'ficha','30 m²',
        'desc','No coração do edifício principal, com as cores quentes da paisagem toscana e design contemporâneo. Todos os serviços do hotel ficam a poucos passos.',
        'photos', jsonb_build_array('fotos/tl054/deluxe-quarto.jpg','fotos/tl054/deluxe-quarto-2.jpg'),
        'links', jsonb_build_array(jsonb_build_object('name','Tour virtual 360°','url','https://my.matterport.com/show/?m=npnBSsjV2Y1'))),
      jsonb_build_object('key','dolcevita', 'optional',true, 'price',0,
        'label','Deluxe Dolcevita com jardim', 'ficha','30 m²',
        'desc','A Deluxe do edifício principal que se abre para a paisagem, com jardim privativo e vista para as colinas.',
        'photos', jsonb_build_array('fotos/tl054/dolcevita-jardim.jpg','fotos/tl054/dolcevita-quarto.jpg'),
        'links', jsonb_build_array(jsonb_build_object('name','Tour virtual 360°','url','https://my.matterport.com/show/?m=UQ4WQoYFbZf'))))
  where proposal_id = prop and section = 'castelfalfi' and 'Castelfalfi' in (title, title_en);
  get diagnostics n = row_count;
  if n <> 1 then raise exception '0166: linha do hotel não encontrada'; end if;

  -- o link dos valores
  update ops_proposal_items set row_desc_pt =
    E'Bilhete Executive VIP, 1ª categoria, com lounge Executive (open bar), presente e programa\nTransfer privativo do hotel ao teatro e de volta · entrega dos bilhetes no hotel · assistência por telefone\nJantar não incluído: opção à parte, na linha abaixo'
  where proposal_id = prop and 'Bilhetes Executive · Bocelli no Teatro del Silenzio' in (title, title_en);
  get diagnostics n = row_count;
  if n <> 1 then raise exception '0166: linha dos bilhetes não encontrada'; end if;

  update ops_proposal_items set row_desc_pt =
    replace(row_desc_pt, 'café da manhã e tarifa flexível', 'café da manhã incluído · city tax e extras não incluídos')
  where proposal_id = prop and section = 'v_hotel';
  get diagnostics n = row_count;
  if n <> 3 then raise exception '0166: esperava 3 quartos no link dos valores, achou %', n; end if;
end $$;

insert into ops_migrations (id) values ('0166-tl-054-26-capa-texto-e-pagamento') on conflict (id) do nothing;
