/* =====================================================================
   PROCESSAR O MATERIAL DO FORNECEDOR

   Ela cola o email, arrasta o tarifário em PDF, clica em Processar. Esta
   função lê tudo e devolve a ficha em JSON, no formato que a tela já sabe
   importar — o mesmo do protótipo, para não existirem duas traduções.

   POR QUE É FUNÇÃO DE FUNDO (o sufixo -background): uma função normal da
   Netlify tem 10 segundos, e ler um tarifário de seis páginas leva bem
   mais. A de fundo tem 15 minutos, responde 202 na hora e escreve o
   resultado no Blobs do próprio site; a tela pergunta "ficou pronto?" a
   cada dois segundos. É o mesmo caminho do PDF da proposta, que já roda.

   A CHAVE DA ANTHROPIC fica só aqui, nas variáveis de ambiente do site.
   Sem ela a função responde dizendo o que falta, em português — e a tela
   mostra esse recado em vez de um erro seco.

   NÃO GRAVA NADA no banco: devolve o rascunho, e quem decide é ela na
   tela de revisão. IA não salva fornecedor.
   ===================================================================== */
import Anthropic from "@anthropic-ai/sdk";
import { getStore } from "@netlify/blobs";

/* As listas fechadas, iguais às do banco (tl_forn_listas) e às da tela.
   Escritas aqui de novo de propósito: é o prompt que precisa delas, e o
   prompt não tem como consultar o banco. Mudar uma lista é mudar nos três. */
const CATS = ["Hotel / Accommodation","Winery","Restaurant","Experience / Activity","Guide",
  "Transfer / Transport","Venue / Events","Private Chef / Catering","Other"];
const SUITE = ["TL Selected Stays","TL Signature Experiences","TL Signature Programs",
  "Concierge","Ground Services","MICE e Exclusive Events"];
const UNITS = ["per person","per group (total)","per vehicle","per hour","per night",
  "per room per night","flat fee"];

