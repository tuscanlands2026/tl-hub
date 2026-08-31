/* =====================================================================
   BAIXAR A PROPOSTA EM PDF — de verdade, um clique, sem caixa de
   impressão e sem virar imagem.

   O caminho é o mesmo do voucher do CRM: um navegador sem tela abre a
   própria página pública da proposta e manda imprimir para arquivo. O
   texto sai vetorial, as fotos na resolução do arquivo, e o desenho é
   exatamente o da folha de impressão que já está aprovada — não existe
   um segundo layout para manter.

   Função no formato novo da Netlify, de propósito: o formato antigo
   devolve o corpo em base64 e estoura em 6 MB, e uma proposta com as
   fotos dos hotéis passa disso fácil. Este devolve o arquivo em fluxo.

   Não expõe nada além do que o link público já mostra: quem tem o link
   vê a proposta de qualquer jeito.
   ===================================================================== */
import chromium from "@sparticuz/chromium";
import puppeteer from "puppeteer-core";

export default async (req) => {
  const url = new URL(req.url);
  const token = url.searchParams.get("token") || "";
  if (!/^[a-f0-9]{16,64}$/i.test(token)) {
    return new Response("Token inválido.", { status: 400 });
  }
  const nome = (url.searchParams.get("nome") || "proposta")
    .replace(/[^\w.-]+/g, "-").slice(0, 60) || "proposta";

  const alvo = `${url.origin}/#/quote/${token}`;

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

    return new Response(pdf, {
      status: 200,
      headers: {
        "Content-Type": "application/pdf",
        /* attachment é o que manda o navegador BAIXAR em vez de abrir
           no visualizador de PDF. */
        "Content-Disposition": `attachment; filename="${nome}.pdf"`,
        "Cache-Control": "no-store"
      }
    });
  } catch (e) {
    /* Mensagem em português e sem jargão: quem vê isto é ela, não eu.
       O detalhe técnico fica no fim, para o dia em que eu precisar. */
    const msg = /timeout|Timed out|Navigation/i.test((e && e.message) || "")
      ? "A proposta demorou mais do que o servidor permite para montar o PDF. "
      + "Costuma ser foto grande demais. Tente de novo; se repetir, me avise."
      : "Não consegui montar o PDF agora. Tente de novo.";
    return new Response(msg + "\n\nDetalhe técnico: " + (e && e.message), { status: 500 });
  } finally {
    if (browser) { try { await browser.close(); } catch (e) {} }
  }
};

export const config = { path: "/api/proposta-pdf" };
