-- =====================================================================
-- 0126 · CORRIGE A 0125: A QUILOMETRAGEM IA PARA A CHAVE ERRADA
--
-- A 0125 gravou o texto novo dos carros em units[].ficha e
-- units[].row_desc, que são as chaves em PORTUGUÊS. A proposta é em
-- inglês e lê ficha_en e row_desc_en, que ficaram como estavam: a
-- quilometragem continuou na mesma linha.
--
-- Aqui o texto vai para ficha_en e row_desc_en, e as duas chaves que a
-- 0125 criou saem. Elas não existiam antes nesses dois carros (a 0102 e a
-- 0119 só gravaram as _en, e o editor não escreve nelas): tirar devolve o
-- que havia.
--
-- Seção 7: update de uma linha da v2, com o sim dela à mudança da 0125.
-- =====================================================================

do $$
declare pid uuid := 'e0530000-0000-0000-0000-000000000002'; n int;
begin
  if exists (select 1 from ops_proposals where id = pid and responded_at is not null) then
    raise exception '0126: a proposta já foi respondida, nada muda';
  end if;

  update ops_proposal_items i set
    units = (select jsonb_agg(
               case u->>'key'
                 when 'c1' then (u - 'ficha' - 'row_desc') || jsonb_build_object(
                   'ficha_en', E'Available models: Mercedes GLE, Maserati Grecale Modena or Audi Q8\n1,400 km included',
                   'row_desc_en', E'Mercedes GLE, Maserati Grecale Modena or Audi Q8, subject to availability\n1,400 km included · fuel not included')
                 when 'c2' then (u - 'ficha' - 'row_desc') || jsonb_build_object(
                   'ficha_en', E'Available models: Land Rover Defender 110, BMW X7 or Range Rover Sport\n1,050 km included',
                   'row_desc_en', E'Land Rover Defender 110, BMW X7 or Range Rover Sport, subject to availability\n1,050 km included · fuel not included')
                 else u end order by o)
               from jsonb_array_elements(i.units) with ordinality t(u, o))
   where proposal_id = pid and section = 'around' and title_en = 'Your car in Tuscany';
  get diagnostics n = row_count;
  if n <> 1 then raise exception '0126: linha dos carros não encontrada'; end if;
end $$;

insert into ops_migrations (id) values ('0126-emily-v2-corrige-km-do-carro') on conflict (id) do nothing;
