-- =====================================================================
-- 0054 · BRIEFING QUE A ADVISOR RESPONDE, POR LINK PRÓPRIO
--
-- Especificação dela, 1 de outubro de 2026. A TL manda um briefing para a
-- advisor por um link, a advisor responde na mesma página, e cada envio
-- vira uma VERSÃO NOVA — nenhuma resposta anterior é alterada. O link
-- vence numa data que a TL define.
--
-- Primeiro caso: o briefing de hotelaria da Emily, 20/6 a 5/7/2027.
--
-- NÃO É O BRIEFING QUE JÁ EXISTE. `ops_briefings` é o briefing INTERNO da
-- oportunidade, que ela preenche sobre o que a agência pediu. Este é o
-- contrário: é uma pergunta DA TL PARA a advisor, com resposta dela. Dois
-- documentos diferentes, em direções opostas, e por isso tabela própria —
-- e nome próprio, para ninguém confundir os dois daqui a seis meses.
--
-- QUATRO DECISÕES QUE A ESPECIFICAÇÃO DEIXOU EM ABERTO, resolvidas aqui
-- do jeito que o hub já funciona:
--
--   · A especificação chama as tabelas de `briefings`, `briefing_perguntas`
--     e por aí. Aqui tudo começa com `ops_` — é a regra que mantém o hub
--     separado do CRM, que mora no mesmo banco. Ficou
--     ops_advisor_briefings, ops_advisor_questions, ops_advisor_answers e
--     ops_advisor_opens.
--
--   · A especificação pede Edge Functions. O hub nunca usou: o documento do
--     cliente e a proposta passam por função `security definer` chamada por
--     RPC, que é o mesmo isolamento sem serviço novo para manter. Ficou RPC.
--
--   · A rota pedida é `/b/{token}`. O hub é um arquivo só servido da raiz e
--     roteia por hash, como `#/quote/TOKEN`. Caminho de verdade exigiria
--     reescrita no servidor. Ficou `#/b/TOKEN`.
--
--   · O aviso por e-mail usa o que já está no ar: ops_notify_config e a
--     Resend, pelo mesmo caminho da confirmação da order.
--
-- O PASSADO: só cria tabela e função. Nenhum update, nenhum delete, nenhuma
-- linha existente tocada. E o desenho inteiro é a favor da regra: resposta
-- é linha nova, numerada, e a anterior fica.
--
-- Só toca em objetos ops_ e tl_. Conferido linha a linha.
-- =====================================================================

-- 1) AS QUATRO TABELAS ------------------------------------------------

create table if not exists ops_advisor_briefings (
  id             uuid primary key default gen_random_uuid(),
  title          text not null,
  client_ref     text,                       -- nome interno do caso
  -- Liga na oportunidade quando ela existir. Sem obrigar: o briefing pode
  -- nascer antes da oportunidade, e apagar a oportunidade não leva junto o
  -- que a advisor respondeu.
  opportunity_id uuid references ops_opportunities(id) on delete set null,
  advisor_name   text,
  agency         text,
  advisor_email  text,
  content        text,                       -- corpo do briefing, em Markdown
  token          text unique not null default encode(gen_random_bytes(16),'hex'),
  valid_until    date,
  status         text not null default 'rascunho',
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now(),
  constraint ops_advisor_briefings_status_ck
    check (status in ('rascunho','enviado','aberto','respondido','expirado'))
);

comment on table ops_advisor_briefings is
  'Briefing que a TL manda para a advisor responder por link. Não confundir '
  'com ops_briefings, que é o briefing interno da oportunidade.';
comment on column ops_advisor_briefings.valid_until is
  'Último dia em que o link funciona. Em branco, não vence. A conferência é '
  'na função, não só na tela.';

