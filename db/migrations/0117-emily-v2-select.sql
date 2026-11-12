-- =====================================================================
-- 0117 · EMILY (TL-053-26, v2): "SELECT", E NÃO "CHOOSE"
--
-- Instrução dela, nov/26: "não use choose, use select". Três lugares:
--   · a abertura da folha de hospedagem;
--   · o depósito, nas condições de pagamento;
--   · a opção dois do shopping ("the looks you'll choose from").
--
-- Troca pontual de palavra, só onde a frase ainda está como a 0116 deixou.
--
-- Seção 7: update em ops_proposals (uma linha) e em uma linha de
-- ops_proposal_items da v2, com o sim dela.
-- =====================================================================

do $mig$
declare v uuid := 'e0530000-0000-0000-0000-000000000002';
begin
  if not exists (select 1 from ops_proposals where id = v and responded_at is null) then
    raise notice '0117: v2 já respondida ou inexistente — nada feito';
    return;
  end if;

  update ops_proposals p set
    sections = (select jsonb_agg(
                  case when s->>'key' = 'stays' and s->>'intro_en' = 'Choose your room in each hotel.'
                       then s || jsonb_build_object('intro_en', 'Select your room in each hotel.')
                       else s end order by o)
                  from jsonb_array_elements(p.sections) with ordinality t(s, o)),
    conditions_en = replace(conditions_en, 'you may choose between two options', 'you may select between two options'),
    updated_at = now()
   where p.id = v;

  update ops_proposal_items i set
    units = (select jsonb_agg(
               case when u->>'key' = 'o2'
                    then u || jsonb_build_object('desc_en', replace(u->>'desc_en', $t$the looks you'll choose from$t$, $t$the looks you'll select from$t$))
                    else u end order by o)
               from jsonb_array_elements(i.units) with ordinality t(u, o))
   where proposal_id = v and section = 'roma'
     and title_en = $t$Rome's fashion houses, with a personal stylist$t$;
end $mig$;

insert into ops_migrations (id) values ('0117-emily-v2-select') on conflict (id) do nothing;
