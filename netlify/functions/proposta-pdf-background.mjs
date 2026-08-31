/* =====================================================================
   MONTAR O PDF SEM RELÓGIO.

   A função síncrona não dava conta e ficou registrado com número: a
   proposta da TL-042-26 levava de 16 a 24 segundos e 4 de 7 chamadas
   morriam, mesmo depois de as fotos caírem de 18 para 6,3 MB. O tempo
   não era do documento — era ligar um Chromium do zero a cada clique,
   dentro do limite de ~25 segundos que o servidor dá.

   Esta é uma função DE FUNDO (o sufixo -background é o que diz isso ao
   Netlify): responde na hora com 202 e continua trabalhando, com 15
   minutos em vez de 25 segundos. O arquivo pronto fica guardado, e
   quem entrega é a proposta-pdf-arquivo, que é rápida porque só lê.

   Guardado onde: Netlify Blobs. Não é o Storage do Supabase de
   propósito — escrever lá pediria uma chave de escrita dentro de uma
   função pública, e a regra da casa é não pôr chave de serviço em
   lugar nenhum. O Blobs é do próprio site e não precisa de chave.
   ===================================================================== */
import chromium from "@sparticuz/chromium";
import puppeteer from "puppeteer-core";
import { getStore } from "@netlify/blobs";

