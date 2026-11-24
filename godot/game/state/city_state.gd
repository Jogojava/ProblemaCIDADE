class_name CityState
extends RefCounted

signal changed()
signal building_completed(project: Dictionary)
signal campaign_event(kind: String)
signal housing_space_needed()

const INITIAL_HOMES := 100
const MIN_INITIAL_APARTMENTS := 40
const MAX_INITIAL_APARTMENTS := 60
const RESIDENTS_PER_APARTMENT := 160
const RESIDENTS_PER_HOME := 4
const MONTHLY_POPULATION_GROWTH := 16
const RESIDENTS_PER_SERVICE_POINT := 1.2
const RESIDENTS_PER_SERVICE_IMPROVEMENT := 8.0
const BUILDING_FOOTPRINT_SIZE := 2
var residences: Array[Dictionary] = []
var initial_apartment_count := 50
var apartment_growth_progress := 0
var town_hall := {"x": -1, "y": -1}
var layout_initialized := false
var grass_lots: Array[Dictionary] = []
var _grass_lot_keys: Dictionary = {}
var _occupied_lots: Dictionary = {}

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
var homes_built_this_month := 0
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
	initial_apartment_count = randi_range(MIN_INITIAL_APARTMENTS, MAX_INITIAL_APARTMENTS)
	apartment_growth_progress = 0
	residences.clear()
	layout_initialized = false
	grass_lots.clear()
	_grass_lot_keys.clear()
	_occupied_lots.clear()
	projects.clear()
	buildings.clear()
	history.clear()
	ledger.clear()
	completed_months = 0
	homes_built_this_month = 0
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
	change_reputation(minf(1.5, amount / 30000.0))
	add_ledger("Investimento", -amount)
	changed.emit()
	return ""

func construct(area: String, day_index: int, lot: Dictionary = {}) -> String:
	if (layout_initialized and lot.is_empty()) or (not lot.is_empty() and not can_build_footprint(lot)):
		return "Escolha quatro lotes livres e conectados na grama."
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
	_occupy_footprint(lot)
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
			change_reputation(2.5)
			building_completed.emit(project)
	changed.emit()

func advance_month() -> void:
	if outcome != "playing":
		return
	completed_months += 1
	homes_built_this_month = 0
	var revenue := float(population) * GameRules.REVENUE_PER_RESIDENT * float(profile().budget)
	var upkeep := GameRules.MONTHLY_BASE_UPKEEP + buildings.size() * GameRules.BUILDING_UPKEEP
	funds += revenue - upkeep
	add_ledger("Receita e despesas do mês", revenue - upkeep)
	for area in GameRules.AREAS:
		indicators[area] = clampf(float(indicators[area]) - GameRules.MONTHLY_SERVICE_DECAY, 0.0, 100.0)
	var service_mean := 0.0
	for area in GameRules.AREAS:
		service_mean += float(indicators[area]) / 6.0
	var previous_service_mean := _service_mean_from_snapshot(history.back()) if not history.is_empty() else service_mean
	indicators.unemployment = clampf(18.0 - float(indicators.education) * 0.1 - buildings.size() * 0.1, 2.0, 35.0)
	indicators.hunger = clampf(20.0 - float(indicators.social) * 0.2, 0.0, 40.0)
	var construction_ok := has_required_buildings()
	var rep_delta := (service_mean - 50.0) / 25.0 - (3.0 if funds < 0 else 0.0)
	if not construction_ok:
		rep_delta = minf(0.0, rep_delta) - (0.5 if buildings.is_empty() else 0.0)
	change_reputation(rep_delta)
	if reputation < GameRules.IMPEACHMENT_APPROVAL:
		crisis_months += 1
	else:
		crisis_months = 0
	# Population grows steadily according to service quality and improvements,
	# provided the city has built the required public infrastructure.
	if service_mean >= 45.0 and construction_ok:
		var service_improvement := maxf(0.0, service_mean - previous_service_mean)
		var service_quality_growth := floori((service_mean - 45.0) * RESIDENTS_PER_SERVICE_POINT)
		var monthly_growth := MONTHLY_POPULATION_GROWTH + service_quality_growth + floori(service_improvement * RESIDENTS_PER_SERVICE_IMPROVEMENT)
		population += monthly_growth
		apartment_growth_progress += monthly_growth
		while apartment_growth_progress >= RESIDENTS_PER_APARTMENT:
			apartment_growth_progress -= RESIDENTS_PER_APARTMENT
			population += RESIDENTS_PER_APARTMENT
		_spawn_growth_homes()
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
	var days_saved := int(definition.get("construction_days_saved", 0))
	var applied_days_saved := 0
	if correct and days_saved > 0 and not projects.is_empty():
		applied_days_saved = days_saved
		for project in projects:
			project.due = maxi(last_day + 1, int(project.due) - days_saved)
	last_result = {"correct": correct, "expired": expired, "funds": money_delta, "reputation": rep_delta * float(profile().gain if rep_delta >= 0 else profile().loss), "title": definition.get("title", "Problema")}
	if applied_days_saved > 0:
		last_result["construction_days_saved"] = applied_days_saved
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
	if history.size() < 6 or completed_months < 6:
		return {"ready": false, "samples": history.size()}
	var window_size := mini(12, history.size())
	var series: Array[float] = []
	for item in history.slice(-window_size):
		series.append(float(item.get(key, 0.0)))
	var n := series.size()
	var mean := 0.0
	for value in series:
		mean += value / float(n)
	var x_mean := float(n - 1) / 2.0
	var denom := 0.0
	var slope := 0.0
	for i in range(n):
		var dx := float(i) - x_mean
		denom += dx * dx
		slope += dx * (series[i] - mean)
	slope = slope / denom if denom > 0.0 else 0.0
	var forecast: Array[float] = []
	for i in range(6):
		var value := mean + slope * (float(n) + float(i) - x_mean)
		forecast.append(value if key == "funds" else clampf(value, 0.0, 100.0))
	return {"ready": true, "history": series, "forecast": forecast, "slope": slope}

