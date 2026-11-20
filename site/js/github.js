// Acesso à API pública do GitHub (sem chave).
// Sem login, o GitHub permite 60 pedidos por hora por IP; por isso as
// respostas ficam guardadas por 10 minutos no sessionStorage.

const GITHUB = (() => {
  const REPO = "Jogojava/ProblemaCIDADE";
  const BASE = "https://api.github.com/repos/" + REPO;
  const VALIDADE_MS = 10 * 60 * 1000;

  function lerCache(chave) {
    try {
      const salvo = JSON.parse(sessionStorage.getItem("gh:" + chave));
      if (salvo && Date.now() - salvo.quando < VALIDADE_MS) return salvo.dados;
    } catch (e) { /* sem armazenamento: segue sem cache */ }
    return null;
  }

  function gravarCache(chave, dados) {
    try {
      sessionStorage.setItem("gh:" + chave, JSON.stringify({ quando: Date.now(), dados }));
    } catch (e) { /* ignora */ }
  }

  async function pedir(caminho, { comCabecalhos = false } = {}) {
    const cache = lerCache(caminho);
    if (cache) return cache;
    const resposta = await fetch(BASE + caminho, { headers: { Accept: "application/vnd.github+json" } });
    if (!resposta.ok) {
      const restante = resposta.headers.get("x-ratelimit-remaining");
      const erro = new Error(restante === "0" ? "limite" : "http " + resposta.status);
      throw erro;
    }
    const corpo = await resposta.json();
    const dados = comCabecalhos ? { corpo, link: resposta.headers.get("link") } : corpo;
    gravarCache(caminho, dados);
    return dados;
  }

  // Total de commits: pede 1 por página e lê o número da última página no cabeçalho Link.
  async function totalCommits() {
    const { corpo, link } = await pedir("/commits?per_page=1", { comCabecalhos: true });
    const ultima = link && link.match(/[?&]page=(\d+)>; rel="last"/);
    return ultima ? Number(ultima[1]) : corpo.length;
  }

  return {
    REPO,
    repositorio: () => pedir(""),
    contribuidores: () => pedir("/contributors?per_page=100"),
    commits: (n = 8) => pedir("/commits?per_page=" + n),
    linguagens: () => pedir("/languages"),
    ultimaVersao: () => pedir("/releases/latest"),
    totalCommits
  };
})();
