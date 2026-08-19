-- =====================================================================
-- TUSCAN LANDS · HUB DE VENDAS E OPERAÇÕES
-- QUOTE — a proposta que o cliente monta escolhendo
--
-- Rodar DEPOIS de tl-hub-opportunities.sql e tl-hub-checkout.sql.
--
-- O que muda: ops_proposals e ops_proposal_items já existiam, com o
-- mesmo formato de ops_order_items, feitas para que linha aprovada
-- virasse linha de order sem reescrever nada. Faltava o que a agência
-- decide: o que é opcional, quais extras cada linha aceita, e o retrato
-- do que ela escolheu.
--
-- A order passa a nascer da quote aceita, dentro da mesma função. Isso
-- não contorna o gatilho tl_guard_order — cumpre: a proposta é marcada
-- como aceita antes da order ser inserida, na mesma transação.
--
-- ---------------------------------------------------------------------
-- CONFERÊNCIA DA SEÇÃO 7 — feita antes de entregar, por escrito.
-- Objetos que este arquivo cria ou altera, um a um:
--   ops_proposals             (alter add column)
--   ops_proposal_items        (alter add column)
--   ops_proposal_selections   (create table)
--   ops_orders                (alter add column, 1 coluna nova)
--   tl_get_quote              (create function — nova, do hub)
--   tl_submit_quote           (create function — nova, do hub)
-- Nenhum drop de tabela. Nenhum delete, truncate ou update de dados
-- existentes. Nenhuma tabela do CRM é lida, escrita ou citada. Nenhum
-- comando percorre o schema. Nenhuma service_role key aparece aqui.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1 · A PROPOSTA VIRA DOCUMENTO QUE SE MANDA
-- Token próprio, separado do da order: são dois documentos, em dois
-- momentos, e quem viu a quote não deve por isso enxergar a order.
-- ---------------------------------------------------------------------
alter table ops_proposals add column if not exists token text
  default encode(gen_random_bytes(16),'hex');
alter table ops_proposals add column if not exists lang          text;
alter table ops_proposals add column if not exists pax_summary   text;
alter table ops_proposals add column if not exists travel_window text;
alter table ops_proposals add column if not exists intro         text;
alter table ops_proposals add column if not exists payment_note  text;
alter table ops_proposals add column if not exists terms_url     text;

-- Proposta sem preço é caso real: às vezes o que vai para a agência é o
-- desenho da viagem, e o valor vem depois. Some o preço de cada linha,
-- o dos extras e o total — o cliente escolhe pelo serviço, não pelo
-- valor, e o que ele escolheu chega igual do outro lado.
alter table ops_proposals add column if not exists show_prices boolean not null default true;

-- Quando o cliente respondeu. Diferente de decided_at, que é quando ELA
-- decidiu: a resposta do cliente é pedido, não fechamento. Entre uma
-- coisa e outra existe a reconfirmação dos serviços.
alter table ops_proposals add column if not exists responded_at timestamptz;

-- Propostas criadas antes desta migração não têm token. Preenche só as
-- que estão nulas — não toca em nenhuma que já tenha.
update ops_proposals set token = encode(gen_random_bytes(16),'hex')
 where token is null;

create unique index if not exists ops_prop_token_idx on ops_proposals(token);

-- ---------------------------------------------------------------------
-- 2 · A LINHA: INCLUSA OU OPCIONAL, COM SEUS EXTRAS
--
-- optional = false é o serviço que faz parte da proposta e não se
-- desmarca. true é o que o cliente decide.
--
-- extras é a mecânica do concierge trazida para cá: transporte,
-- anfitrião, visita guiada, ou o que ela escrever, cada um com preço
-- próprio e marcado à parte. Guardado como jsonb porque a lista muda de
-- linha para linha e criar tabela filha para três checkboxes seria
-- carregar junção onde não há consulta.
-- ---------------------------------------------------------------------
alter table ops_proposal_items add column if not exists optional boolean not null default false;
alter table ops_proposal_items add column if not exists extras   jsonb   not null default '[]'::jsonb;

comment on column ops_proposal_items.optional is
  'false = incluso e não desmarcável; true = o cliente escolhe.';
comment on column ops_proposal_items.extras is
  'Opcionais da linha: [{"key","label_pt","label_en","price"}]. Cada um é uma caixa à parte.';

