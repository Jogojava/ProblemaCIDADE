// Interface do site: abas, menu móvel, dificuldade, filtros, galeria e equipe.

const $ = (seletor, raiz = document) => raiz.querySelector(seletor);
const $$ = (seletor, raiz = document) => [...raiz.querySelectorAll(seletor)];

function criar(tag, atributos = {}, filhos = []) {
  const el = document.createElement(tag);
  for (const [chave, valor] of Object.entries(atributos)) {
    if (chave === "texto") el.textContent = valor;
    else if (chave === "classe") el.className = valor;
    else el.setAttribute(chave, valor);
  }
  for (const filho of [].concat(filhos)) if (filho) el.append(filho);
  return el;
}

/* ---------- Abas ---------- */
const ABAS = ["inicio", "jogo", "problemas", "telas", "download", "equipe"];
let equipeCarregada = false, downloadCarregado = false;

function mostrarAba(nome, { rolar = true } = {}) {
  if (!ABAS.includes(nome)) nome = "inicio";
  for (const painel of $$("[data-painel]")) painel.hidden = painel.dataset.painel !== nome;
  for (const aba of $$(".abas [data-aba]")) {
    const ativa = aba.dataset.aba === nome;
    aba.classList.toggle("ativa", ativa);
    aba.setAttribute("aria-selected", ativa);
  }
  document.body.classList.toggle("na-capa", nome === "inicio");
  fecharMenu();
  if (rolar) window.scrollTo({ top: 0, behavior: "smooth" });
  if (nome === "download" && !downloadCarregado) {
    downloadCarregado = true;
    carregarDownload();
  }
  if (nome === "equipe" && !equipeCarregada) {
    equipeCarregada = true;
    carregarGitHub();
  }
}

document.addEventListener("click", (evento) => {
  const link = evento.target.closest("[data-aba]");
  if (!link) return;
  evento.preventDefault();
  const nome = link.dataset.aba;
  if (location.hash !== "#" + nome) history.pushState(null, "", "#" + nome);
  if (window.transicaoPixel) window.transicaoPixel(); // efeito do efeitos.js
  mostrarAba(nome);
});
window.addEventListener("popstate", () => mostrarAba(location.hash.slice(1), { rolar: false }));

/* ---------- Menu móvel ---------- */
const menuBtn = $(".menu-btn");
function fecharMenu() {
  $("#abas").classList.remove("aberto");
  menuBtn.setAttribute("aria-expanded", "false");
}
menuBtn.addEventListener("click", () => {
  const aberto = $("#abas").classList.toggle("aberto");
  menuBtn.setAttribute("aria-expanded", String(aberto));
});

/* ---------- Dificuldade ---------- */
function escolherDificuldade(chave) {
  const dados = DIFICULDADES[chave];
  for (const botao of $$(".dificuldade button")) {
    botao.setAttribute("aria-checked", String(botao.dataset.dif === chave));
  }
  const valor = $("#rep-valor");
  valor.textContent = dados.rep + "%";
  valor.classList.remove("pulsar");
  void valor.offsetWidth; // reinicia a animação
  valor.classList.add("pulsar");
  const barra = $("#rep-barra");
  barra.style.width = dados.rep + "%";
  barra.classList.toggle("abaixo", dados.rep < 50);
  $("#rep-nota").textContent = dados.nota;
}
$(".dificuldade").addEventListener("click", (evento) => {
  const botao = evento.target.closest("button[data-dif]");
  if (botao) escolherDificuldade(botao.dataset.dif);
});

/* ---------- Problemas ---------- */
function mostrarProblemas(categoria) {
  const lista = $("#lista-problemas");
  lista.replaceChildren();
  const filtrados = PROBLEMAS.filter((p) => categoria === "todos" || p.cat === categoria);
  for (const p of filtrados) {
    const cat = CATEGORIAS[p.cat];
    lista.append(criar("li", { classe: "problema cat-" + p.cat, style: "--i:" + lista.children.length }, [
      criar("img", { src: cat.icone, alt: "", width: "40", height: "40" }),
      criar("div", {}, [
        criar("span", { classe: "selo", texto: cat.nome }),
        criar("h3", { texto: p.titulo }),
        criar("p", { texto: p.texto })
      ])
    ]));
  }
  const n = filtrados.length;
  $("#contagem").textContent = n + (n === 1 ? " problema" : " problemas");
  for (const botao of $$(".filtro")) {
    const ativo = botao.dataset.cat === categoria;
    botao.classList.toggle("ativo", ativo);
    botao.setAttribute("aria-pressed", String(ativo));
  }
}
$(".filtros").addEventListener("click", (evento) => {
  const botao = evento.target.closest(".filtro");
  if (botao) mostrarProblemas(botao.dataset.cat);
});

