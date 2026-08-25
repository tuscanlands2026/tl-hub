-- =====================================================================
-- 0006 · CATÁLOGO DE HOSPEDAGENS E EXPERIÊNCIAS
--
-- Até aqui cada proposta era digitada do zero. Hospedagem e experiência
-- se repetem entre propostas — a mesma villa, a mesma vinícola —, e
-- redigitar é onde o erro entra: uma proposta sai com 5 quartos, outra
-- com 4, e nenhuma das duas está errada por descuido de quem escreveu,
-- mas por não haver uma fonte.
--
-- O catálogo é essa fonte. Ao montar a proposta ela busca pelo nome e o
-- registro é COPIADO para a linha: dali em diante o que vale é a cópia.
-- Mudar o valor de uma venda não pode mudar o catálogo, e corrigir o
-- catálogo não pode reescrever proposta já enviada.
--
-- Só toca em objetos ops_. Nada fora desse prefixo.
-- =====================================================================

create table if not exists ops_catalog (
  id             uuid primary key default gen_random_uuid(),
  kind           text not null default 'stay',      -- stay | experience | transfer
  name           text not null,
  region         text,
  website        text,
  -- O que a pessoa ocupa. Nem sempre é quarto: aqui é a villa inteira.
  accommodation  text,
  accommodation_en text,
  -- A estrutura: piscina, jardim, o que é compartilhado com a propriedade.
  facilities     text,
  facilities_en  text,
  descr          text,
  descr_en       text,
  photos         jsonb not null default '[]'::jsonb,
  attachments    jsonb not null default '[]'::jsonb,
  internal_notes text,
  active         boolean not null default true,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now()
);
comment on table ops_catalog is
  'Hospedagens e experiências que se repetem entre propostas. A proposta leva uma cópia, nunca uma referência viva.';

create index if not exists ops_catalog_nome_idx on ops_catalog (lower(name));
create index if not exists ops_catalog_kind_idx on ops_catalog (kind, active);

alter table ops_catalog enable row level security;
drop policy if exists "auth_all" on ops_catalog;
create policy "auth_all" on ops_catalog for all to authenticated using (true) with check (true);
revoke all on ops_catalog from anon;

-- A linha da proposta guarda de onde veio, só para ela saber. Se o
-- registro do catálogo sumir, a linha continua inteira: o que ela
-- mandou para o cliente não pode depender de um cadastro interno.
alter table ops_proposal_items add column if not exists catalog_id uuid
  references ops_catalog(id) on delete set null;
alter table ops_proposal_items add column if not exists facilities text;
alter table ops_proposal_items add column if not exists facilities_en text;
comment on column ops_proposal_items.facilities is
  'Estrutura e o que é compartilhado. Sai no card, abaixo da descrição.';

-- tl_get_quote devolve a estrutura, resolvida pelo idioma. Continua
-- campo a campo: catalog_id e internal_notes não saem.
create or replace function tl_get_quote(p_token text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  pp ops_proposals%rowtype; o ops_opportunities%rowtype;
  idioma text; ing boolean; secs jsonb; dias jsonb; result jsonb;
begin
  select * into pp from ops_proposals where token = p_token;
  if not found then return null; end if;
  select * into o from ops_opportunities where id = pp.opportunity_id;
  idioma := coalesce(pp.lang, o.lang, 'pt');
  ing := idioma = 'en';

  select coalesce(jsonb_agg(jsonb_build_object(
           'key', s->>'key',
           'title', case when ing then coalesce(nullif(s->>'title_en',''), s->>'title')
                         else coalesce(nullif(s->>'title',''), s->>'title_en') end,
           'note',  case when ing then coalesce(nullif(s->>'note_en',''), s->>'note')
                         else coalesce(nullif(s->>'note',''), s->>'note_en') end,
           'photo', s->>'photo') order by ord), '[]'::jsonb)
    into secs from jsonb_array_elements(coalesce(pp.sections,'[]'::jsonb)) with ordinality as t(s, ord);

  select coalesce(jsonb_agg(jsonb_build_object(
           'date', case when ing then coalesce(nullif(d->>'date_en',''), d->>'date')
                        else coalesce(nullif(d->>'date',''), d->>'date_en') end,
           'lines', case when ing then coalesce(d->'lines_en', d->'lines')
                         else coalesce(d->'lines', d->'lines_en') end) order by ord), '[]'::jsonb)
    into dias from jsonb_array_elements(coalesce(pp.itinerary,'[]'::jsonb)) with ordinality as t(d, ord);

  select jsonb_build_object(
    'proposal', jsonb_build_object(
      'id', pp.id, 'version', pp.version, 'title', pp.title, 'summary', pp.summary,
      'lang', idioma, 'layout', coalesce(pp.layout,'tabela'),
      'pax_summary', pp.pax_summary, 'travel_window', pp.travel_window,
      'intro', pp.intro, 'payment_note', pp.payment_note, 'terms_url', pp.terms_url,
      'cover_img', pp.cover_img,
      'cover_tag', case when ing then coalesce(nullif(pp.cover_tag_en,''), pp.cover_tag_pt)
                        else coalesce(nullif(pp.cover_tag_pt,''), pp.cover_tag_en) end,
      'welcome', case when ing then coalesce(nullif(pp.welcome_en,''), pp.welcome_pt)
                      else coalesce(nullif(pp.welcome_pt,''), pp.welcome_en) end,
      'itinerary', dias,
      'conditions', case when ing then coalesce(nullif(pp.conditions_en,''), pp.conditions_pt, pp.conditions)
                         else coalesce(nullif(pp.conditions_pt,''), pp.conditions) end,
      'excluded', case when ing then coalesce(nullif(pp.excluded_en,''), pp.excluded_pt)
                       else coalesce(nullif(pp.excluded_pt,''), pp.excluded_en) end,
      'sections', secs, 'show_prices', pp.show_prices,
      'crm_code', o.crm_code, 'agency', o.agency, 'final_client', o.final_client,
      'outcome', pp.outcome, 'responded_at', pp.responded_at),
    'items', coalesce((select jsonb_agg(jsonb_build_object(
        'id', i.id, 'service_date', i.service_date,
        'title', case when ing then coalesce(nullif(i.title_en,''), i.title)
                      else coalesce(nullif(i.title,''), i.title_en) end,
        'details', case when ing then coalesce(nullif(i.details_en,''), i.details)
                        else coalesce(nullif(i.details,''), i.details_en) end,
        'room_type', case when ing then coalesce(nullif(i.room_type_en,''), i.room_type)
                          else coalesce(nullif(i.room_type,''), i.room_type_en) end,
        'facilities', case when ing then coalesce(nullif(i.facilities_en,''), i.facilities)
                           else coalesce(nullif(i.facilities,''), i.facilities_en) end,
        'website', i.website, 'photos', i.photos, 'attachments', i.attachments,
        'price', i.price, 'section', i.section,
        'optional', i.optional, 'choice_group', i.choice_group,
        'extras', i.extras) order by i.sort)
      from ops_proposal_items i where i.proposal_id = pp.id), '[]'::jsonb)
  ) into result;
  return result;
end $$;

revoke all on function tl_get_quote(text) from public;
grant execute on function tl_get_quote(text) to anon, authenticated;

insert into ops_migrations (id) values ('0006-catalogo') on conflict (id) do nothing;
