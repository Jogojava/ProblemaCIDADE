// Dados fixos do site, tirados do próprio jogo (godot/scripts/eventdatabase.gd,
// tela de créditos e menu de nova gestão).

const EQUIPE = [
  { nome: "Beatriz Leonardo Fernandes da Silva", login: "liittlebeea", foto: "img/beatriz.jpg" },
  { nome: "Camilo Handal Batista Oliveira", login: "CamiloHandal", foto: "img/camilo.png" },
  { nome: "Débora Luiza de Paula Ferreira", login: "d3bLuiz4", foto: "img/debora.jpg" },
  { nome: "Guilherme Nascimento Bilibio", login: "toybile", foto: "img/guilherme.png" },
  { nome: "Henrique Daisuke Akiyama", login: "AkiyamaDaisuke", foto: "img/henrique.jpg" }
];

const DIFICULDADES = {
  facil: { rep: 65, nota: "Começa com folga sobre a meta da eleição (50%)." },
  medio: { rep: 55, nota: "Começa pouco acima da meta da eleição (50%)." },
  dificil: { rep: 45, nota: "Começa abaixo da meta da eleição (50%): é preciso recuperar." }
};

const TELAS = [
  { img: "img/telas/01-menu.png", legenda: "Menu principal" },
  { img: "img/telas/02-instrucoes.png", legenda: "Início do mandato" },
  { img: "img/telas/03-cidade.png", legenda: "A cidade" },
  { img: "img/telas/04-noite.png", legenda: "A cidade à noite" },
  { img: "img/telas/05-problema.png", legenda: "Resolução de problemas" },
  { img: "img/telas/06-investimentos.png", legenda: "Investimentos e construções" },
  { img: "img/telas/07-projecoes.png", legenda: "Reputação, finanças e projeções" }
];
