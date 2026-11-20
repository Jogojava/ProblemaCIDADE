// Efeitos do site: carregamento, transição pixel, parallax, sons 8-bit,
// dia e noite, cidade que cresce, simulador de reputação, gráfico de commits e o pato.

const semMovimento = matchMedia("(prefers-reduced-motion: reduce)").matches;
const lerPref = (chave) => { try { return localStorage.getItem("pc:" + chave); } catch (e) { return null; } };
const gravarPref = (chave, valor) => { try { localStorage.setItem("pc:" + chave, valor); } catch (e) { /* sem armazenamento */ } };

/* ---------- Tela de carregamento (só na primeira visita da sessão) ---------- */
(() => {
  let jaViu = false;
  try { jaViu = sessionStorage.getItem("pc:carregou") === "1"; sessionStorage.setItem("pc:carregou", "1"); } catch (e) { /* ignora */ }
  const tirar = () => document.body.classList.remove("carregando-site");
  if (jaViu || semMovimento) { tirar(); return; }
  const inicio = performance.now();
  const terminar = () => setTimeout(tirar, Math.max(0, 900 - (performance.now() - inicio)));
  if (document.readyState === "complete") terminar(); else addEventListener("load", terminar);
  setTimeout(tirar, 3500); // nunca prende a página
})();

/* ---------- Transição pixelada entre abas ---------- */
(() => {
  const camada = document.querySelector(".transicao");
  const colunas = 16, linhas = 10;
  for (let i = 0; i < colunas * linhas; i++) {
    const q = document.createElement("span");
    q.style.setProperty("--d", (Math.random() * 280).toFixed(0) + "ms");
    camada.append(q);
  }
  let fim = 0;
  window.transicaoPixel = () => {
    if (semMovimento) return;
    clearTimeout(fim);
    camada.classList.remove("ativa");
    void camada.offsetWidth; // reinicia a animação
    camada.classList.add("ativa");
    fim = setTimeout(() => camada.classList.remove("ativa"), 700);
  };
})();

/* ---------- Parallax da capa com o mouse ---------- */
(() => {
  const heroi = document.querySelector(".heroi");
  if (semMovimento || !matchMedia("(hover: hover)").matches) return;
  let quadro = 0;
  heroi.addEventListener("mousemove", (e) => {
    cancelAnimationFrame(quadro);
    quadro = requestAnimationFrame(() => {
      const r = heroi.getBoundingClientRect();
      heroi.style.setProperty("--mx", ((e.clientX - r.left) / r.width - 0.5).toFixed(3));
      heroi.style.setProperty("--my", ((e.clientY - r.top) / r.height - 0.5).toFixed(3));
    });
  });
  heroi.addEventListener("mouseleave", () => { heroi.style.setProperty("--mx", 0); heroi.style.setProperty("--my", 0); });
})();

/* ---------- Sons 8-bit (começa mudo) ---------- */
const SOM = (() => {
  const botao = document.getElementById("som");
  let ligado = lerPref("som") === "1", ctx = null;
  const mostrar = () => {
    botao.setAttribute("aria-pressed", String(ligado));
    botao.setAttribute("aria-label", ligado ? "Desligar sons" : "Ligar sons");
    botao.classList.toggle("ligado", ligado);
  };
  function tocar(notas, volume = 0.05) {
    if (!ligado) return;
    ctx = ctx || new (window.AudioContext || window.webkitAudioContext)();
    let t = ctx.currentTime;
    for (const [freq, dur] of notas) {
      const osc = ctx.createOscillator(), ganho = ctx.createGain();
      osc.type = "square";
      osc.frequency.value = freq;
      ganho.gain.setValueAtTime(volume, t);
      ganho.gain.exponentialRampToValueAtTime(0.0001, t + dur);
      osc.connect(ganho).connect(ctx.destination);
      osc.start(t);
      osc.stop(t + dur);
      t += dur * 0.85;
    }
  }
  botao.addEventListener("click", () => {
    ligado = !ligado;
    gravarPref("som", ligado ? "1" : "0");
    mostrar();
    tocar([[523, 0.08], [784, 0.12]]);
  });
  document.addEventListener("click", (e) => {
    if (e.target.closest("#som")) return;
    if (e.target.closest("[data-aba]")) tocar([[660, 0.06], [880, 0.08]]);
    else if (e.target.closest("button, .pixel-btn, .membro, .miniatura")) tocar([[440, 0.05]]);
  });
  document.addEventListener("pointerover", (e) => {
    const alvo = e.target.closest(".pixel-btn");
    if (alvo && !alvo.contains(e.relatedTarget)) tocar([[1320, 0.025]], 0.02);
  });
  mostrar();
  return { tocar };
})();

