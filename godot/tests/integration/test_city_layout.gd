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
		check(city.residences.size() == CityState.INITIAL_HOMES, "Moradias iniciais completas.")
		var occupied: Array[Dictionary] = []
		for home in city.residences:
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
			if city.can_build(lot):
				free = lot
				break
		check(city.construct("education", 0, free).is_empty(), "Obra aceita lote livre.")
		check(not city.can_build(free), "Obra reserva lote durante construcao.")
		city.advance_day(GameRules.BUILDING_DAYS)
		check(city.buildings[0].lot == free and not city.can_build(free), "Conclusao preserva local e ocupacao.")
		for month in range(3):
			city.advance_month()
		check(city.population == GameRules.INITIAL_POPULATION + 150, "Servicos suficientes geram crescimento mensal.")
		check(city.housing_requests() == 1, "Crescimento libera uma moradia.")
		for lot in visuals.lots:
			if city.can_build(lot):
				free = lot
				break
		money = city.funds
		check(city.place_home(free).is_empty(), "Moradia nova ocupa o local escolhido.")
		check(city.housing_requests() == 0 and city.funds == money, "Demanda atendida sem cobranca adicional.")
		check(not city.place_home(free).is_empty(), "Moradia nao pode ser duplicada.")
		var loaded := CityState.new()
		loaded.load_save_data(JSON.parse_string(JSON.stringify(city.get_save_data())))
		loaded.configure_lots(visuals.lots)
		check(JSON.parse_string(JSON.stringify(loaded.get_save_data())) == JSON.parse_string(JSON.stringify(city.get_save_data())), "Save JSON preserva populacao, terrenos e variantes.")
		check(not loaded.can_build(loaded.buildings[0].lot), "Obra carregada continua ocupando terreno.")
		check(loaded.can_build({"x": 11, "y": 11}), "Lote livre permanece disponivel depois do JSON.")
		city.start("Outra", "medium")
		check(city.population == GameRules.INITIAL_POPULATION, "Nova partida redefine populacao.")
		visuals.free()
	check(signatures.size() > 1, "Partidas diferentes recebem distribuicoes diferentes.")
	var legacy := CityState.new()
	legacy.load_save_data({"buildings": [{"area": "health"}], "projects": [{"area": "culture", "due": 30}]})
	var map := CityVisuals.new()
	root.add_child(map)
	map.bind(legacy)
	check(legacy.buildings[0].has("lot") and legacy.projects[0].has("lot"), "Save antigo recebe lotes para obras e instalacoes.")
	check(legacy.buildings[0].lot != legacy.projects[0].lot, "Migracao evita sobreposicao.")
	map.free()
	print("Lotes: %d verificacoes, %d falhas. END" % [checks, failures])
	quit(0 if failures == 0 else 1)
