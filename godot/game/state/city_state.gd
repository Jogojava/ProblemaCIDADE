class_name CityState
extends RefCounted

signal changed()
signal building_completed(project: Dictionary)
signal campaign_event(kind: String)

const INITIAL_HOMES := 18
const RESIDENTS_PER_HOME := 150
const MONTHLY_POPULATION_GROWTH := 50
var residences: Array[Dictionary] = []
var town_hall := {"x": -1, "y": -1}
var layout_initialized := false
var grass_lots: Array[Dictionary] = []

var city_name := "Vila Esperança"
var difficulty := "medium"
var funds := GameRules.INITIAL_FUNDS
var reputation := 55.0
var population := GameRules.INITIAL_POPULATION
var indicators: Dictionary = {}
var projects: Array[Dictionary] = []
var buildings: Array[Dictionary] = []
var history: Array[Dictionary] = []
var ledger: Array[Dictionary] = []
var completed_months := 0
var crisis_months := 0
var term := 1
var outcome := "playing"
var solved_count := 0
var correct_count := 0
var expired_count := 0
var last_day := 0
var last_result: Dictionary = {}
var played_seconds := 0.0

func start(name_value: String, difficulty_value: String) -> void:
	population = GameRules.INITIAL_POPULATION
	residences.clear()
	layout_initialized = false
	grass_lots.clear()
	projects.clear()
	buildings.clear()
	history.clear()
	ledger.clear()
	completed_months = 0
	crisis_months = 0
	term = 1
	outcome = "playing"
	solved_count = 0
	correct_count = 0
	expired_count = 0
	last_day = 0
	last_result = {}
	played_seconds = 0.0
	city_name = name_value.strip_edges().left(36)
	if city_name.is_empty():
		city_name = "Vila Esperança"
	difficulty = difficulty_value if GameRules.DIFFICULTIES.has(difficulty_value) else "medium"
	funds = GameRules.INITIAL_FUNDS
	reputation = float(profile().approval)
	indicators = {"unemployment": 12.0, "hunger": 10.0}
	for area in GameRules.AREAS:
		indicators[area] = GameRules.INITIAL_SERVICE_LEVEL
	record_snapshot()

func profile() -> Dictionary:
	return GameRules.DIFFICULTIES.get(difficulty, GameRules.DIFFICULTIES.medium)

func change_reputation(amount: float) -> void:
	var factor: float = float(profile().gain) if amount >= 0.0 else float(profile().loss)
	reputation = clampf(reputation + amount * factor, 0.0, 100.0)

func invest(area: String, amount: float) -> String:
	if outcome != "playing" or not GameRules.AREAS.has(area):
		return "Investimento indisponível."
	if not is_finite(amount) or amount < GameRules.MIN_INVESTMENT or amount > funds:
		return "Escolha um valor entre R$ 5.000 e o saldo disponível."
	if float(indicators.get(area, 0)) >= 100.0:
		return "Esta área já atingiu 100 pontos."
	funds -= amount
	indicators[area] = minf(100.0, float(indicators[area]) + amount / GameRules.INVESTMENT_PER_POINT)
	change_reputation(minf(3.0, amount / 15000.0))
	add_ledger("Investimento", -amount)
	changed.emit()
	return ""

func construct(area: String, day_index: int, lot: Dictionary = {}) -> String:
	if (layout_initialized and lot.is_empty()) or (not lot.is_empty() and not can_build(lot)):
		return "Escolha um lote livre na grama."
	if outcome != "playing" or not GameRules.AREAS.has(area):
		return "Construção indisponível."
	if funds < GameRules.BUILDING_COST:
		return "Saldo insuficiente para a obra."
	if projects.size() >= 3:
		return "Conclua uma das três obras em andamento."
	if buildings.size() + projects.size() >= 30:
		return "A cidade já possui 30 instalações. Invista nos serviços existentes."
	for project in projects:
		if String(project.area) == area:
			return "Já existe uma obra em andamento nesta área."
	funds -= GameRules.BUILDING_COST
	projects.append({"area": area, "started": day_index, "due": day_index + GameRules.BUILDING_DAYS, "cost": GameRules.BUILDING_COST, "lot": lot.duplicate()})
	add_ledger("Construção", -GameRules.BUILDING_COST)
	changed.emit()
	return ""

