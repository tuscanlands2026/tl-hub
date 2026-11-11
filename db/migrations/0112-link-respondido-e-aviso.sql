-- =====================================================================
-- 0112 · O LINK RESPONDIDO MOSTRA O QUE O CLIENTE ESCOLHEU, E O AVISO
--        POR E-MAIL SEM OS DIAS QUE NÃO SE ESCOLHEM — SÓ TROCA FUNÇÃO
--
-- Pergunta dela, nov/26, fechando a TL-053-26: "quando o cliente mandar,
-- eu vou receber o link preenchido?". Conferido:
--   · o aviso por e-mail sai (gatilho ops_quote_notify → tl_notify_quote,
--     Resend, para o endereço de ops_notify_config), e a resposta aparece
--     no editor da proposta no hub;
--   · MAS o link, reaberto depois da resposta, mostrava a marcação PADRÃO
--     travada, e não a escolha do cliente: tl_get_quote não devolvia a
--     resposta. Quem abrisse o link para conferir veria outra coisa.
--
-- 1 · tl_get_quote passa a devolver 'answer' quando a proposta já foi
--     respondida: os serviços, as opções e os extras da resposta mais
--     recente, e o total. Só isso — nome, e-mail e observações de quem
--     respondeu não saem no link. O modelo jornada usa 'answer' para abrir
--     já marcado como o cliente mandou. Proposta não respondida: null.
-- 2 · tl_notify_quote, no modelo jornada, pula as linhas que não são
--     escolha (dia de narrativa sem valor e sem opções). Sem isso o e-mail
--     listava "✕ Arrival", "✕ Montepulciano and Pienza"… como se o cliente
--     tivesse recusado um dia de passeio livre. Proposta de outro modelo:
--     e-mail igual ao de antes.
--
-- Troca pontual no texto das funções no ar, como na 0101: cada troca
-- confere que achou o trecho e, não achando, para tudo.
--
-- Seção 7: só troca de função. Sem update, sem delete. Nenhuma tabela do
-- CRM.
-- =====================================================================

do $$
declare d text; antes text; crlf text := chr(13) || chr(10);
begin
  -- 1 · a resposta no link
  d := pg_get_functiondef('public.tl_get_quote(text)'::regprocedure);
  antes := d;
  d := replace(d, crlf || '  ) into result;',
    $b$,
    'answer', case when pp.responded_at is null then null else (
      select jsonb_build_object(
        'items',  coalesce((select jsonb_agg(l->>'item_id')
                              from jsonb_array_elements(s.lines) l
                             where coalesce((l->>'chosen')::boolean, false)), '[]'::jsonb),
        'units',  coalesce((select jsonb_object_agg(l->>'item_id',
                                     (select coalesce(jsonb_agg(u->>'key'), '[]'::jsonb)
                                        from jsonb_array_elements(coalesce(l->'units','[]'::jsonb)) u))
                              from jsonb_array_elements(s.lines) l
                             where coalesce((l->>'chosen')::boolean, false)), '{}'::jsonb),
        'extras', coalesce((select jsonb_object_agg(l->>'item_id',
                                     (select coalesce(jsonb_agg(e->>'key'), '[]'::jsonb)
                                        from jsonb_array_elements(coalesce(l->'extras','[]'::jsonb)) e))
                              from jsonb_array_elements(s.lines) l
                             where coalesce((l->>'chosen')::boolean, false)), '{}'::jsonb),
        'total', s.total)
        from ops_proposal_selections s
       where s.proposal_id = pp.id
       order by s.submitted_at desc nulls last
       limit 1) end
  ) into result;$b$);
  if d = antes then raise exception '0112: fim da tl_get_quote não encontrado'; end if;
  execute d;

  -- 2 · o e-mail sem os dias que não se escolhem
  d := pg_get_functiondef('public.tl_notify_quote()'::regprocedure);
  antes := d;
  d := replace(d, $a$if found then tit := tl_txt(ing, it.title, it.title_en); end if;$a$,
    $b$if found then tit := tl_txt(ing, it.title, it.title_en); end if;
      if found and pp.modelo = 'jornada'
         and not coalesce((ln->>'chosen')::boolean, false)
         and coalesce(it.price, 0) = 0
         and jsonb_array_length(coalesce(it.units, '[]'::jsonb)) = 0 then
        continue;
      end if;$b$);
  if d = antes then raise exception '0112: trecho do e-mail não encontrado'; end if;
  execute d;
end $$;

insert into ops_migrations (id) values ('0112-link-respondido-e-aviso') on conflict (id) do nothing;
