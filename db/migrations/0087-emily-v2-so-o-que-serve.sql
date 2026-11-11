-- =====================================================================
-- 0087 · EMILY (TL-053-26, v2): SÓ O QUE SERVE PARA ELES
--
-- Instrução dela, nov/26, sobre a 0086: "coloca as informações que são
-- úteis. Quantos dormem é inútil. Se aceita animais, se aceita criança,
-- qualquer coisa para criança, é inútil." São dois adultos.
--
-- Sai do card do Castelfalfi na v2:
--   · "sleeps 3" e "sleeps 4";
--   · "extra single bed available" e "sofa bed" (cama a mais é para
--     terceira pessoa) — no rótulo e no texto da Suite Terrace;
--   · "for guests over 14" no acesso ao spa.
-- Fica: king bed, metragem, terraço, sala, closet, o que inclui.
--
-- Regra para as próximas: hóspede a mais, criança e animal não entram na
-- peça de uma viagem que não tem nenhum dos três.
--
-- Troca de trecho por replace, guardado pela presença do trecho. Mexe só
-- na v2 (e0530000-…-0002), sem link enviado e sem resposta.
--
-- Seção 7: ops_proposal_items (update na v2), ops_migrations (insert).
-- =====================================================================

update ops_proposal_items set
  units = E'[{"key":"u1","label":"Junior Suite Terrace · 40 m² / 431 sq ft · king bed · private terrace, countryside view","label_en":"Junior Suite Terrace · 40 m² / 431 sq ft · king bed · private terrace, countryside view","price":0,"optional":true},
     {"key":"u2","label":"Suite Terrace · 61 m² / 657 sq ft · king bed · living room, walk-in closet, private terrace","label_en":"Suite Terrace · 61 m² / 657 sq ft · king bed · living room, walk-in closet, private terrace","price":0,"optional":true}]'::jsonb,
  details_en = replace(details_en, 'a living room with sofa bed, a walk-in closet', 'a living room, a walk-in closet'),
  included_en = replace(included_en, ' heated pool, for guests over 14.', ' heated pool.')
 where proposal_id = 'e0530000-0000-0000-0000-000000000002'
   and 'Castelfalfi' in (coalesce(title,''), coalesce(title_en,''))
   and units::text like '%sleeps 3%'
   and coalesce((select sum((u->>'price')::numeric) from jsonb_array_elements(units) u),0) = 0
   and exists (select 1 from ops_proposals p
                where p.id = 'e0530000-0000-0000-0000-000000000002' and p.responded_at is null);

insert into ops_migrations (id) values ('0087-emily-v2-so-o-que-serve') on conflict (id) do nothing;
