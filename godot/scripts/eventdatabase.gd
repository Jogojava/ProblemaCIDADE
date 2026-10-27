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
			"explanation": "A viagem leva 22 minutos e paga R$ 4 de pedágio. O combustível custa R$ 18, totalizando R$ 22; as duas restrições são atendidas."
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
			"explanation": "A combinação é C(5, 2) = 5 × 4 ÷ 2 = 10."
		}
	}

	for event_id in problems:
		if event_id == "rota_medicamentos":
			problems[event_id]["choice_effects"] = {"rota_a": {"funds": -600.0, "health": 1.0}, "rota_b": {"funds": -800.0, "health": 2.0}}
		register_event(String(event_id), problems[event_id])

func has_event(event_id: String) -> bool:
	return events.has(event_id)

func get_event(event_id: String) -> Dictionary:
	if not events.has(event_id):
		return {}
	return events[event_id].duplicate(true)

func remove_event(event_id: String) -> void:
	events.erase(event_id)

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
	return {"used_ids_by_category": _used_ids_by_category.duplicate(true), "definitions": events.duplicate(true)}

func load_usage_save_data(data: Dictionary) -> void:
	var definitions: Variant = data.get("definitions", {})
	if definitions is Dictionary:
		for event_id in definitions:
			if definitions[event_id] is Dictionary:
				register_event(String(event_id), definitions[event_id])
	var saved_usage: Variant = data.get("used_ids_by_category", {})
	if not saved_usage is Dictionary:
		return
	for category in _used_ids_by_category.keys():
		var saved_ids: Variant = saved_usage.get(category, [])
		if saved_ids is Array:
			var validated_ids: Array[String] = []
			for event_id in saved_ids:
				var id := String(event_id)
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
				definition.description_pattern = "Uma obra custa R$ 5.000 fixos e R$ 200 por metro. O orçamento é R$ %d. Quantos metros podem ser construídos? Resolva 5000 + 200x = orçamento."
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
				definition.title = "Rotas de abastecimento"
				definition.description_pattern = "Escolha a rota de menor distância entre a prefeitura P e o hospital H. Trechos: P–A = %d km; A–H = 4 km; P–B = %d km; B–H = 7 km. O veículo anda a 30 km/h e gasta R$ 2 por km."
				definition.description_values = [n, n + 2]
				definition.description = definition.description_pattern % definition.description_values
				definition.interaction_type = INTERACTION_CHOICE
				definition.payload = {"options": [{"id": "a", "text": "P → A → H · %d km · R$ %d · %d min" % [n + 4, (n + 4) * 2, (n + 4) * 2]}, {"id": "b", "text": "P → B → H · %d km · R$ %d · %d min" % [n + 9, (n + 9) * 2, (n + 9) * 2]}]}
				definition.correct_answer = "a"
				definition.explanation = "Some as distâncias de cada caminho. A rota por A é 5 km menor; a 30 km/h cada quilômetro leva 2 minutos."
				definition.graph = {"a": n, "b": n + 2}
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

	if not event_data.has("payload"):
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
	if not payload.has("prompt"):
		return false

	if not payload.has("correct_value"):
		return false

	return true

func _validate_text_input_payload(payload: Dictionary) -> bool:
	if not payload.has("prompt"):
		return false

	if not payload.has("accepted_answers"):
		return false

	var accepted_answers = payload["accepted_answers"]
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
