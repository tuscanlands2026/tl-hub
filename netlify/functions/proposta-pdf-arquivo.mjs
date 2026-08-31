/* =====================================================================
   ENTREGAR O PDF JÁ MONTADO — e dizer se ainda não está.

   Esta função é rápida de propósito: não abre navegador, não desenha
   nada, só lê o arquivo que a proposta-pdf-background guardou. É por
   isso que ela nunca estoura o tempo, que era o problema todo.

   Dois usos no mesmo endereço:
     ?token=…            → diz o estado em JSON, para a tela perguntar
     ?token=…&baixar=1   → devolve o arquivo com Content-Disposition,
                           que é o que faz o NAVEGADOR baixar em vez de
                           abrir o visualizador.
   ===================================================================== */
import { getStore } from "@netlify/blobs";

export default async (req) => {
  const url = new URL(req.url);
  const token = url.searchParams.get("token") || "";
  if (!/^[a-f0-9]{16,64}$/i.test(token)) {
    return new Response("Token inválido.", { status: 400 });
  }
  const nome = (url.searchParams.get("nome") || "proposta")
    .replace(/[^\w.-]+/g, "-").slice(0, 60) || "proposta";
  const loja = getStore("propostas-pdf");

  const st = (await loja.get(token + ".estado", { type: "json" })) || { estado: "nada" };

  if (url.searchParams.get("baixar")) {
    const pdf = await loja.get(token, { type: "arrayBuffer" });
    if (!pdf) return new Response("O arquivo ainda não está pronto.", { status: 404 });
    return new Response(pdf, {
      status: 200,
      headers: {
        "Content-Type": "application/pdf",
        "Content-Disposition": `attachment; filename="${nome}.pdf"`,
        "Cache-Control": "no-store"
      }
    });
  }

  /* Montagem que passou de 3 minutos é montagem que morreu: a função de
     fundo tem 15, mas nenhuma proposta leva tanto. Sem este corte a
     tela ficaria girando para sempre quando algo desse errado sem
     chegar a gravar o erro. */
  if (st.estado === "montando" && Date.now() - (st.em || 0) > 180000) {
    st.estado = "erro";
    st.msg = "A montagem não terminou. Tente de novo.";
  }
  return new Response(JSON.stringify(st), {
    status: 200,
    headers: { "Content-Type": "application/json", "Cache-Control": "no-store" }
  });
};

export const config = { path: "/api/proposta-pdf-arquivo" };
