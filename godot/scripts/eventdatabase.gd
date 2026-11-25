extends Node
class_name EventDatabase

const CATEGORY_OPTIONAL := "optional"
const CATEGORY_COMMON := "common"
const CATEGORY_IMPORTANT := "important"
const CATEGORY_URGENT := "urgent"

const INTERACTION_CHOICE := "choice"
const INTERACTION_NUMBER_INPUT := "number_input"
const INTERACTION_TEXT_INPUT := "text_input"
const PROBLEM_AVAILABILITY_DAYS := 30

var events: Dictionary = {}

var _rng := RandomNumberGenerator.new()
var _used_ids_by_category: Dictionary = {
	CATEGORY_OPTIONAL: [],
	CATEGORY_COMMON: [],
	CATEGORY_IMPORTANT: [],
	CATEGORY_URGENT: []
}
var _default_event_ids: Dictionary = {}
var _procedural_event_ids: Dictionary = {}

func _ready() -> void:
	_rng.randomize()

func register_event(event_id: String, data: Dictionary) -> void:
	if event_id.is_empty():
		return

	var event_data := data.duplicate(true)
	event_data["id"] = event_id

	if not event_data.has("category"):
		event_data["category"] = CATEGORY_COMMON

	if not event_data.has("interaction_type"):
		event_data["interaction_type"] = INTERACTION_CHOICE

	if not event_data.has("payload"):
		event_data["payload"] = {}

	if not event_data.has("success_effects"):
		event_data["success_effects"] = {}

	if not event_data.has("failure_effects"):
		event_data["failure_effects"] = {}

	if not event_data.has("expiration_effects"):
		event_data["expiration_effects"] = {}

	if not event_data.has("availability_duration_days"):
		event_data["availability_duration_days"] = null

	# Optional image resource for a problem statement; leave null until artwork is added.
	if not event_data.has("image"):
		event_data["image"] = null

	events[event_id] = event_data

