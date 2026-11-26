-- 0174 · TL-054-26 (Bocelli Experience, Facility Turismo) · 26/11/26
--
-- A linha da Validade, nas condições gerais, passa à frase dela: os valores
-- estão sujeitos a atualização e valem enquanto houver disponibilidade. As
-- condições são da proposta, então a troca vale para os dois links (a peça
-- do cliente e o link dos valores da agência).
--
-- UPDATE em linha que já existe, autorizado por ela ("sim, mude"). Guarda
-- presa à frase que se troca. Antes de rodar: recarregar o editor.

do $$
declare
  prop uuid := 'e0540000-0000-0000-0000-000000000001';
  n int;
begin
  if exists (select 1 from ops_proposals where id = prop and responded_at is not null) then
    raise exception '0174: a TL-054-26 já foi respondida, nada muda';
  end if;

  update ops_proposals set conditions_pt = replace(conditions_pt,
    '**Validade:** as condições desta proposta valem enquanto houver disponibilidade.',
    '**Validade:** os valores desta proposta estão sujeitos a atualização e são válidos enquanto houver disponibilidade.')
  where id = prop
    and position('**Validade:** as condições desta proposta valem enquanto houver disponibilidade.' in conditions_pt) > 0;
  get diagnostics n = row_count;
  if n <> 1 then raise exception '0174: a linha da Validade não é mais a da 0168'; end if;
end $$;

insert into ops_migrations (id) values ('0174-tl-054-26-validade-dos-valores') on conflict (id) do nothing;
