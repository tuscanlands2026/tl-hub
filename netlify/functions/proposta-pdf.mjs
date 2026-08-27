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
      args: [...chromium.args, "--font-render-hinting=none"],
      executablePath: exe,
      headless: chromium.headless,
      defaultViewport: { width: 1280, height: 900 }
    });
    const page = await browser.newPage();
    await page.goto(alvo, { waitUntil: "networkidle0", timeout: 45000 });
    await page.waitForSelector(".apres", { timeout: 20000 });

    // As etapas ficam escondidas até a pessoa chegar nelas, e imagem de
    // etapa escondida pode não ter sido buscada. A folha de impressão
    // mostra todas, mas as fotos precisam já estar em casa antes de
    // imprimir — senão o arquivo sai com imagem pela metade.
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
    return new Response("Não consegui montar o PDF: " + (e && e.message), { status: 500 });
  } finally {
    if (browser) { try { await browser.close(); } catch (e) {} }
  }
};

export const config = { path: "/api/proposta-pdf" };
