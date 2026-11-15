-- =====================================================================
-- 0145 · O AVISO DE ORDER CONFIRMADA NO IDIOMA DA ORDER, E SEM
--        DESCONFIGURAR — SÓ TROCA FUNÇÃO
--
-- Teste de verdade da Services Confirmation da TL-053-26 (15/11/26): o
-- e-mail chegou, mas "desconfigurado" — e ela: "o e-mail tem que ser 100%
-- em inglês".
--
--   · Desconfigurado: em "Dados do checkout" a pergunta ficava numa
--     coluna com white-space:nowrap. A pergunta do carro tem ~180
--     caracteres, a tabela ficava larguíssima e empurrava as respostas
--     para fora da tela. Agora cada pergunta sai numa linha e a resposta
--     embaixo, sem tabela. Quebra de linha da pergunta vale.
--   · Idioma: o aviso era todo em português e lia só label_pt. Agora
--     segue ops_orders.lang: order em inglês → e-mail inteiro em inglês
--     (títulos, rótulos, assunto, pergunta com label_en, status das
--     parcelas, data por extenso em en-US); order em português → como
--     antes.
--   · Data de nascimento sai por extenso ("January 1, 1980" / "01/01/1980")
--     quando vem no formato AAAA-MM-DD; fora dele, sai como veio.
--
-- O resto é igual: mesmos dados, mesma ordem, o envio continua protegido
-- (falha no e-mail não desfaz a confirmação) e o registro em
-- ops_notifications é o mesmo. E-mail já enviado não muda.
--
-- Seção 7: só troca de função. Sem update, sem delete. Nenhuma tabela do
-- CRM.
-- =====================================================================

create or replace function public.tl_notify_confirmation()
returns trigger
language plpgsql
security definer
set search_path to 'public', 'extensions'
as $function$
declare
  c        ops_notify_config%rowtype;
  o        ops_orders%rowtype;
  ing      boolean;
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
  h_tit    constant text := 'style="font-size:11px;letter-spacing:.16em;text-transform:uppercase;color:#595e49;margin:22px 0 6px;"';
