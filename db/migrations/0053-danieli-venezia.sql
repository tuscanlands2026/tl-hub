-- =====================================================================
-- 0053 · DANIELI, VENEZIA, A FOUR SEASONS HOTEL
--
-- Instrução dela, outubro/26: "four seasons tem que fazer separado,
-- procure nos sites as informações corretas". A 0051 tinha posto os dois
-- num arquivo só e com o mínimo; agora cada um tem o seu, e com tudo que
-- a fonte oficial dá.
--
-- ATUALIZA A LINHA QUE A 0051 CRIOU, pelo mesmo id. Se ela já tiver
-- digitado alguma coisa nesta ficha, o que está aqui passa por cima —
-- foi avisado na mensagem. Nenhuma outra linha do banco é tocada.
--
-- A FONTE É O COMUNICADO OFICIAL DE REABERTURA da Four Seasons, de 30 de
-- julho de 2026 (press.fourseasons.com/venice/hotel-news/2026/now-open).
--
-- ESTE HOTEL NÃO TEM FACT SHEET AINDA. Procurei: a página de FACTS não
-- existe no press kit dele, e o servlet que entrega o Word da fact sheet
-- devolve arquivo VAZIO para venice, venezia e danieli. Ele reabriu em
-- julho e o material ainda está sendo montado.
--
-- POR ISSO CONTINUA SEM CATEGORIA DE QUARTO: não é que eu não tenha
-- procurado, é que a Four Seasons ainda não publicou. E fourseasons.com
-- responde 403 a esta máquina, o domínio inteiro.
--
-- UMA DIVERGÊNCIA QUE FICA REGISTRADA: sites de terceiros dizem 176
-- quartos e 79 suítes. O comunicado da própria Four Seasons diz 120 agora
-- e 168 quando o Palazzo Danieli Excelsior ficar pronto, em 2027. Ficou o
-- oficial.
--
-- AS FOTOS SÃO OFICIAIS, do banco de imagens do press kit, na versão 722px.
--
-- Só cria e preenche objetos ops_. Nenhum delete.
-- =====================================================================

update ops_suppliers set
  subcategories = array['City hotel','Historic building','Palazzo'],
  business_suite = array['TL Selected Stays'],
  languages = array['Italian','English'],
  accommodation_summary = E'Reopened on 30 July 2026 with 120 rooms and suites, growing to 168 once the restoration of Palazzo Danieli Excelsior is complete in 2027. The restoration of Palazzo Dandolo and Palazzo Casa Nuova brought more generous layouts and an expanded collection of Junior Suites and One-Bedroom Suites; many suites can be extended through connecting rooms. Four Seasons has not published the category list or the floor areas.',
  accommodation_notes = E'Rooms and suites look over the Lagoon, the canals or the rooftops. Interiors by Pierre-Yves Rochon. A bespoke media wall sets the television inside a composition of artwork and objects; automated curtains, scene lighting and climate control are in every room.',
  highlights = array[
    'Palazzo Dandolo, built in 1471 as the residence of the Dandolo family, one of the finest examples of Venetian Gothic architecture',
    'Palazzo Casa Nuova, once home to the Treasury of the Venetian Republic',
    'Palazzo Danieli Excelsior, under restoration until 2027',
    'On the Riva degli Schiavoni, with the Lagoon and San Giorgio Maggiore from the rooftop; in many rooms the curtains part on the Lagoon like those of a theatre',
    'Interiors by Pierre-Yves Rochon, in a lagoon palette of celadon green, soft blue, terracotta, ochre and powder pink, drawn from the city''s marble façades and historic plasterwork',
    'Murano glass, terrazzo floors and bespoke Rubelli textiles',
    'Hand-restored ceiling in the Palazzo Dandolo lobby',
    'Artwork collection drawn from the spirit of the Grand Tour: intaglios, Venetian engravings and antiqued mirrors',
    'Restaurant and Bar Terrazza Danieli on the roof, redesigned in soft pastels, azure and muted gold; executive chef Adriano Rausa, with many signature dishes finished at the table',
    'Danieli Spa from late 2026: three treatment rooms, one for couples, plus sauna and hammam',
    'Reopened 30 July 2026 after four years of restoration; general manager Christian Zandonella; in partnership with Gruppo Statuto'],
  tags = array['Venice','Riva degli Schiavoni','palazzo','Four Seasons','new opening','Venetian Gothic'],
  summary = E'Venice''s oldest grand hotel, reopened by Four Seasons on 30 July 2026 after four years of restoration. Three palazzi on the Riva degli Schiavoni, the oldest of them the Dandolo residence of 1471, with the Lagoon and San Giorgio Maggiore from the rooftop restaurant. Pierre-Yves Rochon took the palette from the lagoon and the materials from the city: Murano glass, terrazzo, Rubelli textiles. One hundred and twenty rooms now, one hundred and sixty-eight in 2027.',
  open_points = array[
    'ROOM CATEGORIES AND FLOOR AREAS ARE STILL MISSING: this hotel has no FACTS page in the press kit yet and the Word fact sheet servlet returns an empty file. fourseasons.com answers 403 to this machine. Ask Four Seasons for the room fact sheet.',
    'Third-party sites say 176 rooms and 79 suites; the Four Seasons release says 120 now and 168 in 2027. The official figure was kept.',
    'The spa opens late 2026: do not promise it for an earlier date.',
    'Net rates, cancellation policy and payment terms to the supplier not yet collected.',
    'Photo usage not cleared: these are press images, usage_cleared is false.'],
  updated_at = now()