func get_save_data() -> Dictionary:
	return {"housing_model_version": 3, "residences": residences.duplicate(true), "layout_initialized": layout_initialized, "apartment_growth_progress": apartment_growth_progress, "city_name": city_name, "difficulty": difficulty, "funds": funds, "reputation": reputation, "population": population, "indicators": indicators.duplicate(true), "projects": projects.duplicate(true), "buildings": buildings.duplicate(true), "history": history.duplicate(true), "ledger": ledger.duplicate(true), "completed_months": completed_months, "homes_built_this_month": homes_built_this_month, "crisis_months": crisis_months, "term": term, "outcome": outcome, "solved_count": solved_count, "correct_count": correct_count, "expired_count": expired_count, "last_day": last_day, "played_seconds": played_seconds}

func load_save_data(data: Dictionary) -> void:
	start(String(data.get("city_name", "Vila Esperança")), String(data.get("difficulty", "medium")))
	for key in ["funds", "reputation", "population", "completed_months", "homes_built_this_month", "apartment_growth_progress", "crisis_months", "term", "outcome", "solved_count", "correct_count", "expired_count", "last_day", "played_seconds"]:
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
	if int(data.get("housing_model_version", 0)) < 3:
		# Keep existing progress and locations, then fill the new 100-home start
		# when map lots are configured. The old population scale no longer fits.
		population = GameRules.INITIAL_POPULATION
		initial_apartment_count = randi_range(MIN_INITIAL_APARTMENTS, MAX_INITIAL_APARTMENTS)
		layout_initialized = false
	if ledger.size() > 120:
		ledger = ledger.slice(ledger.size() - 120)
	_rebuild_occupied_lots()
	reputation = clampf(reputation, 0.0, 100.0)

# Spatial state belongs to the save; camera motion and rendering never reshuffle it.
func configure_lots(lots: Array[Dictionary]) -> void:
	grass_lots = lots
	_grass_lot_keys.clear()
	for lot in lots:
		var key: Variant = _lot_key(lot)
		if key != null:
			_grass_lot_keys[key] = true
	_rebuild_occupied_lots()
	var hall_key: Variant = _lot_key(town_hall)
	if not layout_initialized:
		var apartments_placed := 0
		for residence in residences:
			if String(residence.get("area", "home")) == "apartment":
				apartments_placed += 1
		for lot in _ordered_footprint_candidates():
			if apartments_placed >= initial_apartment_count:
				break
			if can_build_footprint(lot):
				residences.append({"lot": lot.duplicate(), "area": "apartment", "residents": RESIDENTS_PER_APARTMENT})
				_occupy_footprint(lot)
				apartments_placed += 1
		for lot in _ordered_home_candidates():
			if homes_count() >= INITIAL_HOMES:
				break
			var lot_key: Variant = _lot_key(lot)
			if lot_key == null or lot_key == hall_key or _occupied_lots.has(lot_key):
				continue
			residences.append({"lot": lot.duplicate(), "area": "home", "variant": randi_range(0, 3)})
			_occupied_lots[lot_key] = true
		population = housing_capacity()
		layout_initialized = true
	# Migrate old saves with installations that did not yet have coordinates.
	for collection in [buildings, projects]:
		for item in collection:
			if not item.has("lot") or not (item.lot is Dictionary) or item.lot.is_empty():
				for lot in lots:
					if can_build_footprint(lot):
						item.lot = lot.duplicate()
						_occupy_footprint(item.lot)
						break
	changed.emit()

