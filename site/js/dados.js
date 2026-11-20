// Dados fixos do site, tirados do próprio jogo (godot/scripts/eventdatabase.gd,
// tela de créditos e menu de nova gestão).

const EQUIPE = [
  { nome: "Beatriz Leonardo Fernandes da Silva", login: "liittlebeea", foto: "img/beatriz.jpg" },
  { nome: "Camilo Handal Batista Oliveira", login: "CamiloHandal", foto: "img/camilo.png" },
  { nome: "Débora Luiza de Paula Ferreira", login: "d3bLuiz4", foto: "img/debora.jpg" },
  { nome: "Guilherme Nascimento Bilibio", login: "toybile", foto: "img/guilherme.png" },
  { nome: "Henrique Daisuke Akiyama", login: "AkiyamaDaisuke", foto: "img/henrique.jpg" }
];

const CATEGORIAS = {
  optional: { nome: "Opcional", icone: "img/optional.png" },
  common: { nome: "Comum", icone: "img/common.png" },
  important: { nome: "Importante", icone: "img/important.png" },
  urgent: { nome: "Urgente", icone: "img/urgent.png" }
};

const PROBLEMAS = [
  { titulo: "Ajude AURA na travessia VENIDA", cat: "optional",
    texto: "Uma senhora precisa atravessar uma rua de 8 metros antes de o sinal fechar. Ela consegue?" },
  { titulo: "Comer comer para poder crescer", cat: "common",
    texto: "Transporte fixo, R$ 12 por refeição, 80 alunos e margem de 25%. Qual verba é necessária?" },
  { titulo: "ABUStecimento & ProporcionaCIDADE", cat: "common",
    texto: "R$ 300 mil divididos proporcionalmente entre bairros com 50, 30 e 70 famílias." },
  { titulo: "Juros pelo meu milhão", cat: "common",
    texto: "Juros simples de 25% ao ano ou compostos de 20% ao ano: qual banco custa menos em dois anos?" },
  { titulo: "Obra-primarial", cat: "common",
    texto: "Cinco obras prioritárias, duas por vez. Quantas combinações diferentes existem?" },
  { titulo: "MedicaMOVImentos", cat: "important",
    texto: "Duas rotas para levar remédios: compare tempo e custo e escolha uma." },
  { titulo: "Verba IMSS", cat: "important",
    texto: "População, orçamento e lógica proposicional decidem se a verba aumenta." },
  { titulo: "Tsente: moradias após a enchente", cat: "urgent",
    texto: "120 sobreviventes sem moradia. Qual modelo de casa atende a todos pelo menor custo?" },
  { titulo: "Intriga do Carroeios", cat: "urgent",
    texto: "Levar presos ao presídio em 30 minutos sem passar de R$ 6 de pedágio. Dá tempo?" },
  { titulo: "Pesquisa satisfatória", cat: "optional",
    texto: "1.200 entrevistados: qual o percentual de aprovação e de desaprovação?" }
];

const DIFICULDADES = {
  facil: { rep: 65, nota: "Começa com folga sobre a meta da eleição (50%)." },
  medio: { rep: 55, nota: "Começa pouco acima da meta da eleição (50%)." },
  dificil: { rep: 45, nota: "Começa abaixo da meta da eleição (50%): é preciso recuperar." }
};

const TELAS = [
  { img: "img/telas/01-menu.jpg", legenda: "Menu principal" },
  { img: "img/telas/03-instrucoes.jpg", legenda: "Início do mandato" },
  { img: "img/telas/04-cidade.jpg", legenda: "A cidade" },
  { img: "img/telas/06-problema.jpg", legenda: "Um problema opcional" },
  { img: "img/telas/08-investimentos.jpg", legenda: "Investimentos em serviços" },
  { img: "img/telas/09-projecoes.jpg", legenda: "Reputação, finanças e projeções" }
];
