/* =====================================================================
   TRAZER O ARQUIVO PARA O HUB

   Ela cola o link de uma foto (Drive, site do fornecedor, qualquer um) e
   o Hub grava o arquivo no balde dela. O navegador não consegue fazer
   isso sozinho: o Drive e a maioria dos sites recusam busca de outra
   origem (CORS), e o erro aparece como "falhou" sem dizer por quê.

   Então quem busca é o servidor, que não tem CORS, e devolve os bytes
   para a página — que reduz a imagem e grava no Storage COM O LOGIN DELA.
   Nenhuma chave nova em lugar nenhum: a de serviço do Supabase não
   encosta aqui.

   Só imagem e só PDF, no máximo 25 MB, e só endereço http(s) público:
   isto é um buscador de arquivo, não um proxy para a internet inteira.
   ===================================================================== */
const TIPOS_OK = /^(image\/(jpeg|png|webp|gif|avif|heic|heif)|application\/pdf)/i;
const LIMITE = 25 * 1024 * 1024;

/* O link que a pessoa copia do Drive abre o visualizador, não o arquivo.
   Sem esta conversão o que desce é a página HTML do Drive, e a foto sai
   "não carregou" sem explicação. */
function enderecoDireto(u){
  const g = u.match(/drive\.google\.com\/(?:file\/d\/|open\?id=|uc\?[^#]*id=)([A-Za-z0-9_-]{10,})/);
  if(g) return `https://drive.google.com/uc?export=download&id=${g[1]}`;
  const d = u.match(/docs\.google\.com\/[^?]*[?&]id=([A-Za-z0-9_-]{10,})/);
  if(d) return `https://drive.google.com/uc?export=download&id=${d[1]}`;
  return u;
}

export default async (req) => {
  const url = new URL(req.url);
  const bruto = (url.searchParams.get("url") || "").trim();
  let alvo;
  try { alvo = new URL(enderecoDireto(bruto)); }
  catch { return new Response("Endereço inválido.", {status:400}); }
  if(!/^https?:$/.test(alvo.protocol)) return new Response("Só endereço http ou https.", {status:400});
  if(/^(localhost|127\.|0\.|10\.|192\.168\.|169\.254\.)/i.test(alvo.hostname)
     || /\.internal$/i.test(alvo.hostname))
    return new Response("Endereço de rede interna não é buscado.", {status:400});

  let r;
  try {
    r = await fetch(alvo.href, {redirect:"follow",
      headers:{"User-Agent":"TuscanLandsHub/1.0 (+https://hubtl.netlify.app)"}});
  } catch(e){
    return new Response("Não consegui abrir este endereço: " + (e && e.message), {status:502});
  }
  if(!r.ok) return new Response(`O endereço respondeu ${r.status}. `
    + "Se for do Drive, confira se o arquivo está compartilhado com quem tem o link.", {status:502});

  const tipo = (r.headers.get("content-type") || "").split(";")[0].trim();
  if(!TIPOS_OK.test(tipo))
    return new Response(`O que veio não é imagem nem PDF (${tipo||"tipo não declarado"}). `
      + "Link do Drive precisa estar compartilhado com quem tem o link — "
      + "senão o que desce é a página de login.", {status:415});

  const tam = Number(r.headers.get("content-length") || 0);
  if(tam && tam > LIMITE)
    return new Response(`O arquivo tem ${Math.round(tam/1048576)} MB; o limite é 25 MB.`, {status:413});

  const buf = await r.arrayBuffer();
  if(buf.byteLength > LIMITE)
    return new Response(`O arquivo tem ${Math.round(buf.byteLength/1048576)} MB; o limite é 25 MB.`, {status:413});

  return new Response(buf, {status:200, headers:{
    "Content-Type": tipo, "Cache-Control":"no-store",
    "Content-Disposition":"inline"}});
};

export const config = { path: "/api/buscar-arquivo" };
