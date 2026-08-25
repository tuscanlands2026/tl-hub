-- =====================================================================
-- 0007 · QUEM SOMOS, NO FIM E NÃO NO COMEÇO
--
-- O bloco de apresentação saía logo depois da capa, antes de o cliente
-- ver qualquer hospedagem. Ela mandou o contrário: primeiro o que está
-- sendo proposto, e só perto do fim — na página antes do resumo — quem
-- é a Tuscan Lands e por que ela é regularizada.
--
-- Faz sentido: quem abre a proposta quer ver a villa. A credencial
-- responde a uma pergunta que só aparece depois, na hora de aprovar.
--
-- Duas camadas, como no texto das condições: o padrão da casa fica em
-- ops_text_defaults e toda proposta nova nasce com uma cópia, que ela
-- edita sem mexer nas outras.
--
-- Só toca em objetos ops_. Nada fora desse prefixo.
-- =====================================================================

alter table ops_proposals add column if not exists about_pt text;
alter table ops_proposals add column if not exists about_en text;
alter table ops_proposals add column if not exists credentials_pt text;
alter table ops_proposals add column if not exists credentials_en text;
comment on column ops_proposals.about_pt is
  'Quem é a Tuscan Lands. Sai na seção antes do resumo, não na abertura.';

insert into ops_text_defaults (key, pt, en) values
  ('about', E'A Tuscan Lands é um DMC boutique com base em Pontassieve, na Toscana, operando na Toscana, Umbria e Lazio.\nTrabalhamos com um número pequeno de viagens por vez. Cada proposta é desenhada caso a caso, e a operação em campo é conduzida por nós — não é repassada a um receptivo terceiro.', E'Tuscan Lands is a boutique DMC based in Pontassieve, Tuscany, operating in Tuscany, Umbria and Lazio.\nWe take on a small number of trips at a time. Every proposal is designed case by case, and operations on the ground are run by us — not handed over to a third-party receptive.'),
  ('credentials', E'- DMC licenciada · CCIAA Firenze FI-703029\n- Seguro Unipol n.º 1886/319/177004899\n- Garantia: Fondo Privato di Garanzia Viaggi', E'- Licensed DMC · CCIAA Florence FI-703029\n- Professional liability Unipol No. 1886/319/177004899\n- Insolvency guarantee: Fondo Privato di Garanzia Viaggi')
on conflict (key) do update
   set pt = coalesce(nullif(ops_text_defaults.pt,''), excluded.pt),
       en = coalesce(nullif(ops_text_defaults.en,''), excluded.en),
       updated_at = now();

-- tl_get_quote devolve os dois, resolvidos pelo idioma.
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
      'about', case when ing then coalesce(nullif(pp.about_en,''), pp.about_pt)
                    else coalesce(nullif(pp.about_pt,''), pp.about_en) end,
      'credentials', case when ing then coalesce(nullif(pp.credentials_en,''), pp.credentials_pt)
                          else coalesce(nullif(pp.credentials_pt,''), pp.credentials_en) end,
      'itinerary', dias,
      'conditions', case when ing then coalesce(nullif(pp.conditions_en,''), pp.conditions_pt, pp.conditions)
                         else coalesce(nullif(pp.conditions_pt,''), pp.conditions) end,
      'excluded', case when ing then coalesce(nullif(pp.excluded_en,''), pp.excluded_pt)
                       else coalesce(nullif(pp.excluded_pt,''), pp.excluded_en) end,
      'sections', secs, 'show_prices', pp.show_prices,
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

insert into ops_migrations (id) values ('0007-quem-somos') on conflict (id) do nothing;