func housing_requests() -> int:
	var housing_capacity := housing_capacity()
	var deficit := maxi(0, population - housing_capacity)
	return floori(float(deficit) / float(RESIDENTS_PER_HOME))

func housing_capacity() -> int:
	var capacity := 0
	for residence in residences:
		capacity += int(residence.get("residents", RESIDENTS_PER_APARTMENT if String(residence.get("area", "home")) == "apartment" else RESIDENTS_PER_HOME))
	return capacity

func homes_count() -> int:
	var count := 0
	for residence in residences:
		if String(residence.get("area", "home")) != "apartment":
			count += 1
	return count

func apartments_count() -> int:
	var count := 0
	for residence in residences:
		if String(residence.get("area", "home")) == "apartment":
			count += 1
	return count

func dwelling_units_count() -> int:
	var units := 0
	for residence in residences:
		if String(residence.get("area", "home")) == "apartment":
			units += ceili(float(residence.get("residents", RESIDENTS_PER_APARTMENT)) / float(RESIDENTS_PER_HOME))
		else:
			units += 1
	return units

func _service_mean_from_snapshot(snapshot: Dictionary) -> float:
	var mean := 0.0
	for area in GameRules.AREAS:
		mean += float(snapshot.get(area, 0.0)) / float(GameRules.AREAS.size())
	return mean

func _spawn_growth_homes() -> void:
	var deficit := maxi(0, population - housing_capacity())
	if deficit < RESIDENTS_PER_HOME:
		return
	var needs_space := false
	var apartments_needed := floori(float(deficit) / float(RESIDENTS_PER_APARTMENT))
	if apartments_needed > 0:
		var footprint_candidates := _ordered_footprint_candidates()
		var apartments_built := 0
		for lot in footprint_candidates:
			if apartments_built >= apartments_needed:
				break
			if can_build_footprint(lot):
				residences.append({"lot": lot.duplicate(), "area": "apartment", "residents": RESIDENTS_PER_APARTMENT})
				_occupy_footprint(lot)
				apartments_built += 1
		homes_built_this_month += apartments_built * ceili(float(RESIDENTS_PER_APARTMENT) / float(RESIDENTS_PER_HOME))
		if apartments_built < apartments_needed:
			var before_lots := grass_lots.size()
			housing_space_needed.emit()
			if grass_lots.size() > before_lots:
				return
			needs_space = true
	var requested_homes := housing_requests()
	if requested_homes > 0:
		var available_lots := _ordered_home_candidates()
		var homes_to_build := mini(requested_homes, available_lots.size())
		for index in range(homes_to_build):
			var chosen_lot: Dictionary = available_lots[index]
			residences.append({"lot": chosen_lot.duplicate(), "area": "home", "variant": randi_range(0, 3)})
			var lot_key: Variant = _lot_key(chosen_lot)
			if lot_key != null:
				_occupied_lots[lot_key] = true
		homes_built_this_month += homes_to_build
		if homes_to_build < requested_homes:
			needs_space = true
	if needs_space:
		housing_space_needed.emit()

func _is_block_corner_coord(coord: Vector2i) -> bool:
	var rx := posmod(coord.x, 6)
	var ry := posmod(coord.y, 6)
	return (rx == 1 or rx == 4) and (ry == 1 or ry == 4)

func _is_cross_corridor_coord(coord: Vector2i) -> bool:
	return posmod(coord.x, 6) == 3 or posmod(coord.y, 6) == 3

func _blocks_town_hall_view(coord: Vector2i) -> bool:
	return coord.x >= -3 and coord.x <= 2 and coord.y >= -2 and coord.y <= 3