begin
  select * into c from ops_notify_config where id = 1;

  -- Sem configuração ou desligado: não faz nada e não reclama.
  if not found or c.enabled is not true
     or coalesce(c.resend_key,'') = '' then
    return new;
  end if;

  select * into o from ops_orders where id = new.order_id;
  if not found then return new; end if;
  ing := coalesce(o.lang,'pt') = 'en';

  select coalesce(sum(i.price),0) into total
    from ops_order_items i where i.order_id = o.id;

  select string_agg(
           '<tr><td style="padding:4px 12px 4px 0;color:#595e49;white-space:nowrap;vertical-align:top;">'
           || tl_html(coalesce(i.service_date,'')) ||
           '</td><td style="padding:4px 12px 4px 0;vertical-align:top;">' || tl_html(i.title) ||
           case when coalesce(i.details,'') <> ''
                then '<br><span style="color:#6b6860;font-size:12px;">'
                     || replace(tl_html(i.details), E'\n', '<br>') || '</span>'
                else '' end ||
           '</td><td style="padding:4px 0;text-align:right;white-space:nowrap;vertical-align:top;">' ||
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
           || case when p.status = 'paid' then (case when ing then 'paid' else 'pago' end)
                   else (case when ing then 'due' else 'a pagar' end) end ||
           '</td></tr>', '' order by p.sort)
    into parcelas
    from ops_order_payments p where p.order_id = o.id;

  -- Nomes exatamente como a agência digitou: é isto que vai para a
  -- reserva no fornecedor, e é aqui que o erro de grafia aparece enquanto
  -- ainda dá para corrigir.
  select string_agg(
           '<tr><td ' || h_lbl || '>' || tl_html(t.value->>'name') ||
           '</td><td ' || h_val || '>' ||
           case when coalesce(t.value->>'dob','') ~ '^\d{4}-\d{2}-\d{2}$'
                then case when ing then to_char((t.value->>'dob')::date, 'FMMonth FMDD, YYYY')
                          else to_char((t.value->>'dob')::date, 'DD/MM/YYYY') end
                else tl_html(coalesce(t.value->>'dob','')) end
           || '</td></tr>', '')
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

  -- Campos variáveis daquele checkout, na ordem em que foram mostrados:
  -- a pergunta numa linha e a resposta embaixo (pergunta longa numa coluna
  -- sem quebra desconfigurava o e-mail). Pré-preenchido vem marcado.
  select string_agg(
           '<p style="margin:12px 0 2px;color:#6b6860;font-size:13px;">'
           || replace(tl_html(case when ing then coalesce(nullif(f.value->>'label_en',''), f.value->>'label_pt')
                                   else f.value->>'label_pt' end), E'\n', '<br>')
           || case when (f.value->>'mode') = 'prefilled'
                   then ' <span style="color:#a56850;">' || case when ing then '(prefilled)' else '(pré-preenchido)' end || '</span>'
                   else '' end
           || '</p><p style="margin:0;">'
           || coalesce(nullif(replace(tl_html(f.value->>'value'), E'\n','<br>'),''),
                       '<span style="color:#a2564c;">' || case when ing then '— left blank' else '— em branco' end || '</span>')
           || '</p>', '' order by f.ord)
    into campos
    from jsonb_array_elements(coalesce(new.fields,'[]'::jsonb)) with ordinality as f(value, ord);

  assunto := case when ing then 'Order confirmed · ' else 'Order confirmada · ' end
             || coalesce(o.order_ref,'')
             || ' · ' || coalesce(o.final_client, o.agency, case when ing then 'client' else 'cliente' end);

  corpo :=
    '<div style="font-family:''Libre Franklin'',Helvetica,Arial,sans-serif;font-size:14px;line-height:1.6;color:#2a2a28;max-width:640px;">'
    || '<p style="font-size:11px;letter-spacing:.2em;text-transform:uppercase;color:#595e49;margin:0 0 4px;">'
    || case when ing then 'Tuscan Lands · confirmation received' else 'Tuscan Lands · confirmação recebida' end || '</p>'
    || '<div style="width:30px;height:1px;background:#a56850;margin:0 0 18px;"></div>'

    || '<p style="margin:0 0 18px;"><strong style="font-size:17px;">'
    || tl_html(coalesce(o.final_client, o.agency, '')) || '</strong><br>'
    || 'Order ' || tl_html(coalesce(o.order_ref,''))
    || case when ing then ' · opportunity ' else ' · oportunidade ' end
    || tl_html(coalesce(o.opportunity_code,'—')) || '<br>'
    || case when ing then 'Agency: ' else 'Agência: ' end || tl_html(coalesce(o.agency,'—'))
    || case when coalesce(o.agency_contact,'') <> ''
            then ' · ' || tl_html(o.agency_contact) else '' end || '<br>'
    || case when ing then 'Travel dates: ' else 'Período: ' end || tl_html(coalesce(o.travel_window,'—')) || '</p>'

    || '<p ' || h_tit || '>' || case when ing then 'Acceptance' else 'Aceite' end || '</p>'
    || '<table style="border-collapse:collapse;font-size:14px;">'
    || '<tr><td ' || h_lbl || '>' || case when ing then 'Confirmed by' else 'Confirmado por' end
    || '</td><td ' || h_val || '><strong>'
    || tl_html(coalesce(new.lead_name, new.signature_name, '—')) || '</strong></td></tr>'
    || '<tr><td ' || h_lbl || '>' || case when ing then 'Date and time' else 'Data e hora' end
    || '</td><td ' || h_val || '>'
    || case when ing then to_char(new.submitted_at at time zone 'Europe/Rome', 'FMMonth FMDD, YYYY HH24:MI') || ' (Italy time)'
            else to_char(new.submitted_at at time zone 'Europe/Rome', 'DD/MM/YYYY HH24:MI') || ' (Itália)' end
    || '</td></tr>'
    || '<tr><td ' || h_lbl || '>' || case when ing then 'Terms and conditions' else 'Aceite dos termos' end
    || '</td><td ' || h_val || '>'
    || case when new.ack_terms then (case when ing then 'accepted' else 'aceito' end)
            else '<span style="color:#a2564c;">' || case when ing then 'NOT accepted' else 'NÃO aceito' end || '</span>' end
    || '</td></tr>'
    || '<tr><td ' || h_lbl || '>' || case when ing then 'Vehicle and luggage' else 'Veículo e bagagem' end
    || '</td><td ' || h_val || '>'
    || case when new.ack_vehicle then (case when ing then 'accepted' else 'aceito' end)
            else (case when ing then 'not ticked' else 'não marcado' end) end || '</td></tr>'
    || case when coalesce(o.terms_url,'') <> ''
            then '<tr><td ' || h_lbl || '>' || case when ing then 'Published terms' else 'Termos publicados' end
                 || '</td><td ' || h_val || '><a href="'
                 || tl_html(o.terms_url) || '" style="color:#595e49;">'
                 || tl_html(o.terms_url) || '</a></td></tr>'
            else '' end
    || '</table>'

    || '<p ' || h_tit || '>' || case when ing then 'Contact during the trip' else 'Contato responsável' end || '</p>'
    || '<table style="border-collapse:collapse;font-size:14px;">'
    || '<tr><td ' || h_lbl || '>' || case when ing then 'Name' else 'Nome' end
    || '</td><td ' || h_val || '>' || tl_html(coalesce(new.lead_name,'—')) || '</td></tr>'
    || '<tr><td ' || h_lbl || '>E-mail</td><td ' || h_val || '>' || tl_html(coalesce(new.lead_email,'—')) || '</td></tr>'
    || '<tr><td ' || h_lbl || '>' || case when ing then 'Phone' else 'Telefone' end
    || '</td><td ' || h_val || '>' || tl_html(coalesce(new.lead_phone,'—')) || '</td></tr>'
    || '</table>'

    || '<p ' || h_tit || '>' || case when ing then 'Travellers · name and date of birth' else 'Viajantes · nome e nascimento' end || '</p>'
    || '<table style="border-collapse:collapse;font-size:14px;">'
    || coalesce(viajantes, '<tr><td>—</td></tr>')
    || '</table>'

    || case when coalesce(campos,'') <> ''
            then '<p ' || h_tit || '>' || case when ing then 'Answers' else 'Dados do checkout' end || '</p>'
                 || campos
            else '' end

    || case when coalesce(new.remarks,'') <> ''
            then '<p ' || h_tit || '>' || case when ing then 'Remarks' else 'Observações da agência' end || '</p>'
                 || '<p style="margin:0;">' || replace(tl_html(new.remarks), E'\n','<br>') || '</p>'
            else '' end

    || '<p ' || h_tit || '>' || case when ing then 'Services' else 'Serviços' end || '</p>'
    || '<table style="border-collapse:collapse;font-size:14px;width:100%;">' || coalesce(linhas,'') || '</table>'
    || '<p style="margin:10px 0 0;text-align:right;"><strong>Total ' || tl_eur(total) || '</strong></p>'

    || case when coalesce(parcelas,'') <> '' or coalesce(o.payment_note,'') <> ''
            then '<p ' || h_tit || '>' || case when ing then 'Payments' else 'Pagamentos' end || '</p>'
                 || case when coalesce(parcelas,'') <> ''
                         then '<table style="border-collapse:collapse;font-size:14px;width:100%;">' || parcelas || '</table>'
                         else '' end
                 || case when coalesce(o.payment_note,'') <> ''
                         then '<p style="margin:8px 0 0;color:#6b6860;">'
                              || replace(tl_html(o.payment_note), E'\n','<br>') || '</p>'
                         else '' end
            else '' end

    || '<p style="font-size:11px;color:#6b6860;margin-top:26px;border-top:1px solid #eae4db;padding-top:12px;">'
    || case when ing
            then 'Automatic notice from the hub. The PDF summary to forward to the agency is available from the “Resumo (PDF)” button in the order editor.'
            else 'Aviso automático do hub. O resumo em PDF para encaminhar à agência sai pelo botão “Resumo (PDF)” no editor da order.' end
    || '</p>'
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
end $function$;

insert into ops_migrations (id) values ('0145-aviso-da-order-no-idioma-e-sem-desconfigurar') on conflict (id) do nothing;
