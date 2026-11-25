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
var _variant_seed: int = 0
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

func _make_seeded_rng(salt: int) -> RandomNumberGenerator:
	var seeded := RandomNumberGenerator.new()
	seeded.seed = hash(Vector2i(_variant_seed, salt))
	return seeded

func _fmt_int(value: int) -> String:
	var neg := value < 0
	var digits := str(absi(value))
	var out := ""
	var count := 0
	for i in range(digits.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			out = "." + out
		out = digits[i] + out
		count += 1
	return ("-" + out) if neg else out

func _build_shuffled_options(rng: RandomNumberGenerator, correct_text: String, distractors: Array[String]) -> Dictionary:
	var seen := {correct_text: true}
	var entries: Array[Dictionary] = [{"text": correct_text, "correct": true}]
	for text in distractors:
		if not seen.has(text):
			seen[text] = true
			entries.append({"text": text, "correct": false})
	for i in range(entries.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp := entries[i]
		entries[i] = entries[j]
		entries[j] = tmp
	var ids := ["a", "b", "c", "d"]
	var options: Array = []
	var correct_id := "a"
	for i in range(mini(entries.size(), ids.size())):
		var opt_id: String = ids[i]
		options.append({"id": opt_id, "text": String(entries[i]["text"])})
		if bool(entries[i]["correct"]):
			correct_id = opt_id
	return {"options": options, "correct_answer": correct_id}

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

func register_default_problems(seed_override: int = -1) -> void:
	if seed_override >= 0:
		_variant_seed = seed_override
	else:
		_variant_seed = _rng.randi()
	var prng := _make_seeded_rng(101)

	# 1. aura_travessia (OPTIONAL — varies distance/rest/signal, sim or nao)
	var aura_cases := [
		{"street": 8, "every": 4, "rest": 3, "signal": 15},
		{"street": 8, "every": 4, "rest": 3, "signal": 13},
		{"street": 10, "every": 5, "rest": 4, "signal": 18},
		{"street": 12, "every": 4, "rest": 3, "signal": 19},
	]
	var aura: Dictionary = aura_cases[prng.randi_range(0, aura_cases.size() - 1)]
	var aura_rests := int((int(aura.street) - 1) / int(aura.every))
	var aura_total := int(aura.street) + aura_rests * int(aura.rest) + 3
	var aura_ok := aura_total <= int(aura.signal)

	# 2. merenda_escolar (URGENT — multi-step linear + percentage margin)
	var mer_fixed: int = [400, 500, 600, 750][prng.randi_range(0, 3)]
	var mer_price: int = [10, 12, 14, 15][prng.randi_range(0, 3)]
	var mer_pair: Array = [[80, 25], [100, 20], [120, 25], [60, 25], [150, 20]][prng.randi_range(0, 4)]
	var mer_students: int = mer_pair[0]
	var mer_margin: int = mer_pair[1]
	var mer_extra := int(mer_students * mer_margin / 100)
	var mer_total := mer_fixed + mer_price * (mer_students + mer_extra)

	# 3. transporte_proporcional (URGENT — 3-way proportional division, shuffled)
	var tp_sets := [
		{"f": [50, 30, 70], "k": 2},
		{"f": [50, 30, 70], "k": 3},
		{"f": [40, 60, 100], "k": 2},
		{"f": [40, 60, 100], "k": 3},
		{"f": [30, 45, 75], "k": 4},
	]
	var tp: Dictionary = tp_sets[prng.randi_range(0, tp_sets.size() - 1)]
	var tpf: Array = tp.f
	var tpk: int = tp.k
	var tp_sum: int = int(tpf[0]) + int(tpf[1]) + int(tpf[2])
	var tp_budget := tp_sum * tpk
	var tp_a: int = int(tpf[0]) * tpk
	var tp_b: int = int(tpf[1]) * tpk
	var tp_c: int = int(tpf[2]) * tpk
	var tp_choice := _build_shuffled_options(
		prng,
		"R$ %d mil, R$ %d mil e R$ %d mil" % [tp_a, tp_b, tp_c],
		[
			"R$ %d mil, R$ %d mil e R$ %d mil" % [tp_a, tp_b + 20, tp_c - 20],
			"R$ %d mil, R$ %d mil e R$ %d mil" % [int(tpf[0]), int(tpf[1]), int(tpf[2])],
			"R$ %d mil, R$ %d mil e R$ %d mil" % [tp_b, tp_a, tp_c],
		]
	)

	# 4. juros_bancos (URGENT — simple vs compound interest, either bank can win!)
	var jb_cases := [
		{"months": 24, "years": 2, "simple": 25, "comp": 20, "s_res": "1,50", "c_res": "1,44", "winner": "nuhbanho"},
		{"months": 24, "years": 2, "simple": 20, "comp": 20, "s_res": "1,40", "c_res": "1,44", "winner": "grotesco"},
		{"months": 36, "years": 3, "simple": 25, "comp": 20, "s_res": "1,75", "c_res": "1,728", "winner": "nuhbanho"},
		{"months": 36, "years": 3, "simple": 15, "comp": 15, "s_res": "1,45", "c_res": "1,521", "winner": "grotesco"},
		{"months": 24, "years": 2, "simple": 15, "comp": 10, "s_res": "1,30", "c_res": "1,21", "winner": "nuhbanho"},
		{"months": 36, "years": 3, "simple": 20, "comp": 20, "s_res": "1,60", "c_res": "1,728", "winner": "grotesco"},
	]
	var jb: Dictionary = jb_cases[prng.randi_range(0, jb_cases.size() - 1)]
	var jb_opts := [{"id": "grotesco", "text": "Banco Grotesco"}, {"id": "nuhbanho", "text": "NuhBanho"}]
	if prng.randi_range(0, 1) == 1:
		jb_opts.reverse()

	# 5. rota_medicamentos (IMPORTANT — strategic tradeoff, both routes valid)
	var rm_cases := [
		{"da": 120, "ca": 600, "ta": "2h30", "db": 90, "cb": 800, "tb": "2h"},
		{"da": 150, "ca": 550, "ta": "3h", "db": 90, "cb": 750, "tb": "2h"},
		{"da": 120, "ca": 500, "ta": "2h30", "db": 60, "cb": 750, "tb": "1h30"},
	]
	var rm: Dictionary = rm_cases[prng.randi_range(0, rm_cases.size() - 1)]

	# 6. moradias_enchente (URGENT — A, B, or C can be the cheapest!)
	var me_surv: int = [120, 180, 240][prng.randi_range(0, 2)]
	var me_cases := [
		{"pa": 6000, "pb": 10200, "pc": 18000, "winner": "a"},
		{"pa": 8000, "pb": 9600, "pc": 17500, "winner": "b"},
		{"pa": 8000, "pb": 10500, "pc": 15000, "winner": "c"},
	]
	var me: Dictionary = me_cases[prng.randi_range(0, me_cases.size() - 1)]
	var me_ua := int(me_surv / 4)
	var me_ub := int(me_surv / 6)
	var me_uc := int(me_surv / 10)
	var me_ta := me_ua * int(me.pa)
	var me_tb := me_ub * int(me.pb)
	var me_tc := me_uc * int(me.pc)

	# 7. verba_imss (URGENT — percentage growth + budget cap + P ∧ Q, sim or nao!)
	var imss_cases := [
		{"old": 6400, "new": 6976, "pct": 9, "curr": "1,36", "curr_i": 1360000, "next_i": 1482400, "bud": "17,8", "cap_i": 1780000, "ok": true},
		{"old": 5000, "new": 5300, "pct": 6, "curr": "1,20", "curr_i": 1200000, "next_i": 1272000, "bud": "16,0", "cap_i": 1600000, "ok": false},
		{"old": 8000, "new": 8800, "pct": 10, "curr": "1,70", "curr_i": 1700000, "next_i": 1870000, "bud": "18,0", "cap_i": 1800000, "ok": false},
		{"old": 5000, "new": 5500, "pct": 10, "curr": "1,40", "curr_i": 1400000, "next_i": 1540000, "bud": "16,0", "cap_i": 1600000, "ok": true},
	]
	var imss: Dictionary = imss_cases[prng.randi_range(0, imss_cases.size() - 1)]
	var imss_exp := "O número de elegíveis cresceu (%s − %s) ÷ %s = %d%%. A nova verba fica em R$ %s, frente ao limite de 10%% (R$ %s). %s" % [
		_fmt_int(int(imss.new)), _fmt_int(int(imss.old)), _fmt_int(int(imss.old)), int(imss.pct),
		_fmt_int(int(imss.next_i)), _fmt_int(int(imss.cap_i)),
		"As duas condições são atendidas." if bool(imss.ok) else "Pelo menos uma das condições não é atendida."
	]

	# 8. rota_presidio (URGENT — multi-constraint graph, sim or nao!)
	var rp_cases := [
		{"max_min": 30, "max_cost": 25, "ok": true, "exp": "O caminho H-B-E-R leva 22 minutos, percorre 9 km e paga R$ 4 de pedágio. O combustível custa 9 × R$ 2 = R$ 18; o total é R$ 22, dentro dos dois limites."},
		{"max_min": 25, "max_cost": 24, "ok": true, "exp": "O caminho H-B-E-R leva 22 minutos e custa R$ 22 (9 km × R$ 2 + R$ 4 de pedágio), atendendo aos limites de 25 min e R$ 24."},
		{"max_min": 20, "max_cost": 25, "ok": false, "exp": "O único caminho em até 20 minutos é H-A-C-F-R (20 min), mas ele custa R$ 37. O mais barato (H-B-E-R, R$ 22) leva 22 minutos. Nenhum atende às duas restrições."},
		{"max_min": 30, "max_cost": 20, "ok": false, "exp": "O caminho mais barato possível é H-B-E-R, que custa R$ 22 (9 km × R$ 2 + R$ 4 de pedágio), acima do limite de R$ 20."},
	]
	var rp: Dictionary = rp_cases[prng.randi_range(0, rp_cases.size() - 1)]

	# 9. pesquisa_satisfacao (OPTIONAL — varied percentages, shuffled)
	var ps_cases := [
		{"tot": 1200, "ap": 45, "dp": 35},
		{"tot": 1000, "ap": 40, "dp": 35},
		{"tot": 800, "ap": 55, "dp": 25},
		{"tot": 1500, "ap": 50, "dp": 30},
	]
	var ps: Dictionary = ps_cases[prng.randi_range(0, ps_cases.size() - 1)]
	var ps_a := int(int(ps.tot) * int(ps.ap) / 100)
	var ps_d := int(int(ps.tot) * int(ps.dp) / 100)
	var ps_n := int(ps.tot) - ps_a - ps_d
	var ps_np := 100 - int(ps.ap) - int(ps.dp)
	var ps_choice := _build_shuffled_options(
		prng,
		"%d%% e %d%%" % [int(ps.ap), int(ps.dp)],
		[
			"%d%% e %d%%" % [int(ps.dp), int(ps.ap)],
			"%d%% e %d%%" % [ps_np, int(ps.ap)],
			"%d%% e %d%%" % [ps_np, int(ps.dp)],
		]
	)

	# 10. obras_combinacoes (IMPORTANT — combinatorics C(n, k), shuffled)
	var oc_cases := [
		{"n": 5, "k": 2, "ans": 10, "d": ["5", "20", "25"]},
		{"n": 6, "k": 2, "ans": 15, "d": ["12", "30", "36"]},
		{"n": 7, "k": 2, "ans": 21, "d": ["14", "42", "49"]},
		{"n": 6, "k": 3, "ans": 20, "d": ["18", "60", "120"]},
	]
	var oc: Dictionary = oc_cases[prng.randi_range(0, oc_cases.size() - 1)]
	var oc_d: Array[String] = []
	for item in oc.d:
		oc_d.append(String(item))
	var oc_choice := _build_shuffled_options(prng, str(int(oc.ans)), oc_d)

	var problems := {
		"aura_travessia": {
			"title": "Ajude AURA na travessia VENIDA",
			"image": "res://assets/problems/aura.png",
			"description": "Uma senhora precisa atravessar uma rua de %d metros. Ela anda a 1 metro por segundo e descansa por %d segundos a cada %d metros completos (antes do fim). O sinal fica aberto por %d segundos; ela leva 2 segundos para interpretar a luz e mais 1 para começar a andar. Ela consegue atravessar?" % [int(aura.street), int(aura.rest), int(aura.every), int(aura.signal)],
			"category": CATEGORY_OPTIONAL,
			"interaction_type": INTERACTION_CHOICE,
			"availability_duration_days": PROBLEM_AVAILABILITY_DAYS,
			"payload": {"options": [
				{"id": "sim", "text": "Sim"},
				{"id": "nao", "text": "Não"}
			]},
			"correct_answer": "sim" if aura_ok else "nao",
			"success_effects": {"social": 2.0},
			"failure_effects": {"social": -1.0},
			"expiration_effects": {},
			"explanation": "Ela gasta %d segundos andando, %d descansando (%d pausa(s)) e 3 para reagir ao sinal: %d segundos no total, %s que os %d disponíveis." % [int(aura.street), aura_rests * int(aura.rest), aura_rests, aura_total, "dentro" if aura_ok else "acima", int(aura.signal)]
		},
		"merenda_escolar": {
			"title": "Comer comer para poder crescer",
			"image": "res://assets/problems/merenda_escolar.png",
			"description": "A prefeitura paga R$ %d de transporte fixo e R$ %d por refeição. A escola tem %d alunos e deve incluir uma margem de %d%% para quem repete a refeição. Qual verba é necessária?" % [mer_fixed, mer_price, mer_students, mer_margin],
			"category": CATEGORY_URGENT,
			"interaction_type": INTERACTION_NUMBER_INPUT,
			"availability_duration_days": null,
			"payload": {"prompt": "Digite o valor em reais, sem símbolos", "correct_value": mer_total, "placeholder": "Digite o valor em reais (sem símbolos)"},
			"success_effects": {"education": 2.0},
			"failure_effects": {"education": -1.0},
			"expiration_effects": {"education": -1.0},
			"explanation": "%d%% de %d são %d refeições extras. Então, %d + %d × (%d + %d) = R$ %s." % [mer_margin, mer_students, mer_extra, mer_fixed, mer_price, mer_students, mer_extra, _fmt_int(mer_total)]
		},
		"transporte_proporcional": {
			"title": "ABUStecimento & ProporcionaCIDADE",
			"image": "res://assets/problems/onibus.png",
			"description": "Uma verba de R$ %d mil será distribuída proporcionalmente entre bairros com %d, %d e %d famílias. Quanto cada bairro deve receber, respectivamente?" % [tp_budget, int(tpf[0]), int(tpf[1]), int(tpf[2])],
			"category": CATEGORY_URGENT,
			"interaction_type": INTERACTION_CHOICE,
			"availability_duration_days": null,
			"payload": {"options": tp_choice.options},
			"correct_answer": tp_choice.correct_answer,
			"success_effects": {"social": 2.0},
			"failure_effects": {"social": -1.0},
			"expiration_effects": {"social": -1.0},
			"explanation": "São %d famílias ao todo. Cada família corresponde a R$ %d mil, resultando em R$ %d mil, R$ %d mil e R$ %d mil." % [tp_sum, tpk, tp_a, tp_b, tp_c]
		},
		"juros_bancos": {
			"title": "Juros pelo meu milhão",
			"image": "res://assets/problems/bancos.png",
			"description": "Um empréstimo de R$ 1 milhão será quitado em %d meses (%d anos). O Banco Grotesco cobra juros simples de %d%% ao ano; o NuhBanho cobra juros compostos de %d%% ao ano. Use juros simples = capital × (1 + taxa × anos) e juros compostos = capital × (1 + taxa)^anos. Qual banco custa menos ao final?" % [int(jb.months), int(jb.years), int(jb.simple), int(jb.comp)],
			"category": CATEGORY_URGENT,
			"interaction_type": INTERACTION_CHOICE,
			"availability_duration_days": null,
			"payload": {"options": jb_opts},
			"correct_answer": String(jb.winner),
			"success_effects": {"water": 2.0},
			"failure_effects": {"water": -1.0},
			"expiration_effects": {"water": -1.0},
			"explanation": "Em %d anos, o Grotesco cobra R$ %s milhão (juros simples de %d%% a.a.) e o NuhBanho cobra R$ %s milhão (juros compostos de %d%% a.a.)." % [int(jb.years), String(jb.s_res), int(jb.simple), String(jb.c_res), int(jb.comp)]
		},
		"rota_medicamentos": {
			"title": "MedicaMOVImentos",
			"image": "res://assets/problems/remedios.png",
			"description": "A Rota A tem %d km, média de 60 km/h e custo de R$ %d. A Rota B tem %d km, média de 60 km/h e custo de R$ %d. Some 30 minutos para carga e descarga. Escolha uma rota e compare tempo e custo." % [int(rm.da), int(rm.ca), int(rm.db), int(rm.cb)],
			"category": CATEGORY_IMPORTANT,
			"interaction_type": INTERACTION_CHOICE,
			"availability_duration_days": PROBLEM_AVAILABILITY_DAYS,
			"payload": {"options": [
				{"id": "rota_a", "text": "Rota A: %s, R$ %d (mais barata)" % [String(rm.ta), int(rm.ca)]},
				{"id": "rota_b", "text": "Rota B: %s, R$ %d (mais rápida)" % [String(rm.tb), int(rm.cb)]}
			]},
			"accepted_answers": ["rota_a", "rota_b"],
			"success_effects": {},
			"failure_effects": {"health": -1.0},
			"expiration_effects": {"health": -1.0},
			"explanation": "A Rota A leva %s e custa menos (R$ %d). A Rota B leva %s e custa mais (R$ %d). A escolha depende de priorizar economia ou rapidez." % [String(rm.ta), int(rm.ca), String(rm.tb), int(rm.cb)]
		},
		"moradias_enchente": {
			"title": "Tsente: moradias após a enchente",
			"image": "res://assets/problems/tsente.png",
			"description": "Uma enchente deixou %d sobreviventes sem moradia. Qual modelo atende a todos pelo menor custo? A: 4 pessoas por R$ %s; B: 6 pessoas por R$ %s; C: 10 pessoas por R$ %s." % [me_surv, _fmt_int(int(me.pa)), _fmt_int(int(me.pb)), _fmt_int(int(me.pc))],
			"category": CATEGORY_URGENT,
			"interaction_type": INTERACTION_CHOICE,
			"availability_duration_days": null,
			"payload": {"options": [
				{"id": "a", "text": "Modelo A"},
				{"id": "b", "text": "Modelo B"},
				{"id": "c", "text": "Modelo C"}
			]},
			"correct_answer": String(me.winner),
			"success_effects": {"social": 2.0},
			"failure_effects": {"social": -1.0},
			"expiration_effects": {"social": -1.0},
			"explanation": "Para %d pessoas: %d unidades A (R$ %s), %d unidades B (R$ %s) ou %d unidades C (R$ %s). O Modelo %s tem o menor custo total." % [me_surv, me_ua, _fmt_int(me_ta), me_ub, _fmt_int(me_tb), me_uc, _fmt_int(me_tc), String(me.winner).to_upper()]
		},
		"verba_imss": {
			"title": "Verba IMSS",
			"image": "res://assets/problems/velhoimss.png",
			"description": "O número de pessoas elegíveis passou de %s para %s. A verba atual é R$ %s milhão e será reajustada pelo mesmo percentual desse crescimento. O reajuste só é aprovado se o crescimento for de pelo menos 8%% e a nova verba não passar de 10%% do orçamento municipal de R$ %s milhões. A verba poderá aumentar?" % [_fmt_int(int(imss.old)), _fmt_int(int(imss.new)), String(imss.curr), String(imss.bud)],
			"category": CATEGORY_URGENT,
			"interaction_type": INTERACTION_CHOICE,
			"availability_duration_days": null,
			"payload": {"options": [
				{"id": "sim", "text": "Sim"},
				{"id": "nao", "text": "Não"}
			]},
			"correct_answer": "sim" if bool(imss.ok) else "nao",
			"success_effects": {"social": 2.0},
			"failure_effects": {"social": -1.0},
			"expiration_effects": {"social": -1.0},
			"explanation": imss_exp
		},
		"rota_presidio": {
			"title": "Intriga do Carroeios",
			"description": "A polícia precisa transportar presos de H ao presídio R antes do fechamento, em até %d minutos. O custo total do trajeto (combustível a R$ 2 por quilômetro mais pedágios) não pode passar de R$ %d. Estradas (km, min, pedágio): H-A (4, 6, 0); H-B (2, 10, 2); A-C (5, 5, 1); A-D (3, 12, 0); B-C (6, 4, 3); B-E (4, 7, 1); C-F (2, 3, 2); D-F (7, 8, 0); E-R (3, 5, 1); F-R (5, 6, 2); D-R (9, 15, 0). Existe um caminho que atende às restrições?" % [int(rp.max_min), int(rp.max_cost)],
			"category": CATEGORY_URGENT,
			"interaction_type": INTERACTION_CHOICE,
			"availability_duration_days": null,
			"payload": {"options": [
				{"id": "sim", "text": "Sim"},
				{"id": "nao", "text": "Não"}
			]},
			"correct_answer": "sim" if bool(rp.ok) else "nao",
			"success_effects": {"security": 2.0},
			"failure_effects": {"security": -1.0},
			"expiration_effects": {"security": -1.0},
			"explanation": String(rp.exp),
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
			"image": "res://assets/problems/satisfacao.png",
			"description": "O instituto DataCidade entrevistou %s cidadãos: %s aprovam, %s desaprovam e %s são neutros. Qual é o percentual de aprovação e desaprovação, respectivamente?" % [_fmt_int(int(ps.tot)), _fmt_int(ps_a), _fmt_int(ps_d), _fmt_int(ps_n)],
			"category": CATEGORY_OPTIONAL,
			"interaction_type": INTERACTION_CHOICE,
			"availability_duration_days": PROBLEM_AVAILABILITY_DAYS,
			"payload": {"options": ps_choice.options},
			"correct_answer": ps_choice.correct_answer,
			"success_effects": {"culture": 2.0},
			"failure_effects": {"culture": -1.0},
			"expiration_effects": {},
			"explanation": "%s ÷ %s = %d%% de aprovação; %s ÷ %s = %d%% de desaprovação." % [_fmt_int(ps_a), _fmt_int(int(ps.tot)), int(ps.ap), _fmt_int(ps_d), _fmt_int(int(ps.tot)), int(ps.dp)]
		},
		"obras_combinacoes": {
			"title": "Obra-primarial",
			"image": "res://assets/problems/obra-primarial.png",
			"description": "A prefeitura tem %d obras prioritárias, mas o orçamento permite executar %d no mesmo período. A ordem não importa. Quantas combinações diferentes de obras existem?" % [int(oc.n), int(oc.k)],
			"category": CATEGORY_IMPORTANT,
			"interaction_type": INTERACTION_CHOICE,
			"availability_duration_days": PROBLEM_AVAILABILITY_DAYS,
			"payload": {"options": oc_choice.options},
			"correct_answer": oc_choice.correct_answer,
			"success_effects": {"water": 2.0},
			"failure_effects": {"water": -1.0},
			"expiration_effects": {"water": -1.0},
			"explanation": "A combinação C(%d, %d) resulta em %d combinações diferentes." % [int(oc.n), int(oc.k), int(oc.ans)]
		}
	}

	for event_id in problems:
		if event_id == "rota_medicamentos":
			problems[event_id]["choice_effects"] = {"rota_a": {"funds": -float(rm.ca), "health": 1.0}, "rota_b": {"funds": -float(rm.cb), "health": 2.0}}
		_default_event_ids[String(event_id)] = true
		register_event(String(event_id), problems[event_id])

	_register_suggested_problems(prng)

func _register_suggested_problems(prng: RandomNumberGenerator) -> void:
	# aprova_cidade (OPTIONAL — varied percentage, shuffled)
	var ac_cases := [[180, 240, 75], [120, 200, 60], [160, 200, 80], [140, 200, 70], [162, 180, 90]]
	var ac: Array = ac_cases[prng.randi_range(0, ac_cases.size() - 1)]
	var ac_choice := _build_shuffled_options(prng, "%d%%" % int(ac[2]), ["%d%%" % (int(ac[2]) - 15), "%d%%" % (int(ac[2]) - 5), "%d%%" % mini(95, int(ac[2]) + 10)])

	# media_dos_barulhinhos (COMMON — unsorted 3 measurements, shuffled)
	var mb_cases := [[18, 26, 22, 22], [34, 24, 28, 28], [42, 30, 36, 36], [19, 31, 25, 25]]
	var mb: Array = mb_cases[prng.randi_range(0, mb_cases.size() - 1)]
	var mb_sum := int(mb[0]) + int(mb[1]) + int(mb[2])
	var mb_choice := _build_shuffled_options(prng, "%d decibéis" % int(mb[3]), ["%d decibéis" % (int(mb[3]) - 2), "%d decibéis" % (int(mb[3]) + 2), "%d decibéis" % mb_sum])

	# praca_quadrada (OPTIONAL — varied rectangle perimeter, shuffled)
	var pq_cases := [[18, 12], [20, 15], [24, 16], [14, 11]]
	var pq: Array = pq_cases[prng.randi_range(0, pq_cases.size() - 1)]
	var pq_perim := 2 * (int(pq[0]) + int(pq[1]))
	var pq_area := int(pq[0]) * int(pq[1])
	var pq_choice := _build_shuffled_options(prng, "%d m" % pq_perim, ["%d m" % (int(pq[0]) + int(pq[1])), "%d m" % (pq_perim - 12), "%d m" % pq_area])

	# onibus_sem_lotacao (IMPORTANT — fencepost interval problem, shuffled)
	var osl_cases := [
		{"step": 15, "start": 6, "end": 8, "ans": 9},
		{"step": 20, "start": 6, "end": 8, "ans": 7},
		{"step": 12, "start": 7, "end": 9, "ans": 11},
		{"step": 15, "start": 7, "end": 10, "ans": 13},
	]
	var osl: Dictionary = osl_cases[prng.randi_range(0, osl_cases.size() - 1)]
	var osl_mins := (int(osl.end) - int(osl.start)) * 60
	var osl_choice := _build_shuffled_options(prng, "%d partidas" % int(osl.ans), ["%d partidas" % (int(osl.ans) - 1), "%d partidas" % (int(osl.ans) + 1), "%d partidas" % (int(osl.ans) + 3)])

	# apagao_avenida (URGENT — Offer A, Offer B, or tie can win!, shuffled)
	var aa_cases := [
		{"qty": 17, "unit": 120, "del": 300, "b": 2200},
		{"qty": 15, "unit": 110, "del": 250, "b": 2100},
		{"qty": 20, "unit": 90, "del": 400, "b": 2050},
		{"qty": 16, "unit": 100, "del": 200, "b": 1980},
		{"qty": 18, "unit": 100, "del": 400, "b": 2200},
	]
	var aa: Dictionary = aa_cases[prng.randi_range(0, aa_cases.size() - 1)]
	var aa_cost_a := int(aa.qty) * int(aa.unit) + int(aa.del)
	var aa_cost_b := int(aa.b)
	var aa_diff := absi(aa_cost_a - aa_cost_b)
	var aa_correct_text := ""
	var aa_distractors: Array[String] = []
	var aa_exp := ""
	if aa_cost_a < aa_cost_b:
		aa_correct_text = "Oferta A; economiza R$ %s" % _fmt_int(aa_diff)
		aa_distractors = ["Oferta B; economiza R$ %s" % _fmt_int(aa_diff), "Oferta A; economiza R$ %s" % _fmt_int(int(aa.del)), "As duas custam o mesmo"]
		aa_exp = "A oferta A custa %d × R$ %d + R$ %d = R$ %s. A oferta B custa R$ %s; a oferta A economiza R$ %s." % [int(aa.qty), int(aa.unit), int(aa.del), _fmt_int(aa_cost_a), _fmt_int(aa_cost_b), _fmt_int(aa_diff)]
	elif aa_cost_b < aa_cost_a:
		aa_correct_text = "Oferta B; economiza R$ %s" % _fmt_int(aa_diff)
		aa_distractors = ["Oferta A; economiza R$ %s" % _fmt_int(aa_diff), "Oferta A; economiza R$ %s" % _fmt_int(int(aa.del)), "As duas custam o mesmo"]
		aa_exp = "A oferta A custa %d × R$ %d + R$ %d = R$ %s. A oferta B custa R$ %s; a oferta B economiza R$ %s." % [int(aa.qty), int(aa.unit), int(aa.del), _fmt_int(aa_cost_a), _fmt_int(aa_cost_b), _fmt_int(aa_diff)]
	else:
		aa_correct_text = "As duas custam o mesmo"
		aa_distractors = ["Oferta A; economiza R$ %s" % _fmt_int(int(aa.del)), "Oferta B; economiza R$ %s" % _fmt_int(int(aa.del)), "Oferta B; economiza R$ 200"]
		aa_exp = "A oferta A custa %d × R$ %d + R$ %d = R$ %s, o mesmo valor da oferta B (R$ %s)." % [int(aa.qty), int(aa.unit), int(aa.del), _fmt_int(aa_cost_a), _fmt_int(aa_cost_b)]
	var aa_choice := _build_shuffled_options(prng, aa_correct_text, aa_distractors)

	# feira_de_quem_te_viu (COMMON — varied fraction, shuffled)
	var ff_cases := [
		{"tot": 40, "num": 3, "den": 5, "word": "Três quintos", "d": [8, 16, 32]},
		{"tot": 48, "num": 3, "den": 4, "word": "Três quartos", "d": [12, 24, 42]},
		{"tot": 60, "num": 2, "den": 5, "word": "Dois quintos", "d": [12, 36, 48]},
		{"tot": 36, "num": 5, "den": 6, "word": "Cinco sextos", "d": [6, 18, 24]},
	]
	var ff: Dictionary = ff_cases[prng.randi_range(0, ff_cases.size() - 1)]
	var ff_part := int(int(ff.tot) / int(ff.den))
	var ff_ans := ff_part * int(ff.num)
	var ff_d: Array[String] = []
	for dval in ff.d:
		ff_d.append("%d barracas" % int(dval))
	var ff_choice := _build_shuffled_options(prng, "%d barracas" % ff_ans, ff_d)

	# juros_sem_grasnar (COMMON — multi-expense remainder, shuffled)
	var jg_cases := [
		{"bud": 12000, "m": 3450, "l": 2750},
		{"bud": 15000, "m": 4200, "l": 3650},
		{"bud": 18000, "m": 5400, "l": 4850},
		{"bud": 10000, "m": 2850, "l": 1950},
	]
	var jg: Dictionary = jg_cases[prng.randi_range(0, jg_cases.size() - 1)]
	var jg_spent := int(jg.m) + int(jg.l)
	var jg_rem := int(jg.bud) - jg_spent
	var jg_choice := _build_shuffled_options(prng, "R$ %s" % _fmt_int(jg_rem), ["R$ %s" % _fmt_int(jg_spent), "R$ %s" % _fmt_int(jg_rem + 1000), "R$ %s" % _fmt_int(int(jg.bud) - int(jg.l))])

	# atalho_turistico (COMMON — map scale, shuffled)
	var at_cases := [[200, 4], [250, 5], [150, 6], [300, 4]]
	var at: Array = at_cases[prng.randi_range(0, at_cases.size() - 1)]
	var at_ans := int(at[0]) * int(at[1])
	var at_choice := _build_shuffled_options(prng, "%s m" % _fmt_int(at_ans), ["%s m" % _fmt_int(int(at_ans / 2)), "%s m" % _fmt_int(at_ans + int(at[0]) * 2), "%s m" % _fmt_int(at_ans * 2)])

	# asfalto_cada_metro (IMPORTANT — 3-step paving cost, number_input, no spoiler)
	var asf_cases := [[8, 25, 40, 1000], [6, 30, 50, 1200], [10, 20, 45, 1500], [5, 40, 35, 800]]
	var asf: Array = asf_cases[prng.randi_range(0, asf_cases.size() - 1)]
	var asf_len := int(asf[0]) * int(asf[1])
	var asf_total := asf_len * int(asf[2]) + int(asf[3])

	# lixeira_atacado (COMMON — multiplication, number_input, no spoiler)
	var lix_cases := [[50, 80], [40, 75], [60, 70], [45, 80]]
	var lix: Array = lix_cases[prng.randi_range(0, lix_cases.size() - 1)]
	var lix_ans := int(lix[0]) * int(lix[1])

	# abrigo_do_e (IMPORTANT — arithmetic progression Nth term, shuffled)
	var ab_cases := [
		{"first": 12, "diff": 4, "nth": 5, "ord": "quinto"},
		{"first": 10, "diff": 6, "nth": 5, "ord": "quinto"},
		{"first": 14, "diff": 5, "nth": 6, "ord": "sexto"},
		{"first": 8, "diff": 7, "nth": 5, "ord": "quinto"},
	]
	var ab: Dictionary = ab_cases[prng.randi_range(0, ab_cases.size() - 1)]
	var ab_second := int(ab.first) + int(ab.diff)
	var ab_ans := int(ab.first) + (int(ab.nth) - 1) * int(ab.diff)
	var ab_choice := _build_shuffled_options(prng, "%d colchões" % ab_ans, ["%d colchões" % (ab_ans - int(ab.diff)), "%d colchões" % (ab_ans + int(ab.diff)), "%d colchões" % (ab_ans + 2 * int(ab.diff))])

	# agua_todo_mundo (OPTIONAL — demoted from IMPORTANT, number_input, no spoiler)
	var ag_m3_tenths: int = [25, 32, 45, 18, 36][prng.randi_range(0, 4)]
	var ag_liters := ag_m3_tenths * 100
	var ag_str := "%d,%d" % [int(ag_m3_tenths / 10), ag_m3_tenths % 10]

	# rota_do_remedio (OPTIONAL — demoted from IMPORTANT, number_input, no spoiler)
	var rr_cases := [[48, 6], [72, 8], [63, 7], [84, 6], [56, 8]]
	var rr: Array = rr_cases[prng.randi_range(0, rr_cases.size() - 1)]
	var rr_ans := int(int(rr[0]) / int(rr[1]))

	# raiz_da_praca (COMMON — demoted from IMPORTANT, number_input, no spoiler)
	var rp2_cases := [[18, 12], [22, 15], [25, 14], [20, 16]]
	var rp2: Array = rp2_cases[prng.randi_range(0, rp2_cases.size() - 1)]
	var rp2_ans := int(rp2[0]) * int(rp2[1])

	# conta_luz_reuniao (COMMON — number_input, no spoiler)
	var cl_cases := [[590, 650], [430, 515], [720, 845], [680, 770]]
	var cl: Array = cl_cases[prng.randi_range(0, cl_cases.size() - 1)]
	var cl_ans := int(cl[1]) - int(cl[0])

	# todo_mundo_no_busao (COMMON — demoted from URGENT, shuffled)
	var tm_cases := [[5, 4, 24], [6, 4, 30], [4, 5, 27], [7, 3, 29]]
	var tm: Array = tm_cases[prng.randi_range(0, tm_cases.size() - 1)]
	var tm_have := int(tm[0]) * int(tm[1])
	var tm_miss := int(tm[2]) - tm_have
	var tm_choice := _build_shuffled_options(prng, "%d agentes" % tm_miss, ["%d agentes" % maxi(1, tm_miss - 2), "%d agentes" % (tm_miss + 2), "%d agentes" % tm_have])

	# sirene_do_ou (OPTIONAL — demoted from URGENT, sim OR nao!)
	var sr_cases := [
		{"flood": false, "wind": true, "ok": true, "desc": "Hoje não há alerta de enchente, mas há alerta de ventos fortes."},
		{"flood": true, "wind": false, "ok": true, "desc": "Hoje há alerta de enchente, mas não há alerta de ventos fortes."},
		{"flood": true, "wind": true, "ok": true, "desc": "Hoje há alerta de enchente e também alerta de ventos fortes."},
		{"flood": false, "wind": false, "ok": false, "desc": "Hoje não há alerta de enchente nem alerta de ventos fortes."},
		{"flood": false, "wind": false, "ok": false, "desc": "Hoje os dois sensores estão normais: não há alerta de enchente nem de ventos fortes."},
	]
	var sr: Dictionary = sr_cases[prng.randi_range(0, sr_cases.size() - 1)]

	# rota_do_resgate (COMMON — demoted from URGENT, number_input, no spoiler)
	var res_cases := [
		{"s": "9h35", "e": "11h10", "min": 95},
		{"s": "8h40", "e": "10h05", "min": 85},
		{"s": "14h20", "e": "16h05", "min": 105},
		{"s": "7h50", "e": "9h05", "min": 75},
		{"s": "13h45", "e": "15h25", "min": 100},
	]
	var res: Dictionary = res_cases[prng.randi_range(0, res_cases.size() - 1)]

	# reserva_que_encolheu (IMPORTANT — inflow OR outflow, number_input, no spoiler)
	var rv_cases := [
		{"init": 1000, "rate": 160, "hours": 5, "add": true},
		{"init": 1200, "rate": 140, "hours": 6, "add": true},
		{"init": 2500, "rate": 180, "hours": 5, "add": false},
		{"init": 3000, "rate": 220, "hours": 4, "add": false},
	]
	var rv: Dictionary = rv_cases[prng.randi_range(0, rv_cases.size() - 1)]
	var rv_delta := int(rv.rate) * int(rv.hours)
	var rv_final := int(rv.init) + rv_delta if bool(rv.add) else int(rv.init) - rv_delta

	# merenda_emergencia (COMMON — demoted from URGENT, number_input, no spoiler)
	var me2_cases := [[5, 24, 8], [6, 30, 9], [4, 36, 6], [7, 24, 12]]
	var me2: Array = me2_cases[prng.randi_range(0, me2_cases.size() - 1)]
	var me2_total := int(me2[0]) * int(me2[1])
	var me2_boxes := int(me2_total / int(me2[2]))

	var problems := {
		"aprova_cidade": {
			"title": "AprovaCIDADE",
			"image": "res://assets/problems/aprova_cidade.jpg",
			"description": "Em uma consulta sobre a reforma da praça, %d dos %d moradores ouvidos aprovaram o projeto. Qual foi o percentual de aprovação?" % [int(ac[0]), int(ac[1])],
			"category": CATEGORY_OPTIONAL,
			"interaction_type": INTERACTION_CHOICE,
			"availability_duration_days": PROBLEM_AVAILABILITY_DAYS,
			"payload": {"options": ac_choice.options},
			"correct_answer": ac_choice.correct_answer,
			"success_effects": {"social": 2.0}, "failure_effects": {"social": -1.0},
			"explanation": "%d ÷ %d = %.2f. Multiplicando por 100, a aprovação foi de %d%%." % [int(ac[0]), int(ac[1]), float(ac[0]) / float(ac[1]), int(ac[2])]
		},
		"media_dos_barulhinhos": {
			"title": "Barulhômetro: Mediana no Volume Máximo",
			"image": "res://assets/problems/barulhometro.jpg",
			"description": "A fiscalização anotou %d, %d e %d decibéis perto de uma escola. Qual é a mediana dessas três medições?" % [int(mb[0]), int(mb[1]), int(mb[2])],
			"category": CATEGORY_COMMON,
			"interaction_type": INTERACTION_CHOICE,
			"availability_duration_days": PROBLEM_AVAILABILITY_DAYS,
			"payload": {"options": mb_choice.options},
			"correct_answer": mb_choice.correct_answer,
			"success_effects": {"health": 1.0}, "failure_effects": {"health": -0.5},
			"explanation": "Ordenando os três valores, o número central (mediana) é %d decibéis." % int(mb[3])
		},
		"praca_quadrada": {
			"title": "Praça, que Perímetro!",
			"image": "res://assets/problems/praca_perimetro.jpg",
			"description": "Uma praça retangular mede %d metros por %d metros. Quantos metros de grade são necessários para cercar todo o contorno?" % [int(pq[0]), int(pq[1])],
			"category": CATEGORY_OPTIONAL,
			"interaction_type": INTERACTION_CHOICE,
			"availability_duration_days": PROBLEM_AVAILABILITY_DAYS,
			"payload": {"options": pq_choice.options},
			"correct_answer": pq_choice.correct_answer,
			"success_effects": {"culture": 1.0}, "failure_effects": {"culture": -0.5},
			"explanation": "O contorno tem dois lados de cada medida: 2 × (%d + %d) = %d metros." % [int(pq[0]), int(pq[1]), pq_perim]
		},
		"onibus_sem_lotacao": {
			"title": "Ônibus no Ponto, Horário na Conta",
			"image": "res://assets/problems/onibus_horario.jpg",
			"description": "Uma linha municipal sai do terminal a cada %d minutos, das %dh às %dh, incluindo a saída exatamente às %dh. Quantas partidas estão previstas nesse período?" % [int(osl.step), int(osl.start), int(osl.end), int(osl.end)],
			"category": CATEGORY_IMPORTANT,
			"interaction_type": INTERACTION_CHOICE,
			"availability_duration_days": PROBLEM_AVAILABILITY_DAYS,
			"payload": {"options": osl_choice.options},
			"correct_answer": osl_choice.correct_answer,
			"success_effects": {"education": 2.0}, "failure_effects": {"education": -1.0},
			"explanation": "De %dh até %dh há %d minutos (%d intervalos de %d min). Contando a partida inicial das %dh, são %d partidas." % [int(osl.start), int(osl.end), osl_mins, int(osl.ans) - 1, int(osl.step), int(osl.start), int(osl.ans)]
		},
		"apagao_avenida": {
			"title": "IluminaCIDADE: Apagão de Descontos",
			"image": "res://assets/problems/iluminacidade.jpg",
			"description": "A prefeitura precisa de %d lâmpadas para a avenida. A oferta A cobra R$ %d por lâmpada mais R$ %d de entrega. A oferta B cobra R$ %s com entrega incluída. Qual oferta custa menos e qual é a economia?" % [int(aa.qty), int(aa.unit), int(aa.del), _fmt_int(aa_cost_b)],
			"category": CATEGORY_URGENT,
			"interaction_type": INTERACTION_CHOICE,
			"availability_duration_days": null,
			"payload": {"options": aa_choice.options},
			"correct_answer": aa_choice.correct_answer,
			"success_effects": {"security": 2.0}, "failure_effects": {"security": -1.0},
			"explanation": aa_exp
		},
		"feira_de_quem_te_viu": {
			"title": "Feira-ção de Fração",
			"image": "res://assets/problems/feira_fracao.jpg",
			"description": "A feira municipal tem %d barracas. %s delas vendem alimentos produzidos na própria cidade. Quantas barracas são de produtores locais?" % [int(ff.tot), String(ff.word)],
			"category": CATEGORY_COMMON,
			"interaction_type": INTERACTION_CHOICE,
			"availability_duration_days": PROBLEM_AVAILABILITY_DAYS,
			"payload": {"options": ff_choice.options},
			"correct_answer": ff_choice.correct_answer,
			"success_effects": {"culture": 1.5}, "failure_effects": {"culture": -0.5},
			"explanation": "%d ÷ %d = %d por parte. Multiplicando por %d, são %d barracas." % [int(ff.tot), int(ff.den), ff_part, int(ff.num), ff_ans]
		},
		"juros_sem_grasnar": {
			"title": "Banco Pato: o Cofre Não é Ninho",
			"image": "res://assets/problems/banco_pato.jpg",
			"description": "A prefeitura reservou R$ %s para manutenção. Já usou R$ %s em materiais e R$ %s em mão de obra. Quanto ainda resta nessa verba?" % [_fmt_int(int(jg.bud)), _fmt_int(int(jg.m)), _fmt_int(int(jg.l))],
			"category": CATEGORY_COMMON,
			"interaction_type": INTERACTION_CHOICE,
			"availability_duration_days": PROBLEM_AVAILABILITY_DAYS,
			"payload": {"options": jg_choice.options},
			"correct_answer": jg_choice.correct_answer,
			"success_effects": {"social": 1.5}, "failure_effects": {"social": -0.5},
			"explanation": "As despesas somam R$ %s. Restam R$ %s − R$ %s = R$ %s." % [_fmt_int(jg_spent), _fmt_int(int(jg.bud)), _fmt_int(jg_spent), _fmt_int(jg_rem)]
		},
		"atalho_turistico": {
			"title": "Mapa, Mapa Meu: Qual é o Caminho?",
			"image": "res://assets/problems/mapa_cidade.jpg",
			"description": "No mapa da cidade, 1 cm representa %d metros. A distância entre o depósito municipal e uma praça mede %d cm no mapa. Qual é a distância real?" % [int(at[0]), int(at[1])],
			"category": CATEGORY_COMMON,
			"interaction_type": INTERACTION_CHOICE,
			"availability_duration_days": PROBLEM_AVAILABILITY_DAYS,
			"payload": {"options": at_choice.options},
			"correct_answer": at_choice.correct_answer,
			"success_effects": {"health": 1.5}, "failure_effects": {"health": -0.5},
			"explanation": "Cada centímetro representa %d metros. Então, %d × %d = %s metros." % [int(at[0]), int(at[1]), int(at[0]), _fmt_int(at_ans)]
		},
		"asfalto_cada_metro": {
			"title": "Asfalto Quente, Conta Fria",
			"image": "res://assets/problems/asfalto.jpg",
			"description": "Uma rua será pavimentada em %d trechos de %d metros. O serviço custa R$ %d por metro, mais R$ %s pelo aluguel das máquinas. Qual é o custo total da obra?" % [int(asf[0]), int(asf[1]), int(asf[2]), _fmt_int(int(asf[3]))],
			"category": CATEGORY_IMPORTANT,
			"interaction_type": INTERACTION_NUMBER_INPUT,
			"availability_duration_days": PROBLEM_AVAILABILITY_DAYS,
			"payload": {"prompt": "Digite o total em reais, sem símbolos", "correct_value": asf_total, "placeholder": "Digite o valor total em reais"},
			"success_effects": {"water": 1.5}, "failure_effects": {"water": -0.5},
			"explanation": "A rua terá %d × %d = %d m. O pavimento custa %d × R$ %d = R$ %s; somando R$ %s das máquinas, o total é R$ %s." % [int(asf[0]), int(asf[1]), asf_len, asf_len, int(asf[2]), _fmt_int(asf_len * int(asf[2])), _fmt_int(int(asf[3])), _fmt_int(asf_total)]
		},
		"lixeira_atacado": {
			"title": "Lixômetro: Cabe Mais que Reclamação",
			"image": "res://assets/problems/lixometro.jpg",
			"description": "A cidade instalou %d lixeiras, cada uma com capacidade para %d litros. Qual é a capacidade total de armazenamento, em litros?" % [int(lix[0]), int(lix[1])],
			"category": CATEGORY_COMMON,
			"interaction_type": INTERACTION_NUMBER_INPUT,
			"availability_duration_days": PROBLEM_AVAILABILITY_DAYS,
			"payload": {"prompt": "Digite a capacidade total em litros", "correct_value": lix_ans, "placeholder": "Digite o total em litros"},
			"success_effects": {"social": 1.5}, "failure_effects": {"social": -0.5},
			"explanation": "Multiplique a quantidade de lixeiras pela capacidade de cada uma: %d × %d = %s litros." % [int(lix[0]), int(lix[1]), _fmt_int(lix_ans)]
		},
		"abrigo_do_e": {
			"title": "Abrigo em Progressão: Colchão que Cresce",
			"image": "res://assets/problems/abrigo_progressao.jpg",
			"description": "Para montar abrigos, a prefeitura separou %d colchões para o primeiro, %d para o segundo e segue aumentando a quantidade em %d colchões por abrigo. Quantos colchões serão destinados ao %s abrigo?" % [int(ab.first), ab_second, int(ab.diff), String(ab.ord)],
			"category": CATEGORY_IMPORTANT,
			"interaction_type": INTERACTION_CHOICE,
			"availability_duration_days": PROBLEM_AVAILABILITY_DAYS,
			"payload": {"options": ab_choice.options},
			"correct_answer": ab_choice.correct_answer,
			"success_effects": {"health": 2.0}, "failure_effects": {"health": -1.0},
			"explanation": "Em uma PA com início %d e razão %d, o %s termo é %d + (%d − 1) × %d = %d colchões." % [int(ab.first), int(ab.diff), String(ab.ord), int(ab.first), int(ab.nth), int(ab.diff), ab_ans]
		},
		"agua_todo_mundo": {
			"title": "HidroMetragem: Água em Outra Medida",
			"image": "res://assets/problems/hidrometragem.jpg",
			"description": "Um reservatório municipal comporta %s metros cúbicos de água. Sabendo que 1 metro cúbico equivale a 1.000 litros, quantos litros cabem no reservatório?" % ag_str,
			"category": CATEGORY_OPTIONAL,
			"interaction_type": INTERACTION_NUMBER_INPUT,
			"availability_duration_days": PROBLEM_AVAILABILITY_DAYS,
			"payload": {"prompt": "Digite a capacidade em litros", "correct_value": ag_liters, "placeholder": "Digite a capacidade em litros"},
			"success_effects": {"water": 2.0}, "failure_effects": {"water": -1.0},
			"explanation": "Multiplique %s por 1.000: a capacidade é de %s litros." % [ag_str, _fmt_int(ag_liters)]
		},
		"rota_do_remedio": {
			"title": "Dose Certa: Sem Sobrar, Sem Faltar",
			"image": "res://assets/problems/dose_certa.jpg",
			"description": "A secretaria de saúde recebeu %d kits de primeiros socorros para distribuir igualmente entre %d unidades de saúde. Quantos kits cada unidade receberá?" % [int(rr[0]), int(rr[1])],
			"category": CATEGORY_OPTIONAL,
			"interaction_type": INTERACTION_NUMBER_INPUT,
			"availability_duration_days": PROBLEM_AVAILABILITY_DAYS,
			"payload": {"prompt": "Digite a quantidade de kits por unidade", "correct_value": rr_ans, "placeholder": "Digite a quantidade de kits"},
			"success_effects": {"health": 2.0}, "failure_effects": {"health": -1.0},
			"explanation": "Divida os %d kits igualmente entre as %d unidades: %d ÷ %d = %d kits para cada uma." % [int(rr[0]), int(rr[1]), int(rr[0]), int(rr[1]), rr_ans]
		},
		"raiz_da_praca": {
			"title": "QuadraFora: Área de Jogo",
			"image": "res://assets/problems/quadra_fora.jpg",
			"description": "Uma quadra retangular de um centro esportivo municipal mede %d metros de comprimento e %d metros de largura. Qual é a área total?" % [int(rp2[0]), int(rp2[1])],
			"category": CATEGORY_COMMON,
			"interaction_type": INTERACTION_NUMBER_INPUT,
			"availability_duration_days": PROBLEM_AVAILABILITY_DAYS,
			"payload": {"prompt": "Digite a área em metros quadrados", "correct_value": rp2_ans, "placeholder": "Digite a área em m²"},
			"success_effects": {"culture": 1.5}, "failure_effects": {"culture": -0.5},
			"explanation": "A área do retângulo é comprimento × largura: %d × %d = %d m²." % [int(rp2[0]), int(rp2[1]), rp2_ans]
		},
		"conta_luz_reuniao": {
			"title": "Luz, Câmera… Leitura!",
			"image": "res://assets/problems/leitura_luz.jpg",
			"description": "O medidor de energia de um posto municipal marcava %d kWh no mês passado e %d kWh neste mês. Quantos kWh foram consumidos no período?" % [int(cl[0]), int(cl[1])],
			"category": CATEGORY_COMMON,
			"interaction_type": INTERACTION_NUMBER_INPUT,
			"availability_duration_days": PROBLEM_AVAILABILITY_DAYS,
			"payload": {"prompt": "Digite o consumo em kWh", "correct_value": cl_ans, "placeholder": "Digite o consumo em kWh"},
			"success_effects": {"social": 1.5}, "failure_effects": {"social": -0.5},
			"explanation": "O consumo é a diferença entre as leituras: %d − %d = %d kWh." % [int(cl[1]), int(cl[0]), cl_ans]
		},
		"todo_mundo_no_busao": {
			"title": "Plantão Multiplicado, Problema Dividido",
			"image": "res://assets/problems/plantao.jpg",
			"description": "Na escala de plantão, a prefeitura convocou %d equipes com %d agentes cada. O plano precisa de %d agentes. Quantos agentes ainda faltam?" % [int(tm[0]), int(tm[1]), int(tm[2])],
			"category": CATEGORY_COMMON,
			"interaction_type": INTERACTION_CHOICE,
			"availability_duration_days": PROBLEM_AVAILABILITY_DAYS,
			"payload": {"options": tm_choice.options},
			"correct_answer": tm_choice.correct_answer,
			"success_effects": {"social": 2.0}, "failure_effects": {"social": -1.0},
			"explanation": "As equipes somam %d × %d = %d agentes. Para chegar a %d, faltam %d − %d = %d agentes." % [int(tm[0]), int(tm[1]), tm_have, int(tm[2]), int(tm[2]), tm_have, tm_miss]
		},
		"sirene_do_ou": {
			"title": "Sirene: OU Toca, OU Dá Ruim",
			"image": "res://assets/problems/sirene.jpg",
			"description": "A sirene municipal deve tocar se houver alerta de enchente OU alerta de ventos fortes. %s A sirene deve tocar?" % String(sr.desc),
			"category": CATEGORY_OPTIONAL,
			"interaction_type": INTERACTION_CHOICE,
			"availability_duration_days": PROBLEM_AVAILABILITY_DAYS,
			"payload": {"options": [{"id": "sim", "text": "Sim"}, {"id": "nao", "text": "Não"}]},
			"correct_answer": "sim" if bool(sr.ok) else "nao",
			"success_effects": {"security": 2.0}, "failure_effects": {"security": -1.0},
			"explanation": "No OU lógico, a sirene toca quando pelo menos um dos alertas está ativo — e fica desligada quando ambos são falsos."
		},
		"rota_do_resgate": {
			"title": "Relógio de Resgate: Contra o Tempo",
			"image": "res://assets/problems/relogio_resgate.jpg",
			"description": "Uma equipe saiu às %s para atender uma ocorrência e chegou às %s. Quanto tempo durou o deslocamento, em minutos?" % [String(res.s), String(res.e)],
			"category": CATEGORY_COMMON,
			"interaction_type": INTERACTION_NUMBER_INPUT,
			"availability_duration_days": PROBLEM_AVAILABILITY_DAYS,
			"payload": {"prompt": "Digite a duração total em minutos", "correct_value": int(res.min), "placeholder": "Digite o tempo em minutos"},
			"success_effects": {"health": 2.0}, "failure_effects": {"health": -1.0},
			"explanation": "Das %s até as %s passam exatamente %d minutos." % [String(res.s), String(res.e), int(res.min)]
		},
		"reserva_que_encolheu": {
			"title": "H2Oh Não! Cadê Minha Reserva?",
			"image": "res://assets/problems/reserva_h2oh.jpg",
			"description": "Um reservatório municipal contém %s litros. Uma bomba %s %d litros por hora durante %d horas. Quantos litros haverá no reservatório ao final?" % [_fmt_int(int(rv.init)), "adiciona" if bool(rv.add) else "retira", int(rv.rate), int(rv.hours)],
			"category": CATEGORY_IMPORTANT,
			"interaction_type": INTERACTION_NUMBER_INPUT,
			"availability_duration_days": PROBLEM_AVAILABILITY_DAYS,
			"payload": {"prompt": "Digite o volume final em litros", "correct_value": rv_final, "placeholder": "Digite o volume final em litros"},
			"success_effects": {"water": 2.0}, "failure_effects": {"water": -1.0},
			"explanation": "Em %d horas a bomba movimenta %d × %d = %s litros. Resultado: %s %s %s = %s litros." % [int(rv.hours), int(rv.rate), int(rv.hours), _fmt_int(rv_delta), _fmt_int(int(rv.init)), "+" if bool(rv.add) else "−", _fmt_int(rv_delta), _fmt_int(rv_final)]
		},
		"merenda_emergencia": {
			"title": "Merenda em Conta: Bandejão Multiplicador",
			"image": "res://assets/problems/merenda_conta.jpg",
			"description": "Para abastecer os abrigos, %d cozinhas comunitárias prepararam %d refeições cada. As refeições serão enviadas em caixas com %d unidades. Quantas caixas completas serão entregues?" % [int(me2[0]), int(me2[1]), int(me2[2])],
			"category": CATEGORY_COMMON,
			"interaction_type": INTERACTION_NUMBER_INPUT,
			"availability_duration_days": PROBLEM_AVAILABILITY_DAYS,
			"payload": {"prompt": "Digite a quantidade de caixas", "correct_value": me2_boxes, "placeholder": "Digite a quantidade de caixas"},
			"success_effects": {"education": 1.5, "social": 1.0}, "failure_effects": {"education": -1.0, "social": -0.5},
			"explanation": "As cozinhas prepararam %d × %d = %d refeições. Dividindo em caixas de %d: %d ÷ %d = %d caixas." % [int(me2[0]), int(me2[1]), me2_total, int(me2[2]), me2_total, int(me2[2]), me2_boxes]
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
	var authored_available: Array[String] = []

	for candidate in candidates:
		if not used_ids.has(candidate):
			available.append(candidate)
			if _default_event_ids.has(candidate):
				authored_available.append(candidate)

	if available.is_empty():
		return ""

	# Let every hand-written problem appear before the recurring monthly templates.
	var pool := authored_available if not authored_available.is_empty() else available
	var chosen_id := pool[_rng.randi_range(0, pool.size() - 1)]
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
	var result := {
		"used_ids_by_category": _used_ids_by_category.duplicate(true),
		"variant_seed": _variant_seed
	}
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
	if data.has("variant_seed"):
		var saved_seed := int(data["variant_seed"])
		if saved_seed != _variant_seed:
			for event_id in _procedural_event_ids.keys():
				events.erase(event_id)
			_procedural_event_ids.clear()
			register_default_problems(saved_seed)
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
		var mrng := _make_seeded_rng(index * 97 + i * 13 + 7)
		var definition := {"category": categories[i], "interaction_type": INTERACTION_NUMBER_INPUT, "availability_duration_days": 28, "allow_board": true, "payload": {}}
		match i:
			0:
				var sample: int = [200, 250, 400, 500][mrng.randi_range(0, 3)]
				var pct := mrng.randi_range(5, 18) * 5
				var approved := int(sample * pct / 100)
				definition.title = "Pesquisa de aprovação"
				definition.image = "res://assets/problems/satisfacao.png"
				definition.description_pattern = "Em uma amostra de %d moradores, %d aprovam a gestão. Qual é a aprovação em porcentagem?"
				definition.description_values = [sample, approved]
				definition.description = definition.description_pattern % definition.description_values
				definition.payload = {"correct_value": pct, "placeholder": "Digite o percentual, sem o símbolo %"}
				definition.explanation = "Divida os %d moradores que aprovam por %d e multiplique por 100: %d%%." % [approved, sample, pct]
			1:
				var fixed: int = [3000, 4000, 5000, 6000][mrng.randi_range(0, 3)]
				var rate: int = [150, 200, 250][mrng.randi_range(0, 2)]
				var meters := mrng.randi_range(6, 22)
				var budget := fixed + rate * meters
				definition.title = "Planejamento de obra"
				definition.image = "res://assets/problems/engenheiros.png"
				definition.construction_days_saved = 5
				definition.description_pattern = "Uma obra custa R$ %s fixos e R$ %d por metro. O orçamento é R$ %s. Quantos metros podem ser construídos? Bônus: acertar reduz em 5 dias o prazo das obras em andamento."
				definition.description_values = [_fmt_int(fixed), rate, _fmt_int(budget)]
				definition.description = definition.description_pattern % definition.description_values
				definition.payload = {"correct_value": meters, "placeholder": "Digite a quantidade em metros"}
				definition.explanation = "Subtraia R$ %s de R$ %s e divida por R$ %d: %d metros. Uma resposta correta reduz em 5 dias as obras em andamento." % [_fmt_int(fixed), _fmt_int(budget), rate, meters]
			2:
				var side := mrng.randi_range(5, 22)
				var area_val := side * side
				definition.title = "Área da nova praça"
				definition.image = "res://assets/problems/pracaarea.jpeg"
				definition.description_pattern = "Uma praça quadrada terá área de %d m². Resolva x² = %d: qual é o lado positivo, em metros?"
				definition.description_values = [area_val, area_val]
				definition.description = definition.description_pattern % definition.description_values
				definition.payload = {"correct_value": side, "placeholder": "Digite o lado em metros"}
				definition.explanation = "A raiz quadrada positiva de %d é %d metros." % [area_val, side]
			3:
				var principal: int = [8000, 10000, 12000, 15000][mrng.randi_range(0, 3)]
				var rate_pct: int = [1, 2][mrng.randi_range(0, 1)]
				var months := mrng.randi_range(3, 12)
				var final_amt := principal + int(principal * rate_pct * months / 100)
				definition.title = "Orçamento e juros simples"
				definition.image = "res://assets/problems/juros.jpeg"
				definition.description_pattern = "Uma reserva de R$ %s rende juros simples de %d%% por mês durante %d meses. Qual é o montante final, em reais?"
				definition.description_values = [_fmt_int(principal), rate_pct, months]
				definition.description = definition.description_pattern % definition.description_values
				definition.payload = {"correct_value": final_amt, "placeholder": "Digite o montante em reais (sem símbolos)"}
				definition.explanation = "Use M = C × (1 + i × t): %s × (1 + 0,0%d × %d) = R$ %s." % [_fmt_int(principal), rate_pct, months, _fmt_int(final_amt)]
			4:
				var a_is_shorter := mrng.randi_range(0, 1) == 0
				var base_n := mrng.randi_range(4, 16)
				var extra_gap := mrng.randi_range(1, 5)
				var pa := base_n if a_is_shorter else base_n + 3 + extra_gap
				var pb := base_n + extra_gap if a_is_shorter else base_n
				var total_a := pa + 4
				var total_b := pb + 7
				var opt_a := {"id": "a", "text": "P → A → H · %d km · R$ %d · %d min" % [total_a, total_a * 2, total_a * 2]}
				var opt_b := {"id": "b", "text": "P → B → H · %d km · R$ %d · %d min" % [total_b, total_b * 2, total_b * 2]}
				var swap_options := mrng.randi_range(0, 1) == 1
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
				var mean_val := mrng.randi_range(30, 140)
				var d1 := mrng.randi_range(6, 22)
				var d2 := mrng.randi_range(4, 18)
				if d1 == d2:
					d2 += 3
				var vals := [mean_val - d1, mean_val + d2, mean_val + d1 - d2]
				for k in range(vals.size() - 1, 0, -1):
					var j := mrng.randi_range(0, k)
					var tmp: int = vals[k]
					vals[k] = vals[j]
					vals[j] = tmp
				definition.title = "Média de atendimentos"
				definition.image = "res://assets/problems/atendimento.png"
				definition.description_pattern = "Uma unidade atendeu %d, %d e %d pessoas em três dias. Qual é a média diária?"
				definition.description_values = vals
				definition.description = definition.description_pattern % definition.description_values
				definition.payload = {"correct_value": mean_val, "placeholder": "Digite a média diária"}
				definition.explanation = "Some os três valores (%d + %d + %d = %d) e divida por 3: média de %d atendimentos por dia." % [vals[0], vals[1], vals[2], mean_val * 3, mean_val]
			6:
				# URGENT — both P (beds >= min_beds) and Q (beds * unit_cost <= max_budget) vary dynamically!
				var min_beds: int = [20, 22, 24][mrng.randi_range(0, 2)]
				var unit_cost: int = [2000, 2500][mrng.randi_range(0, 1)]
				var max_budget := (min_beds + 3) * unit_cost
				var mode := mrng.randi_range(0, 3) # 0,1 -> sim; 2 -> fails P; 3 -> fails Q
				var beds := min_beds + mrng.randi_range(0, 3)
				if mode == 2:
					beds = min_beds - mrng.randi_range(1, 4)
				elif mode == 3:
					beds = min_beds + mrng.randi_range(4, 7)
				var total_cost := beds * unit_cost
				var p_ok := beds >= min_beds
				var q_ok := total_cost <= max_budget
				var both_ok := p_ok and q_ok
				definition.title = "Plano de emergência"
				definition.image = "res://assets/problems/macahospitalar.png"
				definition.description_pattern = "O plano é aprovado quando P e Q são verdadeiros. P: há pelo menos %d leitos. Q: o custo total (R$ %s por leito) não supera R$ %s. A proposta tem %d leitos. P ∧ Q é verdadeiro?"
				definition.description_values = [min_beds, _fmt_int(unit_cost), _fmt_int(max_budget), beds]
				definition.description = definition.description_pattern % definition.description_values
				definition.interaction_type = INTERACTION_CHOICE
				definition.payload = {"options": [{"id": "sim", "text": "Sim"}, {"id": "nao", "text": "Não"}]}
				definition.correct_answer = "sim" if both_ok else "nao"
				definition.explanation = "Com %d leitos, o custo total é %d × R$ %s = R$ %s (limite: R$ %s; mínimo: %d leitos). %s" % [
					beds, beds, _fmt_int(unit_cost), _fmt_int(total_cost), _fmt_int(max_budget), min_beds,
					"P e Q são verdadeiros." if both_ok else "Pelo menos uma das condições (P ou Q) é falsa."
				]
				definition.availability_duration_days = null
			7:
				var hoods: int = [4, 5, 6, 8][mrng.randi_range(0, 3)]
				var per_hood := mrng.randi_range(3, 18) * 500
				var total_bud := hoods * per_hood
				definition.title = "Distribuição de recursos"
				definition.image = "res://assets/problems/dinheiro.png"
				definition.description_pattern = "Um orçamento de R$ %s será dividido igualmente entre %d bairros. Quanto cada bairro receberá?"
				definition.description_values = [_fmt_int(total_bud), hoods]
				definition.description = definition.description_pattern % definition.description_values
				definition.payload = {"correct_value": per_hood, "placeholder": "Digite o valor em reais (sem símbolos)"}
				definition.explanation = "Divida R$ %s igualmente entre %d bairros: R$ %s para cada um." % [_fmt_int(total_bud), hoods, _fmt_int(per_hood)]
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
