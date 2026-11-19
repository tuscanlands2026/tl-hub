-- 0156 · Número TL com hífen nas linhas que ainda estavam sem (19/11/26)
--
-- MEXE EM LINHA QUE JÁ EXISTE, com o sim dela (19/11/26: "tudo com hífen").
-- O padrão da casa é TL-###-AA: 69 de 69 no Pipeline do CRM, 34 de 34 em Vendas,
-- e no hub todas, menos a 050 e a 051, digitadas sem hífen na oportunidade e
-- herdadas pelas orders. A diferença fez o Checklist do CRM receber a TL-050-26.1
-- em dobro (0151/0152 do CRM).
--
-- Ela sabe, e decidiu assim: as orders TL050-26.1 e TL051-26.1 estão confirmadas
-- e a TL050-26.1 tem a proforma 166/26. Reabertas, as duas mostram o número com
-- hífen; o PDF que a agência recebeu continua sem. O número da proforma não muda.
--
-- As orders TL050-26.1 e .2 ela mesma corrigiu pelo editor, às 16:59 UTC do mesmo
-- dia; aqui ficam a order TL051-26.1 e as duas oportunidades.
--
-- Troca só o padrão TLnnn- no começo; qualquer outro texto fica como está.

do $$
declare n int;
begin
  update ops_opportunities set crm_code = regexp_replace(crm_code, '^TL(\d{3})-', 'TL-\1-')
   where crm_code in ('TL050-26','TL051-26');
  get diagnostics n = row_count;
  if n <> 2 then raise exception '0156: esperava 2 oportunidades, achou %', n; end if;

  update ops_orders set
     order_ref        = regexp_replace(order_ref,        '^TL(\d{3})-', 'TL-\1-'),
     opportunity_code = regexp_replace(opportunity_code, '^TL(\d{3})-', 'TL-\1-')
   where order_ref = 'TL051-26.1';
  get diagnostics n = row_count;
  if n <> 1 then raise exception '0156: esperava 1 order, achou %', n; end if;
end $$;

insert into ops_migrations (id) values ('0156-codigo-tl-com-hifen') on conflict (id) do nothing;
