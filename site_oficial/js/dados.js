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
  { img: "img/telas/01-menu.jpg", legenda: "Menu principal" },
  { img: "img/telas/03-instrucoes.jpg", legenda: "Início do mandato" },
  { img: "img/telas/04-cidade.jpg", legenda: "A cidade" },
  { img: "img/telas/06-problema.jpg", legenda: "Um problema opcional" },
  { img: "img/telas/08-investimentos.jpg", legenda: "Investimentos em serviços" },
  { img: "img/telas/09-projecoes.jpg", legenda: "Reputação, finanças e projeções" }
];