export default async (req) => {
  const url = new URL(req.url);
  const token = url.searchParams.get("token") || "";
  if (!/^[a-f0-9]{16,64}$/i.test(token)) {
    return new Response("Token inválido.", { status: 400 });
  }
  const alvo = `${url.origin}/#/quote/${token}`;
  const loja = getStore("propostas-pdf");

  /* Marca "montando" ANTES de começar. Sem isto a tela que pergunta se
     ficou pronto não teria como distinguir "ainda não começou" de
     "morreu no meio", e ficaria perguntando para sempre. */
  await loja.setJSON(token + ".estado", { estado: "montando", em: Date.now() });

  let browser;
  try {
    // Sem a parte gráfica: o PDF não precisa dela, e é ela que puxa
    // metade das bibliotecas do pacote.
    chromium.setGraphicsMode = false;
    const exe = await chromium.executablePath();
    const libs = ["/tmp/al2023/lib", "/tmp/al2/lib", "/tmp/lib"];
    process.env.LD_LIBRARY_PATH = [process.env.LD_LIBRARY_PATH || "", ...libs]
      .filter(Boolean).join(":");

    browser = await puppeteer.launch({
      /* disable-web-security: sem ele o canvas fica "manchado" pela
         foto de outro domínio e toDataURL é recusado — as fotos não
         encolheriam. É um Chromium descartável abrindo só a nossa
         própria página, não um navegador de ninguém. */
      args: [...chromium.args, "--font-render-hinting=none", "--disable-web-security"],
      executablePath: exe,
      headless: chromium.headless,
      defaultViewport: { width: 1280, height: 900 }
    });
    const page = await browser.newPage();

    /* PEDIR AS FOTOS COM CORS, DESDE O COMEÇO.
       Sem crossOrigin o canvas fica "manchado" pela foto de outro
       domínio e toDataURL é RECUSADO — o encolhimento lá embaixo caía no
       catch e não fazia nada, em silêncio. Foi o que aconteceu na
       primeira tentativa: o PDF continuou gordo e eu achei que tinha
       encolhido.

       Conferido nas três hospedagens de foto que ela usa — Squarespace,
       cdn-website e postimg: as três respondem
       access-control-allow-origin: *, então o pedido com CORS passa.

       O observador entra ANTES da página desenhar, e marca cada <img>
       assim que ela nasce. Reatribuir o src é o que refaz o pedido com
       CORS: marcar depois de carregada não desmancha a mancha. */
    await page.evaluateOnNewDocument(() => {
      const marcar = (im) => {
        if (!im || im.dataset.cors) return;
        im.dataset.cors = "1";
        const src = im.getAttribute("src");
        im.setAttribute("crossorigin", "anonymous");
        if (src) im.setAttribute("src", src);
      };
      new MutationObserver(muts => {
        for (const m of muts) for (const n of m.addedNodes) {
          if (n.nodeType !== 1) continue;
          if (n.tagName === "IMG") marcar(n);
          else if (n.querySelectorAll) n.querySelectorAll("img").forEach(marcar);
        }
      }).observe(document.documentElement, { childList: true, subtree: true });
    });
    /* domcontentloaded, e não networkidle0: com as fotos dos hotéis o
       networkidle0 espera os 12 MB inteiros descerem antes de sequer
       devolver o controle, e a função tem 10 segundos no total. Quem
       espera pelas fotos é o laço logo abaixo, que é limitado. */
    await page.goto(alvo, { waitUntil: "domcontentloaded", timeout: 20000 });
    // .apres é a proposta apresentada; .doc é a quote simples, que sai
    // com a mesma cara do documento da order. As duas baixam pelo mesmo
    // botão, então esperar só por uma delas dava timeout na outra.
    await page.waitForSelector(".apres, .doc", { timeout: 20000 });

    // As etapas ficam escondidas até a pessoa chegar nelas, e imagem de
    // etapa escondida pode não ter sido buscada. A folha de impressão
    // mostra todas, mas as fotos precisam já estar em casa antes de
    // imprimir — senão o arquivo sai com imagem pela metade.
    await page.evaluate(async () => {
      document.querySelectorAll(".ap-passo").forEach(e => { e.style.display = "block"; });

      const esperar = (ms) => Promise.all(
        [...document.querySelectorAll("img")].filter(i => !i.complete).map(i =>
          new Promise(ok => {
            i.addEventListener("load", ok, { once: true });
            i.addEventListener("error", ok, { once: true });
            setTimeout(ok, ms);
          })));

      /* PRIMEIRO esperar, DEPOIS encolher. Encolher lê naturalWidth, que
         só existe com a foto já carregada — invertendo a ordem o laço
         pula todas em silêncio e o PDF sai gordo do mesmo jeito. */
      /* Rede de segurança: o que escapou do observador (foto que já
         estava no HTML inicial) é marcada aqui e recarregada. */
      document.querySelectorAll("img:not([crossorigin])").forEach(im => {
        const src = im.getAttribute("src");
        im.setAttribute("crossorigin", "anonymous");
        if (src) im.setAttribute("src", src);
      });
      await esperar(6000);

      /* AS FOTOS ENTRAM NO PDF EM BAIXA RESOLUÇÃO. Instrução dela em
         agosto/26: "o PDF é só pra gerar alguma coisa, não é para
         impressão" — é o arquivo que ela manda por e-mail.

         Medido com as fotos reais da TL-042-26 (4,9 MB de origem):
             sem encolher   33,4 MB · 8,9 s
             1600px          3,6 MB · 4,1 s
             1200px          2,8 MB · 2,1 s
         Quem inflava não era o download: era o Chromium embutindo cada
         foto no tamanho original, 2250×3000 numa folha A4. O arquivo
         dela saía com 18 MB em 21 segundos, encostando no limite do
         servidor — daí o erro que parecia queda de internet.

         Redesenhar num canvas e trocar o src resolve para QUALQUER
         hospedagem de foto. A tentativa anterior mexia na URL do
         Squarespace, e as fotos desta proposta estão em três lugares
         diferentes: não pegava a maioria.

         Logo não passa por aqui: tem transparência, e JPEG não tem. */
      const encolher = (im, larg) => {
        if (!im.complete || !im.naturalWidth || im.naturalWidth <= larg) return;
        const alt = Math.round(im.naturalHeight * larg / im.naturalWidth);
        const c = document.createElement("canvas");
        c.width = larg; c.height = alt;
        try {
          c.getContext("2d").drawImage(im, 0, 0, larg, alt);
          im.src = c.toDataURL("image/jpeg", 0.82);
        } catch (e) { /* não deu: fica a original — foto grande é melhor que nenhuma */ }
      };
      document.querySelectorAll("img.ap-fundo").forEach(im => encolher(im, 1200));
      document.querySelectorAll(".ap-fotos img, .ap-card img").forEach(im => encolher(im, 800));

      // As trocadas por dataURL precisam assentar antes de imprimir.
      await esperar(3000);
      if (document.fonts && document.fonts.ready) { try { await document.fonts.ready; } catch (e) {} }
    });

    const pdf = await page.pdf({
      format: "A4",
      printBackground: true,
      preferCSSPageSize: true,
      margin: { top: 0, right: 0, bottom: 0, left: 0 }
    });


    await loja.set(token, pdf, {
      metadata: { tipo: "application/pdf", bytes: pdf.length, em: Date.now() }
    });
    await loja.setJSON(token + ".estado",
      { estado: "pronto", bytes: pdf.length, em: Date.now() });
    return new Response("ok", { status: 200 });
  } catch (e) {
    /* O erro fica GUARDADO, e não só no log: é o que faz a tela poder
       dizer o que houve em vez de girar para sempre. */
    await loja.setJSON(token + ".estado",
      { estado: "erro", msg: String((e && e.message) || e), em: Date.now() });
    return new Response("erro", { status: 500 });
  } finally {
    if (browser) { try { await browser.close(); } catch (e) {} }
  }
};

export const config = { path: "/api/proposta-pdf-montar" };
