-- 0170 · TL-054-26 (Bocelli Experience, Facility Turismo) · 26/11/26
--
-- Crítica dela ao texto da 0169: "você está escrevendo um catálogo, você
-- não está vendendo uma experiência". E o tempo verbal: futuro com "vai"
-- (vai buscar, vai levar), nunca "buscará", nem presente de ficha técnica.
--
-- Os fatos continuam os mesmos da proposta e da oferta do teatro; o que
-- entra a mais é público e conferível: Lajatico é a cidade natal do
-- Bocelli.
--
-- UPDATE em linha que já existe, pedido por ela. Guarda presa à frase da
-- 0169. Antes de rodar: recarregar o editor, senão o save desfaz.

do $$
declare
  prop uuid := 'e0540000-0000-0000-0000-000000000001';
  n int;
begin
  if exists (select 1 from ops_proposals where id = prop and responded_at is not null) then
    raise exception '0170: a TL-054-26 já foi respondida, nada muda';
  end if;

  update ops_proposal_items set details =
$t$No sábado, 24 de julho, o transfer privativo vai buscar vocês no hotel e seguir pelas colinas até Lajatico, a cidade onde Andrea Bocelli nasceu. Quem escolher o jantar vai parar antes num restaurante da região, no caminho, e seguir para o teatro depois.

No Teatro del Silenzio, vocês vão entrar pelo acesso Executive, e o carro deixa vocês a cerca de 100 metros da entrada. Até o concerto começar, vocês vão esperar no lounge Executive, com open bar, enquanto o sol desce sobre o campo.

Às 20h30, Bocelli sobe ao palco. Vocês vão estar no setor Executive, de frente para ele, com o presente do teatro e o programa da noite nas mãos.

Quando a música terminar, o mesmo transfer vai estar esperando para levar vocês de volta ao hotel.

Os bilhetes vão ser entregues no hotel, e vocês vão ter assistência por telefone.$t$
  where proposal_id = prop and 'Bocelli no Teatro del Silenzio' in (title, title_en)
    and position('No sábado, 24 de julho, o transfer privativo busca vocês no hotel' in details) = 1;
  get diagnostics n = row_count;
  if n <> 1 then raise exception '0170: o texto do concerto não é mais o da 0169'; end if;
end $$;

insert into ops_migrations (id) values ('0170-tl-054-26-noite-do-concerto-reescrita') on conflict (id) do nothing;
