/* =====================================================================
   BAIXAR A PROFORMA EM PDF — com o link de pagamento vivo.

   Imprimir pela caixa do Windows mata o link: o "Microsoft Print to PDF"
   desenha a página como papel e a âncora não vai para o arquivo. Aqui
   quem imprime é um Chromium sem tela, no servidor, e o link chega ao PDF
   como link (a âncora /URI). É o mesmo caminho do voucher do CRM e do PDF
   da proposta.

   O navegador abre a PÁGINA PÚBLICA da proforma, pelo token da order — o
   mesmo token que a agência já usa para ver a confirmação. Nada de novo
   fica exposto, e a função do banco só devolve a proforma depois de ela
   ser emitida na tela.

   Sem foto nenhuma: a proforma é texto e tabela, então não tem o circo
   do encolhimento de imagem que o PDF da proposta precisa, e o arquivo
   fica em dezenas de KB — cabe folgado no tempo da função síncrona.
   ===================================================================== */
import chromium from "@sparticuz/chromium";
import puppeteer from "puppeteer-core";

export default async (req) => {
  const url = new URL(req.url);
  const token = url.searchParams.get("token") || "";
  // O token da order é hexadecimal de 32 caracteres (gen_random_bytes(16)).
  if (!/^[a-f0-9]{16,64}$/i.test(token)) {
    return new Response("Token inválido.", { status: 400 });
  }
  const nome = (url.searchParams.get("nome") || "proforma")
    .replace(/[^\w.-]+/g, "-").slice(0, 60) || "proforma";

  const alvo = `${url.origin}/#/proforma/${token}`;

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
    await page.goto(alvo, { waitUntil: "domcontentloaded", timeout: 20000 });

    /* Espera o DOCUMENTO, não a página: o app monta a proforma depois de
       consultar o banco. Se o token não valer, o que aparece é o recado —
       e aí o arquivo sairia com "não encontrado" dentro.

       O recado final é o .done[data-recado]; a TELA DE CARREGAMENTO é um
       .done também, com "…" dentro. Esperar por ".done .muted" pegava o
       carregamento e a função desistia antes de o documento chegar. */
    await page.waitForSelector(".doc.com.pf, .done[data-recado]", { timeout: 20000 });
    const doc = await page.$(".doc.com.pf");
    if (!doc) {
      const recado = await page.$eval(".done[data-recado]", e => e.textContent.trim())
        .catch(() => "");
      return new Response("Não consegui montar a proforma: "
        + (String(recado).replace(/\s+/g, " ").replace(/^Tuscan Lands\s*/, "").slice(0, 200)
           || "link não reconhecido."),
        { status: 404 });
    }
    // As fontes da casa precisam estar em casa antes de imprimir, senão o
    // arquivo sai com a fonte de reserva e a folha fica com outra altura.
    await page.evaluate(async () => {
      if (document.fonts && document.fonts.ready) { try { await document.fonts.ready; } catch (e) {} }
    });

    /* A4 e as margens da folha de impressão (@page{margin:14mm}) — é a
       mesma folha que ela vê na caixa de impressão. preferCSSPageSize
       deixa o CSS mandar quando ele manda. */
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
        /* attachment é o que manda o navegador BAIXAR em vez de abrir no
           visualizador de PDF. */
        "Content-Disposition": `attachment; filename="${nome}.pdf"`,
        "Cache-Control": "no-store"
      }
    });
  } catch (e) {
    const msg = /timeout|Timed out|Navigation/i.test((e && e.message) || "")
      ? "O servidor demorou mais do que o permitido para montar o PDF. Tente de novo; se repetir, me avise."
      : "Não consegui montar o PDF da proforma agora. Tente de novo.";
    return new Response(msg + "\n\nDetalhe técnico: " + (e && e.message), { status: 500 });
  } finally {
    if (browser) { try { await browser.close(); } catch (e) {} }
  }
};

export const config = { path: "/api/proforma-pdf" };
