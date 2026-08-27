-- =====================================================================
-- 0021 · PROPOSTA EM NOME DA AGÊNCIA (WHITE LABEL)
--
-- Instrução dela em agosto/26, depois de uma agência reclamar que a
-- proposta estava "muito personalizada" da Tuscan Lands. Numa venda em
-- que a agência é a dona do cliente, quem assina a peça é a agência: o
-- logo da capa é o dela, a página de apresentação fala dela, e a
-- contracapa de contato da Tuscan Lands não sai.
--
-- É UMA CHAVE SÓ, e não cinco. As cinco peças se movem juntas — logo,
-- página de abertura, contracapa, os dois nomes no envio — e chave
-- separada para cada uma seria uma para ela esquecer de virar. Fica
-- desligada por padrão: proposta que já existe não muda de cara.
--
-- O que varia de agência para agência é o logo e o fundo branco atrás
-- dele. O texto de respaldo tem padrão da casa em ops_text_defaults e
-- cópia na proposta, como todo texto daqui: corrigir o padrão não
-- reescreve proposta já enviada.
--
-- O nome da agência entra no texto por {agencia}, resolvido aqui e não
-- na tela — assim vale igual na página, no PDF e no e-mail.
--
-- O inglês vem escrito porque isto é texto de apresentação, e não
-- cláusula comercial. A regra de deixar o inglês em branco é das
-- condições, que têm efeito jurídico.
--
-- O negrito só na primeira linha: nesta folha o **texto** é a chamada
-- grande, em bloco próprio. Negrito no meio da frase parte o parágrafo
-- em três e a palavra destacada vira título solto.
--
-- Só toca em objetos ops_. Nada fora desse prefixo.
-- =====================================================================

alter table ops_proposals add column if not exists white_label boolean not null default false;
comment on column ops_proposals.white_label is
  'Proposta assinada pela agência: logo dela na capa, página de respaldo '
  'no lugar do "Sobre nós", sem a contracapa de contato da Tuscan Lands.';

alter table ops_proposals add column if not exists agency_logo text;
comment on column ops_proposals.agency_logo is
  'Endereço do logo da agência, usado na capa quando white_label.';

alter table ops_proposals add column if not exists agency_logo_bg boolean not null default false;
comment on column ops_proposals.agency_logo_bg is
  'Fundo branco atrás do logo da agência, para o logo escuro que some na foto.';

alter table ops_proposals add column if not exists assurance_pt text;
alter table ops_proposals add column if not exists assurance_en text;
comment on column ops_proposals.assurance_pt is
  'Página de respaldo da proposta white label: a agência desenha, a DMC opera. '
  '{agencia} é trocado pelo nome da agência da oportunidade.';

alter table ops_proposal_selections add column if not exists designer_name text;
comment on column ops_proposal_selections.designer_name is
  'Travel designer que montou a viagem, pedido junto do travel agent na proposta white label.';

insert into ops_text_defaults (key, pt, en) values
  ('assurance',
   E'**Uma viagem desenhada por {agencia}.**\n\nA curadoria, a escolha das hospedagens e o roteiro que você tem em mãos são de {agencia}, que acompanha você antes, durante e depois da viagem.\n\nA execução em solo italiano fica a cargo da Tuscan Lands Travel, DMC licenciada com sede em Florença, contratada por {agencia} para reconfirmar cada serviço com os fornecedores, coordenar a operação dia a dia e prestar assistência local durante toda a estadia.\n\nÉ essa divisão que garante que o programa desenhado por {agencia} seja entregue exatamente como foi apresentado, com o respaldo de uma operadora registrada na Itália.',
   E'**A journey designed by {agencia}.**\n\nThe curation, the choice of stays and the itinerary in your hands come from {agencia}, who stays with you before, during and after the trip.\n\nDelivery on the ground is carried out by Tuscan Lands Travel, a licensed DMC based in Florence, appointed by {agencia} to reconfirm every service with the suppliers, coordinate day-to-day operations and provide local assistance throughout the stay.\n\nThis is what ensures the programme designed by {agencia} is delivered exactly as presented, backed by a tour operator registered in Italy.')
on conflict (key) do nothing;


