-- =====================================================================
-- TUSCAN LANDS · HUB DE VENDAS E OPERAÇÕES
-- AVISO POR E-MAIL QUANDO A AGÊNCIA CONFIRMA
--
-- Rodar DEPOIS de tl-hub-orders.sql, no mesmo projeto Supabase.
--
-- Por que assim: o próprio banco manda o e-mail, via pg_net. Não precisa
-- de servidor, nem de Edge Function, nem de ferramenta nova na sua
-- máquina. Só de uma chave da Resend, que é grátis até 3 mil e-mails/mês.
--
-- REGRA QUE NÃO SE NEGOCIA: se o e-mail falhar, a confirmação da agência
-- é gravada de qualquer jeito. Perder o dado do cliente porque o e-mail
-- não saiu seria trocar um problema por um pior. Todo o envio está dentro
-- de um bloco que engole exceção, e o pg_net só dispara depois do commit.
-- =====================================================================

create extension if not exists pg_net with schema extensions;

-- ---------------------------------------------------------------------
-- Valor em euro no padrão da casa: € 1.710,00
-- Não usa os marcadores G e D do to_char, que seguem o locale do
-- servidor e sairiam como "1,710.00". Os literais "," e "." são
-- independentes de locale, então trocamos os dois no fim.
-- ---------------------------------------------------------------------
create or replace function tl_eur(v numeric)
returns text language sql immutable as $$
  select '€ ' || translate(to_char(coalesce(v,0), 'FM999,999,990.00'), ',.', '.,');
$$;

-- ---------------------------------------------------------------------
-- CONFIGURAÇÃO
-- RLS ligada e NENHUMA policy: nem anon nem authenticated conseguem ler.
-- A chave da Resend não vaza para o navegador. Só o service_role e o
-- postgres, que ignoram RLS, enxergam. Ver teste no fim do arquivo.
-- ---------------------------------------------------------------------
create table if not exists ops_notify_config (
  id          int primary key default 1,
  resend_key  text,                       -- re_xxxxxxxx
  mail_from   text not null default 'Tuscan Lands <onboarding@resend.dev>',
  mail_to     text not null default 'booking@tuscanlandstravel.com',
  enabled     boolean not null default true,
  updated_at  timestamptz not null default now(),
  constraint ops_notify_config_singleton check (id = 1)
);

alter table ops_notify_config enable row level security;
-- proposital: nenhuma policy criada.

-- ---------------------------------------------------------------------
-- REGISTRO DOS ENVIOS
-- O pg_net apaga a resposta dele depois de 6 horas. Aqui fica o rastro
-- permanente: o que foi enviado, quando, e se deu erro.
-- ---------------------------------------------------------------------
create table if not exists ops_notifications (
  id            uuid primary key default gen_random_uuid(),
  order_id      uuid references ops_orders(id) on delete set null,
  kind          text not null default 'order_confirmed',
  mail_to       text,
  subject       text,
  net_request_id bigint,                  -- cruzar com net._http_response
  error         text,                     -- nulo = disparou sem erro
  created_at    timestamptz not null default now()
);

create index if not exists ops_notif_order_idx on ops_notifications(order_id);
create index if not exists ops_notif_created_idx on ops_notifications(created_at desc);

alter table ops_notifications enable row level security;
drop policy if exists "auth_read" on ops_notifications;
-- você, logada, precisa ver o histórico de avisos na tela.
create policy "auth_read" on ops_notifications
  for select to authenticated using (true);

-- =====================================================================
-- O GATILHO
-- =====================================================================
create or replace function tl_notify_confirmation()
returns trigger
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  c        ops_notify_config%rowtype;
  o        ops_orders%rowtype;
  linhas   text := '';
  total    numeric(12,2) := 0;
  pax      text;
  assunto  text;
  corpo    text;
  req_id   bigint;
