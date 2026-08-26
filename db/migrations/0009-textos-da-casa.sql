-- =====================================================================
-- 0009 · O TEXTO DELA E A CONTRACAPA
--
-- Ela mandou as três páginas prontas: "quem somos" em português, a
-- mesma em inglês e a contracapa com os contatos. É material da casa,
-- já diagramado por ela — entra palavra por palavra, e o que eu tinha
-- escrito sai.
--
-- A contracapa não muda de proposta para proposta, mas mora na proposta
-- como as outras: se um telefone mudar, as propostas já enviadas
-- continuam com o número que estava certo no dia.
--
-- Só toca em objetos ops_. Nada fora desse prefixo.
-- =====================================================================

alter table ops_proposals add column if not exists backcover_pt text;
alter table ops_proposals add column if not exists backcover_en text;

update ops_text_defaults set pt = E'**Transformando a Itália em histórias inesquecíveis.**\nNa Toscana, Umbria e Lazio, há uma Itália que poucos conhecem. É aquela dos pequenos momentos, das descobertas inesperadas, do tempo que corre no ritmo certo. Uma Itália que se revela para quem sabe onde e quando procurar.\nA Tuscan Lands Signature Italian Travel é uma DMC (Destination Management Company) local que une o acolhimento brasileiro às raízes italianas, proporcionando acesso a uma Itália autêntica e além do clássico.\nCom mais de 8 anos de presença no território, oferecemos uma curadoria especializada que combina hospedagens boutique, experiências autênticas e organização impecável. Mantemos relações próximas com parceiros locais selecionados, permitindo que cada viajante — seja individual ou agência de viagem — descubra uma Itália que vai além das rotas tradicionais.\nPorque aqui, a beleza também está nos detalhes que poucos percebem.', en = E'**Turning Italy into stories worth remembering.**\nIn Tuscany, Umbria, and Lazio, there''s an Italy most people never find. It lives in small moments, unexpected discoveries, and days that move at just the right pace.\nAn Italy that reveals itself to those who know where — and when — to look.\nTL Signature Italian Travel is a locally rooted DMC with over eight years on the ground in Tuscany, Umbria, and Lazio. Our story is built on personal relationships, genuine hospitality, and an honest love for this part of the world.\nWe work with a carefully chosen network of local partners to create travel that feels considered at every level: boutique properties with real character, experiences that connect rather than perform, and operations that run quietly in the background so nothing gets in the way.\nAs a guest, what you get is access to an Italy that lives up to everything you''ve always imagined during your days at the bel paese.', updated_at = now() where key = 'about';

insert into ops_text_defaults (key, pt, en) values ('backcover', E'**TL Team**\nAtendimento em português, inglês e italiano.\n**INQUIRIES & PARTNER DESK**\n+39 351 822 0196 (WhatsApp)\nhello@tuscanlandstravel.com\n**BOOKING & CONCIERGE**\n+39 351 757 0067 (WhatsApp)\nbooking@tuscanlandstravel.com\nwww.tuscanlandstravel.com', E'**TL Team**\nAvailable in English, Portuguese and Italian.\n**INQUIRIES & PARTNER DESK**\n+39 351 822 0196 (WhatsApp)\nhello@tuscanlandstravel.com\n**BOOKING & CONCIERGE**\n+39 351 757 0067 (WhatsApp)\nbooking@tuscanlandstravel.com\nwww.tuscanlandstravel.com')
on conflict (key) do update
   set pt = coalesce(nullif(ops_text_defaults.pt,''), excluded.pt),
       en = coalesce(nullif(ops_text_defaults.en,''), excluded.en),
       updated_at = now();

-- A proposta guarda uma cópia do texto. A cópia feita antes deste
-- arquivo tem o texto que eu escrevi; se ela ainda não editou, troca.
-- Editou, fica: proposta enviada não se reescreve pelas costas.
update ops_proposals set about_pt = (select pt from ops_text_defaults where key='about')
 where about_pt like 'A Tuscan Lands é um DMC boutique com base em Pontassieve%'
    or about_pt like 'Uma DMC boutique, com base em Florença.%';
update ops_proposals set about_en = (select en from ops_text_defaults where key='about')
 where about_en like 'Tuscan Lands is a boutique DMC based in Pontassieve%'
    or about_en like 'A boutique DMC based in Florence.%';

update ops_proposals set
  about_pt      = coalesce(nullif(about_pt,''),      (select pt from ops_text_defaults where key='about')),
  about_en      = coalesce(nullif(about_en,''),      (select en from ops_text_defaults where key='about')),
  backcover_pt  = coalesce(nullif(backcover_pt,''),  (select pt from ops_text_defaults where key='backcover')),
  backcover_en  = coalesce(nullif(backcover_en,''),  (select en from ops_text_defaults where key='backcover'))
where layout = 'apresentada';

-- A contracapa entra no que o cliente recebe.
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
      'backcover', case when ing then coalesce(nullif(pp.backcover_en,''), pp.backcover_pt)
                        else coalesce(nullif(pp.backcover_pt,''), pp.backcover_en) end,
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

insert into ops_migrations (id) values ('0009-textos-da-casa') on conflict (id) do nothing;