const PROMPT = `You maintain the supplier database of Tuscan Lands, a luxury B2B DMC based in Florence operating in Tuscany, Umbria and Lazio and selling to travel advisors and agencies.
Read the material below (email, PDF rate sheet, loose notes, Google Maps link, in any language) and extract ONE supplier in the JSON format shown.

Rules:
- Reply with the JSON only. No explanation, no code fence.
- EVERYTHING in English: descriptions, conditions, notes, summary, open points, tags. Translate from Italian, Portuguese or any other language. Keep proper names, place names and dish names as they are.
- Plain, factual English, no marketing adjectives. Service descriptions: 1 to 3 faithful sentences, ready to paste into a proposal.
- Do not invent. Missing information stays "" or [] (hospedagem may be null). What is missing or ambiguous goes in pendencias — that list is what she will confirm with the supplier, so be specific.
- Prices: numbers in euro in preco_adulto and preco_crianca when a clear figure exists; anything conditional (age bands, free under X, optional add-ons, supplements) goes in preco_texto or extras.
- price_basis for each service: "Net" when the material says net, trade, agency, dedicated or exclusive-to-agencies rates; "Gross" when it says public, retail, rack, or commissionable (then put the commission in comissao); otherwise "Not stated". Record VAT in iva.
- business_suite: suggest where this supplier can be used, using ONLY these lines: ${SUITE.join(" | ")}. TL Selected Stays = hotels, villas, accommodation. TL Signature Experiences = tours, tastings, classes, in-villa experiences. TL Signature Programs = multi-day itineraries. Concierge = bookable by Florence hotel guests. Ground Services = transfers, drivers, guides, logistics. MICE e Exclusive Events = corporate groups, venues, group dining, weddings and private celebrations. Only suggest what fits clearly.
- Coordinates: use @lat,lng or !3d/!4d from a Google Maps link if present (coords_aproximadas=false). Otherwise estimate from the address (coords_aproximadas=true). Mobile suppliers with no base address: lat and lng null and fill area_atendimento.
- Include room capacities and accommodation even if the material is mainly about experiences.
- unidade: how the price is charged, one of: ${UNITS.join(" | ")}. When the price changes with group size and is a total, put EVERY step in faixas (pax + total price) and use "per group (total)".
- quartos: only for hotels and rentals, one entry per room type, with every season/rate line found. Always give size in square metres (convert from sq ft if only that is given) and list in diferenciais what distinguishes the type (terrace, patio, separate living room, view, suite extras). If sources disagree on size or occupancy, say so in pendencias.
- VAT exemption (e.g. art. 10 DPR 633/72) means iva = "exempt".
- nome_na_proposta: "Show supplier name" for hotels and restaurants, otherwise "Hide supplier name".
- proposta (for every service): a neutral commercial name and a 1 to 3 sentence description that a client could NOT use to identify or find the supplier: no company or brand names of the supplier, no estate or villa names, no named partner venues, no awards, no founding dates, no staff names, no exact addresses. Keep the city or general area and what the guest does and gets. Generic nouns like "Vespa sidecar" or "Chianti" are fine.

JSON format:
{
 "nome": "trade name",
 "nome_legal": "legal company name if shown",
 "categoria": "one of: ${CATS.join(" | ")}",
 "subcategorias": ["e.g. agriturismo, cooking class, wine tasting"],
 "business_suite": ["zero or more of: ${SUITE.join(" | ")}"],
 "regiao": "one of: Tuscany | Umbria | Lazio | Other",
 "cidade": "comune / town",
 "area_atendimento": "for mobile suppliers (chefs, guides, drivers): where they operate",
 "endereco": "full address",
 "lat": 43.7, "lng": 11.3,
 "coords_aproximadas": true,
 "site": "", "instagram": "",
 "contatos": [{"nome":"","funcao":"","email":"","telefone":"","whatsapp":""}],
 "idiomas": ["English","Italian"],
 "tarifa_tipo": "e.g. Dedicated agency rate (net), Commissionable 10%, Public rate",
 "comissao": "",
 "iva": "included | excluded | exempt | not stated",
 "nome_na_proposta": "Show supplier name | Hide supplier name",
 "dados_bancarios": "account holder, IBAN, SWIFT, bank, if given",
 "validade": "e.g. 2027",
 "condicoes_pagamento": "",
 "condicoes_reserva": "",
 "politica_cancelamento": "",
 "capacidades": "rooms, seated/standing pax, etc.",
 "hospedagem": {"unidades":"","max_hospedes":"","observacoes":""},
 "quartos": [{"nome":"room type","metragem":"e.g. approx. 40 m²","ocupacao_max":"","camas":"","vista":"","quantidade":"","descricao":"","diferenciais":[""],"tarifas":[{"temporada":"","datas":"","regime":"BB | HB | RO","preco":0,"unidade":"per room per night","price_basis":"Net | Gross | Not stated"}]}],
 "servicos": [{"nome":"","tipo":"","descricao":"","duracao":"","idiomas":[],"inclui":[],"preco_adulto":33,"preco_crianca":16,"price_basis":"Net | Gross | Not stated","unidade":"per person","faixas":[{"pax":4,"preco":770}],"horarios":"","ponto_encontro":"","restricoes":"","proposta":{"nome":"neutral commercial name","descricao":"neutral description"},"preco_texto":"","min_pax":"","max_pax":"","extras":"","observacoes":""}],
 "destaques": [""],
 "tags": [""],
 "resumo": "1 or 2 plain sentences",
 "pendencias": [""]
}

MATERIAL:
`;

