-- =====================================================================
-- 0144 · DESENHO "PÁGINA ÚNICA" E A TL-065-26 NELE
--
-- Instrução dela, 13/11/26, vendo a TL-065-26 (0142): "faz tipo one page
-- mesmo, sem capa". E sobre o preço, que saía no cartão do barco e de novo
-- na tabela de "Your proposal": ou fica num lugar, ou no outro. E "põe uma
-- foto de Capri mesmo, porque aqui é outra região".
--
--   · ops_proposals.modelo ganha o valor 'pagina' (a coluna é texto, sem
--     trava: nada a alterar na tabela). Nulo e 'jornada' continuam como
--     estão — o corte é o campo, e nenhuma proposta existente muda;
--   · tl_notify_quote trata 'pagina' como trata 'jornada': o texto sem
--     valor (a folha do dia) não entra no e-mail como linha recusada;
--   · a TL-065-26 passa para 'pagina'. A faixa do alto é a foto de Capri
--     (os Faraglioni); cada barco fica com a foto dele no mar, sem as do
--     convés com Positano atrás; o bloco do dia perde a foto, que repetia
--     a da faixa.
--
-- Seção 7: update em UMA proposta, a TL-065-26 criada na 0142, ainda não
-- enviada nem respondida, por instrução dela nesta conversa. As linhas são
-- miradas por proposta + título, porque o id da linha não é estável.
-- =====================================================================

-- 1 · o e-mail do aviso: 'pagina' igual a 'jornada'
do $$
declare d text;
begin
  d := pg_get_functiondef('tl_notify_quote'::regproc);
  if position('pp.modelo in (''jornada'',''pagina'')' in d) > 0 then return; end if;
  if position('pp.modelo = ''jornada''' in d) = 0 then
    raise exception '0144: tl_notify_quote não tem o trecho esperado';
  end if;
  execute replace(d, 'pp.modelo = ''jornada''', 'pp.modelo in (''jornada'',''pagina'')');
end $$;

-- 2 · a TL-065-26 em página única
do $$
declare
  prop uuid := 'e0650000-0000-0000-0000-000000000001';
  n int;
begin
  if exists (select 1 from ops_proposals where id = prop and responded_at is not null) then
    raise exception '0144: a TL-065-26 já foi respondida, nada muda';
  end if;

  update ops_proposals set modelo = 'pagina' where id = prop;
  get diagnostics n = row_count;
  if n <> 1 then raise exception '0144: TL-065-26 não encontrada'; end if;

  update ops_proposal_items set photos = '[]'::jsonb
   where proposal_id = prop and 'A day on the water, Positano to Capri' in (title, title_en);

  update ops_proposal_items set photos = '["fotos/tl065/serapo-42.jpg"]'::jsonb
   where proposal_id = prop and 'Di Donna Serapo 42 HT' in (title, title_en);
  update ops_proposal_items set photos = '["fotos/tl065/xl-marine-43.jpg"]'::jsonb
   where proposal_id = prop and 'XL Marine 43 Open Cruise' in (title, title_en);
  update ops_proposal_items set photos = '["fotos/tl065/apreamare-100.jpg"]'::jsonb
   where proposal_id = prop and 'Apreamare 100 gozzo' in (title, title_en);
end $$;

insert into ops_migrations (id) values ('0144-pagina-unica-e-tl-065-26') on conflict (id) do nothing;
