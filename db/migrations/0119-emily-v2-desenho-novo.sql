-- =====================================================================
-- 0119 · EMILY (TL-053-26, v2): OS DADOS DO DESENHO NOVO
--
-- Arquivo dela "Mudanças visuais e de layout", nov/26, com a prévia
-- aprovada. O desenho é do código; aqui entra o que ele lê:
--
--   · Castelfalfi: a nota "Room images are by way of example…" sai do
--     texto do hotel e vai para options_note (0118), embaixo do rótulo
--     dos quartos; os dois virtual tours saem dos anexos do hotel e vão
--     para dentro de cada quarto (units[].links); a terceira foto do
--     mosaico é o terraço;
--   · carro: "Category 1" e "Category 2", sem apelido; "Available
--     models: …" na ficha; os modelos de cada categoria com a foto
--     (units[].models) — foto em branco onde o site do fabricante não
--     pôde ser lido; a nota "Models are subject to availability at the
--     time of booking.";
--   · folha da proposta: a data da coluna DATE (row_date), o bloco "Car
--     rental", o concierge com nome, descrição e "13 days × €60", e a
--     linha "During the trip" (nota da seção, com a data em rótulo).
--
--   · a marcação padrão: em cada escolha, a opção mais cara (instrução
--     dela durante o trabalho).
--
-- As fotos novas dos quartos do Castelfalfi NÃO estão aqui: ela pediu
-- para ver a escolha antes de publicar. Vão na 0120.
--
-- Mira por proposal_id + seção + título. Só roda com a v2 sem resposta.
--
-- Seção 7: update em ops_proposals (uma linha) e ops_proposal_items (as
-- linhas da v2), com o sim dela, que é o próprio arquivo.
-- =====================================================================

do $mig$
declare v uuid := 'e0530000-0000-0000-0000-000000000002';
begin
  if not exists (select 1 from ops_proposals where id = v and responded_at is null) then
    raise notice '0119: v2 já respondida ou inexistente — nada feito';
    return;
  end if;

  update ops_proposals p set
    sections = (select jsonb_agg(
                  case when s->>'key' = 'around' then s || jsonb_build_object('note_en',
                    'Additional services or requests, such as a private driver at your disposal for a day, are handled through our on-site concierge service, from €150 per day, always subject to availability.')
                  else s end order by o)
                  from jsonb_array_elements(p.sections) with ordinality t(s, o)),
    labels = coalesce(p.labels, '{}'::jsonb) || jsonb_build_object(
      'j_note_date', jsonb_build_object('en', 'During the trip')),
    updated_at = now()
   where p.id = v;

  update ops_proposal_items i set
    details_en = replace(i.details_en, chr(10) || chr(10) || 'Room images are by way of example; shades and arrangement of the furnishings may vary.', ''),
    options_note_en = 'Room images are by way of example; shades and arrangement of the furnishings may vary.',
    photos = '["fotos/tl053/castelfalfi-borgo.jpg","fotos/tl053/castelfalfi-piscina.jpg","fotos/tl053/castelfalfi-terraco.jpg"]'::jsonb,
    attachments = '[]'::jsonb,
    row_date_en = 'June 25 to 29',
    units = (select jsonb_agg(u || coalesce(m->(u->>'key'), '{}'::jsonb) order by o)
               from jsonb_array_elements(i.units) with ordinality t(u, o),
                    (select jsonb_build_object(
                       'u1', jsonb_build_object('links', '[{"name":"Virtual tour · Junior Suite Terrace","url":"https://my.matterport.com/show/?m=mxG1WKJSv7K"}]'::jsonb),
                       'u2', jsonb_build_object('links', '[{"name":"Virtual tour · Suite Terrace","url":"https://my.matterport.com/show/?m=Wp1a1rBzXp6"}]'::jsonb)) m) mm)
   where proposal_id = v and section = 'stays' and title_en = 'Castelfalfi';

  update ops_proposal_items set row_date_en = 'June 29 to July 3'
   where proposal_id = v and section = 'stays' and title_en = 'Bulgari Hotel Roma';

  update ops_proposal_items i set
    row_group_en = 'Car rental',
    row_date_en = 'June 21 to 28',
    options_note_en = 'Models are subject to availability at the time of booking.',
    units = (select jsonb_agg(u || coalesce(m->(u->>'key'), '{}'::jsonb) order by o)
               from jsonb_array_elements(i.units) with ordinality t(u, o),
                    (select jsonb_build_object(
                       'c1', jsonb_build_object(
                         'label', 'Category 1', 'label_en', 'Category 1',
                         'ficha_en', 'Available models: Mercedes GLE, Maserati Grecale Modena or Audi Q8 · 1,400 km included',
                         'row_en', 'Category 1',
                         'row_desc_en', 'Mercedes GLE, Maserati Grecale Modena or Audi Q8, subject to availability · 1,400 km included · fuel not included',
                         'models', '[{"name":"Mercedes GLE","photo":"fotos/tl053/carro-mercedes-gle.jpg"},{"name":"Maserati Grecale Modena","photo":null},{"name":"Audi Q8","photo":null}]'::jsonb),
                       'c2', jsonb_build_object(
                         'label', 'Category 2', 'label_en', 'Category 2',
                         'ficha_en', 'Available models: Land Rover Defender 110, BMW X7 or Range Rover Sport · 1,050 km included',
                         'row_en', 'Category 2',
                         'row_desc_en', 'Land Rover Defender 110, BMW X7 or Range Rover Sport, subject to availability · 1,050 km included · fuel not included',
                         'models', '[{"name":"Land Rover Defender 110","photo":"fotos/tl053/carro-land-rover-defender.jpg"},{"name":"BMW X7","photo":null},{"name":"Range Rover Sport","photo":"fotos/tl053/carro-range-rover-sport.jpg"}]'::jsonb)) m) mm)
   where proposal_id = v and section = 'around' and title_en = 'Your car in Tuscany';

  update ops_proposal_items set
    row_date_en = 'Before the trip',
    row_en = 'Concierge · restaurant planning for your days',
    row_desc_en = 'The tables worth planning a day around are often booked months ahead. Our team prepares a shortlist for each day, chosen around your route, and once you approve it we make the reservations, always subject to availability.'
      || chr(10) || '13 days × €60'
   where proposal_id = v and section = 'around' and title_en = 'Concierge services · optional';

  -- Instrução dela, durante o trabalho: "já deixa pré-selecionado tudo que
  -- está na proposta, nas opções mais caras". Em cada escolha, a marcada é
  -- a de maior valor; o resto continua marcado como estava.
  update ops_proposal_items i set
    units = (select jsonb_agg(
               u || jsonb_build_object('selected',
                 (u->>'price')::numeric = (select max((x->>'price')::numeric) from jsonb_array_elements(i.units) x))
               order by o)
               from jsonb_array_elements(i.units) with ordinality t(u, o))
   where proposal_id = v and coalesce(choice_group, '') <> ''
     and jsonb_array_length(coalesce(units, '[]'::jsonb)) > 1;
end $mig$;

insert into ops_migrations (id) values ('0119-emily-v2-desenho-novo') on conflict (id) do nothing;
