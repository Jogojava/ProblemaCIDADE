extends SceneTree

var checks := 0
var failures := 0

func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		print("FAIL: ", message)

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var signatures: Dictionary = {}
	for iteration in range(20):
		var city := CityState.new()
		city.start("Teste", "medium")
		var visuals := CityVisuals.new()
		root.add_child(visuals)
		visuals.bind(city)
		check(city.homes_count() == CityState.INITIAL_HOMES, "100 casas iniciais completas.")
		var apartment_count := city.residences.size() - city.homes_count()
		check(apartment_count >= CityState.MIN_INITIAL_APARTMENTS and apartment_count <= CityState.MAX_INITIAL_APARTMENTS, "Quantidade inicial de predios varia entre 40 e 60.")
		check(city.housing_capacity() == city.population and city.population > 1000, "Capacidade residencial inicial corresponde a mais de mil habitantes.")
		var occupied: Array[Dictionary] = []
		var free_footprints := 0
		for lot in visuals.lots:
			if city.can_build_footprint(lot):
				free_footprints += 1
		check(free_footprints >= 20, "Sobram muitos espacos 2x2 livres para construcoes iniciais.")
		for home in city.residences:
			if String(home.get("area", "home")) == "apartment":
				check(city._is_block_corner_coord(Vector2i(int(home.lot.x), int(home.lot.y))), "Predio inicial ocupa canto de quarteirao.")
			check(visuals.lots.has(home.lot), "Moradia inicial fica na grama.")
			check(not occupied.has(home.lot) and home.lot != city.town_hall, "Lotes iniciais distintos da prefeitura e entre si.")
			occupied.append(home.lot)
			check(visuals.lot_at(visuals.point(home.lot)) == home.lot, "Transformacao isometrica reversivel.")
		signatures[str(city.residences)] = true
		var before := city.get_save_data()
		city.configure_lots(visuals.lots)
		check(before == city.get_save_data(), "Reconfigurar mapa nao redistribui moradias.")
		var money := city.funds
		check(not city.construct("education", 0, {"x": 0, "y": 0}).is_empty(), "Rua rejeitada.")
		check(not city.construct("education", 0, occupied[0]).is_empty(), "Moradia ocupada rejeitada.")
		check(not city.construct("education", 0, city.town_hall).is_empty(), "Prefeitura rejeitada.")
		check(not city.construct("education", 0, {"x": 500, "y": 500}).is_empty(), "Fora do mapa rejeitado.")
		check(city.funds == money and city.projects.is_empty(), "Tentativas invalidas nao cobram.")
		var free: Dictionary = {}
		for lot in visuals.lots:
			if city.can_build_footprint(lot):
				free = lot
				break
		check(city.construct("education", 0, free).is_empty(), "Obra aceita quatro lotes contiguos.")
		check(not city.can_build_footprint(free), "Obra reserva os quatro lotes durante construcao.")
		for x in range(CityState.BUILDING_FOOTPRINT_SIZE):
			for y in range(CityState.BUILDING_FOOTPRINT_SIZE):
				check(not city.can_build_coord(Vector2i(int(free.x) + x, int(free.y) + y)), "Cada espaco da obra fica reservado.")
		city.advance_day(GameRules.BUILDING_DAYS)
		check(city.buildings[0].lot == free and not city.can_build_footprint(free), "Conclusao preserva local e os quatro lotes ocupados.")
		var population_before_growth := city.population
		for month in range(3):
			city.advance_month()
		check(city.population >= population_before_growth + 6, "Servicos saudaveis geram crescimento populacional moderado.")
		check(city.housing_requests() == 0, "Crescimento automatico mantem capacidade residencial.")
		city.population += CityState.RESIDENTS_PER_HOME
		check(city.housing_requests() == 1, "Quatro moradores adicionais liberam uma casa.")
		for lot in visuals.lots:
			if city.can_build(lot):
				free = lot
				break
		money = city.funds
		check(city.place_home(free).is_empty(), "Casa nova ocupa o local escolhido.")
		check(city.housing_requests() == 0 and city.funds == money, "Demanda atendida sem cobranca adicional.")
		check(not city.place_home(free).is_empty(), "Moradia nao pode ser duplicada.")
		var loaded := CityState.new()
		loaded.load_save_data(JSON.parse_string(JSON.stringify(city.get_save_data())))
		loaded.configure_lots(visuals.lots)
		check(JSON.parse_string(JSON.stringify(loaded.get_save_data())) == JSON.parse_string(JSON.stringify(city.get_save_data())), "Save JSON preserva populacao, terrenos e variantes.")
		check(not loaded.can_build(loaded.buildings[0].lot), "Obra carregada continua ocupando terreno.")
		var loaded_has_free_lot := false
		for lot in visuals.lots:
			if loaded.can_build(lot):
				loaded_has_free_lot = true
				break
		check(loaded_has_free_lot, "Lotes livres permanecem disponiveis depois do JSON.")
		city.start("Outra", "medium")
		check(city.population == GameRules.INITIAL_POPULATION, "Nova partida redefine populacao.")
		visuals.free()
	check(signatures.size() > 1, "Partidas diferentes recebem distribuicoes diferentes.")
	var legacy := CityState.new()
	legacy.load_save_data({"population": 10000, "layout_initialized": true, "residences": [{"lot": {"x": 1, "y": 1}}], "buildings": [{"area": "health"}], "projects": [{"area": "culture", "due": 30}]})
	var map := CityVisuals.new()
	root.add_child(map)
	map.bind(legacy)
	check(legacy.buildings[0].has("lot") and legacy.projects[0].has("lot"), "Save antigo recebe lotes para obras e instalacoes.")
	check(legacy.buildings[0].lot != legacy.projects[0].lot, "Migracao evita sobreposicao.")
	check(legacy.population == legacy.housing_capacity() and legacy.population > 1000 and legacy.homes_count() == CityState.INITIAL_HOMES, "Save antigo migra para populacao e moradias proporcionais.")
	# Verify road grid repeats every 6 tiles (5 grass lots between perpendicular roads) after expansion
	check(map.expand_map(), "Mapa expande mantendo grade regular.")
	for coord in range(-map.map_radius, map.map_radius + 1):
		var expected_road := posmod(coord, 6) == 0
		check(map._road(coord, 1) == expected_road, "Rua vertical a cada 6 lotes em x=%d." % coord)
		check(map._road(1, coord) == expected_road, "Rua horizontal a cada 6 lotes em y=%d." % coord)
	# Verify that without buildings after grace period, reputation and population stagnate;
	# and once a building is constructed, both houses and apartment buildings spawn.
	var growth_city := CityState.new()
	growth_city.start("Crescimento", "medium")
	var growth_map := CityVisuals.new()
	root.add_child(growth_map)
	growth_map.bind(growth_city)
	for area in GameRules.AREAS:
		growth_city.indicators[area] = 75.0
	for _m in range(4):
		growth_city.advance_month()
	var stalled_pop := growth_city.population
	var stalled_rep := growth_city.reputation
	growth_city.advance_month()
	check(growth_city.population == stalled_pop, "Sem construcoes apos carencia, populacao nao cresce.")
	check(growth_city.reputation <= stalled_rep, "Sem construcoes apos carencia, reputacao nao sobe.")
	for lot in growth_map.lots:
		if growth_city.can_build_footprint(lot):
			check(growth_city.construct("education", 0, lot).is_empty(), "Constroi obra para destravar crescimento.")
			growth_city.advance_day(GameRules.BUILDING_DAYS)
			break
	var start_pop := growth_city.population
	var start_homes := growth_city.homes_count()
	var start_apts := growth_city.apartments_count()
	for _m in range(6):
		growth_city.advance_month()
	check(growth_city.projection("funds").get("ready", false), "Projecoes ficam disponiveis a partir de 6 meses.")
	check(growth_city.population >= start_pop + 400, "Cidade com obra e servicos bons cresce de forma consistente.")
	check(growth_city.homes_count() > start_homes, "Novas casas surgem ao longo dos meses.")
	check(growth_city.apartments_count() > start_apts, "Novos predios residenciais surgem ao longo dos meses.")
	check(growth_city.housing_requests() == 0 and growth_city.population - growth_city.housing_capacity() < CityState.RESIDENTS_PER_HOME, "Capacidade residencial acompanha crescimento com casas e predios.")
	growth_map.free()
	map.free()
	print("Lotes: %d verificacoes, %d falhas. END" % [checks, failures])
	quit(0 if failures == 0 else 1)