/* ---------- Dia e noite ---------- */
(() => {
  const botao = document.getElementById("noite");
  const aplicar = (noite) => {
    document.body.classList.toggle("noite", noite);
    botao.setAttribute("aria-pressed", String(noite));
    botao.setAttribute("aria-label", noite ? "Modo dia" : "Modo noite");
    botao.firstElementChild.textContent = noite ? "☀" : "☾";
  };
  aplicar(lerPref("noite") === "1");
  botao.addEventListener("click", () => {
    const noite = !document.body.classList.contains("noite");
    document.body.classList.add("trocando-tema");
    aplicar(noite);
    gravarPref("noite", noite ? "1" : "0");
    setTimeout(() => document.body.classList.remove("trocando-tema"), 700);
  });
})();

/* ---------- Cidade que cresce ao rolar ---------- */
(() => {
  const faixa = document.querySelector(".cidade-cresce");
  const cores = ["#6d5848", "#1e9bd7", "#3e4452", "#55d23e", "#e9c40c", "#a58c7a", "#10b8b0", "#e5533d"];
  let semente = 7;
  const aleatorio = () => (semente = (semente * 9301 + 49297) % 233280) / 233280; // fixo: sempre a mesma cidade
  for (let i = 0; i < 26; i++) {
    const p = document.createElement("span");
    p.style.setProperty("--h", Math.round(40 + aleatorio() * 110) + "px");
    p.style.setProperty("--w", Math.round(22 + aleatorio() * 26) + "px");
    p.style.setProperty("--c", cores[Math.floor(aleatorio() * cores.length)]);
    p.style.setProperty("--d", (i % 8) * 40 + "ms");
    faixa.append(p);
  }
  const atualizar = () => {
    const max = document.documentElement.scrollHeight - innerHeight;
    const p = max > 0 ? Math.min(scrollY / max, 1) : 1;
    faixa.style.setProperty("--p", p.toFixed(3));
  };
  addEventListener("scroll", atualizar, { passive: true });
  addEventListener("resize", atualizar);
  document.addEventListener("click", () => setTimeout(atualizar, 400));
  atualizar();
})();

/* ---------- Simulador de reputação ---------- */
(() => {
  const valor = document.getElementById("sim-valor"), barra = document.getElementById("sim-barra");
  const status = document.getElementById("sim-status");
  let rep = 55;
  const inicial = () => parseInt(document.getElementById("rep-valor").textContent, 10) || 55;
  function mostrar(texto, classe = "") {
    valor.textContent = rep + "%";
    barra.style.width = rep + "%";
    barra.classList.toggle("abaixo", rep < 50);
    barra.classList.toggle("perigo", rep < 10);
    status.className = "sim-status " + classe;
    status.textContent = texto;
    valor.classList.remove("pulsar");
    void valor.offsetWidth;
    valor.classList.add("pulsar");
  }
  function reiniciar() {
    rep = inicial();
    for (const b of document.querySelectorAll(".sim-acoes button")) b.disabled = false;
    mostrar("Faça uma escolha.");
  }
  document.querySelector(".sim-acoes").addEventListener("click", (e) => {
    const b = e.target.closest("button[data-efeito]");
    if (!b) return;
    const efeito = Number(b.dataset.efeito);
    rep = Math.max(0, Math.min(100, rep + efeito));
    let texto = `${b.dataset.texto}: ${efeito > 0 ? "+" : ""}${efeito}. `, classe = efeito > 0 ? "bom" : "ruim";
    if (rep === 0 || rep < 10) { texto += "Impeachment! A gestão terminou."; classe = "ruim fim"; }
    else if (rep >= 50) texto += "Você seria reeleito.";
    else texto += "Abaixo da meta de 50%: sem reeleição.";
    if (classe.includes("fim")) for (const x of document.querySelectorAll(".sim-acoes button")) x.disabled = true;
    SOM.tocar(efeito > 0 ? [[660, 0.06], [990, 0.1]] : [[300, 0.08], [200, 0.14]]);
    mostrar(texto, classe);
    const flutua = document.createElement("span");
    flutua.className = "sim-flutua " + (efeito > 0 ? "bom" : "ruim");
    flutua.textContent = (efeito > 0 ? "+" : "") + efeito;
    b.append(flutua);
    setTimeout(() => flutua.remove(), 900);
  });
  document.getElementById("sim-reiniciar").addEventListener("click", reiniciar);
  document.querySelector(".dificuldade").addEventListener("click", () => setTimeout(reiniciar, 0));
  reiniciar();
})();

