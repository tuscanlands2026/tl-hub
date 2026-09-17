/* =====================================================================
   TRADUZIR A FICHA PARA PORTUGUÊS

   A ficha é em inglês porque é dela que sai a proposta em inglês. Mas ela
   faz proposta em português também, e pediu em setembro/26: "vc tem que
   traduzir quando eu pedir". O par em português fica GRAVADO na ficha —
   traduzir uma vez, não a cada proposta, e sem sair diferente da vez
   anterior.

   Recebe os textos, devolve a tradução, e NÃO grava nada: quem escreve no
   banco é a tela, que já sabe qual campo é de quem. Mesmo desenho da
   leitura de material: função de fundo, resposta no Blobs, a tela
   pergunta se ficou pronto.

   Escreve no MESMO balde da leitura (fornecedor-extracao) de propósito:
   assim o /api/fornecedor-extrair-status serve as duas, e não existe um
   segundo endpoint de "ficou pronto?" para manter.
   ===================================================================== */
import { getStore } from "@netlify/blobs";

const API = "https://api.anthropic.com/v1/messages";
const VERSAO_API = "2023-06-01";

const PROMPT = `You translate supplier content for Tuscan Lands, a luxury B2B DMC in Tuscany, from English into BRAZILIAN PORTUGUESE.

This text goes into proposals read by Brazilian travel advisors and their clients.

Rules:
- Reply with JSON only. No explanation, no code fence.
- Translate the meaning, not word by word. Natural Brazilian Portuguese, plain and factual, no marketing adjectives that are not in the original.
- Keep in the original language: proper names, place names, hotel and room category names (Classic Room, Junior Suite), dish and wine names, grape varieties, Italian terms that travel (agriturismo, palazzo, borgo, trattoria, aperitivo).
- Do not add information. Do not remove information. No "descubra", "imperdível", "joia escondida" or any sales adjective the English does not have.
- Measurements: keep the numbers as they are, translate only the words (square metres = m²).
- "nome_pt": translate only when the name is descriptive ("Private cellar visit and tasting"). When it is a proper name or a room category, repeat it unchanged.
- Keep the same number of items in destaques_pt as in destaques, in the same order.

Answer in this format, one entry per item received, same id:
{"traducao":[{"id":"<id>","nome_pt":"","descricao_pt":"","destaques_pt":[""]}]}

ITEMS:
`;

export default async (req) => {
  const loja = getStore("fornecedor-extracao");
  let marca = "";
  try {
    const corpo = await req.json();
    marca = String(corpo.marca || "").replace(/[^a-z0-9]/gi, "").slice(0, 40);
    if (!marca) return new Response("sem marca", { status: 400 });

    const chave = process.env.ANTHROPIC_API_KEY;
    if (!chave) {
      await loja.setJSON(marca, {pronto: true, erro:
        "A chave da Anthropic não está no site. Painel da Netlify → Site configuration → "
        + "Environment variables → ANTHROPIC_API_KEY."});
      return new Response("", { status: 202 });
    }

    const itens = Array.isArray(corpo.itens) ? corpo.itens.slice(0, 60) : [];
    if (!itens.length) {
      await loja.setJSON(marca, {pronto: true, erro: "Não veio texto para traduzir."});
      return new Response("", { status: 202 });
    }

    const resp = await pedir(chave, {
      model: "claude-sonnet-5",
      max_tokens: 8000,
      messages: [{ role: "user", content: PROMPT + JSON.stringify(itens) }]
    });
    const bruto = (resp.content || []).filter(b => b.type === "text").map(b => b.text).join("\n");
    const j = soJson(bruto);
    if (!j || !Array.isArray(j.traducao)) {
      await loja.setJSON(marca, {pronto: true, erro:
        "A tradução voltou fora do formato. Tente de novo; se repetir, me avise."});
      return new Response("", { status: 202 });
    }
    const u = resp.usage || {};
    const custo = ((u.input_tokens||0)/1e6*2 + (u.output_tokens||0)/1e6*10) * 0.92;
    await loja.setJSON(marca, {pronto: true, traducao: j.traducao,
      custo: Math.round(custo*100)/100});
    return new Response("", { status: 202 });
  } catch (e) {
    const m = (e && e.message) || String(e);
    const recado = /401|authentication|api key/i.test(m)
      ? "A chave da Anthropic foi recusada. Confira no painel da Netlify se ela está inteira."
      : (/credit|billing|quota|insufficient/i.test(m)
        ? "A conta da Anthropic está sem crédito. Adicione crédito em console.anthropic.com → Billing."
        : "Não consegui traduzir: " + m);
    try { await loja.setJSON(marca || "sem-marca", {pronto: true, erro: recado}); } catch (e2) {}
    return new Response("", { status: 202 });
  }
};

async function pedir(chave, corpo){
  const r = await fetch(API, {method:"POST", headers:{
    "content-type":"application/json", "x-api-key": chave, "anthropic-version": VERSAO_API
  }, body: JSON.stringify(corpo)});
  const t = await r.text();
  let j = null; try { j = JSON.parse(t); } catch (e) {}
  if (!r.ok) {
    const msg = (j && j.error && j.error.message) || t || ("HTTP " + r.status);
    const e = new Error(msg); e.status = r.status; throw e;
  }
  return j || {};
}

function soJson(t) {
  const s = String(t || "").replace(/^```(?:json)?/i, "").replace(/```$/,"").trim();
  const i = s.indexOf("{"), f = s.lastIndexOf("}");
  if (i < 0 || f <= i) return null;
  try { return JSON.parse(s.slice(i, f+1)); } catch (e) { return null; }
}

export const config = { path: "/api/fornecedor-traduzir" };
