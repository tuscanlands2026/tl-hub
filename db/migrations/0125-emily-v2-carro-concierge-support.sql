-- =====================================================================
-- 0125 · EMILY (TL-053-26, v2): QUILOMETRAGEM NA LINHA DE BAIXO, SEM O
--        "OPTIONAL" DO CONCIERGE, SEM A CAIXINHA DO SUPPORT CAR
--
-- Instrução dela, 12/11/26, com o sim por escrito:
--   · carros: "quando você coloca quantidade de quilômetros inclusa, põe
--     na linha de baixo" — no cartão (ficha) e em Your proposal (row_desc);
--   · "Concierge services · optional" → "Concierge services": "tudo é
--     optional, ele pode não contratar";
--   · dia 28: "support car escorting the vintage… tira essa caixinha" —
--     sai o extra 'support' do Sunset in the Tuscan hills. O texto do dia
--     não muda.
--
-- Seção 7: update de linhas da v2 em ops_proposal_items, com o sim dela.
-- Só enquanto a proposta não foi respondida.
-- =====================================================================

do $$
declare pid uuid := 'e0530000-0000-0000-0000-000000000002'; n int;
begin
  if exists (select 1 from ops_proposals where id = pid and responded_at is not null) then
    raise exception '0125: a proposta já foi respondida, nada muda';
  end if;

  -- 1 · carros: km na linha de baixo
  update ops_proposal_items i set
    units = (select jsonb_agg(
               case u->>'key'
                 when 'c1' then u || jsonb_build_object(
                   'ficha', E'Available models: Mercedes GLE, Maserati Grecale Modena or Audi Q8\n1,400 km included',
                   'row_desc', E'Mercedes GLE, Maserati Grecale Modena or Audi Q8, subject to availability\n1,400 km included · fuel not included')
                 when 'c2' then u || jsonb_build_object(
                   'ficha', E'Available models: Land Rover Defender 110, BMW X7 or Range Rover Sport\n1,050 km included',
                   'row_desc', E'Land Rover Defender 110, BMW X7 or Range Rover Sport, subject to availability\n1,050 km included · fuel not included')
                 else u end order by o)
               from jsonb_array_elements(i.units) with ordinality t(u, o))
   where proposal_id = pid and section = 'around' and title_en = 'Your car in Tuscany';
  get diagnostics n = row_count;
  if n <> 1 then raise exception '0125: linha dos carros não encontrada'; end if;

  -- 2 · concierge sem "optional"
  update ops_proposal_items set title_en = 'Concierge services'
   where proposal_id = pid and section = 'around' and title_en = 'Concierge services · optional';
  get diagnostics n = row_count;
  if n <> 1 then raise exception '0125: concierge não encontrado'; end if;

  -- 3 · sem o support car
  update ops_proposal_items i set
    extras = coalesce((select jsonb_agg(e order by o)
                         from jsonb_array_elements(i.extras) with ordinality t(e, o)
                        where e->>'key' <> 'support'), '[]'::jsonb)
   where proposal_id = pid and title_en = 'Sunset in the Tuscan hills'
     and extras @> '[{"key":"support"}]';
  get diagnostics n = row_count;
  if n <> 1 then raise exception '0125: support car não encontrado'; end if;
end $$;

insert into ops_migrations (id) values ('0125-emily-v2-carro-concierge-support') on conflict (id) do nothing;