-- ---------------------------------------------------------------------
-- Proposta nova nasce com o texto de respaldo preenchido, como nasce
-- com o "Sobre nós". Só no insert, e sempre cópia.
-- ---------------------------------------------------------------------
create or replace function tl_proposal_defaults()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare d record;
begin
  for d in select key, pt, en from ops_text_defaults loop
    if d.key = 'about' then
      new.about_pt       := coalesce(nullif(new.about_pt,''),       d.pt);
      new.about_en       := coalesce(nullif(new.about_en,''),       d.en);
    elsif d.key = 'credentials' then
      new.credentials_pt := coalesce(nullif(new.credentials_pt,''), d.pt);
      new.credentials_en := coalesce(nullif(new.credentials_en,''), d.en);
    elsif d.key = 'backcover' then
      new.backcover_pt   := coalesce(nullif(new.backcover_pt,''),   d.pt);
      new.backcover_en   := coalesce(nullif(new.backcover_en,''),   d.en);
    elsif d.key = 'conditions' then
      new.conditions_pt  := coalesce(nullif(new.conditions_pt,''),  d.pt);
      new.conditions_en  := coalesce(nullif(new.conditions_en,''),  d.en);
    elsif d.key = 'assurance' then
      new.assurance_pt   := coalesce(nullif(new.assurance_pt,''),   d.pt);
      new.assurance_en   := coalesce(nullif(new.assurance_en,''),   d.en);
    elsif d.key = 'about_img' then
      new.about_img      := coalesce(nullif(new.about_img,''),      d.pt);
    elsif d.key = 'backcover_img' then
      new.backcover_img  := coalesce(nullif(new.backcover_img,''),  d.pt);
    end if;
  end loop;
  return new;
end $$;

drop trigger if exists ops_proposal_defaults on ops_proposals;
create trigger ops_proposal_defaults
  before insert on ops_proposals
  for each row execute function tl_proposal_defaults();

-- Quem já existe recebe o texto de respaldo agora, para não ficar com a
-- página em branco ao virar a chave. É preenchimento de campo vazio.
update ops_proposals
   set assurance_pt = coalesce(nullif(assurance_pt,''),
                        (select pt from ops_text_defaults where key='assurance')),
       assurance_en = coalesce(nullif(assurance_en,''),
                        (select en from ops_text_defaults where key='assurance')),
       updated_at   = now()
 where layout = 'apresentada'
   and (coalesce(assurance_pt,'') = '' or coalesce(assurance_en,'') = '');


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
  if coalesce(btrim(p_payload->>'lead_name'),'') = '' then
    return jsonb_build_object('ok', false, 'error', 'missing_fields', 'missing', to_jsonb(array['lead_name']));
  end if;
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
     ack_conditions, payment_choice)
  values (pp.id, p_payload->>'lead_name',
          nullif(btrim(coalesce(p_payload->>'designer_name','')),''),
          p_payload->>'lead_email',
          p_payload->>'lead_phone', p_payload->>'remarks', linhas, soma, true,
          p_payload->>'payment_choice');

  update ops_proposals set responded_at = now(), updated_at = now() where id = pp.id;
  return jsonb_build_object('ok', true);
end $$;


revoke all on function tl_submit_quote(text, jsonb) from public;
grant execute on function tl_submit_quote(text, jsonb) to anon, authenticated;


create or replace function tl_notify_quote()
returns trigger
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  c       ops_notify_config%rowtype;
  pp      ops_proposals%rowtype;
  o       ops_opportunities%rowtype;
  ln      jsonb;
  ex      jsonb;
  linhas  text := '';
  assunto text;
  corpo   text;
  req_id  bigint;