func register_default_problems() -> void:
	var problems := {
		"aura_travessia": {
			"title": "Ajude AURA na travessia VENIDA",
			"image": "res://assets/problems/aura.png",
			"description": "Uma senhora precisa atravessar uma rua de 8 metros. Ela anda a 1 metro por segundo e descansa por 3 segundos a cada 4 metros. O sinal fica aberto por 15 segundos; ela leva 2 segundos para interpretar a luz e mais 1 para começar a andar. Ela consegue atravessar?",
			"category": CATEGORY_OPTIONAL,
			"interaction_type": INTERACTION_CHOICE,
			"availability_duration_days": PROBLEM_AVAILABILITY_DAYS,
			"payload": {"options": [
				{"id": "sim", "text": "Sim"},
				{"id": "nao", "text": "Não"}
			]},
			"correct_answer": "sim",
			"success_effects": {"social": 2.0},
			"failure_effects": {"social": -1.0},
			"expiration_effects": {},
			"explanation": "Ela gasta 8 segundos andando, 3 descansando uma vez e 3 para reagir ao sinal: 14 segundos, menos que os 15 disponíveis."
		},
		"merenda_escolar": {
			"title": "Comer comer para poder crescer",
			"image": "res://assets/problems/merenda_escolar.png",
			"description": "A prefeitura paga R$ 500 de transporte fixo e R$ 12 por refeição. A escola tem 80 alunos e deve incluir uma margem de 25% para quem repete a refeição. Qual verba é necessária?",
			"category": CATEGORY_COMMON,
			"interaction_type": INTERACTION_NUMBER_INPUT,
			"availability_duration_days": PROBLEM_AVAILABILITY_DAYS,
			"payload": {"prompt": "Digite o valor sem símbolos", "correct_value": 1700, "placeholder": "Ex.: 1700"},
			"success_effects": {"education": 2.0},
			"failure_effects": {"education": -1.0},
			"expiration_effects": {"education": -1.0},
			"explanation": "25% de 80 são 20 refeições extras. Então, 500 + 12 × (80 + 20) = R$ 1.700."
		},
		"transporte_proporcional": {
			"title": "ABUStecimento & ProporcionaCIDADE",
			"image": "res://assets/problems/onibus.png",
			"description": "Uma verba de R$ 300 mil será distribuída proporcionalmente entre bairros com 50, 30 e 70 famílias. Quanto cada bairro deve receber, respectivamente?",
			"category": CATEGORY_COMMON,
			"interaction_type": INTERACTION_CHOICE,
			"availability_duration_days": PROBLEM_AVAILABILITY_DAYS,
			"payload": {"options": [
				{"id": "a", "text": "R$ 100 mil, R$ 80 mil e R$ 120 mil"},
				{"id": "b", "text": "R$ 100 mil, R$ 60 mil e R$ 140 mil"},
				{"id": "c", "text": "R$ 50 mil, R$ 30 mil e R$ 70 mil"},
				{"id": "d", "text": "R$ 75 mil, R$ 50 mil e R$ 175 mil"}
			]},
			"correct_answer": "b",
			"success_effects": {"social": 2.0},
			"failure_effects": {"social": -1.0},
			"expiration_effects": {"social": -1.0},
			"explanation": "São 150 famílias ao todo. Cada família corresponde a R$ 2 mil, resultando em R$ 100 mil, R$ 60 mil e R$ 140 mil."
		},
		"juros_bancos": {
			"title": "Juros pelo meu milhão",
			"description": "Um empréstimo de R$ 1 milhão será quitado em 24 meses. O Banco Grotesco cobra juros simples de 25% ao ano; o NuhBanho cobra juros compostos de 20% ao ano. Qual banco custa menos ao final de dois anos?",
			"category": CATEGORY_COMMON,
			"interaction_type": INTERACTION_CHOICE,
			"availability_duration_days": PROBLEM_AVAILABILITY_DAYS,
			"payload": {"options": [
				{"id": "grotesco", "text": "Banco Grotesco"},
				{"id": "nuhbanho", "text": "NuhBanho"}
			]},
			"correct_answer": "nuhbanho",
			"success_effects": {"water": 2.0},
			"failure_effects": {"water": -1.0},
			"expiration_effects": {"water": -1.0},
			"explanation": "O Grotesco cobra 1 × (1 + 0,25 × 2) = R$ 1,5 milhão. O NuhBanho cobra 1 × 1,2² = R$ 1,44 milhão."
		},
		"rota_medicamentos": {
			"title": "MedicaMOVImentos",
			"description": "A Rota A tem 120 km, média de 60 km/h e custo de R$ 600. A Rota B tem 90 km, média de 60 km/h e custo de R$ 800. Some 30 minutos para carga e descarga. Escolha uma rota e compare tempo e custo.",
			"category": CATEGORY_IMPORTANT,
			"interaction_type": INTERACTION_CHOICE,
			"availability_duration_days": PROBLEM_AVAILABILITY_DAYS,
			"payload": {"options": [
				{"id": "rota_a", "text": "Rota A: 2h30, R$ 600 (mais barata)"},
				{"id": "rota_b", "text": "Rota B: 2h, R$ 800 (mais rápida)"}
			]},
			"accepted_answers": ["rota_a", "rota_b"],
			"success_effects": {},
			"failure_effects": {"health": -1.0},
			"expiration_effects": {"health": -1.0},
			"explanation": "A Rota A leva 2h30 e custa menos. A Rota B leva 2h e custa mais. A escolha depende de priorizar economia ou rapidez."
		},
		"moradias_enchente": {
			"title": "Tsente: moradias após a enchente",
			"image": "res://assets/problems/tsente.png",
			"description": "Uma enchente deixou 120 sobreviventes sem moradia. Qual modelo atende a todos pelo menor custo? A: 4 pessoas por R$ 78.829,91; B: 6 pessoas por R$ 108.182,34; C: 10 pessoas por R$ 155.330,72.",
			"category": CATEGORY_URGENT,
			"interaction_type": INTERACTION_CHOICE,
			"availability_duration_days": null,
			"payload": {"options": [
				{"id": "a", "text": "Modelo A"},
				{"id": "b", "text": "Modelo B"},
				{"id": "c", "text": "Modelo C"}
			]},
			"correct_answer": "c",
			"success_effects": {"social": 2.0},
			"failure_effects": {"social": -1.0},
			"expiration_effects": {"social": -1.0},
			"explanation": "O modelo C precisa de 12 unidades. Mesmo com o custo unitário maior, o total aproximado é R$ 1,86 milhão, menor que os modelos A e B."
		},
		"verba_imss": {
			"title": "Verba IMSS",
			"description": "25% da população continua elegível ao IMSS. A população passou de 25.932 para 28.484 pessoas. O orçamento disponível é R$ 17,8 milhões e a verba do ano passado foi R$ 1,36 milhão. A verba aumentará quando P e Q forem verdadeiros: P, elegíveis cresceram pelo menos 8%; Q, a verba não passa de 10% do orçamento. A verba aumentará?",
			"category": CATEGORY_IMPORTANT,
			"interaction_type": INTERACTION_CHOICE,
			"availability_duration_days": PROBLEM_AVAILABILITY_DAYS,
			"payload": {"options": [
				{"id": "sim", "text": "Sim"},
				{"id": "nao", "text": "Não"}
			]},
			"correct_answer": "sim",
			"success_effects": {"social": 2.0},
			"failure_effects": {"social": -1.0},
			"expiration_effects": {"social": -1.0},
			"explanation": "Elegíveis cresceram cerca de 9,84%, então P é verdadeiro. O aumento para aproximadamente R$ 1,49 milhão fica abaixo de 10% de R$ 17,8 milhões (R$ 1,78 milhão), então Q também é verdadeiro."
		},
		"rota_presidio": {
			"title": "Intriga do Carroeios",
			"description": "A polícia precisa transportar presos de H ao presídio R antes do fechamento, em 30 minutos. O pedágio total não pode passar de R$ 6; o combustível custa R$ 2 por quilômetro. Estradas (km, min, pedágio): H-A (4, 6, 0); H-B (2, 10, 2); A-C (5, 5, 1); A-D (3, 12, 0); B-C (6, 4, 3); B-E (4, 7, 1); C-F (2, 3, 2); D-F (7, 8, 0); E-R (3, 5, 1); F-R (5, 6, 2); D-R (9, 15, 0). Existe um caminho que atende às restrições?",
			"category": CATEGORY_URGENT,
			"interaction_type": INTERACTION_CHOICE,
			"availability_duration_days": null,
			"payload": {"options": [
				{"id": "sim", "text": "Sim"},
				{"id": "nao", "text": "Não"}
			]},
			"correct_answer": "sim",
			"success_effects": {"security": 2.0},
			"failure_effects": {"security": -1.0},
			"expiration_effects": {"security": -1.0},
			"explanation": "A viagem leva 22 minutos e paga R$ 4 de pedágio. O combustível custa R$ 18, totalizando R$ 22; as duas restrições são atendidas.",
			"graph": {
				"legend": "km, min, pedágio (R$)",
				"nodes": [
					{"id": "H", "label": "H", "pos": Vector2(0.04, 0.50)},
					{"id": "A", "label": "A", "pos": Vector2(0.26, 0.22)},
					{"id": "B", "label": "B", "pos": Vector2(0.26, 0.78)},
					{"id": "C", "label": "C", "pos": Vector2(0.48, 0.50)},
					{"id": "D", "label": "D", "pos": Vector2(0.55, 0.08)},
					{"id": "E", "label": "E", "pos": Vector2(0.56, 0.92)},
					{"id": "F", "label": "F", "pos": Vector2(0.74, 0.44)},
					{"id": "R", "label": "R", "pos": Vector2(0.96, 0.52)}
				],
				"edges": [
					{"from": "H", "to": "A", "label": "4, 6, 0", "label_offset": Vector2(-14, -12)},
					{"from": "H", "to": "B", "label": "2, 10, 2", "label_offset": Vector2(-14, 12)},
					{"from": "A", "to": "C", "label": "5, 5, 1", "label_offset": Vector2(-10, 4)},
					{"from": "A", "to": "D", "label": "3, 12, 0", "label_offset": Vector2(2, -11)},
					{"from": "B", "to": "C", "label": "6, 4, 3", "label_offset": Vector2(-10, -4)},
					{"from": "B", "to": "E", "label": "4, 7, 1", "label_offset": Vector2(-6, 12)},
					{"from": "C", "to": "F", "label": "2, 3, 2", "label_offset": Vector2(0, 14)},
					{"from": "D", "to": "F", "label": "7, 8, 0", "label_offset": Vector2(-16, 10)},
					{"from": "E", "to": "R", "label": "3, 5, 1", "label_offset": Vector2(6, 12)},
					{"from": "F", "to": "R", "label": "5, 6, 2", "label_offset": Vector2(0, 14)},
					{"from": "D", "to": "R", "label": "9, 15, 0", "label_offset": Vector2(10, -14)}
				]
			}
		},
		"pesquisa_satisfacao": {
			"title": "Pesquisa satisfatória",
			"description": "O instituto DataCidade entrevistou 1.200 cidadãos: 540 aprovam, 420 desaprovam e 240 são neutros. Qual é o percentual de aprovação e desaprovação, respectivamente?",
			"category": CATEGORY_OPTIONAL,
			"interaction_type": INTERACTION_CHOICE,
			"availability_duration_days": PROBLEM_AVAILABILITY_DAYS,
			"payload": {"options": [
				{"id": "a", "text": "45% e 35%"},
				{"id": "b", "text": "30% e 50%"},
				{"id": "c", "text": "20% e 45%"},
				{"id": "d", "text": "20% e 35%"}
			]},
			"correct_answer": "a",
			"success_effects": {"culture": 2.0},
			"failure_effects": {"culture": -1.0},
			"expiration_effects": {},
			"explanation": "540 ÷ 1.200 = 45% de aprovação; 420 ÷ 1.200 = 35% de desaprovação."
		},
		"obras_combinacoes": {
			"title": "Obra-primarial",
			"description": "A prefeitura tem 5 obras prioritárias, mas o orçamento permite executar 2 no mesmo período. A ordem não importa. Quantas combinações diferentes de obras existem?",
			"category": CATEGORY_COMMON,
			"interaction_type": INTERACTION_CHOICE,
			"availability_duration_days": PROBLEM_AVAILABILITY_DAYS,
			"payload": {"options": [
				{"id": "a", "text": "5"},
				{"id": "b", "text": "10"},
				{"id": "c", "text": "20"},
				{"id": "d", "text": "25"}
			]},
			"correct_answer": "b",
			"success_effects": {"water": 2.0},
			"failure_effects": {"water": -1.0},
			"expiration_effects": {"water": -1.0},
			"explanation": "A combinação é C(5, 2) = 5 × 4 ÷ 2 = 10."
		}
	}

	for event_id in problems:
		if event_id == "rota_medicamentos":
			problems[event_id]["choice_effects"] = {"rota_a": {"funds": -600.0, "health": 1.0}, "rota_b": {"funds": -800.0, "health": 2.0}}
		_default_event_ids[String(event_id)] = true
		register_event(String(event_id), problems[event_id])

	_register_suggested_problems()

