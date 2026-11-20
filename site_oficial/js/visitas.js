// Contador simples de visitas usando a API pública da CounterAPI.
(async () => {
  const total = document.getElementById("visitas-total");
  if (!total) return;

  const controlador = new AbortController();
  const tempoLimite = setTimeout(() => controlador.abort(), 8000);
  try {
    const resposta = await fetch(
      "https://counterapi.com/api/jogojava-problemacidade-site/view/visitas",
      { signal: controlador.signal, headers: { Accept: "application/json" } }
    );
    if (!resposta.ok) throw new Error("A API de visitas respondeu com erro.");
    const dados = await resposta.json();
    const valor = Number(dados.value);
    if (!Number.isFinite(valor)) throw new Error("A API retornou um total inválido.");
    total.textContent = valor.toLocaleString("pt-BR");
  } catch {
    total.textContent = "—";
    total.title = "Não foi possível carregar o contador agora.";
  } finally {
    clearTimeout(tempoLimite);
  }
})();
