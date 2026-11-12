-- =====================================================================
-- 0123 · PROPOSTA SEM NADA PRÉ-SELECIONADO (preselect)
--
-- Instrução dela, 12/11/26, na TL-053-26: "deixa por padrão nenhuma opção
-- pré-selecionada, porque acho que isso induz o consumidor a erro. Deixa
-- ele selecionando tudo que ele quer."
--
-- ops_proposals.preselect: nulo ou true é o de antes (o programa vem
-- marcado, nas opções marcadas como padrão); false abre tudo desmarcado e
-- o total em zero. Nasce nulo — proposta que já existe não muda de cara.
-- tl_get_quote passa a devolver 'preselect', por TROCA PONTUAL no texto.
--
-- E a v2 da Emily passa a false, com o sim dela: update de uma linha de
-- ops_proposals, só enquanto não foi respondida.
--
-- Seção 7: add column, troca de função e um update com o sim dela.
-- Nenhuma tabela do CRM.
-- =====================================================================

alter table ops_proposals add column if not exists preselect boolean;

do $$
declare d text; antes text;
begin
  d := pg_get_functiondef('public.tl_get_quote(text)'::regprocedure);
  antes := d;
  d := replace(d, $a$jsonb_build_object('modelo', pp.modelo,$a$,
                  $b$jsonb_build_object('modelo', pp.modelo, 'preselect', pp.preselect,$b$);
  if d = antes then raise exception '0123: trecho do modelo não encontrado'; end if;
  execute d;
end $$;

update ops_proposals set preselect = false
 where id = 'e0530000-0000-0000-0000-000000000002' and responded_at is null;

insert into ops_migrations (id) values ('0123-proposta-sem-pre-selecao') on conflict (id) do nothing;
