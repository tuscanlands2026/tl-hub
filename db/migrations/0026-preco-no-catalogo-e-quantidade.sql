-- =====================================================================
-- 0026 · PREÇO DE REFERÊNCIA NO CATÁLOGO, E QUANTIDADE NA LINHA
--
-- Pedido dela em agosto/26: transfer e tour simples se repetem entre
-- propostas, e hoje ela redigita nome, descrição E valor a cada vez.
-- Quer puxar do catálogo com o preço já vindo, pôr a quantidade de
-- veículos, e poder mudar tudo depois.
--
-- DUAS DECISÕES QUE SUSTENTAM ISSO:
--
-- 1. O PREÇO DO CATÁLOGO É REFERÊNCIA, E DIZ DE QUANDO É. Até aqui a
--    regra era "valor nunca vem do catálogo, é desta venda", e o motivo
--    continua de pé: preço muda por temporada, por fornecedor, por
--    tamanho de grupo. O que muda é que redigitar de cabeça erra mais
--    do que conferir um número que já está na tela. Por isso vem junto
--    price_updated_at: preço velho puxado em silêncio é o risco real, e
--    a tela mostra a data ao lado do valor.
--
--    price_unit diz do que aquele valor é: por veículo, por pessoa, por
--    grupo, por dia. Sem isso, 450 não quer dizer nada.
--
-- 2. A LINHA GANHA QUANTIDADE E VALOR UNITÁRIO, MAS price CONTINUA
--    SENDO O TOTAL. Tudo que soma no hub — o total da proposta, o
--    e-mail, a order gerada, o relatório de comissão — lê price. Se a
--    quantidade virasse um segundo fator a multiplicar em cada um
--    desses lugares, bastaria eu esquecer de um para a proposta e a
--    order divergirem. qty e unit_price são COMO ela chegou no total,
--    e a tela recalcula; quem manda é price.
--
-- Só toca em objetos ops_. Nada fora desse prefixo.
-- =====================================================================

alter table ops_catalog add column if not exists price numeric(12,2);
alter table ops_catalog add column if not exists price_unit text;
alter table ops_catalog add column if not exists price_note text;
alter table ops_catalog add column if not exists price_updated_at timestamptz;
comment on column ops_catalog.price is
  'Valor de referência, não verdade: desce para a proposta como ponto de partida.';
comment on column ops_catalog.price_unit is
  'Do que o valor é: vehicle, person, group, day. Sem isso o número não diz nada.';
comment on column ops_catalog.price_note is
  'A condição do valor — "até 3 pax", "temporada baixa", "8h de serviço".';
comment on column ops_catalog.price_updated_at is
  'Quando o valor foi conferido pela última vez. Sai ao lado dele na tela.';

alter table ops_proposal_items add column if not exists qty numeric(10,2) not null default 1;
alter table ops_proposal_items add column if not exists unit_price numeric(12,2);
comment on column ops_proposal_items.qty is
  'Quantos — veículos, pessoas, diárias. price continua sendo o TOTAL da linha.';
comment on column ops_proposal_items.unit_price is
  'Valor de um. qty x unit_price é como o total foi montado; quem soma é price.';

-- price_updated_at nasce com o que já existe, para linha antiga não
-- aparecer como "conferida agora".
update ops_catalog set price_updated_at = updated_at
 where price is not null and price_updated_at is null;


