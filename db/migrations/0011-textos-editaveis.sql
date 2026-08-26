-- =====================================================================
-- 0011 · OS TÍTULOS DA PROPOSTA SÃO DELA, NÃO MEUS
--
-- "Sobre nós", "Proposta e condições comerciais", o convite da capa, o
-- aviso de que enviar não bloqueia — tudo isso estava escrito no código.
-- Trocar uma palavra virava pedido de alteração, e isso não escala:
-- cada proposta tem um tom, e quem escreve é ela.
--
-- Agora cada rótulo tem um padrão embutido e uma cópia opcional na
-- proposta. Campo vazio usa o padrão; preenchido, vale o dela. Assim
-- proposta antiga não muda quando o padrão mudar, e ela não precisa
-- reescrever tudo para trocar uma linha.
--
-- Só toca em objetos ops_. Nada fora desse prefixo.
-- =====================================================================

alter table ops_proposals add column if not exists labels jsonb not null default '{}'::jsonb;
comment on column ops_proposals.labels is
  'Textos que ela pode reescrever: {"chave":{"pt":"…","en":"…"}}. Vazio = usa o padrão do hub.';

create or replace function tl_get_quote(p_token text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  pp ops_proposals%rowtype; o ops_opportunities%rowtype;
  idioma text; ing boolean; secs jsonb; dias jsonb; rots jsonb; result jsonb;
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

  -- Cada rótulo vira texto simples no idioma do documento. Vazio fica
  -- fora do objeto, e a tela usa o padrão dela.
  select coalesce(jsonb_object_agg(k, v), '{}'::jsonb) into rots from (
    select r.key as k,
           case when ing then coalesce(nullif(r.value->>'en',''), nullif(r.value->>'pt',''))
                else coalesce(nullif(r.value->>'pt',''), nullif(r.value->>'en','')) end as v
      from jsonb_each(coalesce(pp.labels,'{}'::jsonb)) r
  ) x where v is not null;

  select jsonb_build_object(
    'proposal', jsonb_build_object(
      'id', pp.id, 'version', pp.version, 'title', pp.title, 'summary', pp.summary,
      'lang', idioma, 'layout', coalesce(pp.layout,'tabela'), 'labels', rots,
      'pax_summary', pp.pax_summary, 'travel_window', pp.travel_window,
      'intro', pp.intro, 'payment_note', pp.payment_note, 'terms_url', pp.terms_url,
      'cover_img', pp.cover_img, 'about_img', pp.about_img,
      'cover_tag', case when ing then coalesce(nullif(pp.cover_tag_en,''), pp.cover_tag_pt)
                        else coalesce(nullif(pp.cover_tag_pt,''), pp.cover_tag_en) end,
      'about', case when ing then coalesce(nullif(pp.about_en,''), pp.about_pt)
                    else coalesce(nullif(pp.about_pt,''), pp.about_en) end,
      'credentials', case when ing then coalesce(nullif(pp.credentials_en,''), pp.credentials_pt)
                          else coalesce(nullif(pp.credentials_pt,''), pp.credentials_en) end,
      'backcover', case when ing then coalesce(nullif(pp.backcover_en,''), pp.backcover_pt)
                        else coalesce(nullif(pp.backcover_pt,''), pp.backcover_en) end,
      'itinerary', dias,
      'conditions', case when ing then coalesce(nullif(pp.conditions_en,''), pp.conditions_pt, pp.conditions)
                         else coalesce(nullif(pp.conditions_pt,''), pp.conditions) end,
      'excluded', case when ing then coalesce(nullif(pp.excluded_en,''), pp.excluded_pt)
                       else coalesce(nullif(pp.excluded_pt,''), pp.excluded_en) end,
      'sections', secs, 'show_prices', pp.show_prices,
      'payment_options', coalesce((select jsonb_agg(jsonb_build_object(
          'key', po->>'key',
          'label', case when ing then coalesce(nullif(po->>'label_en',''), po->>'label')
                        else coalesce(nullif(po->>'label',''), po->>'label_en') end) order by ord)
        from jsonb_array_elements(coalesce(pp.payment_options,'[]'::jsonb)) with ordinality as q(po, ord)),
        '[]'::jsonb),
      'crm_code', o.crm_code, 'agency', o.agency, 'final_client', o.final_client,
      'agency_contact', o.agency_contact,
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
        'included', case when ing then coalesce(nullif(i.included_en,''), i.included_pt)
                         else coalesce(nullif(i.included_pt,''), i.included_en) end,
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

insert into ops_migrations (id) values ('0011-textos-editaveis') on conflict (id) do nothing;