/* ---------- Gráfico de commits por semana (API do GitHub) ---------- */
(() => {
  const caixa = document.getElementById("grafico");
  let pedido = false;
  async function participacao(tentativa = 0) {
    try {
      const salvo = JSON.parse(sessionStorage.getItem("gh:participacao"));
      if (salvo && Date.now() - salvo.quando < 600000) return salvo.dados;
    } catch (e) { /* sem cache */ }
    const r = await fetch(`https://api.github.com/repos/${GITHUB.REPO}/stats/participation`);
    if (r.status === 202 && tentativa < 4) { // o GitHub ainda está calculando
      await new Promise((ok) => setTimeout(ok, 2500));
      return participacao(tentativa + 1);
    }
    if (!r.ok) throw new Error("http " + r.status);
    const dados = (await r.json()).all;
    try { sessionStorage.setItem("gh:participacao", JSON.stringify({ quando: Date.now(), dados })); } catch (e) { /* ignora */ }
    return dados;
  }
  function desenhar(semanas) {
    const ultimas = semanas.slice(-26), maior = Math.max(1, ...ultimas);
    const hoje = new Date();
    const lista = document.createElement("div");
    lista.className = "barras";
    ultimas.forEach((n, i) => {
      const inicio = new Date(hoje - (ultimas.length - 1 - i) * 7 * 864e5);
      const barra = document.createElement("span");
      barra.style.setProperty("--alt", (n / maior * 100).toFixed(1) + "%");
      barra.style.setProperty("--d", i * 25 + "ms");
      barra.dataset.n = n;
      barra.title = `Semana de ${inicio.toLocaleDateString("pt-BR", { day: "2-digit", month: "short" })}: ${n} commit${n === 1 ? "" : "s"}`;
      lista.append(barra);
    });
    const total = ultimas.reduce((a, b) => a + b, 0);
    const legenda = document.createElement("p");
    legenda.className = "nota";
    legenda.textContent = `${total} commits nas últimas 26 semanas. Passe o mouse numa barra para ver a semana.`;
    caixa.replaceChildren(lista, legenda);
    requestAnimationFrame(() => lista.classList.add("cheio"));
  }
  const carregar = () => {
    if (pedido) return;
    pedido = true;
    participacao().then(desenhar).catch(() => {
      caixa.replaceChildren(Object.assign(document.createElement("p"), { className: "nota erro", textContent: "Gráfico indisponível agora." }));
    });
  };
  if (location.hash === "#equipe") carregar();
  document.addEventListener("click", (e) => { if (e.target.closest('[data-aba="equipe"]')) carregar(); });
  addEventListener("popstate", () => { if (location.hash === "#equipe") carregar(); });
})();

/* ---------- Easter egg do pato: ↑↑↓↓←→←→BA ou 5 cliques no logo ---------- */
(() => {
  const pato = document.querySelector(".pato");
  const codigo = ["ArrowUp", "ArrowUp", "ArrowDown", "ArrowDown", "ArrowLeft", "ArrowRight", "ArrowLeft", "ArrowRight", "b", "a"];
  let pos = 0, cliques = 0, zerar = 0;
  function quack() {
    if (pato.classList.contains("andando")) return;
    pato.classList.add("andando");
    SOM.tocar([[520, 0.07], [390, 0.09], [520, 0.07], [390, 0.12]], 0.06);
    const aviso = document.createElement("div");
    aviso.className = "aviso-pato";
    aviso.textContent = "Quack! Feito pela Pato Jogos.";
    document.body.append(aviso);
    setTimeout(() => aviso.remove(), 3200);
    setTimeout(() => pato.classList.remove("andando"), 5200);
  }
  addEventListener("keydown", (e) => {
    pos = e.key.toLowerCase() === codigo[pos].toLowerCase() ? pos + 1 : (e.key === codigo[0] ? 1 : 0);
    if (pos === codigo.length) { pos = 0; quack(); }
  });
  document.addEventListener("click", (e) => {
    if (!e.target.closest(".logo")) return;
    clearTimeout(zerar);
    zerar = setTimeout(() => { cliques = 0; }, 1500);
    if (++cliques >= 5) { cliques = 0; quack(); }
  });
  window.quack = quack;
})();
