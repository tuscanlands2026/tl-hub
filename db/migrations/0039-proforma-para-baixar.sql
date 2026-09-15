-- =====================================================================
-- 0039 — A PROFORMA PARA BAIXAR, COM O LINK VIVO
--
-- Imprimir pela caixa do Windows mata o link de pagamento: o "Microsoft
-- Print to PDF" imprime a página como papel e a âncora não vai para o
-- arquivo. Quem desenha o PDF passa a ser um Chromium sem tela, no
-- servidor — o mesmo caminho do voucher do CRM e do PDF da proposta —,
-- e ele entra pela porta que já existe: o token da order, o mesmo que a
-- agência usa para ver a confirmação.
--
-- Esta função é o que esse navegador lê. Só leitura, e só devolve algo
-- se a proforma JÁ FOI EMITIDA (número gravado na order): documento de
-- cobrança sem número não existe, e emitir número é decisão dela, na
-- tela, não efeito colateral de alguém abrir um link.
-- =====================================================================

create or replace function tl_get_proforma(p_token text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare o ops_orders%rowtype; v_lang text; v_terms text;
begin
  select * into o from ops_orders where token = p_token;
  if not found then return null; end if;

  if o.token_expires_at is not null and o.token_expires_at < now() then
    return jsonb_build_object('expired', true);
  end if;

  if o.proforma_no is null then
    return jsonb_build_object('nao_emitida', true);
  end if;

  v_lang := case when o.lang = 'en' then 'en' else 'pt' end;
  -- Sem cair no outro idioma: proforma em inglês com bloco em português
  -- é o mesmo erro do relatório. Em branco, o bloco não sai.
  select case when v_lang = 'en' then t.en else t.pt end
    into v_terms
    from ops_text_defaults t
   where t.key = 'proforma_terms';

  return jsonb_build_object(
    'order', jsonb_build_object(
      'id', o.id, 'order_ref', o.order_ref, 'lang', v_lang,
      'agency', o.agency, 'final_client', o.final_client,
      'pax_summary', o.pax_summary, 'travel_window', o.travel_window,
      'proforma_no', o.proforma_no, 'proforma_date', o.proforma_date),
    'items', coalesce((select jsonb_agg(jsonb_build_object(
        'service_date', i.service_date, 'title', i.title,
        'details', i.details, 'price', i.price) order by i.sort)
      from ops_order_items i where i.order_id = o.id), '[]'::jsonb),
    'terms', coalesce(v_terms, '')
  );
end $$;

revoke all on function tl_get_proforma(text) from public;
grant execute on function tl_get_proforma(text) to anon, authenticated;

insert into ops_migrations (id) values ('0039-proforma-para-baixar') on conflict (id) do nothing;
