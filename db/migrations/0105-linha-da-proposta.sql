-- =====================================================================
-- 0105 · O TEXTO DA LINHA EM "YOUR PROPOSAL" — SÓ CRIA
--
-- Instrução dela, nov/26, nas correções da TL-053-26: na tabela da
-- proposta "cada linha traz o dia da semana, a data e o nome completo da
-- experiência, para o cliente escolher sem precisar voltar às telas de
-- dia (importante no celular)".
--
-- O título do serviço não serve para isso: na tela do dia ele é curto
-- ("Montalcino"), e na tabela a linha precisa dizer o que é aquilo que se
-- marca ("Monday, June 21 · Montalcino · Lunch with the chef at a
-- historic estate, with five wines"). Dois lugares, dois textos.
--
--   ops_proposal_items row_pt/_en   a linha do serviço sem opções
--   units[].row / row_en (jsonb)    a linha de cada opção, quarto ou carro
--   extras[].row / row_en (jsonb)   a linha do extra — extras já saem
--                                   inteiros em tl_get_quote, sem troca
--
-- Vazio é o normal: o desenho cai no título, como antes. Proposta que já
-- existe não muda.
--
-- tl_get_quote passa a devolver 'row' no serviço e na opção, por TROCA
-- PONTUAL no texto da função no ar, como na 0101: cada troca confere que
-- achou o trecho e, não achando, para tudo.
--
-- Seção 7: só alter table add column e troca de função. Sem update, sem
-- delete. Nenhuma tabela do CRM.
-- =====================================================================

alter table ops_proposal_items add column if not exists row_pt text;
alter table ops_proposal_items add column if not exists row_en text;

do $$
declare d text; antes text;
begin
  d := pg_get_functiondef('public.tl_get_quote(text)'::regprocedure);

  -- 1 · opção (unidade): a linha da tabela
  antes := d;
  d := replace(d, $a$'photos', coalesce(u->'photos', '[]'::jsonb)) order by ord)$a$,
    $b$'photos', coalesce(u->'photos', '[]'::jsonb),
            'row', case when ing then coalesce(nullif(u->>'row_en',''), u->>'row') else coalesce(nullif(u->>'row',''), u->>'row_en') end) order by ord)$b$);
  if d = antes then raise exception '0105: trecho das unidades não encontrado'; end if;

  -- 2 · serviço: a linha da tabela
  antes := d;
  d := replace(d, $a$else coalesce(nullif(i.good_pt,''), i.good_en) end) order by i.sort)$a$,
    $b$else coalesce(nullif(i.good_pt,''), i.good_en) end,
        'row', case when ing then coalesce(nullif(i.row_en,''), i.row_pt)
                    else coalesce(nullif(i.row_pt,''), i.row_en) end) order by i.sort)$b$);
  if d = antes then raise exception '0105: trecho da linha não encontrado'; end if;

  execute d;
end $$;

insert into ops_migrations (id) values ('0105-linha-da-proposta') on conflict (id) do nothing;