create table if not exists ops_advisor_questions (
  id          uuid primary key default gen_random_uuid(),
  briefing_id uuid not null references ops_advisor_briefings(id) on delete cascade,
  sort        int not null default 0,
  kind        text not null,
  label       text not null,                 -- em inglês: é o que a advisor lê
  options     jsonb not null default '[]'::jsonb,
  max_choices int,
  required    boolean not null default false,
  constraint ops_advisor_questions_kind_ck
    check (kind in ('escolha_unica','escolha_multipla','sim_nao','texto'))
);
create index if not exists ops_advisor_questions_brief_idx
  on ops_advisor_questions (briefing_id, sort);

-- Uma linha por envio. NUNCA se atualiza: é o retrato do que a advisor
-- mandou naquele dia, e é o que sustenta "o passado não se mexe".
create table if not exists ops_advisor_answers (
  id          uuid primary key default gen_random_uuid(),
  briefing_id uuid not null references ops_advisor_briefings(id) on delete cascade,
  version     int not null,
  answers     jsonb not null default '{}'::jsonb,   -- { pergunta_id: valor }
  notes       text,
  sent_at     timestamptz not null default now(),
  unique (briefing_id, version)
);

create table if not exists ops_advisor_opens (
  id          uuid primary key default gen_random_uuid(),
  briefing_id uuid not null references ops_advisor_briefings(id) on delete cascade,
  opened_at   timestamptz not null default now(),
  user_agent  text
);
create index if not exists ops_advisor_opens_brief_idx
  on ops_advisor_opens (briefing_id, opened_at desc);

-- 2) RLS: quem está logado mexe, anon não enxerga nada --------------
-- A advisor não fala com as tabelas. Ela passa pelas duas funções tl_,
-- que só enxergam o briefing do token recebido.
do $$
declare t text;
begin
  foreach t in array array['ops_advisor_briefings','ops_advisor_questions',
                           'ops_advisor_answers','ops_advisor_opens']
  loop
    execute format('alter table %I enable row level security', t);
    execute format('drop policy if exists "auth_all" on %I', t);
    execute format('create policy "auth_all" on %I for all to authenticated using (true) with check (true)', t);
    execute format('revoke all on %I from anon', t);
  end loop;
end $$;

-- 3) LER O BRIEFING PELO TOKEN ---------------------------------------
-- Devolve o briefing, as perguntas e a ÚLTIMA versão de respostas, para a
-- página abrir preenchida. Registra a abertura e, na primeira, move o
-- status de enviado para aberto.
--
-- Vencido não devolve conteúdo nenhum — nem o briefing, nem as perguntas,
-- nem o que já foi respondido. A tela não teria o que esconder porque não
-- recebe. É o mesmo desenho do link da proposta.
create or replace function tl_get_advisor_briefing(p_token text, p_ua text default null)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare b ops_advisor_briefings%rowtype; perg jsonb; ult ops_advisor_answers%rowtype;
begin
  select * into b from ops_advisor_briefings where token = p_token;
  if not found then return null; end if;

  if b.valid_until is not null and b.valid_until < current_date then
    -- Marca o vencimento quando alguém tenta abrir, para a lista interna
    -- refletir o que já aconteceu sem precisar de rotina agendada.
    if b.status <> 'expirado' then
      update ops_advisor_briefings set status = 'expirado', updated_at = now() where id = b.id;
    end if;
    return jsonb_build_object('expired', true, 'valid_until', b.valid_until);
  end if;

  insert into ops_advisor_opens (briefing_id, user_agent) values (b.id, left(coalesce(p_ua,''), 400));
  if b.status = 'enviado' then
    update ops_advisor_briefings set status = 'aberto', updated_at = now() where id = b.id;
    b.status := 'aberto';
  end if;

  select coalesce(jsonb_agg(jsonb_build_object(
           'id', q.id, 'kind', q.kind, 'label', q.label,
           'options', q.options, 'max_choices', q.max_choices,
           'required', q.required) order by q.sort, q.id), '[]'::jsonb)
    into perg from ops_advisor_questions q where q.briefing_id = b.id;

  select * into ult from ops_advisor_answers a
   where a.briefing_id = b.id order by a.version desc limit 1;

  -- Campo a campo, como as outras funções públicas do hub: coluna nova não
  -- vaza para a advisor só por ter sido acrescentada à tabela.
  return jsonb_build_object(
    'briefing', jsonb_build_object(
      'title', b.title, 'content', b.content,
      'valid_until', b.valid_until, 'status', b.status,
      'advisor_name', b.advisor_name, 'agency', b.agency),
    'questions', perg,
    'last', case when ult.id is null then null else jsonb_build_object(
      'version', ult.version, 'answers', ult.answers,
      'notes', ult.notes, 'sent_at', ult.sent_at) end);
