/* Ficou pronto? A tela pergunta a cada dois segundos, e esta função só lê
   o que a função de fundo escreveu. Depois de entregar, apaga: rascunho de
   ficha com preço de fornecedor não fica guardado no servidor. */
import { getStore } from "@netlify/blobs";

export default async (req) => {
  const url = new URL(req.url);
  const marca = (url.searchParams.get("marca") || "").replace(/[^a-z0-9]/gi, "").slice(0, 40);
  if (!marca) return Response.json({pronto: false, erro: "sem marca"}, {status: 400});
  const loja = getStore("fornecedor-extracao");
  const r = await loja.get(marca, {type: "json"}).catch(() => null);
  if (!r) return Response.json({pronto: false});
  if (r.pronto) { try { await loja.delete(marca); } catch (e) {} }
  return Response.json(r);
};

export const config = { path: "/api/fornecedor-extrair-status" };
