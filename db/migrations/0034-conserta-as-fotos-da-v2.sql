-- =====================================================================
-- 0034 · DEVOLVE À TL-042-26 v2 AS FOTOS QUE A CÓPIA PERDEU
--
-- O botão "Nova versão" copiava metade da memória e metade do banco, e
-- as SEÇÕES não vinham de lugar nenhum: a foto de capa de cada folha se
-- perdia quando a versão era criada sem salvar antes. O botão já está
-- corrigido; esta migração conserta a versão que nasceu torta.
--
-- O QUE ELA FAZ, e só isto:
--   Da versão anterior para a última da TL-042-26, copia a foto de cada
--   seção (casando pela chave da seção) e as quatro fotos fixas — capa,
--   sobre nós, contracapa e convite.
--
-- O QUE ELA NÃO FAZ:
--   Não sobrescreve NADA que já esteja preenchido na v2. Só preenche o
--   que está vazio. Se ela tirou uma foto de propósito, a foto continua
--   fora. Não mexe em texto, valor, serviço, link nem resposta. Não
--   toca em nenhuma outra proposta: o alvo é a TL-042-26.
--
-- Rodar duas vezes não muda nada na segunda: a primeira já preencheu, e
-- preenchido não é sobrescrito.
--
-- Só toca em objetos ops_. Nada fora desse prefixo.
-- =====================================================================

do $$
declare
  v_opp   uuid;
  v_nova  ops_proposals%rowtype;
  v_velha ops_proposals%rowtype;
  v_secs  jsonb;
  v_quantas int := 0;
begin
  select id into v_opp from ops_opportunities where crm_code = 'TL-042-26' limit 1;
  if v_opp is null then
    raise notice 'Oportunidade TL-042-26 não encontrada. Nada a fazer.';
    return;
  end if;

  select * into v_nova from ops_proposals
   where opportunity_id = v_opp order by version desc limit 1;
  select * into v_velha from ops_proposals
   where opportunity_id = v_opp and version < v_nova.version
   order by version desc limit 1;

  if v_velha.id is null then
    raise notice 'A TL-042-26 só tem uma versão. Nada a copiar.';
    return;
  end if;

  -- Seções: casa pela chave e só preenche a foto que está vazia.
  select coalesce(jsonb_agg(
           case when coalesce(s->>'photo','') = '' and anterior.photo is not null
                then s || jsonb_build_object('photo', anterior.photo)
                else s end
           order by ord), '[]'::jsonb)
    into v_secs
    from jsonb_array_elements(coalesce(v_nova.sections,'[]'::jsonb))
         with ordinality as t(s, ord)
    left join lateral (
      select x->>'photo' as photo
        from jsonb_array_elements(coalesce(v_velha.sections,'[]'::jsonb)) x
       where x->>'key' = s->>'key' and coalesce(x->>'photo','') <> ''
       limit 1) anterior on true;

  select count(*) into v_quantas
    from jsonb_array_elements(v_secs) a,
         jsonb_array_elements(coalesce(v_nova.sections,'[]'::jsonb)) b
   where a->>'key' = b->>'key'
     and coalesce(a->>'photo','') <> '' and coalesce(b->>'photo','') = '';

  update ops_proposals set
    sections      = v_secs,
    cover_img     = coalesce(nullif(v_nova.cover_img,''),     v_velha.cover_img),
    about_img     = coalesce(nullif(v_nova.about_img,''),     v_velha.about_img),
    backcover_img = coalesce(nullif(v_nova.backcover_img,''), v_velha.backcover_img),
    assurance_img = coalesce(nullif(v_nova.assurance_img,''), v_velha.assurance_img),
    updated_at    = now()
  where id = v_nova.id;

  raise notice 'TL-042-26: v% recebeu a foto de % seção(ões) da v%.',
    v_nova.version, v_quantas, v_velha.version;
end $$;

insert into ops_migrations (id) values ('0034-conserta-as-fotos-da-v2') on conflict (id) do nothing;
