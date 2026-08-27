-- =====================================================================
-- 0027 · ACABA O GRUPO DE ESCOLHA
--
-- Instrução dela em agosto/26, olhando a proposta no ar: não existe
-- "escolha uma opção". O cliente aprova este serviço E aqueles outros,
-- e cada linha tem de ficar aberta para marcar e desmarcar.
--
-- Isso tira a exclusividade das DUAS pontas. A tela já não desenha a
-- etiqueta nem desmarca as irmãs; aqui sai a conferência que recusava o
-- envio quando um grupo ficava sem nenhuma linha marcada. Deixar só a
-- do banco seria o pior dos mundos: a tela não fala de grupo nenhum, e
-- o cliente levaria um "falta escolher em: hotel_umbria" sem ter como
-- entender o que é.
--
-- choice_group continua na tabela e nas respostas já gravadas — o que
-- foi respondido não se reescreve. O que zera é o valor nas linhas de
-- proposta, que a partir de agora não quer dizer nada.
--
-- Só toca em objetos ops_. Nada fora desse prefixo.
-- =====================================================================

update ops_proposal_items set choice_group = null where choice_group is not null;

comment on column ops_proposal_items.choice_group is
  'Sem uso desde 0027: o grupo de escolha acabou. Fica pela resposta antiga que o gravou.';


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

insert into ops_migrations (id) values ('0027-acaba-o-grupo-de-escolha') on conflict (id) do nothing;