func advance_day(day_index: int) -> void:
	last_day = day_index
	for project in projects.duplicate():
		if day_index >= int(project.due):
			projects.erase(project)
			buildings.append(project.duplicate(true))
			var area := String(project.area)
			indicators[area] = minf(100.0, float(indicators[area]) + 12.0)
			change_reputation(3.0)
			building_completed.emit(project)
	changed.emit()

func advance_month() -> void:
	if outcome != "playing":
		return
	completed_months += 1
	var revenue := float(population) * GameRules.REVENUE_PER_RESIDENT * float(profile().budget)
	var upkeep := GameRules.MONTHLY_BASE_UPKEEP + buildings.size() * GameRules.BUILDING_UPKEEP
	funds += revenue - upkeep
	add_ledger("Receita e despesas do mês", revenue - upkeep)
	for area in GameRules.AREAS:
		indicators[area] = clampf(float(indicators[area]) - GameRules.MONTHLY_SERVICE_DECAY, 0.0, 100.0)
	var service_mean := 0.0
	for area in GameRules.AREAS:
		service_mean += float(indicators[area]) / 6.0
	indicators.unemployment = clampf(18.0 - float(indicators.education) * 0.1 - buildings.size() * 0.1, 2.0, 35.0)
	indicators.hunger = clampf(20.0 - float(indicators.social) * 0.2, 0.0, 40.0)
	change_reputation((service_mean - 50.0) / 25.0 - (3.0 if funds < 0 else 0.0))
	if reputation < GameRules.IMPEACHMENT_APPROVAL:
		crisis_months += 1
	else:
		crisis_months = 0
	population += MONTHLY_POPULATION_GROWTH if service_mean >= 45.0 else 0
	record_snapshot()
	if crisis_months >= GameRules.CRISIS_MONTHS or reputation <= 0.0:
		outcome = "impeachment"
	elif completed_months >= GameRules.FINAL_MONTH:
		outcome = "completed"
	elif completed_months == GameRules.TERM_MONTHS:
		if reputation >= GameRules.REELECTION_APPROVAL:
			term = 2
			campaign_event.emit("reelected")
		else:
			outcome = "not_reelected"
	if outcome != "playing":
		campaign_event.emit(outcome)
	changed.emit()

func apply_problem(definition: Dictionary, correct: bool, expired: bool = false, answer: String = "") -> Dictionary:
	var category := String(definition.get("category", "common"))
	var weight: float = {"optional": 1.0, "common": 2.0, "important": 3.0, "urgent": 4.0}.get(category, 2.0)
	var rep_delta := weight * (GameRules.EVENT_REPUTATION if correct else -GameRules.EVENT_REPUTATION)
	if expired and category == "optional":
		rep_delta = 0.0
	var money_delta := weight * (GameRules.EVENT_REWARD_FUNDS if correct else -GameRules.EVENT_LOSS_FUNDS)
	if expired and category == "optional":
		money_delta = 0.0
	var choice: Dictionary = definition.get("choice_effects", {}).get(answer, {}) if not expired else {}
	money_delta += float(choice.get("funds", 0.0))
	funds += money_delta
	change_reputation(rep_delta)
	if expired:
		expired_count += 1
	else:
		solved_count += 1
		if correct:
			correct_count += 1
	var effects: Dictionary = definition.get("success_effects" if correct else ("expiration_effects" if expired else "failure_effects"), {})
	for key in effects:
		if indicators.has(key):
			indicators[key] = clampf(float(indicators[key]) + float(effects[key]), 0.0, 100.0)
	for key in choice:
		if indicators.has(key):
			indicators[key] = clampf(float(indicators[key]) + float(choice[key]), 0.0, 100.0)
	var days_saved := int(definition.get("construction_days_saved", 5 if String(definition.get("id", "")).contains("obra") else 0))
	if correct and days_saved > 0:
		for project in projects:
			project.due = maxi(last_day + 1, int(project.due) - days_saved)
	last_result = {"correct": correct, "expired": expired, "funds": money_delta, "reputation": rep_delta * float(profile().gain if rep_delta >= 0 else profile().loss), "title": definition.get("title", "Problema")}
	add_ledger("Problema resolvido" if not expired else "Problema expirado", money_delta)
	changed.emit()
	if outcome == "playing" and reputation <= 0.0:
		outcome = "impeachment"
		campaign_event.emit(outcome)
	return last_result.duplicate(true)