where id = '29000000-0000-0000-0000-000000000000';

-- Fotos oficiais do press kit --
insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('29000000-0000-0000-0000-000000000001', '29000000-0000-0000-0000-000000000000', null, E'https://press.fourseasons.com/content/dam/fourseasons/images/web/DAN/DAN_261_aspect16x9.jpg/jcr:content/renditions/cq5dam.web.press.722.keepaspectratio.jpeg', E'https://press.fourseasons.com/venice/', E'Danieli, Venezia, A Four Seasons Hotel', true, false, 1)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('29000000-0000-0000-0000-000000000002', '29000000-0000-0000-0000-000000000000', null, E'https://press.fourseasons.com/content/dam/fourseasons/images/web/DAN/DAN_262_aspect16x9.jpg/jcr:content/renditions/cq5dam.web.press.722.keepaspectratio.jpeg', E'https://press.fourseasons.com/venice/', E'Danieli, Venezia, A Four Seasons Hotel', true, false, 2)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('29000000-0000-0000-0000-000000000003', '29000000-0000-0000-0000-000000000000', null, E'https://press.fourseasons.com/content/dam/fourseasons/images/web/DAN/DAN_263_aspect16x9.jpg/jcr:content/renditions/cq5dam.web.press.722.keepaspectratio.jpeg', E'https://press.fourseasons.com/venice/', E'Danieli, Venezia, A Four Seasons Hotel', true, false, 3)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('29000000-0000-0000-0000-000000000004', '29000000-0000-0000-0000-000000000000', null, E'https://press.fourseasons.com/content/dam/fourseasons/images/web/DAN/DAN_264_aspect16x9.jpg/jcr:content/renditions/cq5dam.web.press.722.keepaspectratio.jpeg', E'https://press.fourseasons.com/venice/', E'Danieli, Venezia, A Four Seasons Hotel', true, false, 4)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('29000000-0000-0000-0000-000000000005', '29000000-0000-0000-0000-000000000000', null, E'https://press.fourseasons.com/content/dam/fourseasons/images/web/DAN/DAN_265_aspect16x9.jpg/jcr:content/renditions/cq5dam.web.press.722.keepaspectratio.jpeg', E'https://press.fourseasons.com/venice/', E'Danieli, Venezia, A Four Seasons Hotel', true, false, 5)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('29000000-0000-0000-0000-000000000006', '29000000-0000-0000-0000-000000000000', null, E'https://press.fourseasons.com/content/dam/fourseasons/images/web/DAN/DAN_266_aspect16x9.jpg/jcr:content/renditions/cq5dam.web.press.722.keepaspectratio.jpeg', E'https://press.fourseasons.com/venice/', E'Danieli, Venezia, A Four Seasons Hotel', true, false, 6)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('29000000-0000-0000-0000-000000000007', '29000000-0000-0000-0000-000000000000', null, E'https://press.fourseasons.com/content/dam/fourseasons/images/web/DAN/DAN_267_aspect16x9.jpg/jcr:content/renditions/cq5dam.web.press.722.keepaspectratio.jpeg', E'https://press.fourseasons.com/venice/', E'Danieli, Venezia, A Four Seasons Hotel', true, false, 7)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_supplier_photos (id, supplier_id, room_type_id, url, source_url, caption, ok_for_proposal, usage_cleared, sort_order)
values ('29000000-0000-0000-0000-000000000008', '29000000-0000-0000-0000-000000000000', null, E'https://press.fourseasons.com/content/dam/fourseasons/images/web/DAN/DAN_268_aspect16x9.jpg/jcr:content/renditions/cq5dam.web.press.722.keepaspectratio.jpeg', E'https://press.fourseasons.com/venice/', E'Danieli, Venezia, A Four Seasons Hotel', true, false, 8)
on conflict (id) do update set url = excluded.url, source_url = excluded.source_url,
  caption = excluded.caption, ok_for_proposal = excluded.ok_for_proposal,
  room_type_id = excluded.room_type_id, sort_order = excluded.sort_order;

insert into ops_migrations (id) values ('0053-danieli-venezia') on conflict (id) do nothing;
