-- =====================================================================
-- 0136 · O E-MAIL DA RESPOSTA MOSTRA "FROM € 300", E SAI O CANTUCCINI
--
-- Instruções dela, 13/11/26:
--   1 · "tem que mostrar o valor, porque zero" — a opção com preço "a
--       partir de" (price_text, 0132) saía no e-mail de aviso como
--       "€ 0,00", na linha e na coluna de valor. Agora sai o texto dela,
--       "From € 300". Duas trocas pontuais:
--         · tl_submit_quote guarda o price_text da opção escolhida na
--           resposta (resposta antiga continua como foi gravada);
--         · tl_notify_quote mostra o price_text no lugar do valor, e na
--           coluna da direita quando a linha não tem valor nenhum.
--   2 · "tira esse negócio de cantuccini, isso é feio" — e depois: "não é
--       para falar que tem cantucci e vin santo, isso é inútil". Sai a
--       degustação do texto e do Included. E o fecho fala da
--       boutique deles, com tempo para explorar e o Steve à disposição para
--       ajudar na escolha — "não pode ficar igualzinho ao site, porque eu
--       estou cobrando a mais. Cuidado para não inventar". O texto da
--       experiência na Steli d'oro (TL-064-26) é reescrito com palavras
--       próprias, sem nada que o ateliê não ofereça.
--
-- Seção 7: troca de função e update no dia de Arezzo da proposta da
-- TL-064-26, com o sim dela. A guarda se prende à frase que se troca.
-- =====================================================================

do $$
declare d text; antes text; n int;
  prop uuid := 'e0530000-0000-0000-0000-000000000003';
begin
  -- 1a · a resposta guarda o price_text
  d := pg_get_functiondef('public.tl_submit_quote(text,jsonb)'::regprocedure);
  antes := d;
  d := replace(d, $a$'optional', coalesce((un->>'optional')::boolean, false));$a$,
                  $b$'optional', coalesce((un->>'optional')::boolean, false),
            'price_text', coalesce(nullif(un->>'price_text_en',''), un->>'price_text'));$b$);
  if d = antes then raise exception '0136: opção não encontrada em tl_submit_quote'; end if;
  execute d;

  -- 1b · o e-mail mostra o price_text
  d := pg_get_functiondef('public.tl_notify_quote()'::regprocedure);
  antes := d;
  d := replace(d,
    $a$tl_html(coalesce(tl_txt(ing, ex->>'label', ex->>'label_en'), ex->>'key'))$a$ || E'\r\n' ||
    $a$        || case when pp.show_prices then ' · ' || tl_eur((ex->>'price')::numeric) else '' end$a$,
    $b$tl_html(coalesce(tl_txt(ing, ex->>'label', ex->>'label_en'), ex->>'key'))
        || case when pp.show_prices then ' · ' || coalesce(nullif(ex->>'price_text',''), tl_eur((ex->>'price')::numeric)) else '' end$b$);
  if d = antes then raise exception '0136: linha da opção não encontrada em tl_notify_quote'; end if;

  antes := d;
  d := replace(d, $a$when pp.show_prices then tl_eur(coalesce((ln->>'price')::numeric,0)$a$,
    $b$when pp.show_prices
                   and coalesce((ln->>'price')::numeric,0)
                       + coalesce((select sum((u->>'price')::numeric)
                                     from jsonb_array_elements(coalesce(ln->'units','[]'::jsonb)) u),0) = 0
                   and exists (select 1 from jsonb_array_elements(coalesce(ln->'units','[]'::jsonb)) u
                                where coalesce(u->>'price_text','') <> '')
                then (select string_agg(u->>'price_text', ' / ')
                        from jsonb_array_elements(coalesce(ln->'units','[]'::jsonb)) u
                       where coalesce(u->>'price_text','') <> '')
              when pp.show_prices then tl_eur(coalesce((ln->>'price')::numeric,0)$b$);
  if d = antes then raise exception '0136: coluna de valor não encontrada em tl_notify_quote'; end if;
  execute d;

  -- 2 · sem degustação; a boutique no fecho
  if exists (select 1 from ops_proposals where id = prop and responded_at is not null) then
    raise exception '0136: a proposta já foi respondida, nada muda';
  end if;
  update ops_proposal_items i set units = (
      select jsonb_agg(case when u->>'key' = 'steli_lab' then u
          || jsonb_build_object(
               'desc_en', $t$Two hours in Steve Angeli's workshop, at his side. From the first sketch to the finished metal, he walks you through how a jewel takes shape and the traditional techniques behind the details. Then you take his place at the bench and try stone setting with your own hands. To close, there is time to explore their boutique, with Steve on hand to help if a piece catches your eye.$t$,
               'included_en', $t$Guided visit of the workshop with Steve Angeli, the goldsmith's techniques and process explained, a personal bench for stone setting, and time in the boutique.$t$)
        else u end order by o)
      from jsonb_array_elements(i.units) with ordinality t(u, o))
   where proposal_id = prop and title_en = 'Arezzo and its goldsmiths'
     and units::text like '%cantuccini from the Arezzo area%';
  get diagnostics n = row_count;
  if n <> 1 then raise exception '0136: o texto com cantuccini não foi encontrado'; end if;
  if exists (select 1 from ops_proposal_items where proposal_id = prop and title_en = 'Arezzo and its goldsmiths'
             and (units::text ilike '%cantucc%' or units::text ilike '%vin santo%')) then
    raise exception '0136: ainda sobrou cantucci ou Vin Santo';
  end if;
end $$;

insert into ops_migrations (id) values ('0136-email-com-from-e-sem-cantuccini') on conflict (id) do nothing;
