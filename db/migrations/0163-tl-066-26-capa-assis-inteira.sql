-- =====================================================================
-- 0163 · TL-066-26: A FAIXA DO ALTO MOSTRA ASSIS INTEIRA
--
-- Instrução dela, 25/11/26: a foto da faixa não estava centralizada e não
-- mostrava Assis — era a vista de cima, com a planície tomando a faixa e
-- a cidade cortada embaixo. Entra Assis inteira no morro, vista de baixo,
-- com a Rocca no alto e a Basílica à direita ("Panorama (Assisi) 07 05
-- 2026 03.jpg", Effems, CC0 — sem crédito, como ela pediu). A foto foi
-- recortada no arquivo para a cidade ficar no meio da faixa e as placas
-- de rua do primeiro plano saírem.
--
-- Seção 7: update em UMA proposta, a TL-066-26 (0157), sem envio e sem
-- resposta, por instrução dela nesta conversa.
-- =====================================================================

do $$
declare
  prop uuid := 'e0660000-0000-0000-0000-000000000001';
  n int;
begin
  if exists (select 1 from ops_proposals where id = prop and responded_at is not null) then
    raise exception '0163: a TL-066-26 já foi respondida, nada muda';
  end if;

  update ops_proposals set cover_img = 'fotos/tl066/assisi-morro.jpg' where id = prop;
  get diagnostics n = row_count;
  if n <> 1 then raise exception '0163: TL-066-26 não encontrada'; end if;
end $$;

insert into ops_migrations (id) values ('0163-tl-066-26-capa-assis-inteira') on conflict (id) do nothing;
