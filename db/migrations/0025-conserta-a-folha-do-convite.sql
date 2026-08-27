-- =====================================================================
-- 0025 · A FOLHA DO CONVITE EM INGLÊS, E COM A FOTO
--
-- Dois defeitos vistos na TL-042-26, que está em inglês:
--
-- 1. A FOLHA SAÍA EM PORTUGUÊS. tl_get_quote cai no português quando o
--    inglês está vazio — é a regra da casa, e está certa. O que estava
--    errado é a proposta ter ficado com assurance_en vazio: ela nasceu
--    antes de 0021, então o gatilho, que só age no insert, nunca a
--    alcançou, e as trocas de 0022 e 0023 só mexem em quem está com o
--    texto anterior INTEIRO — vazio não casa com texto nenhum.
--
--    Aqui o inglês é preenchido onde estiver vazio, e o português
--    também, pelo mesmo motivo.
--
-- 2. A FOLHA SAÍA SEM FOTO. assurance_img nasceu em 0024 e ficou nulo
--    em todo mundo, e nulo quer dizer "folha sem faixa". Ela quer a
--    peça institucional ali. Vira padrão da casa, desce para toda
--    proposta nova pelo gatilho, e preenche as que estão vazias.
--    Continua sendo campo dela: apagar no editor tira a faixa.
--
-- Só toca em objetos ops_. Nada fora desse prefixo.
-- =====================================================================

insert into ops_text_defaults (key, pt, en) values
  ('assurance_img', 'https://i.postimg.cc/HsV7Z2fq/Tuscan-Lands-Travel-Luxury-DMC.png', null)
on conflict (key) do update set pt = excluded.pt, updated_at = now();

create or replace function tl_proposal_defaults()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare d record;
begin
  for d in select key, pt, en from ops_text_defaults loop
    if d.key = 'about' then
      new.about_pt       := coalesce(nullif(new.about_pt,''),       d.pt);
      new.about_en       := coalesce(nullif(new.about_en,''),       d.en);
    elsif d.key = 'credentials' then
      new.credentials_pt := coalesce(nullif(new.credentials_pt,''), d.pt);
      new.credentials_en := coalesce(nullif(new.credentials_en,''), d.en);
    elsif d.key = 'backcover' then
      new.backcover_pt   := coalesce(nullif(new.backcover_pt,''),   d.pt);
      new.backcover_en   := coalesce(nullif(new.backcover_en,''),   d.en);
    elsif d.key = 'conditions' then
      new.conditions_pt  := coalesce(nullif(new.conditions_pt,''),  d.pt);
      new.conditions_en  := coalesce(nullif(new.conditions_en,''),  d.en);
    elsif d.key = 'assurance' then
      new.assurance_pt   := coalesce(nullif(new.assurance_pt,''),   d.pt);
      new.assurance_en   := coalesce(nullif(new.assurance_en,''),   d.en);
    elsif d.key = 'about_img' then
      new.about_img      := coalesce(nullif(new.about_img,''),      d.pt);
    elsif d.key = 'backcover_img' then
      new.backcover_img  := coalesce(nullif(new.backcover_img,''),  d.pt);
    elsif d.key = 'assurance_img' then
      new.assurance_img  := coalesce(nullif(new.assurance_img,''),  d.pt);
    end if;
  end loop;
  return new;
end $$;

drop trigger if exists ops_proposal_defaults on ops_proposals;
create trigger ops_proposal_defaults
  before insert on ops_proposals
  for each row execute function tl_proposal_defaults();

-- Preenche só o que está vazio. Onde ela escreveu o dela, não se mexe.
update ops_proposals
   set assurance_pt  = coalesce(nullif(assurance_pt,''),
                         (select pt from ops_text_defaults where key='assurance')),
       assurance_en  = coalesce(nullif(assurance_en,''),
                         (select en from ops_text_defaults where key='assurance')),
       assurance_img = coalesce(nullif(assurance_img,''),
                         (select pt from ops_text_defaults where key='assurance_img')),
       updated_at    = now()
 where layout = 'apresentada'
   and (coalesce(assurance_pt,'') = ''
     or coalesce(assurance_en,'') = ''
     or coalesce(assurance_img,'') = '');

insert into ops_migrations (id) values ('0025-conserta-a-folha-do-convite') on conflict (id) do nothing;
