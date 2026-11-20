# Site do ProblemaCIDADE

Site de apresentação do jogo, feito com HTML, CSS e JavaScript puros, sem bibliotecas nem etapa de build.

## Como abrir

- **Direto:** abra `site/index.html` no navegador. Não precisa de servidor.
- **Com servidor local** (opcional):

  ```bash
  cd site
  python -m http.server 8000
  ```

  Depois acesse `http://localhost:8000`.

- **Publicado:** <https://jogojava.github.io/ProblemaCIDADE/>

## Publicação no GitHub Pages

O workflow `.github/workflows/pages.yml` publica a pasta `site/` sempre que algo nela muda no branch `site` (também dá para rodar à mão na aba *Actions*). Não há etapa de build: a pasta é enviada como está.

Configuração, feita uma vez por alguém com acesso de admin: *Settings → Pages → Build and deployment → Source:* **GitHub Actions**.

Todos os caminhos do site são relativos, então ele funciona no endereço `/ProblemaCIDADE/` do Pages.

## Estrutura

```
site/
  index.html      estrutura das abas (Início, O jogo, Problemas, Telas, Equipe)
  css/style.css   visual, estados de hover e regras de responsividade
  js/dados.js     dados fixos tirados do jogo (equipe, problemas, dificuldades, telas)
  js/github.js    acesso à API do GitHub, com cache
  js/app.js       abas, menu móvel, filtros, galeria e montagem da equipe no DOM
  img/            arte do jogo, fotos da equipe, ícones e capturas (img/telas/)
```

## Abas

| Aba | O que mostra | Interação |
|---|---|---|
| Início | Capa com o fundo do menu do jogo e botões no estilo dos botões do jogo | Botões levam às outras abas |
| O jogo | Objetivo, regras, seis serviços e como rodar | Escolher a dificuldade muda a reputação inicial na barra (65%, 55% ou 45%) |
| Problemas | Os 10 problemas do banco de eventos do jogo | Filtro por categoria (opcional, comum, importante, urgente) com contagem |
| Telas | Capturas da versão atual do jogo | Clique abre a imagem ampliada (`<dialog>`), fecha no ×, no fundo ou com Esc |
| Equipe | Integrantes com foto e link para o GitHub, e dados do repositório | Carrega a API do GitHub na primeira vez que a aba abre |

As abas usam o endereço (`#jogo`, `#equipe`…), então dá para mandar o link de uma aba e os botões voltar e avançar do navegador funcionam.

## JavaScript e DOM

- Os painéis ficam no HTML; `app.js` mostra um e esconde os outros (`hidden`) e marca a aba ativa (`aria-selected`).
- Listas de problemas, galeria, cartões da equipe, commits e barra de linguagens são criados com `document.createElement`, pela função `criar()`. Textos entram por `textContent`, nunca por `innerHTML`, para não executar nada que venha da API.
- Os cliques são tratados por delegação de eventos (um ouvinte por grupo de botões).

## API do GitHub

`js/github.js` usa a API REST pública, sem chave, no repositório `Jogojava/ProblemaCIDADE`:

| Endpoint | Uso no site |
|---|---|
| `GET /repos/Jogojava/ProblemaCIDADE` | Data de criação e da última atualização |
| `GET /repos/.../commits?per_page=1` | Total de commits, lido do número da última página no cabeçalho `Link` |
| `GET /repos/.../contributors` | Número de contribuidores e commits de cada integrante no cartão dele |
| `GET /repos/.../languages` | Barra de linguagens do repositório |
| `GET /repos/.../commits?per_page=8` | Lista dos commits recentes com link para cada um |

- **Limite:** sem login, o GitHub aceita 60 pedidos por hora por IP. Cada abertura da aba usa 5. Por isso as respostas ficam em `sessionStorage` por 10 minutos.
- **Erros:** se a API falhar ou o limite acabar, a aba continua funcionando (fotos, nomes e links são fixos) e mostra um aviso em vermelho explicando o motivo.

Para trocar o repositório, altere `REPO` em `js/github.js`. Para mudar integrantes ou problemas, edite `js/dados.js`.

## Responsividade

- Acima de 820 px: abas no topo.
- Até 820 px: as abas viram um menu que abre no botão de três linhas; os números do repositório passam para duas colunas.
- Até 480 px: listas e galeria em uma coluna, equipe em duas colunas, títulos menores.
- As grades usam `auto-fill` com `minmax`, então se ajustam a qualquer largura entre esses pontos.
- Com "reduzir movimento" ligado no sistema, as animações são desativadas.

## Acessibilidade

- Abas com `role="tablist"`/`tab`/`tabpanel`, dificuldade com `radiogroup` e filtros com `aria-pressed`.
- Contagem de problemas e reputação com `aria-live`, para leitores de tela anunciarem a mudança.
- Foco visível em todos os elementos clicáveis.

## Créditos das imagens

Fundo, botões e ícones de categoria: Débora Luiza de Paula Ferreira. Fotos e logo: tela de créditos do jogo. Ícones dos serviços: HUD do jogo. Capturas: tiradas da versão atual do jogo.
