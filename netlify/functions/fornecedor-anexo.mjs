/* =====================================================================
   O ANEXO SOBE ANTES, EM PEDAÇOS

   POR QUE ESTA FUNÇÃO EXISTE: a função que lê o material roda em fundo
   (15 minutos), e função de fundo é chamada de forma assíncrona — o
   pedido inteiro tem de caber em 256 KB. Medido no ar: 250 KB passa,
   256 KB volta 413 com o corpo "Error", que é o erro seco que ela viu
   na tela ao mandar dois PDFs de 627 KB juntos.

   Então o arquivo não viaja mais dentro daquele pedido. Sobe aqui antes,
   em pedaços de 3 MB, cada pedaço num pedido normal (síncrono, que
   aceita bem mais), e vai para o Blobs do próprio site. Depois a tela
   chama a leitura mandando só o texto e a lista de anexos; quem junta os
   pedaços e converte para base64 é o servidor.

   Nada fica guardado: a função de fundo apaga cada pedaço depois de ler.
   ===================================================================== */
import { getStore } from "@netlify/blobs";

const PEDACO_MAX = 4 * 1024 * 1024;   // pedido síncrono aceita mais, mas 4 MB já é folgado

export default async (req) => {
  const u = new URL(req.url);
  const marca = (u.searchParams.get("marca") || "").replace(/[^a-z0-9]/gi, "").slice(0, 40);
  if (!marca) return Response.json({erro: "sem marca"}, {status: 400});

  const i = inteiro(u.searchParams.get("i")), p = inteiro(u.searchParams.get("p"));
  if (i == null || p == null || i > 7 || p > 40)
    return Response.json({erro: "anexo fora da conta"}, {status: 400});

  const buf = await req.arrayBuffer();
  if (!buf || !buf.byteLength) return Response.json({erro: "pedaço vazio"}, {status: 400});
  if (buf.byteLength > PEDACO_MAX) return Response.json({erro: "pedaço grande demais"}, {status: 413});

  try {
    await getStore("fornecedor-material").set(`${marca}/${i}/${p}`, buf);
  } catch (e) {
    return Response.json({erro: (e && e.message) || String(e)}, {status: 500});
  }
  return Response.json({ok: true, bytes: buf.byteLength});
};

function inteiro(v){
  if (v == null || v === "" || !/^\d+$/.test(v)) return null;
  return parseInt(v, 10);
}

export const config = { path: "/api/fornecedor-anexo" };
