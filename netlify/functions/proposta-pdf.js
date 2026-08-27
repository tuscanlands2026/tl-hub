/* =====================================================================
   BAIXAR A PROPOSTA EM PDF — de verdade, um clique, sem caixa de
   impressão e sem virar imagem.

   O caminho é o mesmo do voucher do CRM: um navegador sem tela abre a
   própria página da proposta, no endereço público dela, e manda
   imprimir para arquivo. O texto sai vetorial, as fotos na resolução
   do arquivo, e o desenho é exatamente o da folha de impressão que já
   está aprovada — não existe um segundo layout para manter.

   Recebe o token da proposta. Não recebe nem devolve nada além do que
   o link público já mostra: quem tem o link vê a proposta de qualquer
   jeito.
   ===================================================================== */
const chromium = require("@sparticuz/chromium");
const puppeteer = require("puppeteer-core");

/* O pacote completo, e não o -min: ele traz o Chromium E as bibliotecas
   que o binário precisa, e aponta o LD_LIBRARY_PATH sozinho. Com o -min
   e o pacote remoto o binário descompactava mas subia sem as libs —
   "libnspr4.so: cannot open shared object file". */

exports.handler = async (event) => {
  const token = (event.queryStringParameters || {}).token || "";
  if (!/^[a-f0-9]{16,64}$/i.test(token)) {
    return { statusCode: 400, body: "Token inválido." };
  }
  const nome = ((event.queryStringParameters || {}).nome || "proposta")
    .replace(/[^\w.-]+/g, "-").slice(0, 60) || "proposta";

  const base = process.env.URL || `https://${event.headers.host}`;
  const alvo = `${base}/#/quote/${token}`;

  let browser;
  try {
    browser = await puppeteer.launch({
      args: chromium.args,
      executablePath: await chromium.executablePath(),
      headless: true,
      defaultViewport: { width: 1280, height: 900 }
    });
    const page = await browser.newPage();
    await page.goto(alvo, { waitUntil: "networkidle0", timeout: 45000 });
    await page.waitForSelector(".apres", { timeout: 20000 });

    // As etapas ficam escondidas até a pessoa chegar nelas, e fundo de
    // etapa escondida não é buscado. A folha de impressão mostra todas,
    // mas as fotos precisam já estar em casa antes de imprimir — senão
    // o arquivo sai com imagem pela metade.
    await page.evaluate(async () => {
      document.querySelectorAll(".ap-passo").forEach(e => { e.style.display = "block"; });
      const imgs = [...document.querySelectorAll("img")].filter(i => !i.complete);
      await Promise.all(imgs.map(i => new Promise(ok => {
        const fim = () => ok();
        i.addEventListener("load", fim, { once: true });
        i.addEventListener("error", fim, { once: true });
        setTimeout(fim, 8000);
      })));
      if (document.fonts && document.fonts.ready) { try { await document.fonts.ready; } catch (e) {} }
    });

    const pdf = await page.pdf({
      format: "A4",
      printBackground: true,
      preferCSSPageSize: true,
      margin: { top: 0, right: 0, bottom: 0, left: 0 }
    });

    return {
      statusCode: 200,
      headers: {
        "Content-Type": "application/pdf",
        "Content-Disposition": `attachment; filename="${nome}.pdf"`,
        "Cache-Control": "no-store"
      },
      body: Buffer.from(pdf).toString("base64"),
      isBase64Encoded: true
    };
  } catch (e) {
    return { statusCode: 500, body: "Não consegui montar o PDF: " + (e && e.message) };
  } finally {
    if (browser) { try { await browser.close(); } catch (e) {} }
  }
};
