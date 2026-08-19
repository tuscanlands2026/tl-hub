-- =====================================================================
-- 0001 · CONTROLE DE MIGRAÇÕES
--
-- O SQL é rodado à mão no painel do Supabase, e até aqui não havia como
-- saber o que já tinha sido aplicado: o hub descobria pelo erro, na hora
-- de gravar. Esta tabela guarda o que já rodou; o hub compara com a
-- lista que ele espera e avisa na tela o que falta, com o link do
-- arquivo.
--
-- Só toca em objetos ops_. Nada fora desse prefixo.
-- =====================================================================

create table if not exists ops_migrations (
  id         text primary key,
  applied_at timestamptz not null default now()
);
comment on table ops_migrations is
  'Uma linha por arquivo de db/migrations já rodado. O hub lê para avisar o que falta.';

alter table ops_migrations enable row level security;
drop policy if exists "auth_all" on ops_migrations;
create policy "auth_all" on ops_migrations
  for all to authenticated using (true) with check (true);
revoke all on ops_migrations from anon;

-- O que já estava no ar antes deste controle existir. Registrado de uma
-- vez para o hub não pedir que ela rode de novo o que já rodou.
insert into ops_migrations (id) values
  ('base-orders'), ('base-opportunities'), ('base-checkout'),
  ('base-notify'), ('base-quote'), ('0001-controle-de-migracoes')
on conflict (id) do nothing;
