-- =====================================================================
-- 0086 · EMILY (TL-053-26, v2): AS DUAS CATEGORIAS DO CASTELFALFI
--
-- Ela mandou o texto das duas categorias (nov/26), do material do hotel:
-- Junior Suite Terrace (ou Garden) e Suite Terrace. Resolve o que a 0083
-- deixou em aberto: a Junior Suite Terrace TEM king bed (+ 1 cama de
-- solteiro adicional, até 3 pessoas). A página dela no site pedia CAPTCHA.
--
-- Na v2, no card do Castelfalfi:
--   · as duas categorias ganham cama, ocupação e o que distingue cada uma;
--   · o texto do card ganha um parágrafo por categoria, com o nome em
--     negrito, depois da descrição do hotel — do texto dela, enxugado,
--     sem acrescentar nada que ela não mandou;
--   · o "inclui" ganha o acesso ao RAKxa Wellness Spa (ela marcou INCLUI).
--     Entra no card, valendo para as duas categorias — se for só de uma,
--     muda de lugar.
--
-- Valores continuam em branco (price 0). A ficha do fornecedor
-- (ops_room_types) NÃO é tocada: lá a Junior Suite Terrace diz 41 m² e
-- "1 bedroom", do fact sheet; corrigir a ficha é trocar dado que já
-- existe, e fica para quando ela disser.
--
-- Mexe só na v2 (e0530000-…-0002), sem link enviado e sem resposta.
-- Guardado: o texto só é acrescentado se ainda não tiver as categorias.
--
-- Seção 7: ops_proposal_items (update na v2), ops_migrations (insert).
-- =====================================================================

update ops_proposal_items set
  units = E'[{"key":"u1","label":"Junior Suite Terrace · 40 m² / 431 sq ft · king bed, extra single bed available · sleeps 3 · private terrace, countryside view","label_en":"Junior Suite Terrace · 40 m² / 431 sq ft · king bed, extra single bed available · sleeps 3 · private terrace, countryside view","price":0,"optional":true},
     {"key":"u2","label":"Suite Terrace · 61 m² / 657 sq ft · king bed and sofa bed · sleeps 4 · living room, walk-in closet, private terrace","label_en":"Suite Terrace · 61 m² / 657 sq ft · king bed and sofa bed · sleeps 4 · living room, walk-in closet, private terrace","price":0,"optional":true}]'::jsonb,
  details_en = details_en || E'\n\n**Junior Suite Terrace**\nThe highlight is the private terrace, with panoramic views over rolling hills, olive groves and vineyards, an extension of the suite for a morning coffee or a sunset aperitif. Inside, refined furnishings in warm tones and materials that recall traditional Tuscan design. Marble bathroom with bathtub and shower, Dyson hairdryer, coffee and tea maker, and a minibar with water and soft drinks included.\n\n**Suite Terrace**\nA sequence of spacious rooms: a living room with sofa bed, a walk-in closet, the bedroom and a travertine marble bathroom with separate shower and bathtub. Large windows light both the sleeping and the living area, and the large private terrace looks onto the Tuscan countryside. Turndown service, a minibar with water and soft drinks included, and access to the Beach Club in Forte dei Marmi.\n\nRoom images are by way of example; shades and arrangement of the furnishings may vary.',
  included_en = E'Flexible rate, breakfast included. Access to the RAKxa Wellness Spa, with two saunas, a Turkish bath, the vitality pool and an indoor/outdoor heated pool, for guests over 14. City tax and extras are not included.'
 where proposal_id = 'e0530000-0000-0000-0000-000000000002'
   and 'Castelfalfi' in (coalesce(title,''), coalesce(title_en,''))
   and position('**Junior Suite Terrace**' in coalesce(details_en,'')) = 0
   and coalesce((select sum((u->>'price')::numeric) from jsonb_array_elements(units) u),0) = 0
   and exists (select 1 from ops_proposals p
                where p.id = 'e0530000-0000-0000-0000-000000000002' and p.responded_at is null);

insert into ops_migrations (id) values ('0086-emily-v2-quartos-castelfalfi') on conflict (id) do nothing;
