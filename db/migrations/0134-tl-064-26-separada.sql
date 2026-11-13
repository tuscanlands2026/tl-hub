-- =====================================================================
-- 0134 · AS EXPERIÊNCIAS DA EMILY VIRAM A OPORTUNIDADE TL-064-26
--
-- Instrução dela, 13/11/26: "ao invés de deixar dentro da TL-053, cria a
-- 064 e separa, e coloca nas informações que é a parte das experiências da
-- 053 — eu só não quero perder histórico". E: "v1, concordo, não v3".
--
--   · nasce a oportunidade TL-064-26, com a mesma agência, idioma e
--     cliente da TL-053-26, e a nota de origem em internal_notes;
--   · a proposta que era a v3 da TL-053-26 passa para ela como versão 1.
--     O link (token) não muda: quem já recebeu continua abrindo. ref_code
--     volta a vazio, porque o número agora vem da oportunidade;
--   · a TL-053-26 fica inteira: v1 (o estudo), v2 e a order TL-053-26 dos
--     quartos e do carro. Nada nela muda.
--
-- Quando as experiências forem aprovadas, a order nasce desta oportunidade.
--
-- Seção 7: um insert, e update de UMA proposta (a ex-v3, criada na 0131 e
-- ainda sem resposta), com o sim dela. Roda uma vez: se a TL-064-26 já
-- existe, para.
-- =====================================================================

do $$
declare
  velha uuid := '560f448e-61fe-4ec0-be7e-16fa5c5518b1';   -- TL-053-26
  prop  uuid := 'e0530000-0000-0000-0000-000000000003';   -- a ex-v3
  nova  uuid;
  o     ops_opportunities%rowtype;
  n     int;
begin
  if exists (select 1 from ops_opportunities where crm_code = 'TL-064-26') then
    raise exception '0134: a TL-064-26 já existe';
  end if;
  if exists (select 1 from ops_proposals where id = prop and responded_at is not null) then
    raise exception '0134: a proposta já foi respondida, nada muda';
  end if;
  select * into o from ops_opportunities where id = velha;
  if not found then raise exception '0134: TL-053-26 não encontrada'; end if;

  insert into ops_opportunities (crm_code, title, lang, agency, agency_contact, final_client, outcome, internal_notes)
  values ('TL-064-26', o.title || ' · Experiences', o.lang, o.agency, o.agency_contact, o.final_client, 'open',
          'Experiências da viagem da TL-053-26. Hotéis (Suite Terrace no Castelfalfi, Junior Suite no Bulgari) e carro Categoria 1 já aprovados na order TL-053-26. Esta proposta nasceu como v3 da TL-053-26 e foi separada em 13/11/26.')
  returning id into nova;

  update ops_proposals set opportunity_id = nova, version = 1, ref_code = null
   where id = prop and opportunity_id = velha;
  get diagnostics n = row_count;
  if n <> 1 then raise exception '0134: a ex-v3 não foi encontrada na TL-053-26'; end if;
end $$;

insert into ops_migrations (id) values ('0134-tl-064-26-separada') on conflict (id) do nothing;
