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

      /* AS FOTOS DESCEM MENORES. Medido em agosto/26 com as fotos do
         Borgo Vescine: 20 fotos de hotel em tamanho original são
         11,7 MB, e a função tem 10 segundos para tudo — abrir o
         Chromium, carregar a página, buscar as fotos e imprimir. Era
         por isso que a proposta com fotos falhava como se tivesse caído
         a internet: o Netlify cortava antes de o arquivo ficar pronto.

         O CDN do Squarespace serve a mesma foto em qualquer largura
         pelo parâmetro format. 1600w cobre a folha A4 inteira sangrada
         a 150dpi (210mm = 1240px), e 1000w cobre a fita de fotos do
         card, que nunca passa de meia folha. Com isso os mesmos 12 MB
         viram menos de 4.

         Só o Squarespace: parâmetro que outro CDN não entende viraria
         404, e foto faltando é pior que foto pesada. */
      document.querySelectorAll("img").forEach(im => {
        const src = im.getAttribute("src") || "";
        if (!/images\.squarespace-cdn\.com/.test(src) || /[?&]format=/.test(src)) return;
        const larg = im.classList.contains("ap-fundo") ? "1600w" : "1000w";
        im.setAttribute("src", src + (src.includes("?") ? "&" : "?") + "format=" + larg);
      });

      const imgs = [...document.querySelectorAll("img")].filter(i => !i.complete);
      await Promise.all(imgs.map(i => new Promise(ok => {
        const fim = () => ok();
        i.addEventListener("load", fim, { once: true });
        i.addEventListener("error", fim, { once: true });
        setTimeout(fim, 6000);
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