func add_ledger(label: String, value: float) -> void:
	ledger.append({"month": completed_months, "label": label, "value": value})
	if ledger.size() > 120:
		ledger.pop_front()

func record_snapshot() -> void:
	var item := {"month": completed_months, "funds": funds, "reputation": reputation}
	item.merge(indicators)
	history.append(item)

func projection(key: String) -> Dictionary:
	if history.size() < 12 or completed_months < 12:
		return {"ready": false, "samples": history.size()}
	var series: Array[float] = []
	for item in history.slice(-12):
		series.append(float(item.get(key, 0.0)))
	var mean := 0.0
	for value in series:
		mean += value / 12.0
	var slope := 0.0
	for i in range(12):
		slope += (float(i) - 5.5) * (series[i] - mean) / 143.0
	var forecast: Array[float] = []
	for i in range(6):
		var value := mean + slope * (12.0 + i - 5.5)
		forecast.append(value if key == "funds" else clampf(value, 0.0, 100.0))
	return {"ready": true, "history": series, "forecast": forecast, "slope": slope}

func get_save_data() -> Dictionary:
	return {"residences": residences.duplicate(true), "layout_initialized": layout_initialized, "city_name": city_name, "difficulty": difficulty, "funds": funds, "reputation": reputation, "population": population, "indicators": indicators.duplicate(true), "projects": projects.duplicate(true), "buildings": buildings.duplicate(true), "history": history.duplicate(true), "ledger": ledger.duplicate(true), "completed_months": completed_months, "crisis_months": crisis_months, "term": term, "outcome": outcome, "solved_count": solved_count, "correct_count": correct_count, "expired_count": expired_count, "last_day": last_day, "played_seconds": played_seconds}

func load_save_data(data: Dictionary) -> void:
	start(String(data.get("city_name", "Vila Esperança")), String(data.get("difficulty", "medium")))
	for key in ["funds", "reputation", "population", "completed_months", "crisis_months", "term", "outcome", "solved_count", "correct_count", "expired_count", "last_day", "played_seconds"]:
		if data.has(key):
			set(key, data[key])
	if data.get("indicators") is Dictionary:
		indicators.merge(data.indicators, true)
	layout_initialized = bool(data.get("layout_initialized", false))
	for key in ["residences", "projects", "buildings", "history", "ledger"]:
		var items: Array[Dictionary] = []
		for item in data.get(key, []):
			if item is Dictionary:
				items.append(item.duplicate(true))
		set(key, items)
	reputation = clampf(reputation, 0.0, 100.0)

# Spatial state belongs to the save; camera motion and rendering never reshuffle it.
func configure_lots(lots: Array[Dictionary]) -> void:
	grass_lots = lots
	if not layout_initialized:
		var available := lots.duplicate(true)
		available.shuffle()
		for lot in available:
			if residences.size() >= INITIAL_HOMES:
				break
			if absi(int(lot.x)) <= 5 and absi(int(lot.y)) <= 5 and lot != town_hall:
				residences.append({"lot": lot.duplicate(), "variant": randi_range(0, 3)})
		layout_initialized = true
	# Migrate old saves with installations that did not yet have coordinates.
	for collection in [buildings, projects]:
		for item in collection:
			if not item.has("lot") or item.lot.is_empty():
				for lot in lots:
					if can_build(lot):
						item.lot = lot.duplicate()
						break
	changed.emit()

func housing_requests() -> int:
	var extra := maxi(0, population - GameRules.INITIAL_POPULATION)
	return maxi(0, int(extra / RESIDENTS_PER_HOME) - maxi(0, residences.size() - INITIAL_HOMES))

func can_build(lot: Dictionary) -> bool:
	if not grass_lots.has(lot) or lot == town_hall:
		return false
	for collection in [residences, buildings, projects]:
		for item in collection:
			if item.get("lot", {}) == lot:
				return false
	return true

func place_home(lot: Dictionary) -> String:
	if outcome != "playing" or housing_requests() <= 0:
		return "Ainda não há demanda por novas moradias."
	if not can_build(lot):
		return "Escolha um lote livre na grama."
	residences.append({"lot": lot.duplicate(), "variant": randi_range(0, 3)})
	changed.emit()
	return ""