func _register_suggested_problems() -> void:
	var problems := {
		"aprova_cidade": {
			"title": "AprovaCIDADE",
			"description": "Em uma consulta sobre a reforma da praça, 180 dos 240 moradores ouvidos aprovaram o projeto. Qual foi o percentual de aprovação?",
			"category": CATEGORY_OPTIONAL,
			"interaction_type": INTERACTION_CHOICE,
			"availability_duration_days": PROBLEM_AVAILABILITY_DAYS,
			"payload": {"options": [
				{"id": "a", "text": "60%"}, {"id": "b", "text": "70%"},
				{"id": "c", "text": "75%"}, {"id": "d", "text": "80%"}
			]},
			"correct_answer": "c",
			"success_effects": {"social": 2.0}, "failure_effects": {"social": -1.0},
			"explanation": "180 ÷ 240 = 0,75. Multiplicando por 100, a aprovação foi de 75%."
		},
		"media_dos_barulhinhos": {
			"title": "A Média dos Barulhinhos",
			"description": "A fiscalização mediu o ruído perto de uma escola em três horários: 18, 22 e 26 decibéis. Qual foi a média das medições?",
			"category": CATEGORY_OPTIONAL,
			"interaction_type": INTERACTION_CHOICE,
			"availability_duration_days": PROBLEM_AVAILABILITY_DAYS,
			"payload": {"options": [
				{"id": "a", "text": "20 decibéis"}, {"id": "b", "text": "22 decibéis"},
				{"id": "c", "text": "24 decibéis"}, {"id": "d", "text": "66 decibéis"}
			]},
			"correct_answer": "b",
			"success_effects": {"health": 1.0}, "failure_effects": {"health": -0.5},
			"explanation": "(18 + 22 + 26) ÷ 3 = 66 ÷ 3 = 22 decibéis."
		},
		"praca_quadrada": {
			"title": "Praça Quadrada, Conta Redonda",
			"description": "O projeto de uma praça quadrada prevê área de 144 m². Qual deve ser a medida de cada lado?",
			"category": CATEGORY_OPTIONAL,
			"interaction_type": INTERACTION_CHOICE,
			"availability_duration_days": PROBLEM_AVAILABILITY_DAYS,
			"payload": {"options": [
				{"id": "a", "text": "10 m"}, {"id": "b", "text": "12 m"},
				{"id": "c", "text": "14 m"}, {"id": "d", "text": "18 m"}
			]},
			"correct_answer": "b",
			"success_effects": {"culture": 1.0}, "failure_effects": {"culture": -0.5},
			"explanation": "A área do quadrado é lado × lado. Como 12 × 12 = 144, cada lado mede 12 m."
		},
		"onibus_sem_lotacao": {
			"title": "Ônibus sem Lotação",
			"image": "res://assets/problems/onibus.png",
			"description": "Quatro ônibus escolares iguais transportam 120 estudantes, sem lugares sobrando. Para uma visita com 180 estudantes, mantendo a mesma quantidade de estudantes por ônibus, quantos ônibus serão necessários?",
			"category": CATEGORY_OPTIONAL,
			"interaction_type": INTERACTION_NUMBER_INPUT,
			"availability_duration_days": PROBLEM_AVAILABILITY_DAYS,
			"payload": {"prompt": "Digite a quantidade de ônibus", "correct_value": 6, "placeholder": "Ex.: 6"},
			"success_effects": {"education": 2.0}, "failure_effects": {"education": -1.0},
			"explanation": "Cada ônibus leva 120 ÷ 4 = 30 estudantes. Para 180 estudantes: 180 ÷ 30 = 6 ônibus."
		},
		"apagao_avenida": {
			"title": "Apagão na Avenida",
			"description": "A prefeitura vai trocar 17 lâmpadas queimadas. Cada lâmpada custa R$ 120, e o deslocamento da equipe custa R$ 300. Qual é o custo total do serviço?",
			"category": CATEGORY_OPTIONAL,
			"interaction_type": INTERACTION_NUMBER_INPUT,
			"availability_duration_days": PROBLEM_AVAILABILITY_DAYS,
			"payload": {"prompt": "Digite o total em reais, sem símbolos", "correct_value": 2340, "placeholder": "Ex.: 2340"},
			"success_effects": {"security": 2.0}, "failure_effects": {"security": -1.0},
			"explanation": "As lâmpadas custam 17 × 120 = R$ 2.040. Somando R$ 300 de deslocamento, o total é R$ 2.340."
		},
		"feira_de_quem_te_viu": {
			"title": "Feira de Quem Te Viu",
			"description": "A feira municipal recebeu 120 visitantes pela manhã e 180 à tarde. Quantas visitas foram registradas no dia?",
			"category": CATEGORY_COMMON,
			"interaction_type": INTERACTION_CHOICE,
			"availability_duration_days": PROBLEM_AVAILABILITY_DAYS,
			"payload": {"options": [
				{"id": "a", "text": "280 visitas"}, {"id": "b", "text": "300 visitas"},
				{"id": "c", "text": "320 visitas"}, {"id": "d", "text": "360 visitas"}
			]},
			"correct_answer": "b",
			"success_effects": {"culture": 1.5}, "failure_effects": {"culture": -0.5},
			"explanation": "Somando os dois períodos: 120 + 180 = 300 visitas."
		},
		"juros_sem_grasnar": {
			"title": "Banco Pato: Juros sem Grasnar",
			"description": "A prefeitura aplicou R$ 1.000 em uma reserva com juros simples de 2% ao mês por 5 meses. Quanto a aplicação rendeu somente em juros?",
			"category": CATEGORY_COMMON,
			"interaction_type": INTERACTION_CHOICE,
			"availability_duration_days": PROBLEM_AVAILABILITY_DAYS,
			"payload": {"options": [
				{"id": "a", "text": "R$ 50"}, {"id": "b", "text": "R$ 100"},
				{"id": "c", "text": "R$ 200"}, {"id": "d", "text": "R$ 1.100"}
			]},
			"correct_answer": "b",
			"success_effects": {"social": 1.5}, "failure_effects": {"social": -0.5},
			"explanation": "Juros simples: 1.000 × 0,02 × 5 = R$ 100 de rendimento."
		},
		"atalho_turistico": {
			"title": "Atalho ou Passeio Turístico?",
			"description": "Uma equipe de manutenção pode chegar ao posto de saúde pela Rota A (3 km + 4 km) ou pela Rota B (5 km + 5 km). Qual rota é mais curta?",
			"category": CATEGORY_COMMON,
			"interaction_type": INTERACTION_CHOICE,
			"availability_duration_days": PROBLEM_AVAILABILITY_DAYS,
			"payload": {"options": [
				{"id": "a", "text": "Rota A, com 7 km"}, {"id": "b", "text": "Rota B, com 10 km"}
			]},
			"correct_answer": "a",
			"success_effects": {"health": 1.5}, "failure_effects": {"health": -0.5},
			"explanation": "A Rota A totaliza 3 + 4 = 7 km. A Rota B totaliza 5 + 5 = 10 km."
		},
		"asfalto_cada_metro": {
			"title": "Asfalto: Cada Metro Conta",
			"description": "Uma rua será pavimentada em 8 trechos de 25 metros. O serviço custa R$ 40 por metro, mais R$ 1.000 pelo aluguel das máquinas. Qual é o custo total da obra?",
			"category": CATEGORY_COMMON,
			"interaction_type": INTERACTION_NUMBER_INPUT,
			"availability_duration_days": PROBLEM_AVAILABILITY_DAYS,
			"payload": {"prompt": "Digite o total em reais, sem símbolos", "correct_value": 9000, "placeholder": "Ex.: 9000"},
			"success_effects": {"water": 1.5}, "failure_effects": {"water": -0.5},
			"explanation": "A rua terá 8 × 25 = 200 m. O pavimento custa 200 × R$ 40 = R$ 8.000; com as máquinas, R$ 9.000."
		},
		"lixeira_atacado": {
			"title": "Lixeira em Lote: Prefeitura em Atacado",
			"description": "A cidade comprará 50 lixeiras por R$ 80 cada. O fornecedor ofereceu 10% de desconto no valor total. Quanto a prefeitura pagará?",
			"category": CATEGORY_COMMON,
			"interaction_type": INTERACTION_CHOICE,
			"availability_duration_days": PROBLEM_AVAILABILITY_DAYS,
			"payload": {"options": [
				{"id": "a", "text": "R$ 3.200"}, {"id": "b", "text": "R$ 3.600"},
				{"id": "c", "text": "R$ 4.000"}, {"id": "d", "text": "R$ 4.400"}
			]},
			"correct_answer": "b",
			"success_effects": {"social": 1.5}, "failure_effects": {"social": -0.5},
			"explanation": "O preço sem desconto é 50 × 80 = R$ 4.000. Dez por cento são R$ 400; o total fica R$ 3.600."
		},
		"abrigo_do_e": {
			"title": "O Abrigo do “E”",
			"description": "Um abrigo emergencial só é aprovado se tiver pelo menos 20 leitos E custar no máximo R$ 50.000. A proposta tem 24 leitos e custa R$ 55.000. Ela atende às duas condições?",
			"category": CATEGORY_IMPORTANT,
			"interaction_type": INTERACTION_CHOICE,
			"availability_duration_days": PROBLEM_AVAILABILITY_DAYS,
			"payload": {"options": [{"id": "sim", "text": "Sim"}, {"id": "nao", "text": "Não"}]},
			"correct_answer": "nao",
			"success_effects": {"health": 2.0}, "failure_effects": {"health": -1.0},
			"explanation": "A proposta atende ao mínimo de leitos, mas excede o limite de custo. Como as duas condições precisam ser verdadeiras, ela não é aprovada."
		},
		"agua_todo_mundo": {
			"title": "Água pra Todo Mundo",
			"description": "Para distribuir água em três bairros, a defesa civil estimou a necessidade de 24, 36 e 60 caixas. O estoque municipal tem 80 caixas. Quantas caixas ainda precisam ser compradas?",
			"category": CATEGORY_IMPORTANT,
			"interaction_type": INTERACTION_NUMBER_INPUT,
			"availability_duration_days": PROBLEM_AVAILABILITY_DAYS,
			"payload": {"prompt": "Digite a quantidade de caixas", "correct_value": 40, "placeholder": "Ex.: 40"},
			"success_effects": {"water": 2.0}, "failure_effects": {"water": -1.0},
			"explanation": "A necessidade total é 24 + 36 + 60 = 120 caixas. Como há 80 no estoque, faltam 120 − 80 = 40."
		},
		"rota_do_remedio": {
			"title": "A Rota do Remédio",
			"description": "Uma unidade de saúde precisa de um medicamento com urgência. A Rota A leva 20 minutos e custa R$ 30; a Rota B leva 15 minutos e custa R$ 40. Se a prioridade é entregar o mais rápido possível, qual rota escolher?",
			"category": CATEGORY_IMPORTANT,
			"interaction_type": INTERACTION_CHOICE,
			"availability_duration_days": PROBLEM_AVAILABILITY_DAYS,
			"payload": {"options": [{"id": "a", "text": "Rota A: 20 min, R$ 30"}, {"id": "b", "text": "Rota B: 15 min, R$ 40"}]},
			"correct_answer": "b",
			"success_effects": {"health": 2.0}, "failure_effects": {"health": -1.0},
			"explanation": "A Rota B leva 15 minutos, cinco a menos que a Rota A. Como o enunciado prioriza rapidez, essa é a escolha adequada."
		},
		"raiz_da_praca": {
			"title": "A Raiz da Praça",
			"description": "Uma praça quadrada terá área de 196 m². Qual será a medida, em metros, de cada lado do terreno?",
			"category": CATEGORY_IMPORTANT,
			"interaction_type": INTERACTION_NUMBER_INPUT,
			"availability_duration_days": PROBLEM_AVAILABILITY_DAYS,
			"payload": {"prompt": "Digite o lado em metros", "correct_value": 14, "placeholder": "Ex.: 14"},
			"success_effects": {"culture": 1.5}, "failure_effects": {"culture": -0.5},
			"explanation": "Em um quadrado, lado × lado = área. A raiz quadrada de 196 é 14, então cada lado mede 14 m."
		},
		"conta_luz_reuniao": {
			"title": "Conta de Luz em Reunião",
			"description": "A conta de energia de um prédio municipal tem taxa fixa de R$ 100 mais R$ 5 por unidade consumida. Se a conta foi de R$ 400, quantas unidades foram consumidas?",
			"category": CATEGORY_IMPORTANT,
			"interaction_type": INTERACTION_NUMBER_INPUT,
			"availability_duration_days": PROBLEM_AVAILABILITY_DAYS,
			"payload": {"prompt": "Digite a quantidade de unidades", "correct_value": 60, "placeholder": "Ex.: 60"},
			"success_effects": {"social": 1.5}, "failure_effects": {"social": -0.5},
			"explanation": "Retire a taxa fixa: R$ 400 − R$ 100 = R$ 300. Cada unidade custa R$ 5, então 300 ÷ 5 = 60 unidades."
		},
		"todo_mundo_no_busao": {
			"title": "Todo Mundo no Mesmo Busão",
			"description": "Uma evacuação precisa transportar 72 pessoas. Cada ônibus da frota comporta 18 passageiros. Quantos ônibus completos são necessários?",
			"category": CATEGORY_URGENT,
			"interaction_type": INTERACTION_CHOICE,
			"availability_duration_days": null,
			"payload": {"options": [
				{"id": "a", "text": "3 ônibus"}, {"id": "b", "text": "4 ônibus"},
				{"id": "c", "text": "5 ônibus"}, {"id": "d", "text": "6 ônibus"}
			]},
			"correct_answer": "b",
			"success_effects": {"social": 2.0}, "failure_effects": {"social": -1.0},
			"explanation": "72 ÷ 18 = 4 ônibus, sem deixar passageiros para trás."
		},
		"sirene_do_ou": {
			"title": "A Sirene do “OU”",
			"description": "A sirene municipal deve tocar se houver alerta de enchente OU alerta de ventos fortes. Hoje não há alerta de enchente, mas há alerta de ventos fortes. A sirene deve tocar?",
			"category": CATEGORY_URGENT,
			"interaction_type": INTERACTION_CHOICE,
			"availability_duration_days": null,
			"payload": {"options": [{"id": "sim", "text": "Sim"}, {"id": "nao", "text": "Não"}]},
			"correct_answer": "sim",
			"success_effects": {"security": 2.0}, "failure_effects": {"security": -1.0},
			"explanation": "No OU lógico, basta uma das condições ser verdadeira. O alerta de ventos fortes já ativa a sirene."
		},
		"rota_do_resgate": {
			"title": "A Rota do Resgate",
			"description": "Uma equipe de resgate compara dois caminhos até o bairro isolado. A Rota A leva 8 + 7 minutos; a Rota B leva 6 + 4 minutos. Quantos minutos a Rota B economiza?",
			"category": CATEGORY_URGENT,
			"interaction_type": INTERACTION_NUMBER_INPUT,
			"availability_duration_days": null,
			"payload": {"prompt": "Digite os minutos economizados", "correct_value": 5, "placeholder": "Ex.: 5"},
			"success_effects": {"health": 2.0}, "failure_effects": {"health": -1.0},
			"explanation": "A Rota A leva 15 minutos e a Rota B leva 10. A economia é 15 − 10 = 5 minutos."
		},
		"reserva_que_encolheu": {
			"title": "A Reserva que Encolheu",
			"description": "A defesa civil tinha 2.400 litros de água. Durante uma emergência, distribuiu 650 litros a um bairro e 750 a outro. Quantos litros restaram?",
			"category": CATEGORY_URGENT,
			"interaction_type": INTERACTION_NUMBER_INPUT,
			"availability_duration_days": null,
			"payload": {"prompt": "Digite o volume restante em litros", "correct_value": 1000, "placeholder": "Ex.: 1000"},
			"success_effects": {"water": 2.0}, "failure_effects": {"water": -1.0},
			"explanation": "Foram distribuídos 650 + 750 = 1.400 litros. Restaram 2.400 − 1.400 = 1.000 litros."
		},
		"merenda_emergencia": {
			"title": "Merenda em Dia de Emergência",
			"image": "res://assets/problems/merenda_escolar.png",
			"description": "Um abrigo municipal precisa servir uma refeição a 80 pessoas. A equipe deve preparar 25% a mais para cobrir imprevistos. Quantas refeições devem ser preparadas?",
			"category": CATEGORY_URGENT,
			"interaction_type": INTERACTION_NUMBER_INPUT,
			"availability_duration_days": null,
			"payload": {"prompt": "Digite a quantidade de refeições", "correct_value": 100, "placeholder": "Ex.: 100"},
			"success_effects": {"education": 1.5, "social": 1.0}, "failure_effects": {"education": -1.0, "social": -0.5},
			"explanation": "25% de 80 são 20 refeições extras. A equipe deve preparar 80 + 20 = 100 refeições."
		}
	}

	for event_id in problems:
		_default_event_ids[String(event_id)] = true
		register_event(String(event_id), problems[event_id])