/* ---------- Galeria ---------- */
const ampliar = $("#ampliar");
function montarGaleria() {
  const galeria = $("#galeria");
  TELAS.forEach((tela, i) => {
    const botao = criar("button", { type: "button", classe: "miniatura", "data-i": String(i) }, [
      criar("img", { src: tela.img, alt: tela.legenda, loading: "lazy", width: "1280", height: "720" }),
      criar("span", { texto: tela.legenda })
    ]);
    galeria.append(botao);
  });
  let atual = 0;
  const mostrarTela = (i, direcao = 0) => {
    atual = (i + TELAS.length) % TELAS.length;
    const tela = TELAS[atual], img = $("img", ampliar);
    img.src = tela.img;
    img.alt = tela.legenda;
    $("p", ampliar).textContent = `${tela.legenda} · ${atual + 1} de ${TELAS.length}`;
    if (direcao) {
      img.classList.remove("deslizar-esq", "deslizar-dir");
      void img.offsetWidth;
      img.classList.add(direcao > 0 ? "deslizar-esq" : "deslizar-dir");
    }
  };
  galeria.addEventListener("click", (evento) => {
    const botao = evento.target.closest(".miniatura");
    if (!botao) return;
    mostrarTela(Number(botao.dataset.i));
    ampliar.showModal();
  });
  $(".anterior", ampliar).addEventListener("click", () => mostrarTela(atual - 1, -1));
  $(".proxima", ampliar).addEventListener("click", () => mostrarTela(atual + 1, 1));
  ampliar.addEventListener("keydown", (evento) => {
    if (evento.key === "ArrowLeft") mostrarTela(atual - 1, -1);
    if (evento.key === "ArrowRight") mostrarTela(atual + 1, 1);
  });
  $(".fechar", ampliar).addEventListener("click", () => ampliar.close());
  ampliar.addEventListener("click", (evento) => { if (evento.target === ampliar) ampliar.close(); });
}

/* ---------- Equipe e GitHub ---------- */
function montarEquipe() {
  const grade = $("#grade-equipe");
  for (const pessoa of EQUIPE) {
    grade.append(criar("a", {
      classe: "membro",
      href: "https://github.com/" + pessoa.login,
      target: "_blank",
      rel: "noopener",
      "data-login": pessoa.login.toLowerCase()
    }, [
      criar("div", { classe: "membro-giro" }, [
        criar("div", { classe: "membro-frente" }, [
          criar("img", { src: pessoa.foto, alt: "Foto de " + pessoa.nome, loading: "lazy" }),
          criar("strong", { texto: pessoa.nome }),
          criar("span", { classe: "login", texto: "@" + pessoa.login }),
          criar("span", { classe: "papel", texto: "Desenvolvimento" }),
          criar("span", { classe: "contrib", texto: "" })
        ]),
        criar("div", { classe: "membro-verso", "aria-hidden": "true" }, [
          criar("span", { classe: "verso-num", texto: "…" }),
          criar("span", { classe: "verso-rotulo", texto: "commits no projeto" }),
          criar("span", { classe: "verso-link", texto: "Abrir GitHub →" })
        ])
      ])
    ]));
  }
}

const formatarData = (iso) => new Date(iso).toLocaleDateString("pt-BR", { day: "2-digit", month: "short", year: "numeric" });
// Números inteiros sobem contando até o valor; datas entram direto.
const numero = (chave, valor) => {
  const el = $(`[data-num="${chave}"]`);
  if (typeof valor !== "number" || matchMedia("(prefers-reduced-motion: reduce)").matches) { el.textContent = valor; return; }
  const inicio = performance.now(), duracao = 900;
  const passo = (agora) => {
    const t = Math.min((agora - inicio) / duracao, 1);
    el.textContent = Math.round(valor * (1 - Math.pow(1 - t, 3)));
    if (t < 1) requestAnimationFrame(passo);
  };
  requestAnimationFrame(passo);
};

async function carregarGitHub() {
  const status = $("#api-status");
  status.textContent = "Dados ao vivo da API do GitHub.";
  const tarefas = [
    GITHUB.repositorio().then((repo) => {
      const curta = (iso) => new Date(iso).toLocaleDateString("pt-BR");
      numero("criado", curta(repo.created_at));
      numero("atualizado", curta(repo.pushed_at));
    }),
    GITHUB.totalCommits().then((total) => numero("commits", total)),
    GITHUB.contribuidores().then((lista) => {
      numero("contribuidores", lista.length);
      for (const c of lista) {
        const card = $(`.membro[data-login="${c.login.toLowerCase()}"] .contrib`);
        if (card) card.textContent = c.contributions + (c.contributions === 1 ? " commit" : " commits");
        const verso = $(`.membro[data-login="${c.login.toLowerCase()}"] .verso-num`);
        if (verso) verso.textContent = c.contributions;
      }
    }),
    GITHUB.linguagens().then(mostrarLinguagens),
    GITHUB.commits(8).then(mostrarCommits)
  ];
  const resultados = await Promise.allSettled(tarefas);
  const falhas = resultados.filter((r) => r.status === "rejected");
  if (falhas.length) {
    const limite = falhas.some((f) => f.reason && f.reason.message === "limite");
    status.textContent = limite
      ? "O GitHub limitou os pedidos por agora (60 por hora sem login). Tente de novo mais tarde."
      : "Não foi possível falar com o GitHub agora. Confira a conexão e recarregue a página.";
    status.classList.add("erro");
    for (const el of $$("[data-num]")) if (el.textContent === "…") el.textContent = "–";
    const commits = $("#commits");
    if ($(".carregando", commits)) commits.replaceChildren(criar("li", { classe: "vazio", texto: "Commits indisponíveis no momento." }));
  }
}