create or replace function tl_get_quote(p_token text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  pp ops_proposals%rowtype; o ops_opportunities%rowtype;
  idioma text; ing boolean; secs jsonb; dias jsonb; rots jsonb; result jsonb;
begin
  select * into pp from ops_proposals where token = p_token;
  if not found then return null; end if;
  -- Mesmo desenho do link da order: passou da data, o link não abre.
  if pp.token_expires_at is not null and pp.token_expires_at < now() then
    return jsonb_build_object('expired', true);
  end if;
  select * into o from ops_opportunities where id = pp.opportunity_id;
  idioma := coalesce(pp.lang, o.lang, 'pt');
  ing := idioma = 'en';

  select coalesce(jsonb_agg(jsonb_build_object(
           'key', s->>'key',
           'title', case when ing then coalesce(nullif(s->>'title_en',''), s->>'title')
                         else coalesce(nullif(s->>'title',''), s->>'title_en') end,
           'note',  case when ing then coalesce(nullif(s->>'note_en',''), s->>'note')
                         else coalesce(nullif(s->>'note',''), s->>'note_en') end,
           'photo', s->>'photo') order by ord), '[]'::jsonb)
    into secs from jsonb_array_elements(coalesce(pp.sections,'[]'::jsonb)) with ordinality as t(s, ord);

  select coalesce(jsonb_agg(jsonb_build_object(
           'date', case when ing then coalesce(nullif(d->>'date_en',''), d->>'date')
                        else coalesce(nullif(d->>'date',''), d->>'date_en') end,
           'lines', case when ing then coalesce(d->'lines_en', d->'lines')
                         else coalesce(d->'lines', d->'lines_en') end) order by ord), '[]'::jsonb)
    into dias from jsonb_array_elements(coalesce(pp.itinerary,'[]'::jsonb)) with ordinality as t(d, ord);

  -- Cada rótulo vira texto simples no idioma do documento. Vazio fica
  -- fora do objeto, e a tela usa o padrão dela.
  select coalesce(jsonb_object_agg(k, v), '{}'::jsonb) into rots from (
    select r.key as k,
           case when ing then coalesce(nullif(r.value->>'en',''), nullif(r.value->>'pt',''))
                else coalesce(nullif(r.value->>'pt',''), nullif(r.value->>'en','')) end as v
      from jsonb_each(coalesce(pp.labels,'{}'::jsonb)) r
  ) x where v is not null;

  select jsonb_build_object(
    'proposal', jsonb_build_object(
      'id', pp.id, 'version', pp.version, 'title', pp.title, 'summary', pp.summary,
      'lang', idioma, 'layout', coalesce(pp.layout,'tabela'), 'labels', rots,
      'pax_summary', pp.pax_summary, 'travel_window', pp.travel_window,
      'intro', pp.intro, 'payment_note', pp.payment_note, 'terms_url', pp.terms_url,
      'cover_img', pp.cover_img, 'about_img', pp.about_img,
      -- White label: a proposta sai assinada pela agência.
      'white_label', coalesce(pp.white_label, false),
      'agency_logo', pp.agency_logo,
      'agency_logo_bg', coalesce(pp.agency_logo_bg, false),
      'assurance_img', pp.assurance_img,
      -- Nulo cai no de antes; vazio é vazio de propósito.
      'cover_title', coalesce(pp.cover_title, o.final_client, o.agency, ''),
      'confirm_mode', coalesce(pp.confirm_mode, 'full'),
      'assurance', replace(
        case when ing then coalesce(nullif(pp.assurance_en,''), pp.assurance_pt)
             else coalesce(nullif(pp.assurance_pt,''), pp.assurance_en) end,
        '{agencia}', coalesce(o.agency, '')),
      'cover_tag', case when ing then coalesce(nullif(pp.cover_tag_en,''), pp.cover_tag_pt)
                        else coalesce(nullif(pp.cover_tag_pt,''), pp.cover_tag_en) end,
      'about', case when ing then coalesce(nullif(pp.about_en,''), pp.about_pt)
                    else coalesce(nullif(pp.about_pt,''), pp.about_en) end,
      'credentials', case when ing then coalesce(nullif(pp.credentials_en,''), pp.credentials_pt)
                          else coalesce(nullif(pp.credentials_pt,''), pp.credentials_en) end,
      'backcover', case when ing then coalesce(nullif(pp.backcover_en,''), pp.backcover_pt)
                        else coalesce(nullif(pp.backcover_pt,''), pp.backcover_en) end,
      'backcover_img', pp.backcover_img,
      'itinerary', dias,
      'conditions', case when ing then coalesce(nullif(pp.conditions_en,''), pp.conditions_pt, pp.conditions)
                         else coalesce(nullif(pp.conditions_pt,''), pp.conditions) end,
      'excluded', case when ing then coalesce(nullif(pp.excluded_en,''), pp.excluded_pt)
                       else coalesce(nullif(pp.excluded_pt,''), pp.excluded_en) end,
      'sections', secs, 'show_prices', pp.show_prices,
      'payment_options', coalesce((select jsonb_agg(jsonb_build_object(
          'key', po->>'key',
          'label', case when ing then coalesce(nullif(po->>'label_en',''), po->>'label')
                        else coalesce(nullif(po->>'label',''), po->>'label_en') end) order by ord)
        from jsonb_array_elements(coalesce(pp.payment_options,'[]'::jsonb)) with ordinality as q(po, ord)),
        '[]'::jsonb),
      'crm_code', o.crm_code, 'agency', o.agency, 'final_client', o.final_client,
      'agency_contact', o.agency_contact,
      'outcome', pp.outcome, 'responded_at', pp.responded_at),
    'items', coalesce((select jsonb_agg(jsonb_build_object(
        'id', i.id, 'service_date', i.service_date,
        'title', case when ing then coalesce(nullif(i.title_en,''), i.title)
                      else coalesce(nullif(i.title,''), i.title_en) end,
        'details', case when ing then coalesce(nullif(i.details_en,''), i.details)
                        else coalesce(nullif(i.details,''), i.details_en) end,
        'room_type', case when ing then coalesce(nullif(i.room_type_en,''), i.room_type)
                          else coalesce(nullif(i.room_type,''), i.room_type_en) end,
        'facilities', case when ing then coalesce(nullif(i.facilities_en,''), i.facilities)
                           else coalesce(nullif(i.facilities,''), i.facilities_en) end,
        'included', case when ing then coalesce(nullif(i.included_en,''), i.included_pt)
                         else coalesce(nullif(i.included_pt,''), i.included_en) end,
        'kind', coalesce(i.kind,'stay'),
        'units', coalesce((select jsonb_agg(jsonb_build_object(
            'key', u->>'key',
            'label', case when ing then coalesce(nullif(u->>'label_en',''), u->>'label')
                          else coalesce(nullif(u->>'label',''), u->>'label_en') end,
            'price', (u->>'price')::numeric,
            'optional', coalesce((u->>'optional')::boolean, false)) order by ord)
          from jsonb_array_elements(coalesce(i.units,'[]'::jsonb)) with ordinality as w(u, ord)),
          '[]'::jsonb),
        'website', i.website, 'photos', i.photos, 'attachments', i.attachments,
        -- qty e unit_price são como o total foi montado; price é o total.
        'qty', coalesce(i.qty, 1), 'unit_price', i.unit_price,
        'price', i.price, 'section', i.section,
        'optional', i.optional, 'choice_group', i.choice_group,
        'extras', i.extras) order by i.sort)
      from ops_proposal_items i where i.proposal_id = pp.id), '[]'::jsonb)
  ) into result;
  return result;
end $$;

revoke all on function tl_get_quote(text) from public;
grant execute on function tl_get_quote(text) to anon, authenticated;


create or replace function tl_submit_quote(p_token text, p_payload jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  pp       ops_proposals%rowtype;
  it       ops_proposal_items%rowtype;
  ex       jsonb;
  un       jsonb;
  unsel    jsonb;
  unmarc   jsonb;
  temun    boolean;
  g        text;
  faltando text[] := '{}';
  marcados jsonb;
  exmarc   jsonb;
  escol    boolean;
  exsel    jsonb;
  linhas   jsonb := '[]'::jsonb;
  soma     numeric := 0;
  quantos  int := 0;
  simples  boolean;
begin
  select * into pp from ops_proposals where token = p_token;
  if not found then return jsonb_build_object('ok', false, 'error', 'not_found'); end if;
  -- A conferência vive aqui também, e não só na tela: quem tiver a
  -- página aberta desde antes da data não passa a poder enviar.
  if pp.token_expires_at is not null and pp.token_expires_at < now() then
    return jsonb_build_object('ok', false, 'error', 'expired');
  end if;
  if pp.responded_at is not null then
    return jsonb_build_object('ok', false, 'error', 'already_answered');
  end if;
  -- No bloco simples não existe campo de nome na tela. Exigir aqui
  -- travaria o envio numa tela onde não há como preencher.
  simples := coalesce(pp.confirm_mode, 'full') = 'simple';
  if not simples and coalesce(btrim(p_payload->>'lead_name'),'') = '' then
    return jsonb_build_object('ok', false, 'error', 'missing_fields', 'missing', to_jsonb(array['lead_name']));
  end if;
  -- A caixinha é obrigatória nos dois: no completo é o aceite das
  -- condições, no simples é a confirmação de interesse.
  if coalesce((p_payload->>'ack_conditions')::boolean, false) is not true then
    return jsonb_build_object('ok', false, 'error', 'missing_ack');
  end if;

  marcados := coalesce(p_payload->'items','[]'::jsonb);
  exmarc   := coalesce(p_payload->'extras','{}'::jsonb);
  unmarc   := coalesce(p_payload->'units','{}'::jsonb);

  for g in select distinct choice_group from ops_proposal_items
            where proposal_id = pp.id and choice_group is not null loop
    if not exists (select 1 from ops_proposal_items i
                    where i.proposal_id = pp.id and i.choice_group = g
                      and marcados @> to_jsonb(i.id::text)) then
      faltando := array_append(faltando, g);
    end if;
  end loop;
  if array_length(faltando,1) > 0 then
    return jsonb_build_object('ok', false, 'error', 'missing_choice', 'missing', to_jsonb(faltando));
  end if;

  for it in select * from ops_proposal_items where proposal_id = pp.id order by sort loop
    -- Marcada ou não entra. Não existe mais linha que entra sozinha.
    escol := marcados @> to_jsonb(it.id::text);
    exsel := '[]'::jsonb;
    unsel := '[]'::jsonb;
    if escol then
      quantos := quantos + 1;
      soma := soma + coalesce(it.price,0);
      -- Unidades: quarto e apartamento do mesmo hotel, cada um com o
      -- seu valor. A que não é opcional entra por fazer parte da
      -- hospedagem; a opcional só entra se o cliente marcou.
      temun := false;
      for un in select * from jsonb_array_elements(coalesce(it.units,'[]'::jsonb)) loop
        if coalesce((un->>'optional')::boolean, false) is not true
           or coalesce(unmarc->(it.id::text), '[]'::jsonb) @> to_jsonb(un->>'key') then
          soma  := soma + coalesce((un->>'price')::numeric, 0);
          unsel := unsel || jsonb_build_object('key', un->>'key', 'label', un->>'label',
            'label_en', un->>'label_en', 'price', un->>'price',
            'optional', coalesce((un->>'optional')::boolean, false));
          temun := true;
        end if;
      end loop;
      -- Hospedagem com unidades, e nenhuma marcada, não é escolha: o
      -- cliente marcou o hotel e não disse em que quarto vai ficar.
      if not temun and jsonb_array_length(coalesce(it.units,'[]'::jsonb)) > 0 then
        return jsonb_build_object('ok', false, 'error', 'missing_units',
                                  'missing', to_jsonb(array[it.title]));
      end if;
      for ex in select * from jsonb_array_elements(coalesce(it.extras,'[]'::jsonb)) loop
        if coalesce(exmarc->(it.id::text), '[]'::jsonb) @> to_jsonb(ex->>'key') then
          soma  := soma + coalesce((ex->>'price')::numeric, 0);
          exsel := exsel || jsonb_build_object('key', ex->>'key', 'label_pt', ex->>'label_pt',
            'label_en', ex->>'label_en', 'price', ex->>'price');
        end if;
      end loop;
    end if;
    linhas := linhas || jsonb_build_object(
      'item_id', it.id, 'service_date', it.service_date, 'title', it.title,
      'details', it.details, 'price', it.price, 'optional', it.optional,
      'qty', coalesce(it.qty,1), 'unit_price', it.unit_price,
      'section', it.section, 'choice_group', it.choice_group,
      'supplier', it.supplier,
      'included', it.included_pt,
      'kind', coalesce(it.kind,'stay'),
      'chosen', escol, 'units', unsel, 'extras', exsel);
  end loop;

  -- Resposta sem nenhum serviço marcado não é resposta: é formulário
  -- enviado por engano, e viraria uma order vazia lá na frente.
  if quantos = 0 then
    return jsonb_build_object('ok', false, 'error', 'missing_items');
  end if;

  -- O travel designer é pedido junto do travel agent na proposta white
  -- label. Não é obrigatório: quem responde às vezes é a mesma pessoa.
  insert into ops_proposal_selections
    (proposal_id, lead_name, designer_name, lead_email, lead_phone, remarks, lines, total,
     ack_conditions, payment_choice, confirm_mode)
  values (pp.id, nullif(btrim(coalesce(p_payload->>'lead_name','')),''),
          nullif(btrim(coalesce(p_payload->>'designer_name','')),''),
          p_payload->>'lead_email',
          p_payload->>'lead_phone', p_payload->>'remarks', linhas, soma, true,
          case when simples then null else p_payload->>'payment_choice' end,
          case when simples then 'simple' else 'full' end);

  update ops_proposals set responded_at = now(), updated_at = now() where id = pp.id;
  return jsonb_build_object('ok', true);
end $$;


revoke all on function tl_submit_quote(text, jsonb) from public;
grant execute on function tl_submit_quote(text, jsonb) to anon, authenticated;


-- ---------------------------------------------------------------------
-- OS QUE VOLTAM SEMPRE, para ela não redigitar. Os nomes e as descrições
-- vêm das linhas reais da TL-034-26 — não são invenção minha. O VALOR
-- FICA EM BRANCO de propósito: preço dela eu não sei, e chutar um número
-- que depois desce sozinho para uma proposta é o pior defeito possível
-- neste cadastro. Ela lança o valor uma vez, na tela do Catálogo, e
-- daí em diante puxa.
--
-- Só entra o que ainda não existe pelo nome: rodar de novo não duplica
-- nem reescreve o que ela já ajustou.
-- ---------------------------------------------------------------------
insert into ops_catalog (kind, name, region, accommodation, descr, price_unit, price_note)
select v.kind, v.name, v.region, v.accommodation, v.descr, v.price_unit, v.price_note
  from (values
    ('transfer', 'Transfer privativo · aeroporto ↔ hotel', 'Toscana',
     'Veículo Mercedes Sedan ou equivalente · motorista falante de inglês',
     'Transfer privativo direto, com acompanhamento na chegada.',
     'vehicle', 'até 3 passageiros com bagagem'),
    ('transfer', 'Transfer privativo entre cidades · com stopover', 'Toscana · Umbria',
     'Veículo Mercedes Sedan ou equivalente · motorista falante de inglês',
     E'Transfer privativo entre as duas hospedagens, com parada em cidade no caminho.\nDespesas da parada não inclusas. Permanência de até 2 horas.',
     'vehicle', 'stopover de até 2h'),
    ('transfer', 'Transfer privativo · van', 'Toscana',
     'Van privativa até 8 pessoas · motorista falante de inglês',
     'Transfer privativo em van, para grupo com bagagem.',
     'vehicle', 'até 8 passageiros'),
    ('experience', 'Motorista à disposição · dia inteiro', 'Toscana',
     'Serviço privativo com transporte de ida e volta do hotel',
     E'Dia à disposição com motorista, com tempo livre nas cidades visitadas.\nDuração de aproximadamente 8 horas.',
     'day', '8 horas de serviço'),
    ('experience', 'Visita a vinícola com degustação', 'Chianti Classico',
     'Visita privada · degustação',
     E'Visita à vinícola com degustação conduzida.\nVisita em inglês.',
     'person', 'mínimo 2 pessoas'),
    ('experience', 'Visita a vinícola com almoço harmonizado', 'Toscana',
     'Visita privada · almoço harmonizado',
     E'Visita à vinícola com almoço harmonizado com os rótulos da casa.\nVisita em inglês.',
     'person', 'mínimo 2 pessoas'),
    ('experience', 'Tour guiado a pé · centro histórico', 'Toscana',
     'Guia local licenciado · a pé',
     E'Caminhada guiada pelo centro histórico, com guia local licenciado.\nIngressos de monumento não inclusos.',
     'group', '2 a 3 horas · até 8 pessoas')
  ) as v(kind, name, region, accommodation, descr, price_unit, price_note)
 where not exists (
   select 1 from ops_catalog c where lower(c.name) = lower(v.name)
 );

insert into ops_migrations (id) values ('0026-preco-no-catalogo-e-quantidade') on conflict (id) do nothing;
