-- =====================================================================
-- 0101 · O MODELO "JORNADA" DA PROPOSTA APRESENTADA — SÓ CRIA
--
-- Instrução dela, nov/26 (arquivo "proposta-emily-nathan-TL-053-26.md",
-- Parte A): a proposta passa a ser contada em telas — capa, abertura,
-- "at a glance", uma tela de narrativa por base (sem preço nenhum), onde
-- vai ficar, como se desloca, dining, e só então "Your proposal", a única
-- tela com valores e total. Vale "para todas as propostas" daqui em diante.
--
-- O CORTE É UM CAMPO (regra do passado): ops_proposals.modelo. Nulo é o
-- desenho de sempre, e toda proposta que já existe continua igual. 'jornada'
-- liga o desenho novo. Nada aqui muda proposta nenhuma.
--
-- O que entra:
--   ops_proposals      modelo · closing_pt/_en (a tela de fechamento: no
--                      white label a contracapa da casa não sai, e sem isto
--                      não haveria tela nenhuma depois da proposta)
--   ops_proposal_items not_included_pt/_en · good_pt/_en ("Not included" e
--                      "Good to know" de cada experiência)
--   sections (jsonb)   tipo (narrativa | hospedagem | transporte | dining) e
--                      intro/intro_en — sem coluna, só a função passa a ler
--   units (jsonb)      desc, included, not_included, good, ficha, photos —
--                      cada opção de um dia, cada quarto de um hotel, cada
--                      categoria de carro, com texto e foto próprios
--
-- tl_get_quote passa a devolver isso. É feito por TROCA PONTUAL no texto da
-- função que está no ar, e não reescrevendo a função: o resto dela fica
-- byte a byte como estava. Cada troca confere que achou o trecho; não
-- achando, para tudo (raise), e nada é aplicado.
--
-- tl_submit_quote ganha uma conferência: num serviço com choice_group, mais
-- de uma opção marcada é recusada (choice_conflict) — hotel, carro e dia com
-- duas opções são escolha única, e tela se contorna.
--
-- Seção 7: só alter table add column e troca de função. Sem update, sem
-- delete. Nenhuma tabela do CRM.
-- =====================================================================

alter table ops_proposals      add column if not exists modelo       text;
alter table ops_proposals      add column if not exists closing_pt   text;
alter table ops_proposals      add column if not exists closing_en   text;
alter table ops_proposal_items add column if not exists not_included_pt text;
alter table ops_proposal_items add column if not exists not_included_en text;
alter table ops_proposal_items add column if not exists good_pt      text;
alter table ops_proposal_items add column if not exists good_en      text;

do $$
declare d text; antes text;
begin
  d := pg_get_functiondef('public.tl_get_quote(text)'::regprocedure);

  -- 1 · seção: tipo e abertura
  antes := d;
  d := replace(d, $a$'photo', s->>'photo',$a$,
    $b$'photo', s->>'photo',
           'tipo', nullif(s->>'tipo',''),
           'intro', case when ing then coalesce(nullif(s->>'intro_en',''), s->>'intro')
                         else coalesce(nullif(s->>'intro',''), s->>'intro_en') end,$b$);
  if d = antes then raise exception '0101: trecho da seção não encontrado'; end if;

  -- 2 · proposta: modelo e fechamento (concatenados, para não passar do
  --     limite de 100 argumentos do jsonb_build_object)
  antes := d;
  d := replace(d, $a$'outcome', pp.outcome, 'responded_at', pp.responded_at),$a$,
    $b$'outcome', pp.outcome, 'responded_at', pp.responded_at)
      || jsonb_build_object('modelo', pp.modelo,
           'closing', case when ing then coalesce(nullif(pp.closing_en,''), pp.closing_pt)
                           else coalesce(nullif(pp.closing_pt,''), pp.closing_en) end),$b$);
  if d = antes then raise exception '0101: trecho da proposta não encontrado'; end if;

  -- 3 · opção (unidade): texto, foto e inclusões próprios
  antes := d;
  d := replace(d, $a$'optional', coalesce((u->>'optional')::boolean, false)) order by ord)$a$,
    $b$'optional', coalesce((u->>'optional')::boolean, false),
            'selected', coalesce((u->>'selected')::boolean, false),
            'ficha', case when ing then coalesce(nullif(u->>'ficha_en',''), u->>'ficha') else coalesce(nullif(u->>'ficha',''), u->>'ficha_en') end,
            'desc', case when ing then coalesce(nullif(u->>'desc_en',''), u->>'desc') else coalesce(nullif(u->>'desc',''), u->>'desc_en') end,
            'included', case when ing then coalesce(nullif(u->>'included_en',''), u->>'included') else coalesce(nullif(u->>'included',''), u->>'included_en') end,
            'not_included', case when ing then coalesce(nullif(u->>'not_included_en',''), u->>'not_included') else coalesce(nullif(u->>'not_included',''), u->>'not_included_en') end,
            'good', case when ing then coalesce(nullif(u->>'good_en',''), u->>'good') else coalesce(nullif(u->>'good',''), u->>'good_en') end,
            'photos', coalesce(u->'photos', '[]'::jsonb)) order by ord)$b$);
  if d = antes then raise exception '0101: trecho das unidades não encontrado'; end if;

  -- 4 · linha: "not included" e "good to know"
  antes := d;
  d := replace(d, $a$'extras', i.extras) order by i.sort)$a$,
    $b$'extras', i.extras,
        'not_included', case when ing then coalesce(nullif(i.not_included_en,''), i.not_included_pt)
                             else coalesce(nullif(i.not_included_pt,''), i.not_included_en) end,
        'good', case when ing then coalesce(nullif(i.good_en,''), i.good_pt)
                     else coalesce(nullif(i.good_pt,''), i.good_en) end) order by i.sort)$b$);
  if d = antes then raise exception '0101: trecho da linha não encontrado'; end if;

  execute d;

  -- 5 · envio: escolha única dentro do serviço com choice_group
  d := pg_get_functiondef('public.tl_submit_quote(text,jsonb)'::regprocedure);
  antes := d;
  d := replace(d, $a$      soma := soma + coalesce(it.price,0);$a$,
    $b$      soma := soma + coalesce(it.price,0);
      if coalesce(it.choice_group,'') <> ''
         and jsonb_typeof(unmarc->(it.id::text)) = 'array'
         and jsonb_array_length(unmarc->(it.id::text)) > 1 then
        return jsonb_build_object('ok', false, 'error', 'choice_conflict',
                                  'missing', to_jsonb(array[it.title]));
      end if;$b$);
  if d = antes then raise exception '0101: trecho do envio não encontrado'; end if;
  execute d;
end $$;

insert into ops_migrations (id) values ('0101-modelo-jornada') on conflict (id) do nothing;