function mostrarLinguagens(bytes) {
  const total = Object.values(bytes).reduce((a, b) => a + b, 0);
  if (!total) return;
  const caixa = $("#linguagens");
  const barra = criar("div", { classe: "ling-barra", role: "img", "aria-label": "Linguagens do repositório" });
  const legenda = criar("ul", { classe: "ling-legenda" });
  Object.entries(bytes).sort((a, b) => b[1] - a[1]).forEach(([nome, n], i) => {
    const pct = (n / total) * 100;
    const cor = "var(--ling-" + Math.min(i, 4) + ")";
    const parte = criar("span", { title: `${nome}: ${pct.toFixed(1)}%` });
    parte.style.width = pct + "%";
    parte.style.background = cor;
    barra.append(parte);
    const item = criar("li", {}, [criar("i"), `${nome} ${pct < 0.1 ? "<0,1" : pct.toFixed(1).replace(".", ",")}%`]);
    item.firstChild.style.background = cor;
    legenda.append(item);
  });
  caixa.replaceChildren(barra, legenda);
}

function mostrarCommits(lista) {
  const ul = $("#commits");
  ul.replaceChildren();
  for (const c of lista) {
    const mensagem = c.commit.message.split("\n")[0];
    const autor = c.author ? c.author.login : c.commit.author.name;
    ul.append(criar("li", { style: "--i:" + ul.children.length }, [
      criar("a", { href: c.html_url, target: "_blank", rel: "noopener", classe: "sha", texto: c.sha.slice(0, 7) }),
      criar("span", { classe: "msg", texto: mensagem }),
      criar("span", { classe: "meta", texto: autor + " · " + formatarData(c.commit.author.date) })
    ]));
  }
}

/* ---------- Download (último release do GitHub) ---------- */
const RELEASES = "https://github.com/" + GITHUB.REPO + "/releases";
const tamanho = (bytes) => (bytes / 1048576).toLocaleString("pt-BR", { maximumFractionDigits: 1 }) + " MB";

async function carregarDownload() {
  const caixa = $("#versao");
  try {
    const rel = await GITHUB.ultimaVersao();
    const zip = rel.assets.find((a) => a.name.endsWith(".zip")) || rel.assets[0];
    const baixados = rel.assets.reduce((soma, a) => soma + a.download_count, 0);
    const botao = $("#baixar-jogo");
    botao.href = zip ? zip.browser_download_url : rel.html_url;
    botao.removeAttribute("aria-disabled");
    caixa.replaceChildren(
      criar("div", {}, [criar("strong", { texto: rel.tag_name }), criar("span", { texto: "versão" })]),
      criar("div", {}, [criar("strong", { texto: new Date(rel.published_at).toLocaleDateString("pt-BR") }), criar("span", { texto: "publicada em" })]),
      criar("div", {}, [criar("strong", { texto: zip ? tamanho(zip.size) : "–" }), criar("span", { texto: "tamanho do .zip" })]),
      criar("div", {}, [criar("strong", { texto: String(baixados) }), criar("span", { texto: baixados === 1 ? "download" : "downloads" })])
    );
    if (zip) $("#nome-zip").textContent = zip.name;
  } catch (erro) {
    caixa.replaceChildren(criar("p", { classe: "nota erro", texto: "Não deu para consultar o GitHub agora. Os arquivos estão na página de Releases." }));
    $("#baixar-jogo").href = RELEASES;
  }
}

/* ---------- Revelar ao rolar ---------- */
// Cada bloco surge ao entrar na tela, em cascata com os irmãos.
function prepararRevelar() {
  if (!("IntersectionObserver" in window)) return;
  const observador = new IntersectionObserver((entradas) => {
    for (const e of entradas) {
      if (!e.isIntersecting) continue;
      const el = e.target;
      el.style.transitionDelay = (el.dataset.i * 70) + "ms";
      el.classList.add("visivel");
      setTimeout(() => { el.style.transitionDelay = ""; }, 1200);
      observador.unobserve(el);
    }
  }, { threshold: 0.12 });
  for (const el of $$(".cartao, .servicos li, .membro, .miniatura, .numeros div, .objetivo, .baixar, .sobre > div")) {
    el.dataset.i = [...el.parentElement.children].indexOf(el) % 6;
    el.classList.add("revelar");
    observador.observe(el);
  }
}

/* ---------- Início ---------- */
montarEquipe();
montarGaleria();
prepararRevelar();
mostrarProblemas("todos");
escolherDificuldade("medio");
mostrarAba(location.hash.slice(1), { rolar: false });
