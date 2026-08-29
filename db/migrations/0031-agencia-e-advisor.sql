-- =====================================================================
-- 0031 · AGÊNCIA É EMPRESA, ADVISOR É PESSOA
--
-- O bloco de envio da proposta white label pedia "Travel agent" e
-- "Travel designer". Instrução dela em agosto/26: agent e advisor são
-- a MESMA COISA — as duas caixas pediam pessoa, e uma delas devia ser
-- a agência, que é empresa.
--
-- Então:
--   agency_name  (novo) — o nome do business. Não é obrigatório: a
--                         agência já está na oportunidade, e o campo é
--                         confirmação, não descoberta.
--   lead_name    (já existe) — a PESSOA. Continua obrigatório: é quem
--                         respondeu, e é o que o e-mail e o editor
--                         mostram. Agent, advisor e agente de viagens
--                         são a mesma pessoa; o rótulo é que muda.
--
-- designer_name NÃO é apagado. A tela para de pedir, a coluna fica, e
-- as respostas já gravadas continuam sendo exibidas — resposta antiga
-- não se reescreve. Mesmo tratamento que choice_group teve na 0027.
--
-- Só toca em objetos ops_. Nada fora desse prefixo.
-- =====================================================================

alter table ops_proposal_selections add column if not exists agency_name text;
comment on column ops_proposal_selections.agency_name is
  'Nome da agência (empresa) informado por quem respondeu. lead_name é '
  'a pessoa. Opcional: a agência já vem da oportunidade.';

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

  -- Sem grupo de escolha: cada linha entra ou não entra por si. O que
  -- continua sendo cobrado é ter pelo menos uma marcada, lá embaixo.

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

  -- lead_name é a PESSOA que respondeu — o travel agent, que é a mesma
  -- coisa que o advisor. agency_name é a EMPRESA dela. designer_name
  -- continua sendo gravado quando vier, para não perder resposta antiga
  -- que ainda mande o campo, mas a tela não pede mais.
  insert into ops_proposal_selections
    (proposal_id, lead_name, agency_name, designer_name, lead_email, lead_phone, remarks,
     lines, total, ack_conditions, payment_choice, confirm_mode)
  values (pp.id, nullif(btrim(coalesce(p_payload->>'lead_name','')),''),
          nullif(btrim(coalesce(p_payload->>'agency_name','')),''),
          nullif(btrim(coalesce(p_payload->>'designer_name','')),''),
          p_payload->>'lead_email',
          p_payload->>'lead_phone', p_payload->>'remarks', linhas, soma, true,
          case when simples then null else p_payload->>'payment_choice' end,
          case when simples then 'simple' else 'full' end);

  update ops_proposals set responded_at = now(), updated_at = now() where id = pp.id;
  return jsonb_build_object('ok', true);
end $$;

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

  -- No bloco simples não há nome: quem respondeu é a agência da
  -- oportunidade, e é ela que vai no assunto.
  assunto := case when new.confirm_mode = 'simple' then 'Interesse confirmado · ' else 'Quote respondida · ' end
             || coalesce(o.crm_code, pp.title, '')
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
    || case when new.confirm_mode = 'simple'
            then '<p>Interesse confirmado por <strong>' || tl_html(coalesce(new.lead_name, o.agency, '—'))
                 || '</strong><br><span style="color:#6b6860;font-size:12px;">'
                 || 'Proposta enviada com o bloco simples: só a confirmação de interesse.</span></p>'
            else '<p>Respondida por <strong>' || tl_html(coalesce(new.lead_name,'—')) || '</strong><br>'
                 || case when coalesce(new.agency_name,'') <> ''
                         then 'Agência: ' || tl_html(new.agency_name) || '<br>' else '' end
                 || case when coalesce(new.designer_name,'') <> ''
                         then 'Travel designer: ' || tl_html(new.designer_name) || '<br>' else '' end
                 || 'Contato: ' || tl_html(coalesce(new.lead_email,'—')) || ' · '
                 || tl_html(coalesce(new.lead_phone,'—')) || '</p>' end
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

revoke all on function tl_submit_quote(text, jsonb) from public;
grant execute on function tl_submit_quote(text, jsonb) to anon, authenticated;

insert into ops_migrations (id) values ('0031-agencia-e-advisor') on conflict (id) do nothing;