begin
  select * into c from ops_notify_config where id = 1;
  if not found or c.enabled is not true or coalesce(c.resend_key,'') = '' then
    return new;
  end if;

  select * into pp from ops_proposals     where id = new.proposal_id;
  select * into o  from ops_opportunities where id = pp.opportunity_id;

  for ln in select * from jsonb_array_elements(new.lines) loop
    linhas := linhas
      || '<tr><td style="padding:5px 12px 5px 0;color:#595e49;white-space:nowrap;">'
      || tl_html(coalesce(ln->>'service_date','')) || '</td>'
      || '<td style="padding:5px 12px 5px 0;">'
      || case when (ln->>'chosen')::boolean then '' else '<span style="color:#a2564c;">✕ </span>' end
      || tl_html(ln->>'title')
      || case when (ln->>'optional')::boolean then ' <span style="color:#6b6860;font-size:11px;">(opcional)</span>' else '' end;
    for ex in select * from jsonb_array_elements(coalesce(ln->'units','[]'::jsonb)) loop
      linhas := linhas || '<br><span style="color:#595e49;font-size:12px;">· '
        || tl_html(coalesce(ex->>'label', ex->>'key'))
        || case when pp.show_prices then ' · ' || tl_eur((ex->>'price')::numeric) else '' end
        || '</span>';
    end loop;
    for ex in select * from jsonb_array_elements(coalesce(ln->'extras','[]'::jsonb)) loop
      linhas := linhas || '<br><span style="color:#a56850;font-size:12px;">+ '
        || tl_html(coalesce(ex->>'label_pt', ex->>'key'))
        || case when pp.show_prices then ' · ' || tl_eur((ex->>'price')::numeric) else '' end
        || '</span>';
    end loop;
    linhas := linhas || '</td><td style="padding:5px 0;text-align:right;white-space:nowrap;">'
      || case when not (ln->>'chosen')::boolean then '—'
              when pp.show_prices then tl_eur(coalesce((ln->>'price')::numeric,0)
                   + coalesce((select sum((u->>'price')::numeric)
                                 from jsonb_array_elements(coalesce(ln->'units','[]'::jsonb)) u),0)
                   + coalesce((select sum((e2->>'price')::numeric)
                                 from jsonb_array_elements(coalesce(ln->'extras','[]'::jsonb)) e2),0))
              else '' end
      || '</td></tr>';
  end loop;

  assunto := 'Quote respondida · ' || coalesce(o.crm_code, pp.title, '')
             || ' · ' || coalesce(new.lead_name, o.agency, '');

  corpo :=
    '<div style="font-family:''Libre Franklin'',Helvetica,Arial,sans-serif;font-size:14px;line-height:1.6;color:#2a2a28;max-width:640px;">'
    || '<p style="font-size:11px;letter-spacing:.2em;text-transform:uppercase;color:#595e49;margin:0 0 4px;">Tuscan Lands · quote respondida</p>'
    || '<div style="width:30px;height:1px;background:#a56850;margin:0 0 18px;"></div>'
    || '<p style="margin:0 0 18px;"><strong style="font-size:17px;">'
    || tl_html(coalesce(o.final_client, o.agency, '')) || '</strong><br>'
    || tl_html(coalesce(pp.title,'')) || ' · versão ' || pp.version || '<br>'
    || 'Oportunidade ' || tl_html(coalesce(o.crm_code,'—')) || '<br>'
    || 'Período: ' || tl_html(coalesce(pp.travel_window,'—')) || '</p>'
    || '<p>Respondida por <strong>' || tl_html(coalesce(new.lead_name,'—')) || '</strong><br>'
    || case when coalesce(new.designer_name,'') <> ''
            then 'Travel designer: ' || tl_html(new.designer_name) || '<br>' else '' end
    || 'Contato: ' || tl_html(coalesce(new.lead_email,'—')) || ' · ' || tl_html(coalesce(new.lead_phone,'—')) || '</p>'
    || case when coalesce(new.remarks,'') <> ''
            then '<p>Observações:<br><em>' || replace(tl_html(new.remarks), E'\n','<br>') || '</em></p>'
            else '' end
    || '<p style="font-size:11px;letter-spacing:.16em;text-transform:uppercase;color:#595e49;margin:22px 0 6px;">O que ele escolheu</p>'
    || '<table style="border-collapse:collapse;font-size:14px;width:100%;">' || linhas || '</table>'
    || case when pp.show_prices
            then '<p style="margin:10px 0 0;text-align:right;"><strong>Total ' || tl_eur(new.total) || '</strong></p>'
            else '<p style="margin:10px 0 0;color:#6b6860;font-size:12px;">Proposta enviada sem preços.</p>' end
    || '<p style="font-size:12px;color:#6b6860;margin-top:26px;border-top:1px solid #eae4db;padding-top:12px;">'
    || 'A order <strong>não</strong> foi criada. Reconfirme os serviços e gere a order pelo hub.</p>'
    || '</div>';

  begin
    select net.http_post(
      url     := 'https://api.resend.com/emails',
      headers := jsonb_build_object('Content-Type','application/json',
                                    'Authorization','Bearer ' || c.resend_key),
      body    := jsonb_build_object('from', c.mail_from,
                                    'to', string_to_array(c.mail_to, ','),
                                    'subject', assunto, 'html', corpo),
      timeout_milliseconds := 8000
    ) into req_id;
    insert into ops_notifications (order_id, kind, mail_to, subject, net_request_id)
    values (null, 'quote_answered', c.mail_to, assunto, req_id);
  exception when others then
    insert into ops_notifications (order_id, kind, mail_to, subject, error)
    values (null, 'quote_answered', c.mail_to, assunto, sqlerrm);
  end;

  return new;
end $$;

drop trigger if exists ops_quote_notify on ops_proposal_selections;
create trigger ops_quote_notify
  after insert on ops_proposal_selections
  for each row execute function tl_notify_quote();

insert into ops_migrations (id) values ('0021-proposta-da-agencia') on conflict (id) do nothing;