-- ---------------------------------------------------------------------
-- 3 · O QUE O CLIENTE ESCOLHEU
--
-- Retrato, como nas confirmações da order: rótulo, preço e escolha
-- juntos, montados pelo banco a partir da proposta e nunca do que o
-- navegador mandou. Proposta reescrita depois não altera o que ele viu.
-- ---------------------------------------------------------------------
create table if not exists ops_proposal_selections (
  id           uuid primary key default gen_random_uuid(),
  proposal_id  uuid not null references ops_proposals(id) on delete cascade,
  order_id     uuid references ops_orders(id) on delete set null,
  lead_name    text,
  lead_email   text,
  lead_phone   text,
  remarks      text,
  lines        jsonb not null default '[]'::jsonb,
  total        numeric(12,2) not null default 0,
  submitted_at timestamptz not null default now()
);
create index if not exists ops_prop_sel_prop_idx on ops_proposal_selections(proposal_id);

alter table ops_proposal_selections enable row level security;
drop policy if exists "auth_all" on ops_proposal_selections;
create policy "auth_all" on ops_proposal_selections
  for all to authenticated using (true) with check (true);

-- ---------------------------------------------------------------------
-- 4 · LINK DE PAGAMENTO NA ORDER
-- Separado do link de confirmação de propósito: são dois atos, e juntar
-- os dois num link só faria o cliente pagar antes de conferir os nomes.
-- ---------------------------------------------------------------------
alter table ops_orders add column if not exists payment_url text;

comment on column ops_orders.payment_url is
  'Link de pagamento, gerado fora do hub por enquanto. Some do documento quando vazio.';

