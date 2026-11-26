-- 0169 · TL-054-26 (Bocelli Experience, Facility Turismo) · 26/11/26
--
-- Pedido dela, sobre a peça do cliente:
--   1. o cartão de crédito sai sem o "com acréscimo de 3% de taxas da
--      plataforma" (a linha das taxas de conversão, nas condições gerais,
--      continua);
--   2. o texto do concerto e o do hotel contam a viagem, em vez de listar
--      serviços: "no dia do concerto, um transfer irá buscá-los no hotel...
--      direto ao Teatro del Silenzio, com opção de jantar antes". Nada
--      novo foi acrescentado: tudo o que está aqui já estava na proposta,
--      na oferta do teatro ou no que ela passou;
--   3. a Deluxe tinha duas fotos do mesmo ângulo. A segunda passa a ser a
--      da janela com os ciprestes, da galeria oficial do quarto.
--
-- UPDATE em linha que já existe: proposta em montagem, não respondida, e
-- autorizada por ela na conversa. Guardas presas às frases que mudam.
-- Antes de rodar: fechar o editor da proposta, senão o save desfaz.

do $$
declare
  prop uuid := 'e0540000-0000-0000-0000-000000000001';
  n int;
begin
  if exists (select 1 from ops_proposals where id = prop and responded_at is not null) then
    raise exception '0169: a TL-054-26 já foi respondida, nada muda';
  end if;

  update ops_proposals set conditions_pt = replace(conditions_pt,
    '- Cartão de crédito, por link de pagamento, com acréscimo de 3% de taxas da plataforma',
    '- Cartão de crédito, por link de pagamento')
  where id = prop
    and position('- Cartão de crédito, por link de pagamento, com acréscimo de 3% de taxas da plataforma' in conditions_pt) > 0;
  get diagnostics n = row_count;
  if n <> 1 then raise exception '0169: a linha do cartão não é mais a da 0168'; end if;

  update ops_proposal_items set details =
$t$No sábado, 24 de julho, o transfer privativo busca vocês no hotel e segue para Lajatico. Quem escolher o jantar para antes do concerto senta à mesa num restaurante da região, no caminho, e de lá segue para o teatro.

No Teatro del Silenzio, a chegada é pelo acesso Executive, com estacionamento próprio a cerca de 100 metros do controle de entrada. A espera é no lounge Executive, com open bar, até o concerto começar às 20h30. Os lugares ficam no setor Executive, de frente para o palco, e cada convidado recebe um presente do teatro e o programa da noite.

Terminado o concerto, o mesmo transfer leva vocês de volta ao hotel.

Os bilhetes são entregues no hotel, e há assistência por telefone.$t$
  where proposal_id = prop and 'Bocelli no Teatro del Silenzio' in (title, title_en)
    and position('Os lugares são no setor Executive, de frente para o palco' in details) = 1;
  get diagnostics n = row_count;
  if n <> 1 then raise exception '0169: o texto do concerto não é mais o da 0168'; end if;

  update ops_proposal_items set
    details =
$t$A chegada é na sexta, 23 de julho. O Castelfalfi fica no alto de uma colina em Montaione, entre Florença e Pisa, a cerca de 40 minutos do teatro: um cinco estrelas construído em volta de um borgo medieval, com o castelo, a igreja de San Floriano e o jardim dos Medici. Em volta são cerca de 1.100 hectares de campo, de onde vêm o vinho e o azeite orgânicos servidos à mesa.

O sábado é a noite do concerto. O domingo fica livre, entre o spa, a piscina e o campo de golfe, com jantar no próprio borgo, se quiserem. E se o mau tempo levar o concerto para domingo, vocês continuam hospedados.

A saída é na segunda, 26 de julho.

City tax e extras não estão incluídos.$t$,
    units = (select jsonb_agg(case u->>'key'
               when 'deluxe' then jsonb_set(u, '{photos}',
                 '["fotos/tl054/deluxe-quarto.jpg","fotos/tl054/deluxe-janela.jpg"]'::jsonb)
               else u end order by ord)
             from jsonb_array_elements(units) with ordinality as e(u, ord))
  where proposal_id = prop and section = 'castelfalfi' and 'Castelfalfi' in (title, title_en)
    and position('No alto de uma colina em Montaione' in details) = 1;
  get diagnostics n = row_count;
  if n <> 1 then raise exception '0169: o texto do hotel não é mais o da 0168'; end if;
end $$;

insert into ops_migrations (id) values ('0169-tl-054-26-noite-do-concerto-e-cartao') on conflict (id) do nothing;
