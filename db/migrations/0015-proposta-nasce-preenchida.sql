-- =====================================================================
-- 0015 · TODA PROPOSTA NOVA NASCE COM O TEXTO E AS FOTOS DA CASA
--
-- Instrução dela: "contracapa e sobre nós é fixa, sempre essa foto".
--
-- O que estava acontecendo: as propostas que existem hoje têm o texto
-- do "Sobre nós", as credenciais, a contracapa e as duas fotos porque
-- as migrações 0008, 0009, 0010 e 0013 preencheram uma a uma, para
-- trás. Proposta NOVA nascia sem nada disso — só com as condições
-- comerciais, que a tela preenche. Ela ia descobrir isso na próxima
-- proposta que criasse, com o "Sobre nós" em branco e a contracapa em
-- creme, e ia ter de redigitar tudo.
--
-- O preenchimento vive no banco, e não na tela, porque a tela é um
-- caminho entre vários: o exemplo em SQL, uma cópia de proposta, uma
-- correção feita no painel. Uma trava só, no insert, vale para todos.
--
-- É CÓPIA, e só no insert. Continua valendo a regra dela: mudar o
-- padrão da casa depois não pode reescrever proposta já enviada. E o
-- que ela escrever na proposta ganha do padrão — o preenchimento só
-- entra onde veio vazio.
--
-- Só toca em objetos ops_. Nada fora desse prefixo.
-- =====================================================================

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
    elsif d.key = 'about_img' then
      new.about_img      := coalesce(nullif(new.about_img,''),      d.pt);
    elsif d.key = 'backcover_img' then
      new.backcover_img  := coalesce(nullif(new.backcover_img,''),  d.pt);
    end if;
  end loop;
  return new;
end $$;

drop trigger if exists ops_proposal_defaults on ops_proposals;
create trigger ops_proposal_defaults
  before insert on ops_proposals
  for each row execute function tl_proposal_defaults();

-- As que já existem e ficaram sem foto por terem nascido antes de 0010
-- ou de 0013. Só onde está vazio: proposta com foto própria não muda.
update ops_proposals
   set about_img     = coalesce(nullif(about_img,''),
                         (select pt from ops_text_defaults where key='about_img')),
       backcover_img = coalesce(nullif(backcover_img,''),
                         (select pt from ops_text_defaults where key='backcover_img')),
       updated_at    = now()
 where layout = 'apresentada'
   and (coalesce(about_img,'') = '' or coalesce(backcover_img,'') = '');

insert into ops_migrations (id) values ('0015-proposta-nasce-preenchida') on conflict (id) do nothing;
