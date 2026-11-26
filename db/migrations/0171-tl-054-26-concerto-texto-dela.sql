-- 0171 · TL-054-26 (Bocelli Experience, Facility Turismo) · 26/11/26
--
-- O texto da noite do concerto e o "Inclui" passam a ser os que ela escreveu,
-- palavra por palavra. No "Inclui", cada frase dela vira uma linha da lista
-- (regra da casa: uma informação por linha), sem trocar palavra. O "Não
-- inclui" e o "Bom saber" ficam como estão, por instrução dela.
--
-- UPDATE em linha que já existe, pedido por ela. Guarda presa ao texto da
-- 0170. Antes de rodar: recarregar o editor, senão o save desfaz.

do $$
declare
  prop uuid := 'e0540000-0000-0000-0000-000000000001';
  n int;
begin
  if exists (select 1 from ops_proposals where id = prop and responded_at is not null) then
    raise exception '0171: a TL-054-26 já foi respondida, nada muda';
  end if;

  update ops_proposal_items set
    details =
$t$No final da tarde do dia 24, um transfer privado irá buscá-los no hotel, e vocês seguirão pelas colinas até Lajatico, a cidade onde Andrea Bocelli nasceu. Também é possível organizarmos um jantar num restaurante da região antes do concerto.

O Teatro del Silenzio é uma estrutura a céu aberto, no meio do campo. Vocês chegarão pelo acesso Executive, a cerca de 100 metros da entrada, e poderão ficar no lounge Executive até o concerto começar.

Por volta das 20h30, o maestro Bocelli subirá ao palco. Ao final do concerto, o transfer irá levá-los de volta ao hotel.$t$,
    included_pt =
$t$- Bilhete Executive, cat 2
- Acesso ao lounge Executive, com open bar até o início do concerto
- Estacionamento e entrada reservados ao setor Executive
- Presente do teatro e programa da noite
- Transfer privado do hotel ao Teatro del Silenzio e de volta ao hotel
- Bilhetes entregues no hotel
- Coordenação e assistência remota da nossa equipe, em português, no dia do concerto$t$
  where proposal_id = prop and 'Bocelli no Teatro del Silenzio' in (title, title_en)
    and position('No sábado, 24 de julho, o transfer privativo vai buscar vocês no hotel' in details) = 1;
  get diagnostics n = row_count;
  if n <> 1 then raise exception '0171: o texto do concerto não é mais o da 0170'; end if;
end $$;

insert into ops_migrations (id) values ('0171-tl-054-26-concerto-texto-dela') on conflict (id) do nothing;