begin
  select * into c from ops_notify_config where id = 1;

  -- Sem configuração ou desligado: não faz nada e não reclama.
  if not found or c.enabled is not true
     or coalesce(c.resend_key,'') = '' then
    return new;
  end if;

  select * into o from ops_orders where id = new.order_id;
  if not found then return new; end if;

  select coalesce(sum(i.price),0) into total
    from ops_order_items i where i.order_id = o.id;

  select string_agg(
           '<tr><td style="padding:4px 10px 4px 0;">' || coalesce(i.service_date,'') ||
           '</td><td style="padding:4px 10px 4px 0;">' || i.title ||
           '</td><td style="padding:4px 0;text-align:right;">' ||
           tl_eur(i.price) || '</td></tr>',
           '' order by i.sort)
    into linhas
    from ops_order_items i where i.order_id = o.id;

  pax := coalesce(jsonb_array_length(new.adults),0)::text || ' adulto(s)'
         || case when coalesce(jsonb_array_length(new.children),0) > 0
                 then ' + ' || jsonb_array_length(new.children)::text || ' criança(s)'
                 else '' end;

  assunto := 'Order confirmada · ' || coalesce(o.order_ref,'')
             || ' · ' || coalesce(o.final_client, o.agency, 'cliente');

  corpo :=
    '<div style="font-family:Helvetica,Arial,sans-serif;font-size:14px;color:#2a2a28;">'
    || '<p style="font-size:11px;letter-spacing:.18em;text-transform:uppercase;color:#595e49;margin:0 0 14px;">Tuscan Lands · confirmação recebida</p>'
    || '<p><strong>' || coalesce(o.final_client, o.agency, '') || '</strong><br>'
    || 'Order ' || coalesce(o.order_ref,'') || ' · oportunidade ' || coalesce(o.opportunity_code,'—') || '<br>'
    || 'Agência: ' || coalesce(o.agency,'—') || '<br>'
    || 'Período: ' || coalesce(o.travel_window,'—') || '</p>'
    || '<p>Assinado por <strong>' || coalesce(new.signature_name, new.lead_name, '—') || '</strong><br>'
    || 'Contato: ' || coalesce(new.lead_email,'—') || ' · ' || coalesce(new.lead_phone,'—') || '<br>'
    || 'Passageiros informados: ' || pax || '</p>'
    || case when coalesce(new.remarks,'') <> ''
            then '<p>Observações da agência:<br><em>' || new.remarks || '</em></p>'
            else '' end
    || '<table style="border-collapse:collapse;margin:16px 0;">' || coalesce(linhas,'') || '</table>'
    || '<p><strong>Total: ' || tl_eur(total) || '</strong></p>'
    || '<p style="font-size:12px;color:#6b6860;">Aviso automático do hub. Abra o hub para ver os nomes completos dos passageiros.</p>'
    || '</div>';

  -- O envio inteiro protegido: qualquer falha aqui NÃO desfaz a
  -- confirmação da agência. Registra o erro e segue.
  begin
    select net.http_post(
      url     := 'https://api.resend.com/emails',
      headers := jsonb_build_object(
                   'Content-Type',  'application/json',
                   'Authorization', 'Bearer ' || c.resend_key),
      body    := jsonb_build_object(
                   'from',    c.mail_from,
                   'to',      string_to_array(c.mail_to, ','),
                   'subject', assunto,
                   'html',    corpo),
      timeout_milliseconds := 8000
    ) into req_id;

    insert into ops_notifications (order_id, mail_to, subject, net_request_id)
    values (o.id, c.mail_to, assunto, req_id);

  exception when others then
    insert into ops_notifications (order_id, mail_to, subject, error)
    values (o.id, c.mail_to, assunto, sqlerrm);
  end;

  return new;
end $$;

drop trigger if exists ops_confirmation_notify on ops_order_confirmations;
create trigger ops_confirmation_notify
  after insert on ops_order_confirmations
  for each row execute function tl_notify_confirmation();

-- =====================================================================
-- CONFERIR SE O E-MAIL SAIU MESMO
-- O pg_net é assíncrono: ele devolve um número de pedido e sai. Para ver
-- o que a Resend respondeu, rode isto nas primeiras 6 horas.
-- 200 = enviado. 401 = chave errada. 403 = remetente não verificado.
-- =====================================================================
create or replace view ops_notifications_status as
select
  n.created_at,
  n.subject,
  n.mail_to,
  n.error                              as erro_no_disparo,
  r.status_code                        as resposta_resend,
  r.content                            as detalhe_resend
from ops_notifications n
left join net._http_response r on r.id = n.net_request_id
order by n.created_at desc;

revoke all on ops_notifications_status from anon;
grant select on ops_notifications_status to authenticated;

-- =====================================================================
-- COMO LIGAR (rodar uma vez, com a sua chave)
--
--   insert into ops_notify_config (id, resend_key, mail_to)
--   values (1, 're_SUA_CHAVE_AQUI', 'booking@tuscanlandstravel.com')
--   on conflict (id) do update
--     set resend_key = excluded.resend_key,
--         mail_to    = excluded.mail_to,
--         updated_at = now();
--
-- Enquanto a chave não estiver aqui, o gatilho não faz nada e a
-- confirmação da agência continua sendo gravada normalmente.
--
-- Remetente: 'onboarding@resend.dev' funciona sem verificar domínio, mas
-- só entrega no e-mail dono da conta Resend. Para enviar para
-- booking@tuscanlandstravel.com de verdade, verifique o domínio na
-- Resend e troque mail_from para algo como
-- 'Tuscan Lands <hub@tuscanlandstravel.com>'.
-- =====================================================================