func _ordered_footprint_candidates() -> Array[Dictionary]:
	var corners: Array[Dictionary] = []
	var others: Array[Dictionary] = []
	for lot in grass_lots:
		if not can_build_footprint(lot):
			continue
		var key: Variant = _lot_key(lot)
		if key != null and _blocks_town_hall_view(key as Vector2i):
			continue
		if key != null and _is_block_corner_coord(key as Vector2i):
			corners.append(lot)
		else:
			others.append(lot)
	corners.shuffle()
	others.shuffle()
	corners.append_array(others)
	return corners

func required_buildings() -> int:
	if completed_months < 4:
		return 0
	return mini(8, 1 + floori(float(completed_months - 4) / 12.0))

func has_required_buildings() -> bool:
	return buildings.size() >= required_buildings()

func _ordered_home_candidates() -> Array[Dictionary]:
	var preferred: Array[Dictionary] = []
	var others: Array[Dictionary] = []
	for lot in grass_lots:
		if not can_build(lot):
			continue
		var key: Variant = _lot_key(lot)
		if key != null and _is_cross_corridor_coord(key as Vector2i):
			if randf() < 0.78:
				preferred.append(lot)
			else:
				others.append(lot)
		elif randf() < 0.22:
			preferred.append(lot)
		else:
			others.append(lot)
	preferred.shuffle()
	others.shuffle()
	preferred.append_array(others)
	return preferred

func fulfill_housing_demand() -> void:
	_spawn_growth_homes()
	changed.emit()

func _lot_key(lot: Dictionary) -> Variant:
	if not lot.has("x") or not lot.has("y"):
		return null
	var x: Variant = lot["x"]
	var y: Variant = lot["y"]
	if not (x is int or x is float) or not (y is int or y is float):
		return null
	if not is_finite(float(x)) or not is_finite(float(y)):
		return null
	return Vector2i(int(x), int(y))

func town_hall_coords() -> Array[Vector2i]:
	var hall_key: Variant = _lot_key(town_hall)
	if hall_key == null:
		return []
	var anchor := hall_key as Vector2i
	var coords: Array[Vector2i] = []
	for dx in range(-2, 1):
		for dy in range(-1, 1):
			coords.append(Vector2i(anchor.x + dx, anchor.y + dy))
	return coords

func _rebuild_occupied_lots() -> void:
	_occupied_lots.clear()
	for coord in town_hall_coords():
		_occupied_lots[coord] = true
	for item in residences:
		var raw_home_lot: Variant = item.get("lot", {})
		if raw_home_lot is Dictionary:
			if String(item.get("area", "home")) == "apartment":
				_occupy_footprint(raw_home_lot)
			else:
				var home_key: Variant = _lot_key(raw_home_lot)
				if home_key != null:
					_occupied_lots[home_key] = true
	for collection in [buildings, projects]:
		for item in collection:
			var raw_lot: Variant = item.get("lot", {})
			if raw_lot is Dictionary:
				_occupy_footprint(raw_lot)

func can_build_coord(coord: Vector2i) -> bool:
	if not _grass_lot_keys.has(coord):
		return false
	var hall_key: Variant = _lot_key(town_hall)
	if hall_key != null and coord == hall_key:
		return false
	return not _occupied_lots.has(coord)

func can_build(lot: Dictionary) -> bool:
	var key: Variant = _lot_key(lot)
	if key == null:
		return false
	return can_build_coord(key as Vector2i)

func can_build_footprint(lot: Dictionary) -> bool:
	var anchor: Variant = _lot_key(lot)
	if anchor == null:
		return false
	for coord in _footprint_coords(anchor as Vector2i):
		if not can_build_coord(coord):
			return false
	return true

func _footprint_coords(anchor: Vector2i) -> Array[Vector2i]:
	var coords: Array[Vector2i] = []
	for x in range(BUILDING_FOOTPRINT_SIZE):
		for y in range(BUILDING_FOOTPRINT_SIZE):
			coords.append(anchor + Vector2i(x, y))
	return coords

func _occupy_footprint(lot: Dictionary) -> void:
	var anchor: Variant = _lot_key(lot)
	if anchor == null:
		return
	for coord in _footprint_coords(anchor as Vector2i):
		_occupied_lots[coord] = true

func place_home(lot: Dictionary) -> String:
	if outcome != "playing" or housing_requests() <= 0:
		return "Ainda não há demanda por novas moradias."
	if not can_build(lot):
		return "Escolha um lote livre na grama."
	residences.append({"lot": lot.duplicate(), "variant": randi_range(0, 3)})
	var lot_key: Variant = _lot_key(lot)
	if lot_key != null:
		_occupied_lots[lot_key] = true
	homes_built_this_month += 1
	changed.emit()
	return ""
