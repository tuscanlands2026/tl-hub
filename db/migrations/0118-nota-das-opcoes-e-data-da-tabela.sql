-- =====================================================================
-- 0118 · NOTA DAS OPÇÕES, DATA DA TABELA, MODELOS E LINKS — SÓ CRIA
--
-- Mudanças visuais dela para a TL-053-26, nov/26 (arquivo "Mudanças
-- visuais e de layout", com prévia aprovada):
--   · embaixo das opções de um serviço, uma nota em itálico pequeno —
--     "Room images are by way of example…" no hotel, "Models are subject
--     to availability at the time of booking." nos carros;
--   · na folha da proposta, coluna DATE com a data só na primeira linha
--     de cada grupo, e nem sempre é a data da tela ("June 25 to 29" no
--     hotel, "June 21 to 28" no carro, "Before the trip" no concierge);
--   · em cada categoria de carro, três fotos pequenas, uma por modelo,
--     com o nome do modelo na foto;
--   · o link de cada quarto (o virtual tour) dentro do quarto, e não mais
--     no cartão do hotel.
--
--   ops_proposal_items options_note_pt/_en   a nota embaixo das opções
--   ops_proposal_items row_date_pt/_en       a data na coluna DATE
--   units[].models  [{name, photo}]          os modelos de uma categoria
--   units[].links   [{name, url}]            os links de um quarto
--
-- Vazio é o normal: sem eles o desenho faz o que já fazia. tl_get_quote
-- passa a devolver os quatro, por TROCA PONTUAL no texto da função.
--
-- Seção 7: só alter table add column e troca de função. Sem update, sem
-- delete. Nenhuma tabela do CRM.
-- =====================================================================

alter table ops_proposal_items add column if not exists options_note_pt text;
alter table ops_proposal_items add column if not exists options_note_en text;
alter table ops_proposal_items add column if not exists row_date_pt     text;
alter table ops_proposal_items add column if not exists row_date_en     text;

do $$
declare d text; antes text;
begin
  d := pg_get_functiondef('public.tl_get_quote(text)'::regprocedure);

  antes := d;
  d := replace(d,
    $a$'row_desc', case when ing then coalesce(nullif(u->>'row_desc_en',''), u->>'row_desc') else coalesce(nullif(u->>'row_desc',''), u->>'row_desc_en') end) order by ord)$a$,
    $b$'row_desc', case when ing then coalesce(nullif(u->>'row_desc_en',''), u->>'row_desc') else coalesce(nullif(u->>'row_desc',''), u->>'row_desc_en') end,
            'models', coalesce(u->'models', '[]'::jsonb),
            'links', coalesce(u->'links', '[]'::jsonb)) order by ord)$b$);
  if d = antes then raise exception '0118: trecho das unidades não encontrado'; end if;

  antes := d;
  d := replace(d,
    $a$else coalesce(nullif(i.row_desc_pt,''), i.row_desc_en) end) order by i.sort)$a$,
    $b$else coalesce(nullif(i.row_desc_pt,''), i.row_desc_en) end,
        'options_note', case when ing then coalesce(nullif(i.options_note_en,''), i.options_note_pt)
                             else coalesce(nullif(i.options_note_pt,''), i.options_note_en) end,
        'row_date', case when ing then coalesce(nullif(i.row_date_en,''), i.row_date_pt)
                         else coalesce(nullif(i.row_date_pt,''), i.row_date_en) end) order by i.sort)$b$);
  if d = antes then raise exception '0118: trecho da linha não encontrado'; end if;

  execute d;
end $$;

insert into ops_migrations (id) values ('0118-nota-das-opcoes-e-data-da-tabela') on conflict (id) do nothing;
