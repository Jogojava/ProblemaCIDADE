# Site do ProblemaCIDADE

Site de apresentação do jogo, feito com HTML, CSS e JavaScript puros, sem bibliotecas nem etapa de build.

## Como abrir

- **Direto:** abra `site_oficial/index.html` no navegador. Não precisa de servidor.
- **Com servidor local** (opcional):

  ```bash
  cd site_oficial
  python -m http.server 8000
  ```

  Depois acesse `http://localhost:8000`.

- **Publicado:** <https://jogojava.github.io/ProblemaCIDADE/>

## Publicação no GitHub Pages

O workflow `../.github/workflows/pages.yml` publica a pasta `site_oficial/` sempre que algo nela muda no branch `site` (também dá para rodar à mão na aba *Actions*). Não há etapa de build: a pasta é enviada como está.

Configuração, feita uma vez por alguém com acesso de admin: *Settings → Pages → Build and deployment → Source:* **GitHub Actions**.

Todos os caminhos do site são relativos, então ele funciona no endereço `/ProblemaCIDADE/` do Pages.

## Estrutura

```
site_oficial/
  index.html      estrutura das abas (Início, O jogo, Telas, Download, Equipe)
  css/style.css   visual, estados de hover e regras de responsividade
  css/efeitos.css capa animada, dia e noite, transições, simulador, gráfico e download
  js/dados.js     dados fixos tirados do jogo (equipe, dificuldades, telas)
  js/github.js    acesso à API do GitHub, com cache
  js/app.js       abas, menu móvel, galeria, download e montagem da equipe no DOM
  js/efeitos.js   carregamento, transição entre abas, parallax, sons, dia e noite,
                  cidade que cresce, simulador, gráfico de commits e o pato
  img/            arte do jogo, fotos da equipe, ícones e capturas (img/telas/)
```

## Abas

| Aba | O que mostra | Interação |
|---|---|---|
| Início | Capa com o fundo do menu do jogo, nuvens e carros passando, e botões no estilo do jogo | O fundo se move com o mouse (parallax); botões levam às outras abas |
| O jogo | Objetivo, regras, categorias de ocorrências, seis serviços e como rodar | Escolher a dificuldade muda a reputação inicial (65%, 55% ou 45%); o simulador soma ou tira reputação a cada escolha e diz se haveria reeleição ou impeachment (valores ilustrativos, não os do jogo) |
| Telas | Capturas da versão atual do jogo | Clique abre a imagem ampliada (`<dialog>`); setas na tela ou ← → do teclado trocam a captura; fecha no ×, no fundo ou com Esc |
| Download | Botão para o `.zip` do último release, com versão, data, tamanho e número de downloads | Dados lidos do Releases do GitHub; instruções para Windows e Linux |
| Equipe | Integrantes com foto e link para o GitHub, dados do repositório e gráfico de commits por semana | Passar o mouse num cartão o vira e mostra os commits da pessoa; carrega a API na primeira vez que a aba abre |

As abas usam o endereço (`#jogo`, `#equipe`…), então dá para mandar o link de uma aba e os botões voltar e avançar do navegador funcionam.

## JavaScript e DOM

- Os painéis ficam no HTML; `app.js` mostra um e esconde os outros (`hidden`) e marca a aba ativa (`aria-selected`).
- Galeria, cartões da equipe, commits e barra de linguagens são criados com `document.createElement`, pela função `criar()`. Textos entram por `textContent`, nunca por `innerHTML`, para não executar nada que venha da API.
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
| `GET /repos/.../stats/participation` | Gráfico de commits das últimas 26 semanas (se o GitHub responder 202, o site tenta de novo) |
| `GET /repos/.../releases/latest` | Aba Download: link do `.zip`, versão, data, tamanho e downloads |

- **Limite:** sem login, o GitHub aceita 60 pedidos por hora por IP. Cada abertura da aba usa 6. Por isso as respostas ficam em `sessionStorage` por 10 minutos.
- **Erros:** se a API falhar ou o limite acabar, a aba continua funcionando (fotos, nomes e links são fixos) e mostra um aviso em vermelho explicando o motivo.

Para trocar o repositório, altere `REPO` em `js/github.js`. Para mudar integrantes, dificuldades ou capturas, edite `js/dados.js`.

## Efeitos e preferências

- **Tela de carregamento** pixelada na primeira visita da sessão.
- **Transição** em quadradinhos ao trocar de aba.
- **Sons 8-bit** (botão ♪ no topo), feitos com Web Audio. Começam desligados.
- **Dia e noite** (botão ☾/☀): a capa ganha céu escuro, estrelas e faróis acesos, e as caixas ficam escuras.
- **Cidade que cresce**: prédios em pixel acima do rodapé que sobem conforme a página é rolada.
- **Cursor** em pixel art.
- **Pato:** ↑↑↓↓←→←→ B A, ou cinco cliques no logo da equipe.

Som e modo noite ficam salvos no `localStorage` do navegador.

## Responsividade

- Acima de 820 px: abas no topo.
- Até 820 px: as abas viram um menu que abre no botão de três linhas; os números do repositório passam para duas colunas.
- Até 480 px: listas e galeria em uma coluna, equipe em duas colunas, títulos menores.
- As grades usam `auto-fill` com `minmax`, então se ajustam a qualquer largura entre esses pontos.
- Com "reduzir movimento" ligado no sistema, as animações são desativadas.

## Acessibilidade

- Abas com `role="tablist"`/`tab`/`tabpanel`, dificuldade com `radiogroup`.
- Reputação e estado do simulador com `aria-live`, para leitores de tela anunciarem a mudança.
- Foco visível em todos os elementos clicáveis.

## Créditos das imagens

Fundo, botões e ícones de categoria: Débora Luiza de Paula Ferreira. Fotos e logo: tela de créditos do jogo. Ícones dos serviços: HUD do jogo. Capturas: tiradas da versão atual do jogo.

