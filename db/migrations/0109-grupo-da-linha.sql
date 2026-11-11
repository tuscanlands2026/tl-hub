-- =====================================================================
-- 0109 · O GRUPO DA LINHA EM "YOUR PROPOSAL" — SÓ CRIA
--
-- Instrução dela, nov/26, olhando a tabela da TL-053-26: "está muito
-- bagunçado... organiza isso melhor". Nas experiências, primeiro a data e
-- embaixo, como subitem, cada serviço ou opção daquele dia. Em Ground
-- Services, não por data, e sim por serviço: "car rental, opção 1, opção
-- 2", os transfers juntos, e assim por diante.
--
-- Nas experiências o grupo é a data, e a data já existe (service_date). Em
-- Ground Services o grupo é o serviço, e isso não estava escrito em lugar
-- nenhum: dois transfers em dias diferentes ficam no mesmo grupo. Daí
-- este campo.
--
--   ops_proposal_items row_group_pt/_en   o título do grupo da linha
--
-- Vazio é o normal: nas experiências cai na data, e onde não há grupo a
-- linha sai solta, como antes. Proposta que já existe não muda.
--
-- tl_get_quote passa a devolver 'row_group' no serviço, por TROCA PONTUAL
-- no texto da função no ar, como na 0101 e na 0105.
--
-- Seção 7: só alter table add column e troca de função. Sem update, sem
-- delete. Nenhuma tabela do CRM.
-- =====================================================================

alter table ops_proposal_items add column if not exists row_group_pt text;
alter table ops_proposal_items add column if not exists row_group_en text;

do $$
declare d text; antes text;
begin
  d := pg_get_functiondef('public.tl_get_quote(text)'::regprocedure);
  antes := d;
  d := replace(d, $a$else coalesce(nullif(i.row_pt,''), i.row_en) end) order by i.sort)$a$,
    $b$else coalesce(nullif(i.row_pt,''), i.row_en) end,
        'row_group', case when ing then coalesce(nullif(i.row_group_en,''), i.row_group_pt)
                          else coalesce(nullif(i.row_group_pt,''), i.row_group_en) end) order by i.sort)$b$);
  if d = antes then raise exception '0109: trecho da linha não encontrado'; end if;
  execute d;
end $$;

insert into ops_migrations (id) values ('0109-grupo-da-linha') on conflict (id) do nothing;