const TIPOS_IMG = ["image/jpeg","image/png","image/gif","image/webp"];
const LIMITE = 20 * 1024 * 1024;   // o pedido inteiro da API cabe em 32 MB

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
        "A chave da Anthropic ainda não está no site. No painel da Netlify: "
        + "Site configuration → Environment variables → Add a variable → "
        + "nome ANTHROPIC_API_KEY, valor a chave do console.anthropic.com. "
        + "Depois publique o site de novo (Deploys → Trigger deploy)."});
      return new Response("", { status: 202 });
    }

    const texto = String(corpo.texto || "").slice(0, 400000);
    const arquivos = Array.isArray(corpo.arquivos) ? corpo.arquivos.slice(0, 8) : [];
    if (!texto.trim() && !arquivos.length) {
      await loja.setJSON(marca, {pronto: true, erro: "Não veio material nenhum para ler."});
      return new Response("", { status: 202 });
    }

    /* PDF vai INTEIRO para o modelo, como documento — não extraio texto no
       navegador. Resolve o tarifário escaneado pelo mesmo caminho do
       digital, e é uma peça a menos para manter. Documento antes do texto,
       que é como a API recomenda. */
    let bytes = 0;
    const blocos = [];
    for (const a of arquivos) {
      const dados = String(a.dados || "").replace(/^data:[^,]*,/, "").replace(/\s/g, "");
      if (!dados) continue;
      bytes += Math.floor(dados.length * 3 / 4);
      if (bytes > LIMITE) {
        await loja.setJSON(marca, {pronto: true, erro:
          "Os anexos passam de 20 MB juntos. Mande o tarifário e deixe as fotos para depois — "
          + "foto entra na ficha pelo botão de fotos."});
        return new Response("", { status: 202 });
      }
      const tipo = String(a.tipo || "");
      if (tipo === "application/pdf")
        blocos.push({type:"document", source:{type:"base64", media_type:"application/pdf", data:dados}});
      else if (TIPOS_IMG.includes(tipo))
        blocos.push({type:"image", source:{type:"base64", media_type:tipo, data:dados}});
    }
    blocos.push({type:"text", text: PROMPT + (texto.trim() || "(sem texto colado; o material está nos anexos)")});

    const client = new Anthropic({ apiKey: chave });
    /* Sonnet 5 é o modelo pedido na especificação dela. Esforço médio:
       extração de tarifário é trabalho de leitura, não de raciocínio longo,
       e cada centavo aqui sai do bolso dela. */
    const resp = await client.messages.create({
      model: "claude-sonnet-5",
      max_tokens: 16000,
      thinking: { type: "adaptive" },
      output_config: { effort: "medium" },
      messages: [{ role: "user", content: blocos }]
    });

    const bruto = (resp.content || []).filter(b => b.type === "text").map(b => b.text).join("\n");
    const ficha = soJson(bruto);
    if (!ficha) {
      await loja.setJSON(marca, {pronto: true, erro:
        "O modelo respondeu, mas não em JSON. Tente de novo; se repetir, me avise.",
        bruto: bruto.slice(0, 2000)});
      return new Response("", { status: 202 });
    }
    /* O que a leitura custou, em euro, para ela ver na tela. Sonnet 5:
       US$ 2 por milhão de tokens de entrada, US$ 10 na saída. */
    const u = resp.usage || {};
    const custo = ((u.input_tokens||0)/1e6*2 + (u.output_tokens||0)/1e6*10) * 0.92;
    await loja.setJSON(marca, {pronto: true, ficha,
      custo: Math.round(custo*100)/100,
      tokens: {entrada: u.input_tokens||0, saida: u.output_tokens||0}});
    return new Response("", { status: 202 });
  } catch (e) {
    const m = (e && e.message) || String(e);
    const recado = /401|authentication|api key/i.test(m)
      ? "A chave da Anthropic foi recusada. Confira se você copiou a chave inteira no painel da Netlify."
      : (/credit|billing|quota|insufficient/i.test(m)
        ? "A conta da Anthropic está sem crédito. Adicione crédito em console.anthropic.com → Billing."
        : "Não consegui ler o material: " + m);
    try { await loja.setJSON(marca || "sem-marca", {pronto: true, erro: recado}); } catch (e2) {}
    return new Response("", { status: 202 });
  }
};

/* O modelo às vezes embrulha o JSON em cerca de código ou escreve uma frase
   antes. Pega do primeiro { ao último } e tenta. */
function soJson(t) {
  const s = String(t || "").replace(/^```(?:json)?/i, "").replace(/```$/,"").trim();
  const i = s.indexOf("{"), f = s.lastIndexOf("}");
  if (i < 0 || f <= i) return null;
  try { return JSON.parse(s.slice(i, f+1)); } catch (e) { return null; }
}

export const config = { path: "/api/fornecedor-extrair" };