-- =====================================================================
-- 5 · LEITURA PÚBLICA DA QUOTE
-- =====================================================================
create or replace function tl_get_quote(p_token text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare pp ops_proposals%rowtype; o ops_opportunities%rowtype; result jsonb;
begin
  select * into pp from ops_proposals where token = p_token;
  if not found then return null; end if;
  select * into o from ops_opportunities where id = pp.opportunity_id;

  select jsonb_build_object(
    'proposal', jsonb_build_object(
      'id', pp.id, 'version', pp.version, 'title', pp.title, 'summary', pp.summary,
      'lang', coalesce(pp.lang, o.lang, 'pt'),
      'pax_summary', pp.pax_summary, 'travel_window', pp.travel_window,
      'intro', pp.intro, 'payment_note', pp.payment_note, 'terms_url', pp.terms_url,
      'show_prices', pp.show_prices,
      'crm_code', o.crm_code, 'agency', o.agency, 'final_client', o.final_client,
      'outcome', pp.outcome, 'responded_at', pp.responded_at),
    'items', coalesce((select jsonb_agg(jsonb_build_object(
        'id', i.id, 'service_date', i.service_date, 'title', i.title,
        'details', i.details, 'price', i.price,
        'optional', i.optional, 'extras', i.extras) order by i.sort)
      from ops_proposal_items i where i.proposal_id = pp.id), '[]'::jsonb)
  ) into result;
  return result;
end $$;

-- =====================================================================
-- 6 · O CLIENTE ENVIA A ESCOLHA
--
-- Não cria order. Ela precisa validar antes, porque há reconfirmação
-- dos serviços com os fornecedores entre o pedido e o fechamento — e
-- order criada sozinha significaria compromisso assumido sem que
-- ninguém tivesse conferido disponibilidade.
--
-- O retrato é montado a partir da proposta, nunca do payload: o
-- navegador diz apenas quais ids marcou.
-- =====================================================================
create or replace function tl_submit_quote(p_token text, p_payload jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  pp     ops_proposals%rowtype;
  it     ops_proposal_items%rowtype;
  ex     jsonb;
  linhas jsonb := '[]'::jsonb;
  exsel  jsonb;
  escol  boolean;
  soma   numeric(12,2) := 0;
  marcados jsonb;
  exmarc   jsonb;
begin
  select * into pp from ops_proposals where token = p_token;
  if not found then return jsonb_build_object('ok', false, 'error', 'not_found'); end if;
  if pp.responded_at is not null then
    return jsonb_build_object('ok', false, 'error', 'already_answered');
  end if;
  if coalesce(btrim(p_payload->>'lead_name'),'') = '' then
    return jsonb_build_object('ok', false, 'error', 'missing_fields', 'missing', to_jsonb(array['lead_name']));
  end if;

  marcados := coalesce(p_payload->'items','[]'::jsonb);   -- ids escolhidos
  exmarc   := coalesce(p_payload->'extras','{}'::jsonb);  -- {item_id:[chaves]}

  for it in select * from ops_proposal_items where proposal_id = pp.id order by sort loop
    -- Linha inclusa entra sempre. Opcional entra se veio marcada.
    escol := (not it.optional) or (marcados @> to_jsonb(it.id::text));
    exsel := '[]'::jsonb;
    if escol then
      soma := soma + coalesce(it.price,0);
      for ex in select * from jsonb_array_elements(coalesce(it.extras,'[]'::jsonb)) loop
        if coalesce(exmarc->(it.id::text), '[]'::jsonb) @> to_jsonb(ex->>'key') then
          soma  := soma + coalesce((ex->>'price')::numeric, 0);
          exsel := exsel || jsonb_build_object(
            'key', ex->>'key', 'label_pt', ex->>'label_pt',
            'label_en', ex->>'label_en', 'price', ex->>'price');
        end if;
      end loop;
    end if;
    linhas := linhas || jsonb_build_object(
      'item_id', it.id, 'service_date', it.service_date, 'title', it.title,
      'details', it.details, 'price', it.price, 'optional', it.optional,
      'chosen', escol, 'extras', exsel);
  end loop;

  insert into ops_proposal_selections
    (proposal_id, lead_name, lead_email, lead_phone, remarks, lines, total)
  values (pp.id, p_payload->>'lead_name', p_payload->>'lead_email',
          p_payload->>'lead_phone', p_payload->>'remarks', linhas, soma);

  -- Respondida, não aceita. Aceitar é ato dela, depois da reconfirmação.
  update ops_proposals set responded_at = now(), updated_at = now() where id = pp.id;

  return jsonb_build_object('ok', true);
end $$;

revoke all on function tl_get_quote(text) from public;
revoke all on function tl_submit_quote(text, jsonb) from public;
grant execute on function tl_get_quote(text) to anon, authenticated;
grant execute on function tl_submit_quote(text, jsonb) to anon, authenticated;

-- =====================================================================
-- 7 · ELA VALIDA E A ORDER NASCE
--
-- Só ela chama isto, logada, depois de reconfirmar os serviços. A
-- proposta é marcada como aceita ANTES da order ser inserida, na mesma
-- transação: não é contorno do tl_guard_order, é o caminho que ele
-- exige. Se a order falhar, o accepted desfaz junto.
--
-- Só entram as linhas escolhidas, e os extras que ele marcou viram
-- linha própria — no dia da operação, transporte contratado à parte é
-- um serviço a confirmar, não uma observação embaixo de outro.
-- =====================================================================
create or replace function tl_order_from_quote(p_selection uuid)
returns jsonb
language plpgsql
set search_path = public
as $$
declare
  sel    ops_proposal_selections%rowtype;
  pp     ops_proposals%rowtype;
  o      ops_opportunities%rowtype;
  ln     jsonb;
  ex     jsonb;
  novo   uuid;
  ref    text;
  n      int := 0;
  idioma text;
begin
  select * into sel from ops_proposal_selections where id = p_selection;
  if not found then return jsonb_build_object('ok', false, 'error', 'selection_not_found'); end if;
  if sel.order_id is not null then
    return jsonb_build_object('ok', false, 'error', 'already_generated', 'order_id', sel.order_id);
  end if;

  select * into pp from ops_proposals    where id = sel.proposal_id;
  select * into o  from ops_opportunities where id = pp.opportunity_id;
  idioma := coalesce(pp.lang, o.lang, 'pt');

  -- Aceita agora. O índice único do arquivo de oportunidades garante uma
  -- só aceita por oportunidade; se já houver outra, a gravação falha aqui
  -- e nada é criado — que é o certo, porque duas propostas aceitas para a
  -- mesma venda é contradição, não caso de uso.
  update ops_proposals
     set outcome = 'accepted', acceptance_mode = 'written',
         decided_at = coalesce(decided_at, now()), updated_at = now()
   where id = pp.id;

  select coalesce(o.crm_code, pp.title, 'TL') || '.' ||
         (1 + (select count(*) from ops_orders r where r.opportunity_id = o.id))
    into ref;

  insert into ops_orders
    (opportunity_id, opportunity_code, order_ref, lang, status, agency, agency_contact,
     final_client, pax_summary, travel_window, intro, terms_url, payment_note)
  values (o.id, coalesce(o.crm_code,''), ref, idioma, 'draft', o.agency, o.agency_contact,
     coalesce(o.final_client, sel.lead_name), pp.pax_summary, pp.travel_window,
     pp.intro, pp.terms_url, pp.payment_note)
  returning id into novo;

  for ln in select * from jsonb_array_elements(sel.lines) loop
    if (ln->>'chosen')::boolean then
      insert into ops_order_items (order_id, sort, service_date, title, details, price)
      values (novo, n, ln->>'service_date', ln->>'title', ln->>'details',
              coalesce((ln->>'price')::numeric, 0));
      n := n + 1;
      for ex in select * from jsonb_array_elements(coalesce(ln->'extras','[]'::jsonb)) loop
        insert into ops_order_items (order_id, sort, service_date, title, details, price)
        values (novo, n, ln->>'service_date',
                coalesce(ex->>'label_pt', ex->>'label_en', ex->>'key'),
                (ln->>'title'), coalesce((ex->>'price')::numeric, 0));
        n := n + 1;
      end loop;
    end if;
  end loop;

  update ops_proposal_selections set order_id = novo where id = sel.id;
  return jsonb_build_object('ok', true, 'order_id', novo, 'order_ref', ref);
end $$;

revoke all on function tl_order_from_quote(uuid) from public, anon;
grant execute on function tl_order_from_quote(uuid) to authenticated;

-- =====================================================================
-- 8 · O E-MAIL QUANDO O CLIENTE RESPONDE
--
-- Mesmo desenho do aviso de confirmação: pg_net depois do commit, e o
-- envio inteiro dentro de um bloco que engole exceção. Se o e-mail
-- falhar, a escolha do cliente fica gravada assim mesmo — perder o
-- pedido porque o aviso não saiu seria trocar um problema por um pior.
--
-- Depende de tl-hub-notify.sql, que cria ops_notify_config, tl_eur e
-- tl_html. Sem chave configurada, não faz nada e não reclama.
-- =====================================================================
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
    for ex in select * from jsonb_array_elements(coalesce(ln->'extras','[]'::jsonb)) loop
      linhas := linhas || '<br><span style="color:#a56850;font-size:12px;">+ '
        || tl_html(coalesce(ex->>'label_pt', ex->>'key'))
        || case when pp.show_prices then ' · ' || tl_eur((ex->>'price')::numeric) else '' end
        || '</span>';
    end loop;
    linhas := linhas || '</td><td style="padding:5px 0;text-align:right;white-space:nowrap;">'
      || case when not (ln->>'chosen')::boolean then '—'
              when pp.show_prices then tl_eur((ln->>'price')::numeric)
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

-- =====================================================================
-- 9 · GRUPO DE ESCOLHA — "um destes dois"
--
-- Acrescentado depois de ler uma proposta real: hospedagem de 4 a 6 de
-- maio era "Borghi dell'Eremo OU Relais Villa Monte Solare", e o modelo
-- só sabia incluso e opcional. Marcadas as duas, o total sairia com o
-- dobro das noites que existem.
--
-- Linhas com o mesmo choice_group formam uma escolha: exatamente uma.
-- Nulo é o comportamento de antes.
-- =====================================================================
alter table ops_proposal_items add column if not exists choice_group text;

comment on column ops_proposal_items.choice_group is
  'Linhas com o mesmo valor formam uma escolha de uma só. Nulo = linha comum.';

create or replace function tl_submit_quote(p_token text, p_payload jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  pp     ops_proposals%rowtype;
  it     ops_proposal_items%rowtype;
  ex     jsonb;
  linhas jsonb := '[]'::jsonb;
  exsel  jsonb;
  escol  boolean;
  soma   numeric(12,2) := 0;
  marcados jsonb;
  exmarc   jsonb;
  g        text;
  faltando text[] := '{}';
begin
  select * into pp from ops_proposals where token = p_token;
  if not found then return jsonb_build_object('ok', false, 'error', 'not_found'); end if;
  if pp.responded_at is not null then
    return jsonb_build_object('ok', false, 'error', 'already_answered');
  end if;
  if coalesce(btrim(p_payload->>'lead_name'),'') = '' then
    return jsonb_build_object('ok', false, 'error', 'missing_fields', 'missing', to_jsonb(array['lead_name']));
  end if;

  marcados := coalesce(p_payload->'items','[]'::jsonb);
  exmarc   := coalesce(p_payload->'extras','{}'::jsonb);

  -- Grupo sem nenhuma escolhida é pergunta sem resposta, e recusar aqui
  -- é melhor que gravar uma viagem sem onde dormir.
  for g in select distinct choice_group from ops_proposal_items
            where proposal_id = pp.id and choice_group is not null loop
    if not exists (select 1 from ops_proposal_items i
                    where i.proposal_id = pp.id and i.choice_group = g
                      and marcados @> to_jsonb(i.id::text)) then
      faltando := array_append(faltando, g);
    end if;
  end loop;
  if array_length(faltando,1) > 0 then
    return jsonb_build_object('ok', false, 'error', 'missing_choice',
                              'missing', to_jsonb(faltando));
  end if;

  for it in select * from ops_proposal_items where proposal_id = pp.id order by sort loop
    -- Inclusa entra sempre. Opcional e alternativa entram se marcadas.
    escol := (not it.optional and it.choice_group is null)
             or (marcados @> to_jsonb(it.id::text));
    exsel := '[]'::jsonb;
    if escol then
      soma := soma + coalesce(it.price,0);
      for ex in select * from jsonb_array_elements(coalesce(it.extras,'[]'::jsonb)) loop
        if coalesce(exmarc->(it.id::text), '[]'::jsonb) @> to_jsonb(ex->>'key') then
          soma  := soma + coalesce((ex->>'price')::numeric, 0);
          exsel := exsel || jsonb_build_object(
            'key', ex->>'key', 'label_pt', ex->>'label_pt',
            'label_en', ex->>'label_en', 'price', ex->>'price');
        end if;
      end loop;
    end if;
    linhas := linhas || jsonb_build_object(
      'item_id', it.id, 'service_date', it.service_date, 'title', it.title,
      'details', it.details, 'price', it.price, 'optional', it.optional,
      'choice_group', it.choice_group, 'chosen', escol, 'extras', exsel);
  end loop;

  insert into ops_proposal_selections
    (proposal_id, lead_name, lead_email, lead_phone, remarks, lines, total)
  values (pp.id, p_payload->>'lead_name', p_payload->>'lead_email',
          p_payload->>'lead_phone', p_payload->>'remarks', linhas, soma);

  update ops_proposals set responded_at = now(), updated_at = now() where id = pp.id;
  return jsonb_build_object('ok', true);
end $$;

-- tl_get_quote precisa devolver o grupo para a tela desenhar o botão.
create or replace function tl_get_quote(p_token text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare pp ops_proposals%rowtype; o ops_opportunities%rowtype; result jsonb;
begin
  select * into pp from ops_proposals where token = p_token;
  if not found then return null; end if;
  select * into o from ops_opportunities where id = pp.opportunity_id;

  select jsonb_build_object(
    'proposal', jsonb_build_object(
      'id', pp.id, 'version', pp.version, 'title', pp.title, 'summary', pp.summary,
      'lang', coalesce(pp.lang, o.lang, 'pt'),
      'pax_summary', pp.pax_summary, 'travel_window', pp.travel_window,
      'intro', pp.intro, 'payment_note', pp.payment_note, 'terms_url', pp.terms_url,
      'show_prices', pp.show_prices,
      'crm_code', o.crm_code, 'agency', o.agency, 'final_client', o.final_client,
      'outcome', pp.outcome, 'responded_at', pp.responded_at),
    'items', coalesce((select jsonb_agg(jsonb_build_object(
        'id', i.id, 'service_date', i.service_date, 'title', i.title,
        'details', i.details, 'price', i.price,
        'optional', i.optional, 'choice_group', i.choice_group,
        'extras', i.extras) order by i.sort)
      from ops_proposal_items i where i.proposal_id = pp.id), '[]'::jsonb)
  ) into result;
  return result;
end $$;

revoke all on function tl_get_quote(text) from public;
revoke all on function tl_submit_quote(text, jsonb) from public;
grant execute on function tl_get_quote(text) to anon, authenticated;
grant execute on function tl_submit_quote(text, jsonb) to anon, authenticated;