func has_event(event_id: String) -> bool:
	return events.has(event_id)

func get_event(event_id: String) -> Dictionary:
	if not events.has(event_id):
		return {}
	return events[event_id].duplicate(true)

func remove_event(event_id: String) -> void:
	events.erase(event_id)
	_default_event_ids.erase(event_id)
	_procedural_event_ids.erase(event_id)

	for category in _used_ids_by_category.keys():
		_used_ids_by_category[category].erase(event_id)

func mark_event_used(event_id: String) -> void:
	if not events.has(event_id):
		return
	var category := String(events[event_id].get("category", CATEGORY_COMMON))
	var used_ids: Array = _used_ids_by_category.get(category, [])
	if not used_ids.has(event_id):
		used_ids.append(event_id)
		_used_ids_by_category[category] = used_ids

func clear_all() -> void:
	events.clear()
	_default_event_ids.clear()
	_procedural_event_ids.clear()

	for category in _used_ids_by_category.keys():
		_used_ids_by_category[category].clear()

func get_all_event_ids() -> Array[String]:
	var result: Array[String] = []

	for id in events.keys():
		result.append(String(id))

	return result

func get_events_by_category(category: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []

	for event_data in events.values():
		if String(event_data.get("category", "")) == category:
			result.append(event_data.duplicate(true))

	return result

func get_events_by_interaction_type(interaction_type: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []

	for event_data in events.values():
		if String(event_data.get("interaction_type", "")) == interaction_type:
			result.append(event_data.duplicate(true))

	return result

func get_random_event_id_by_category(category: String) -> String:
	var candidates: Array[String] = []

	for event_id in events.keys():
		var event_data: Dictionary = events[event_id]
		if String(event_data.get("category", "")) == category:
			candidates.append(String(event_id))

	if candidates.is_empty():
		return ""

	var used_ids: Array = _used_ids_by_category.get(category, [])
	var available: Array[String] = []

	for candidate in candidates:
		if not used_ids.has(candidate):
			available.append(candidate)

	if available.is_empty():
		return ""

	var chosen_id := available[_rng.randi_range(0, available.size() - 1)]
	used_ids.append(chosen_id)
	_used_ids_by_category[category] = used_ids

	return chosen_id

func reset_category_usage(category: String) -> void:
	if _used_ids_by_category.has(category):
		_used_ids_by_category[category].clear()

func reset_all_category_usage() -> void:
	for category in _used_ids_by_category.keys():
		_used_ids_by_category[category].clear()

func get_usage_save_data() -> Dictionary:
	var custom_definitions: Dictionary = {}
	for event_id in events.keys():
		var id := String(event_id)
		if _default_event_ids.has(id) or _procedural_event_ids.has(id) or id.begins_with("municipal_"):
			continue
		custom_definitions[id] = events[event_id].duplicate(true)
	var result := {"used_ids_by_category": _used_ids_by_category.duplicate(true)}
	if not custom_definitions.is_empty():
		result["definitions"] = custom_definitions
	return result

func ensure_months_through(month: int, year: int) -> void:
	if year < 1 or month < 1:
		return
	var target_index := (year - 1) * 12 + month
	for idx in range(1, target_index + 1):
		var y := floori(float(idx - 1) / 12.0) + 1
		var m := ((idx - 1) % 12) + 1
		ensure_month_content(m, y)

func _ensure_procedural_event_if_needed(event_id: String) -> void:
	if not event_id.begins_with("municipal_") or events.has(event_id):
		return
	var parts := event_id.split("_")
	if parts.size() != 3 or not parts[1].is_valid_int() or not parts[2].is_valid_int():
		return
	var idx := int(parts[1])
	if idx < 1:
		return
	var y := floori(float(idx - 1) / 12.0) + 1
	var m := ((idx - 1) % 12) + 1
	ensure_month_content(m, y)

func load_usage_save_data(data: Dictionary) -> void:
	var definitions: Variant = data.get("definitions", {})
	if definitions is Dictionary:
		for event_id in definitions:
			var id := String(event_id)
			if _default_event_ids.has(id) or id.begins_with("municipal_"):
				continue
			if definitions[event_id] is Dictionary:
				register_event(id, definitions[event_id])
	var saved_usage: Variant = data.get("used_ids_by_category", {})
	if not saved_usage is Dictionary:
		return
	for category in _used_ids_by_category.keys():
		var saved_ids: Variant = saved_usage.get(category, [])
		if saved_ids is Array:
			var validated_ids: Array[String] = []
			for event_id in saved_ids:
				var id := String(event_id)
				_ensure_procedural_event_if_needed(id)
				if events.has(id) and String(events[id].get("category", "")) == category and not validated_ids.has(id):
					validated_ids.append(id)
			_used_ids_by_category[category] = validated_ids

func ensure_month_content(month: int, year: int) -> void:
	var index := (year - 1) * 12 + month
	var categories := [CATEGORY_OPTIONAL, CATEGORY_COMMON, CATEGORY_IMPORTANT, CATEGORY_COMMON, CATEGORY_IMPORTANT, CATEGORY_OPTIONAL, CATEGORY_URGENT, CATEGORY_COMMON]
	for i in range(categories.size()):
		var event_id := "municipal_%d_%d" % [index, i]
		if has_event(event_id):
			continue
		var n := 4 + (index * 7 + i * 3) % 15
		var definition := {"category": categories[i], "interaction_type": INTERACTION_NUMBER_INPUT, "availability_duration_days": 28, "allow_board": true, "payload": {}}
		match i:
			0:
				definition.title = "Pesquisa de aprovação"
				definition.description_pattern = "Em uma amostra de 200 moradores, %d aprovam a gestão. Qual é a aprovação em porcentagem?"
				definition.description_values = [(n * 10)]
				definition.description = definition.description_pattern % definition.description_values
				definition.payload = {"correct_value": n * 5, "placeholder": "Percentual, sem o símbolo %"}
				definition.explanation = "Divida os moradores que aprovam por 200 e multiplique por 100."
			1:
				definition.title = "Planejamento de obra"
				definition.construction_days_saved = 5
				definition.description_pattern = "Uma obra custa R$ 5.000 fixos e R$ 200 por metro. O orçamento é R$ %d. Quantos metros podem ser construídos? Resolva 5000 + 200x = orçamento. Bônus: acertar reduz em 5 dias o prazo das obras em andamento."
				definition.description_values = [(5000 + n * 200)]
				definition.description = definition.description_pattern % definition.description_values
				definition.payload = {"correct_value": n}
				definition.explanation = "Subtraia R$ 5.000 do orçamento e divida o restante por R$ 200. Uma resposta correta reduz em 5 dias as obras em andamento."
			2:
				definition.title = "Área da nova praça"
				definition.description_pattern = "Uma praça quadrada terá área de %d m². Resolva x² = %d: qual é o lado positivo, em metros?"
				definition.description_values = [n * n, n * n]
				definition.description = definition.description_pattern % definition.description_values
				definition.payload = {"correct_value": n}
				definition.explanation = "O lado é a raiz quadrada positiva da área."
			3:
				definition.title = "Orçamento e juros simples"
				definition.description_pattern = "Uma reserva de R$ 10.000 rende juros simples de 1%% por mês durante %d meses. Qual é o montante final, em reais?"
				definition.description_values = [n]
				definition.description = definition.description_pattern % definition.description_values
				definition.payload = {"correct_value": 10000 + n * 100}
				definition.explanation = "Use M = C × (1 + i × t), com C = 10000 e i = 0,01."
			4:
				var a_is_shorter := (index % 2) == 1
				var pa := n if a_is_shorter else n + 6
				var pb := n + 2 if a_is_shorter else n
				var total_a := pa + 4
				var total_b := pb + 7
				var opt_a := {"id": "a", "text": "P → A → H · %d km · R$ %d · %d min" % [total_a, total_a * 2, total_a * 2]}
				var opt_b := {"id": "b", "text": "P → B → H · %d km · R$ %d · %d min" % [total_b, total_b * 2, total_b * 2]}
				var swap_options := floori(float(index - 1) / 2.0) % 2 == 1
				var shorter_branch := "A" if a_is_shorter else "B"
				var diff_km := absi(total_b - total_a)
				definition.title = "Rotas de abastecimento"
				definition.description_pattern = "Escolha a rota de menor distância entre a prefeitura P e o hospital H. Trechos: P–A = %d km; A–H = 4 km; P–B = %d km; B–H = 7 km. O veículo anda a 30 km/h e gasta R$ 2 por km."
				definition.description_values = [pa, pb]
				definition.description = definition.description_pattern % definition.description_values
				definition.interaction_type = INTERACTION_CHOICE
				definition.payload = {"options": [opt_b, opt_a] if swap_options else [opt_a, opt_b]}
				definition.correct_answer = "a" if a_is_shorter else "b"
				definition.explanation_pattern = "Some as distâncias de cada caminho. A rota por %s é %d km menor; a 30 km/h cada quilômetro leva 2 minutos."
				definition.explanation_values = [shorter_branch, diff_km]
				definition.explanation = definition.explanation_pattern % definition.explanation_values
				definition.graph = {"a": pa, "b": pb}
			5:
				definition.title = "Média de atendimentos"
				definition.description_pattern = "Uma unidade atendeu %d, %d e %d pessoas em três dias. Qual é a média diária?"
				definition.description_values = [n * 10, n * 10 + 10, n * 10 + 20]
				definition.description = definition.description_pattern % definition.description_values
				definition.payload = {"correct_value": n * 10 + 10}
				definition.explanation = "Some os três valores e divida por três."
			6:
				definition.title = "Plano de emergência"
				definition.description_pattern = "O plano é aprovado quando P e Q são verdadeiros. P: há pelo menos 20 leitos. Q: o custo não supera R$ 50.000. A proposta tem %d leitos e custa R$ 45.000. P ∧ Q é verdadeiro?"
				definition.description_values = [(n + 10)]
				definition.description = definition.description_pattern % definition.description_values
				definition.interaction_type = INTERACTION_CHOICE
				definition.payload = {"options": [{"id": "sim", "text": "Sim"}, {"id": "nao", "text": "Não"}]}
				definition.correct_answer = "sim" if n >= 10 else "nao"
				definition.explanation = "A conjunção só é verdadeira quando as duas condições são satisfeitas. O custo atende Q; compare os leitos com o mínimo de 20."
				definition.availability_duration_days = null
			7:
				definition.title = "Distribuição de recursos"
				definition.description_pattern = "Um orçamento de R$ %d será dividido igualmente entre 4 bairros. Quanto cada bairro receberá?"
				definition.description_values = [(n * 4000)]
				definition.description = definition.description_pattern % definition.description_values
				definition.payload = {"correct_value": n * 1000}
				definition.explanation = "Divida o orçamento total por quatro."
		var area: String = ["social", "education", "culture", "water", "health", "education", "health", "social"][i]
		definition.success_effects = {area: 2.0}
		definition.failure_effects = {area: -1.0}
		definition.expiration_effects = {} if String(categories[i]) == CATEGORY_OPTIONAL else {area: -1.0}
		_procedural_event_ids[event_id] = true
		register_event(event_id, definition)


func build_runtime_event(event_id: String, start_day: int, start_month: int, start_year: int, days_per_month: int = 30, months_per_year: int = 12) -> Dictionary:
	var base_event := get_event(event_id)
	if base_event.is_empty():
		return {}

	var duration = base_event.get("availability_duration_days", null)
	var expires_on = null

	if duration != null:
		expires_on = _add_days_to_date(start_day, start_month, start_year, int(duration), days_per_month, months_per_year)

	return {
		"event_id": event_id,
		"title": String(base_event.get("title", event_id)),
		"category": base_event.get("category", CATEGORY_COMMON),
		"interaction_type": base_event.get("interaction_type", INTERACTION_CHOICE),
		"status": "pending",
		"available_from": {
			"day": start_day,
			"month": start_month,
			"year": start_year
		},
		"availability_duration_days": duration,
		"expires_on": expires_on
	}

func _add_days_to_date(day: int, month: int, year: int, days_to_add: int, days_per_month: int, months_per_year: int) -> Dictionary:
	var safe_days_per_month := maxi(1, days_per_month)
	var safe_months_per_year := maxi(1, months_per_year)
	var days_per_year := safe_days_per_month * safe_months_per_year
	var absolute_day := (year - 1) * days_per_year + (month - 1) * safe_days_per_month + (day - 1) + days_to_add
	var result_year := floori(float(absolute_day) / float(days_per_year)) + 1
	var day_of_year := absolute_day % days_per_year
	var result_month := floori(float(day_of_year) / float(safe_days_per_month)) + 1
	var result_day := day_of_year % safe_days_per_month + 1
	return {"day": result_day, "month": result_month, "year": result_year}

func validate_event_structure(event_data: Dictionary) -> bool:
	if not event_data.has("id"):
		return false

	if not event_data.has("category"):
		return false

	if not event_data.has("interaction_type"):
		return false

	if not event_data.has("payload") or not (event_data["payload"] is Dictionary):
		return false

	if not _is_valid_category(String(event_data["category"])):
		return false

	var interaction_type := String(event_data["interaction_type"])

	match interaction_type:
		INTERACTION_CHOICE:
			return _validate_choice_payload(event_data["payload"])
		INTERACTION_NUMBER_INPUT:
			return _validate_number_input_payload(event_data["payload"])
		INTERACTION_TEXT_INPUT:
			return _validate_text_input_payload(event_data["payload"])
		_:
			return false

func _is_valid_category(category: String) -> bool:
	return category == CATEGORY_OPTIONAL \
		or category == CATEGORY_COMMON \
		or category == CATEGORY_IMPORTANT \
		or category == CATEGORY_URGENT

func _validate_choice_payload(payload: Dictionary) -> bool:
	if not payload.has("options"):
		return false

	var options = payload["options"]
	return options is Array and options.size() > 0

func _validate_number_input_payload(payload: Dictionary) -> bool:
	if payload.has("prompt") and not (payload["prompt"] is String):
		return false

	if not payload.has("correct_value"):
		return false

	var correct_value: Variant = payload["correct_value"]
	return (correct_value is int or correct_value is float) and is_finite(float(correct_value))

func _validate_text_input_payload(payload: Dictionary) -> bool:
	if payload.has("prompt") and not (payload["prompt"] is String):
		return false

	if not payload.has("accepted_answers"):
		return false

	var accepted_answers: Variant = payload["accepted_answers"]
	return accepted_answers is Array and accepted_answers.size() > 0

func get_save_data() -> Dictionary:
	return {
		"events": events,
		"used_ids_by_category": _used_ids_by_category
	}

func load_save_data(data: Dictionary) -> void:
	events = data.get("events", {})
	_used_ids_by_category = data.get("used_ids_by_category", {
		CATEGORY_OPTIONAL: [],
		CATEGORY_COMMON: [],
		CATEGORY_IMPORTANT: [],
		CATEGORY_URGENT: []
	})
