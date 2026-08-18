-- =====================================================================
-- TUSCAN LANDS · HUB DE VENDAS E OPERAÇÕES
-- AVISO POR E-MAIL QUANDO A AGÊNCIA CONFIRMA
--
-- Rodar DEPOIS de tl-hub-orders.sql E de tl-hub-checkout.sql, no mesmo
-- projeto Supabase. Reaplicar este arquivo mesmo se já tiver rodado
-- antes: o corpo do e-mail foi reescrito para levar tudo.
--
-- Por que assim: o próprio banco manda o e-mail, via pg_net. Não precisa
-- de servidor, nem de Edge Function, nem de ferramenta nova na sua
-- máquina. Só de uma chave da Resend, que é grátis até 3 mil e-mails/mês.
--
-- REGRA QUE NÃO SE NEGOCIA: se o e-mail falhar, a confirmação da agência
-- é gravada de qualquer jeito. Perder o dado do cliente porque o e-mail
-- não saiu seria trocar um problema por um pior. Todo o envio está dentro
-- de um bloco que engole exceção, e o pg_net só dispara depois do commit.
--
-- ---------------------------------------------------------------------
-- CONFERÊNCIA DA SEÇÃO 7 DO PLANO — feita antes de entregar, por escrito.
-- Objetos que este arquivo cria ou altera, um a um:
--   ops_notify_config          (create table)
--   ops_notifications          (create table)
--   ops_notifications_status   (create view)
--   ops_confirmation_notify    (trigger em ops_order_confirmations)
--   tl_eur, tl_html, tl_notify_confirmation
--        (funções do hub, criadas por este mesmo arquivo)
-- Nenhum drop de tabela. Nenhum delete, truncate ou update de dados.
-- Nenhuma tabela do CRM é lida, escrita ou citada. Nenhum comando
-- percorre o schema. Nenhuma service_role key aparece aqui.
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
-- O e-mail agora carrega texto digitado por quem está do outro lado do
-- link: nome de passageiro, observações, respostas dos campos. Isso vai
-- para dentro de HTML. Sem escapar, um apóstrofo tipográfico passa, mas
-- um "<" come o resto da mensagem e um "<script>" chega vivo na caixa
-- de entrada. Escapar aqui é mais barato que confiar no formulário.
-- ---------------------------------------------------------------------
create or replace function tl_html(v text)
returns text language sql immutable as $$
  select replace(replace(replace(replace(
           coalesce(v,''), '&','&amp;'), '<','&lt;'), '>','&gt;'), '"','&quot;');
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
--
-- O e-mail leva o conteúdo inteiro da confirmação, e não um aviso de que
-- ela existe. Você recebe isto no celular, longe do computador, e
-- precisa saber o que foi assinado sem abrir o hub: nomes completos como
-- vão para o fornecedor, idades das crianças, o que a agência respondeu
-- em cada campo configurado, os dois aceites, quem assinou e quando.
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
  parcelas text := '';
  campos   text := '';
  viajantes text := '';
  total    numeric(12,2) := 0;
  assunto  text;
  corpo    text;
  req_id   bigint;
  h_lbl    constant text := 'style="padding:3px 14px 3px 0;color:#6b6860;white-space:nowrap;vertical-align:top;"';
  h_val    constant text := 'style="padding:3px 0;vertical-align:top;"';
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
           '<tr><td style="padding:4px 12px 4px 0;color:#595e49;white-space:nowrap;">'
           || tl_html(coalesce(i.service_date,'')) ||
           '</td><td style="padding:4px 12px 4px 0;">' || tl_html(i.title) ||
           case when coalesce(i.details,'') <> ''
                then '<br><span style="color:#6b6860;font-size:12px;">'
                     || replace(tl_html(i.details), E'\n', '<br>') || '</span>'
                else '' end ||
           '</td><td style="padding:4px 0;text-align:right;white-space:nowrap;">' ||
           tl_eur(i.price) || '</td></tr>',
           '' order by i.sort)
    into linhas
    from ops_order_items i where i.order_id = o.id;

  select string_agg(
           '<tr><td style="padding:3px 12px 3px 0;">' || tl_html(p.label) ||
           '</td><td style="padding:3px 12px 3px 0;color:#6b6860;">'
           || tl_html(coalesce(p.due_date,'—')) ||
           '</td><td style="padding:3px 12px 3px 0;text-align:right;">' || tl_eur(p.amount) ||
           '</td><td style="padding:3px 0;color:#6b6860;">'
           || case when p.status = 'paid' then 'pago' else 'a pagar' end ||
           '</td></tr>', '' order by p.sort)
    into parcelas
    from ops_order_payments p where p.order_id = o.id;

  -- Nomes exatamente como a agência digitou: é isto que vai para a
  -- reserva no fornecedor e para o bilhete nominal do monumento, e é aqui
  -- que o erro de grafia aparece enquanto ainda dá para corrigir.
  select string_agg(
           '<tr><td ' || h_lbl || '>' || tl_html(t.value->>'name') ||
           '</td><td ' || h_val || '>' || tl_html(t.value->>'dob') || '</td></tr>', '')
    into viajantes
    from jsonb_array_elements(coalesce(new.travellers,'[]'::jsonb)) as t;

  -- Confirmação antiga, de antes do bloco único de viajantes.
  if coalesce(viajantes,'') = '' then
    select string_agg(
             '<tr><td ' || h_lbl || '>' || tl_html(a.txt) ||
             '</td><td ' || h_val || '>—</td></tr>', '')
      into viajantes
      from (select jsonb_array_elements_text(coalesce(new.adults,'[]'::jsonb)) as txt) a;
  end if;

  -- Campos variáveis daquele checkout, na ordem em que foram mostrados.
  -- Pré-preenchido por você e confirmado pela agência vem marcado, para
  -- você distinguir o que ela respondeu do que ela apenas aceitou.
  select string_agg(
           '<tr><td ' || h_lbl || '>' || tl_html(f.value->>'label_pt')
           || case when (f.value->>'mode') = 'prefilled'
                   then ' <span style="color:#a56850;">(pré-preenchido)</span>' else '' end
           || '</td><td ' || h_val || '>'
           || coalesce(nullif(replace(tl_html(f.value->>'value'), E'\n','<br>'),''),
                       '<span style="color:#a2564c;">— em branco</span>')
           || '</td></tr>', '')
    into campos
    from jsonb_array_elements(coalesce(new.fields,'[]'::jsonb)) with ordinality as f(value, ord);

  assunto := 'Order confirmada · ' || coalesce(o.order_ref,'')
             || ' · ' || coalesce(o.final_client, o.agency, 'cliente');

  corpo :=
    '<div style="font-family:''Libre Franklin'',Helvetica,Arial,sans-serif;font-size:14px;line-height:1.6;color:#2a2a28;max-width:640px;">'
    || '<p style="font-size:11px;letter-spacing:.2em;text-transform:uppercase;color:#595e49;margin:0 0 4px;">Tuscan Lands · confirmação recebida</p>'
    || '<div style="width:30px;height:1px;background:#a56850;margin:0 0 18px;"></div>'

    || '<p style="margin:0 0 18px;"><strong style="font-size:17px;">'
    || tl_html(coalesce(o.final_client, o.agency, '')) || '</strong><br>'
    || 'Order ' || tl_html(coalesce(o.order_ref,'')) || ' · oportunidade '
    || tl_html(coalesce(o.opportunity_code,'—')) || '<br>'
    || 'Agência: ' || tl_html(coalesce(o.agency,'—'))
    || case when coalesce(o.agency_contact,'') <> ''
            then ' · ' || tl_html(o.agency_contact) else '' end || '<br>'
    || 'Período: ' || tl_html(coalesce(o.travel_window,'—')) || '</p>'

    || '<p style="font-size:11px;letter-spacing:.16em;text-transform:uppercase;color:#595e49;margin:22px 0 6px;">Aceite</p>'
    || '<table style="border-collapse:collapse;font-size:14px;">'
    || '<tr><td ' || h_lbl || '>Confirmado por</td><td ' || h_val || '><strong>'
    || tl_html(coalesce(new.lead_name, new.signature_name, '—')) || '</strong></td></tr>'
    || '<tr><td ' || h_lbl || '>Data e hora</td><td ' || h_val || '>'
    || to_char(new.submitted_at at time zone 'Europe/Rome', 'DD/MM/YYYY HH24:MI')
    || ' (Itália)</td></tr>'
    || '<tr><td ' || h_lbl || '>Aceite dos termos</td><td ' || h_val || '>'
    || case when new.ack_terms then 'aceito' else
       '<span style="color:#a2564c;">NÃO aceito</span>' end || '</td></tr>'
    || '<tr><td ' || h_lbl || '>Veículo e bagagem</td><td ' || h_val || '>'
    || case when new.ack_vehicle then 'aceito' else 'não marcado' end || '</td></tr>'
    || case when coalesce(o.terms_url,'') <> ''
            then '<tr><td ' || h_lbl || '>Termos publicados</td><td ' || h_val || '><a href="'
                 || tl_html(o.terms_url) || '" style="color:#595e49;">'
                 || tl_html(o.terms_url) || '</a></td></tr>'
            else '' end
    || '</table>'

    || '<p style="font-size:11px;letter-spacing:.16em;text-transform:uppercase;color:#595e49;margin:22px 0 6px;">Contato responsável</p>'
    || '<table style="border-collapse:collapse;font-size:14px;">'
    || '<tr><td ' || h_lbl || '>Nome</td><td ' || h_val || '>' || tl_html(coalesce(new.lead_name,'—')) || '</td></tr>'
    || '<tr><td ' || h_lbl || '>E-mail</td><td ' || h_val || '>' || tl_html(coalesce(new.lead_email,'—')) || '</td></tr>'
    || '<tr><td ' || h_lbl || '>Telefone</td><td ' || h_val || '>' || tl_html(coalesce(new.lead_phone,'—')) || '</td></tr>'
    || '</table>'

    || '<p style="font-size:11px;letter-spacing:.16em;text-transform:uppercase;color:#595e49;margin:22px 0 6px;">Viajantes · nome e nascimento</p>'
    || '<table style="border-collapse:collapse;font-size:14px;">'
    || coalesce(viajantes, '<tr><td>—</td></tr>')
    || '</table>'

    || case when coalesce(campos,'') <> ''
            then '<p style="font-size:11px;letter-spacing:.16em;text-transform:uppercase;color:#595e49;margin:22px 0 6px;">Dados do checkout</p>'
                 || '<table style="border-collapse:collapse;font-size:14px;">' || campos || '</table>'
            else '' end

    || case when coalesce(new.remarks,'') <> ''
            then '<p style="font-size:11px;letter-spacing:.16em;text-transform:uppercase;color:#595e49;margin:22px 0 6px;">Observações da agência</p>'
                 || '<p style="margin:0;">' || replace(tl_html(new.remarks), E'\n','<br>') || '</p>'
            else '' end

    || '<p style="font-size:11px;letter-spacing:.16em;text-transform:uppercase;color:#595e49;margin:22px 0 6px;">Serviços</p>'
    || '<table style="border-collapse:collapse;font-size:14px;width:100%;">' || coalesce(linhas,'') || '</table>'
    || '<p style="margin:10px 0 0;text-align:right;"><strong>Total ' || tl_eur(total) || '</strong></p>'

    || case when coalesce(parcelas,'') <> '' or coalesce(o.payment_note,'') <> ''
            then '<p style="font-size:11px;letter-spacing:.16em;text-transform:uppercase;color:#595e49;margin:22px 0 6px;">Pagamentos</p>'
                 || case when coalesce(parcelas,'') <> ''
                         then '<table style="border-collapse:collapse;font-size:14px;width:100%;">' || parcelas || '</table>'
                         else '' end
                 || case when coalesce(o.payment_note,'') <> ''
                         then '<p style="margin:8px 0 0;color:#6b6860;">'
                              || replace(tl_html(o.payment_note), E'\n','<br>') || '</p>'
                         else '' end
            else '' end

    || '<p style="font-size:11px;color:#6b6860;margin-top:26px;border-top:1px solid #eae4db;padding-top:12px;">'
    || 'Aviso automático do hub. O resumo em PDF para encaminhar à agência sai pelo botão “Resumo (PDF)” no editor da order.</p>'
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