end $$;

revoke all on function tl_get_advisor_briefing(text, text) from public;
grant execute on function tl_get_advisor_briefing(text, text) to anon, authenticated;

-- 4) RECEBER AS RESPOSTAS ---------------------------------------------
-- Confere aqui, e não só na tela: tela se contorna com o console aberto.
-- O que é conferido: prazo, obrigatórias, limite de escolhas, e um envio
-- por minuto para o clique repetido não virar duas versões.
create or replace function tl_submit_advisor_briefing(p_token text, p_payload jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  b        ops_advisor_briefings%rowtype;
  q        ops_advisor_questions%rowtype;
  v        jsonb;
  faltam   text[] := '{}';
  demais   text[] := '{}';
  nova     int;
  c        ops_notify_config%rowtype;
  corpo    text := '';
  req_id   bigint;
begin
  select * into b from ops_advisor_briefings where token = p_token;
  if not found then return jsonb_build_object('ok', false, 'error', 'not_found'); end if;

  if b.valid_until is not null and b.valid_until < current_date then
    update ops_advisor_briefings set status = 'expirado', updated_at = now() where id = b.id;
    return jsonb_build_object('ok', false, 'error', 'expired');
  end if;

  -- Um envio por minuto por briefing. Clique repetido não vira duas versões.
  if exists (select 1 from ops_advisor_answers a
              where a.briefing_id = b.id and a.sent_at > now() - interval '1 minute') then
    return jsonb_build_object('ok', false, 'error', 'too_soon');
  end if;

  for q in select * from ops_advisor_questions where briefing_id = b.id order by sort, id loop
    v := p_payload -> 'answers' -> (q.id::text);

    if q.required and (v is null or v = 'null'::jsonb
         or (jsonb_typeof(v) = 'string' and btrim(v #>> '{}') = '')
         or (jsonb_typeof(v) = 'array'  and jsonb_array_length(v) = 0)) then
      faltam := faltam || q.label;
    end if;

    if q.kind = 'escolha_multipla' and q.max_choices is not null
       and jsonb_typeof(v) = 'array' and jsonb_array_length(v) > q.max_choices then
      demais := demais || q.label;
    end if;
  end loop;

  if array_length(faltam, 1) is not null then
    return jsonb_build_object('ok', false, 'error', 'missing', 'fields', to_jsonb(faltam));
  end if;
  if array_length(demais, 1) is not null then
    return jsonb_build_object('ok', false, 'error', 'too_many', 'fields', to_jsonb(demais));
  end if;

  select coalesce(max(version), 0) + 1 into nova
    from ops_advisor_answers where briefing_id = b.id;

  insert into ops_advisor_answers (briefing_id, version, answers, notes)
  values (b.id, nova,
          coalesce(p_payload -> 'answers', '{}'::jsonb),
          nullif(btrim(coalesce(p_payload ->> 'notes', '')), ''));

  update ops_advisor_briefings set status = 'respondido', updated_at = now() where id = b.id;

  -- Aviso por e-mail, pelo mesmo caminho da confirmação da order. Falhando
  -- o e-mail, a resposta fica gravada assim mesmo.
  select * into c from ops_notify_config where id = 1;
  if found and c.enabled is true and coalesce(c.resend_key,'') <> '' then
    select string_agg(
             '<tr><td style="padding:4px 14px 4px 0;color:#6b6860;vertical-align:top;">'
             || tl_html(x.label) || '</td><td style="padding:4px 0;vertical-align:top;">'
             || tl_html(x.valor) || '</td></tr>', '')
      into corpo
      from (
        select q2.label,
               case when jsonb_typeof(p_payload -> 'answers' -> (q2.id::text)) = 'array'
                    then (select string_agg(e #>> '{}', ' · ')
                            from jsonb_array_elements(p_payload -> 'answers' -> (q2.id::text)) e)
                    else coalesce(p_payload -> 'answers' ->> (q2.id::text), '—') end as valor,
               q2.sort, q2.id
          from ops_advisor_questions q2 where q2.briefing_id = b.id
         order by q2.sort, q2.id) x;

    select net.http_post(
      url     := 'https://api.resend.com/emails',
      headers := jsonb_build_object('Content-Type','application/json',
                   'Authorization', 'Bearer ' || c.resend_key),
      body    := jsonb_build_object(
        'from', c.mail_from,
        'to',   to_jsonb(array[c.mail_to]),
        'subject', 'Briefing respondido · ' || b.title || ' · versão ' || nova,
        'html', '<div style="font-family:Helvetica,Arial,sans-serif;color:#2a2a28;font-size:14px;">'
             || '<p style="color:#595e49;font-weight:500;letter-spacing:.18em;text-transform:uppercase;'
             || 'font-size:11px;margin:0 0 14px;">Tuscan Lands · briefing da advisor</p>'
             || '<p style="margin:0 0 4px;font-size:17px;">' || tl_html(b.title) || '</p>'
             || '<p style="margin:0 0 18px;color:#6b6860;">'
             || tl_html(coalesce(b.advisor_name,'—'))
             || case when coalesce(b.agency,'') <> '' then ' · ' || tl_html(b.agency) else '' end
             || ' · versão ' || nova || '</p>'
             || '<table style="border-collapse:collapse;">' || coalesce(corpo,'') || '</table>'
             || case when coalesce(nullif(btrim(coalesce(p_payload ->> 'notes','')),''),'') <> ''
                     then '<p style="margin:18px 0 0;"><span style="color:#6b6860;">Observações</span><br>'
                          || tl_html(p_payload ->> 'notes') || '</p>' else '' end
             || '</div>')
    ) into req_id;
  end if;

  return jsonb_build_object('ok', true, 'version', nova);
end $$;

revoke all on function tl_submit_advisor_briefing(text, jsonb) from public;
grant execute on function tl_submit_advisor_briefing(text, jsonb) to anon, authenticated;

-- 5) PRORROGAR A VALIDADE SEM TROCAR O LINK ---------------------------
-- Pedido da especificação. O status volta para o que fazia sentido antes:
-- respondido se já houve resposta, aberto se já foi aberto, enviado se não.
create or replace function tl_extend_advisor_briefing(p_id uuid, p_until date)
returns text
language plpgsql
security definer
set search_path = public
as $$
declare novo text;
begin
  select case
           when exists (select 1 from ops_advisor_answers a where a.briefing_id = p_id) then 'respondido'
           when exists (select 1 from ops_advisor_opens  o where o.briefing_id = p_id) then 'aberto'
           else 'enviado' end into novo;
  update ops_advisor_briefings
     set valid_until = p_until, status = novo, updated_at = now()
   where id = p_id;
  return novo;
end $$;

revoke all on function tl_extend_advisor_briefing(uuid, date) from public;
grant execute on function tl_extend_advisor_briefing(uuid, date) to authenticated;

insert into ops_migrations (id) values ('0054-briefing-da-advisor') on conflict (id) do nothing;
