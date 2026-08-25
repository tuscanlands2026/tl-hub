-- =====================================================================
-- 0005 · PROPOSTA APRESENTADA
--
-- O modelo em tabela serve para orçamento seco: transfer avulso, pacote
-- pequeno. Não serve para vender hospedagem cara, onde o que decide é
-- ver o quarto, a metragem, o site da propriedade e a planimetria.
--
-- Esta migração acrescenta o que a proposta apresentada precisa, sem
-- tirar nada do que já existe: a mesma proposta passa a ter um campo
-- "layout" que diz como ela sai. Duas caras, um cadastro só — porque
-- dois cadastros para a mesma venda divergem.
--
-- Nada aqui sai para o cliente por acidente: tl_get_quote continua
-- montando o objeto campo a campo, e supplier e internal_notes seguem
-- de fora.
--
-- Só toca em objetos ops_. Nada fora desse prefixo.
-- =====================================================================

-- ------------------------------------------------------ A PROPOSTA ---
alter table ops_proposals add column if not exists layout text not null default 'tabela';
comment on column ops_proposals.layout is
  'tabela = orçamento seco. apresentada = capa, índice e blocos de hospedagem.';

alter table ops_proposals add column if not exists cover_img text;
alter table ops_proposals add column if not exists cover_tag_pt text;
alter table ops_proposals add column if not exists cover_tag_en text;
comment on column ops_proposals.cover_img is 'Imagem da capa, por link.';

-- Bloco de abertura, depois da capa. É o "quem somos" da proposta.
alter table ops_proposals add column if not exists welcome_pt text;
alter table ops_proposals add column if not exists welcome_en text;

-- Itinerário dia a dia. Vazio quando a proposta é só hospedagem — e aí
-- a seção inteira não aparece, em vez de sair com título e nada dentro.
alter table ops_proposals add column if not exists itinerary jsonb not null default '[]'::jsonb;
comment on column ops_proposals.itinerary is
  'Dia a dia: [{"date","date_en","lines":[],"lines_en":[]}]. Vazio = proposta sem itinerário.';

-- ---------------------------------------------------- CADA SERVIÇO ---
-- Título e descrição passam a ter versão em inglês. As colunas antigas
-- continuam sendo o português: renomear quebraria o que já está gravado.
alter table ops_proposal_items add column if not exists title_en text;
alter table ops_proposal_items add column if not exists details_en text;

alter table ops_proposal_items add column if not exists website text;
comment on column ops_proposal_items.website is 'Site da propriedade. Ela tem de todas.';

alter table ops_proposal_items add column if not exists room_type text;
alter table ops_proposal_items add column if not exists room_type_en text;
comment on column ops_proposal_items.room_type is
  'Tipo e metragem do quarto: "Quarto superior · 35 m²".';

alter table ops_proposal_items add column if not exists photos jsonb not null default '[]'::jsonb;
comment on column ops_proposal_items.photos is 'Fotos por link, na ordem. ["https://…"]';

alter table ops_proposal_items add column if not exists attachments jsonb not null default '[]'::jsonb;
comment on column ops_proposal_items.attachments is
  'Anexos: [{"name","url"}]. Planimetria, ficha da propriedade. Por link enquanto o Storage não entra.';

-- =====================================================================
-- tl_get_quote passa a devolver os campos novos, resolvidos pelo idioma
-- da proposta, com o português como rede. Continua campo a campo.
-- =====================================================================
create or replace function tl_get_quote(p_token text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  pp ops_proposals%rowtype;
  o  ops_opportunities%rowtype;
  idioma text;
  ing    boolean;
  secs   jsonb;
  dias   jsonb;
  result jsonb;
begin
  select * into pp from ops_proposals where token = p_token;
  if not found then return null; end if;
  select * into o from ops_opportunities where id = pp.opportunity_id;
  idioma := coalesce(pp.lang, o.lang, 'pt');
  ing := idioma = 'en';

  select coalesce(jsonb_agg(jsonb_build_object(
           'key',   s->>'key',
           'title', case when ing then coalesce(nullif(s->>'title_en',''), s->>'title')
                         else coalesce(nullif(s->>'title',''), s->>'title_en') end,
           'note',  case when ing then coalesce(nullif(s->>'note_en',''), s->>'note')
                         else coalesce(nullif(s->>'note',''), s->>'note_en') end,
           'photo', s->>'photo'
         ) order by ord), '[]'::jsonb)
    into secs
    from jsonb_array_elements(coalesce(pp.sections,'[]'::jsonb)) with ordinality as t(s, ord);

  select coalesce(jsonb_agg(jsonb_build_object(
           'date',  case when ing then coalesce(nullif(d->>'date_en',''), d->>'date')
                         else coalesce(nullif(d->>'date',''), d->>'date_en') end,
           'lines', case when ing then coalesce(d->'lines_en', d->'lines')
                         else coalesce(d->'lines', d->'lines_en') end
         ) order by ord), '[]'::jsonb)
    into dias
    from jsonb_array_elements(coalesce(pp.itinerary,'[]'::jsonb)) with ordinality as t(d, ord);

  select jsonb_build_object(
    'proposal', jsonb_build_object(
      'id', pp.id, 'version', pp.version, 'title', pp.title, 'summary', pp.summary,
      'lang', idioma, 'layout', coalesce(pp.layout,'tabela'),
      'pax_summary', pp.pax_summary, 'travel_window', pp.travel_window,
      'intro', pp.intro, 'payment_note', pp.payment_note, 'terms_url', pp.terms_url,
      'cover_img', pp.cover_img,
      'cover_tag', case when ing then coalesce(nullif(pp.cover_tag_en,''), pp.cover_tag_pt)
                        else coalesce(nullif(pp.cover_tag_pt,''), pp.cover_tag_en) end,
      'welcome',   case when ing then coalesce(nullif(pp.welcome_en,''), pp.welcome_pt)
                        else coalesce(nullif(pp.welcome_pt,''), pp.welcome_en) end,
      'itinerary', dias,
      'conditions', case when ing then coalesce(nullif(pp.conditions_en,''), pp.conditions_pt, pp.conditions)
                         else coalesce(nullif(pp.conditions_pt,''), pp.conditions) end,
      'excluded',   case when ing then coalesce(nullif(pp.excluded_en,''), pp.excluded_pt)
                         else coalesce(nullif(pp.excluded_pt,''), pp.excluded_en) end,
      'sections', secs,
      'show_prices', pp.show_prices,
      'crm_code', o.crm_code, 'agency', o.agency, 'final_client', o.final_client,
      'outcome', pp.outcome, 'responded_at', pp.responded_at),
    'items', coalesce((select jsonb_agg(jsonb_build_object(
        'id', i.id, 'service_date', i.service_date,
        'title',   case when ing then coalesce(nullif(i.title_en,''), i.title)
                        else coalesce(nullif(i.title,''), i.title_en) end,
        'details', case when ing then coalesce(nullif(i.details_en,''), i.details)
                        else coalesce(nullif(i.details,''), i.details_en) end,
        'room_type', case when ing then coalesce(nullif(i.room_type_en,''), i.room_type)
                          else coalesce(nullif(i.room_type,''), i.room_type_en) end,
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

insert into ops_migrations (id) values ('0005-proposta-apresentada')
on conflict (id) do nothing;
