extends SceneTree

var failures := 0
var checks := 0
var _save: Node
var game: Node

func _initialize() -> void:
	call_deferred("_run")

func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		print("FAIL: ", message)

func _run() -> void:
	node_added.connect(func(node: Node):
		if node is TimeManager or (node.get_script() != null and node.get_script().resource_path == "res://scripts/game_manager.gd"):
			node.set_process(false))
	_save = root.get_node("SaveManager")
	_save.save_dir = "user://verification_saves_20261016"
	await process_frame
	_unit_rules()
	_save.start_new("Cidade de verificação", "medium")
	change_scene_to_file("res://scenes/game/Game.tscn")
	await process_frame
	await process_frame
	game = current_scene
	check(game != null, "A partida deve carregar.")
	if game == null:
		quit(1)
		return
	await process_frame
	game.time_manager.set_process(false)
	game.set_process(false)
	game._close_dialog()
	await process_frame
	check(game.city.funds == GameRules.INITIAL_FUNDS, "Saldo inicial real.")
	check(not game.hud.funds_button.disabled, "Investimentos acessíveis.")
	var initial_funds: float = game.city.funds
	game._construct("education")
	check(game.city.projects.size() == 1, "Obra iniciada.")
	check(game.city.funds == initial_funds - GameRules.BUILDING_COST, "Custo da obra debitado uma vez.")
	var initial_day: int = game.time_manager.current_day
	game.time_manager.hold("menu")
	game.time_manager._process(100)
	check(game.time_manager.current_day == initial_day, "Menu pausa calendário.")
	game.time_manager.hold("inactive")
	game.time_manager.release("menu")
	check(game.time_manager.paused, "Um motivo de pausa não libera outro.")
	game.time_manager.release("inactive")
	check(not game.time_manager.paused, "Retoma após liberar todos os motivos.")
	var checkpoint_done := false
	for _day in range(2880):
		if game._modal != null:
			game._close_dialog()
		game.time_manager._advance_one_day()
		await _answer_all()
		if not checkpoint_done and game.city.completed_months >= 6:
			await _save_and_reload()
			checkpoint_done = true
		if game.city.outcome != "playing":
			break
	check(game.city.outcome == "completed", "Campanha termina após dois mandatos.")
	check(game.city.completed_months == 96, "96 meses completos.")
	check(game.city.term == 2, "Reeleição inicia segundo mandato.")
	check(game.city.solved_count > 100, "Catálogo continua após os problemas iniciais.")
	check(game.city.buildings.size() == 1 and game.city.projects.is_empty(), "Obra concluída permanece após carregar.")
	check(game.time_manager.paused, "Tela final interrompe simulação.")
	check(game._modal != null, "Resultado final é exibido.")
	check(game.city.projection("funds").get("ready", false), "Histórico gera projeções.")
	await _save_and_reload()
	check(game.city.outcome == "completed", "Resultado final é persistido.")
	check(game.time_manager.paused, "Resultado carregado continua encerrado.")
	await _failure_paths()
	for slot in range(1, 4):
		_save.delete_slot(slot)
	current_scene.queue_free()
	await process_frame
	print("Campanha: %d verificações, %d falhas. END" % [checks, failures])
	quit(0 if failures == 0 else 1)

func _answer_all() -> void:
	for event in game.event_manager.get_active_events():
		if game._modal != null:
			game._close_dialog()
		var id := String(event.event_id)
		var definition: Dictionary = game.event_database.get_event(id)
		game.open_problem(id)
		await process_frame
		if game._current_problem_popup == null:
			check(false, "Problema deve abrir: " + id)
			continue
		check(game.time_manager.paused, "Problema pausa o tempo.")
		var before: int = game.city.solved_count
		var answer := String(definition.get("correct_answer", ""))
		var payload: Dictionary = definition.get("payload", {})
		if String(definition.interaction_type) == "number_input":
			answer = str(payload.correct_value)
			game._current_problem_popup.answer_input.text = answer
			game._current_problem_popup._submit_typed_answer()
		else:
			if definition.has("accepted_answers"):
				answer = String(definition.accepted_answers[0])
			var options: Array = payload.get("options", [])
			for i in range(options.size()):
				if String(options[i].id) == answer:
					game._current_problem_popup._on_option_pressed(i)
					break
		check(game.city.solved_count == before + 1, "Resposta altera o estado uma vez.")
		check(game.city.last_result.get("correct", false), "Resposta esperada reconhecida: " + id)
		check(game._modal != null, "Explicação e consequências são exibidas.")
		game._close_dialog()
		await process_frame

func _save_and_reload() -> void:
	var city_before: Dictionary = game.city.get_save_data()
	var time_before: Dictionary = game.time_manager.get_save_data()
	check(_save.save_game(game.time_manager, game.event_manager, 1, game.event_database, game.city), "Grava save completo.")
	check(_save.save_game(game.time_manager, game.event_manager, 1, game.event_database, game.city), "Regrava e preserva backup.")
	check(FileAccess.file_exists(_save.slot_path(1) + ".backup"), "Backup existe.")
	check(_save.load_slot(1), "Carrega slot válido.")
	change_scene_to_file("res://scenes/game/Game.tscn")
	await process_frame
	await process_frame
	game = current_scene
	game.time_manager.set_process(false)
	game.set_process(false)
	check(_same(game.city.get_save_data(), city_before), "Cidade preservada no round-trip.")
	if not _same(game.city.get_save_data(), city_before):
		for key in city_before:
			if not _same(game.city.get_save_data().get(key), city_before[key]):
				print("CHECK city difference: ", key)
	check(_same(game.time_manager.get_save_data(), time_before), "Calendário preservado no round-trip.")
	if not _same(game.time_manager.get_save_data(), time_before):
		for key in time_before:
			if not _same(game.time_manager.get_save_data().get(key), time_before[key]):
				print("CHECK time difference: ", key)
	var file := FileAccess.open(_save.slot_path(1), FileAccess.WRITE)
	file.store_string("{arquivo danificado")
	file.close()
	check(_save.load_slot(1) and _save.recovered_backup, "Corrupção recupera backup válido.")
	_save.pending_save = {}

func _unit_rules() -> void:
	var city := CityState.new()
	city.start("Regras", "hard")
	check(city.reputation == 45, "Dificuldade altera reputação inicial.")
	var funds := city.funds
	check(not city.invest("health", -100).is_empty() and city.funds == funds, "Investimento negativo rejeitado.")
	check(not city.invest("health", funds + 1).is_empty() and city.funds == funds, "Saldo insuficiente rejeitado.")
	check(city.invest("health", 10000).is_empty() and city.funds == funds - 10000, "Investimento válido debita e aplica.")
	check(city.construct("education", 0).is_empty(), "Construção válida.")
	city.advance_day(19)
	check(city.buildings.is_empty(), "Obra não conclui antes do prazo.")
	city.advance_day(20)
	check(city.buildings.size() == 1, "Obra conclui no prazo.")
	check(not city.projection("funds").ready, "Não extrapola histórico insuficiente.")
	city.start("Derrota", "medium")
	city.completed_months = 47
	city.reputation = 30
	city.advance_month()
	check(city.outcome == "not_reelected", "Reputação baixa perde a eleição.")
	city = CityState.new()
	city.start("Crise", "medium")
	city.reputation = 1
	for _month in range(3):
		city.advance_month()
	check(city.outcome == "impeachment", "Crise persistente encerra mandato.")
	var time := load("res://scripts/timemanager.gd").new() as TimeManager
	time._advance_one_day()
	check(time.current_day == 2, "Dia avança.")
	time.set_date(30, 12, 1)
	time._advance_one_day()
	check(time.current_day == 1 and time.current_month == 1 and time.current_year == 2, "Virada de ano.")
	for pair in [[TimeManager.Speed.NORMAL, 6.0], [TimeManager.Speed.FAST, 3.0], [TimeManager.Speed.VERY_FAST, 1.0]]:
		time.set_speed(pair[0])
		check(is_equal_approx(time._get_real_seconds_per_game_day(), pair[1]), "Velocidades previstas no RF11.")
	time.free()

func _failure_paths() -> void:
	_save.start_new("Cenários de falha", "hard")
	change_scene_to_file("res://scenes/game/Game.tscn")
	await process_frame
	await process_frame
	game = current_scene
	game._close_dialog()
	await process_frame
	game.notification(NOTIFICATION_APPLICATION_FOCUS_OUT)
	check(game.time_manager.paused, "Inatividade pausa a sessão.")
	game.notification(NOTIFICATION_APPLICATION_FOCUS_IN)
	check(not game.time_manager.paused, "Foco libera a pausa por inatividade.")
	game.time_manager.pause_game()
	var before_day := int(game.time_manager.current_day)
	game._skip_to_next()
	check(game.time_manager.current_day == before_day, "Avanço não ignora pausa manual.")
	game.time_manager.resume_game()
	game._skip_to_next()
	check(game._current_problem_popup != null, "Avanço encontra uma ocorrência e abre a interface.")
	game._close_current_problem()
	game.event_manager.clear_all()
	var urgent: Dictionary = game.event_database.build_runtime_event("moradias_enchente", 1, 1, 1)
	urgent.deadline_phase = "opening"
	urgent.deadline_remaining_seconds = 2.0
	game.event_manager.active_events.append(urgent)
	game.time_manager.pause_game()
	game._process(10.0)
	check(urgent.deadline_remaining_seconds == 2.0, "Pausa congela prazo urgente.")
	game.open_problem("moradias_enchente")
	await process_frame
	game._on_problem_close_requested()
	check(game._current_problem_popup == null and game.event_manager.active_events.size() == 1, "Fechar urgente mantém a ocorrência pendente.")
	check(urgent.deadline_remaining_seconds == 2.0 and urgent.deadline_phase == "opening", "Fechar urgente preserva prazo restante sem reiniciá-lo.")
	game.open_problem("moradias_enchente")
	await process_frame
	check(urgent.deadline_remaining_seconds == 2.0, "Reabrir urgente não concede tempo adicional.")
	game._on_problem_close_requested()
	var reputation_before := float(game.city.reputation)
	game.time_manager.resume_game()
	game._process(3.0)
	check(game.event_manager.active_events.is_empty(), "Prazo urgente expira quando o tempo corre.")
	check(game.city.expired_count == 1 and game.city.reputation < reputation_before, "Expiração aplica consequências reais.")
	var time := game.time_manager as TimeManager
	var database := game.event_database as EventDatabase
	var cross_year := database.build_runtime_event("aura_travessia", 28, 12, 1)
	if cross_year.is_empty():
		cross_year = database.build_runtime_event("pesquisa_satisfacao", 28, 12, 1)
	check(not cross_year.is_empty(), "Evento de calendário disponível.")
	if not cross_year.is_empty():
		var expiry: Dictionary = cross_year.expires_on
		check(int(expiry.year) == 2 and int(expiry.day) <= 30, "Expiração é normalizada na virada de ano.")
	time.set_date(30, 12, 4)
	game.city.completed_months = 47
	game.city.reputation = 30
	time._advance_one_day()
	check(game.city.outcome == "not_reelected" and game._modal != null, "Derrota eleitoral aparece na cena real.")
	check(game.time_manager.paused, "Derrota interrompe calendário.")
	_save.start_new("Crise imediata", "medium")
	change_scene_to_file("res://scenes/game/Game.tscn")
	await process_frame
	await process_frame
	game = current_scene
	game._close_dialog()
	await process_frame
	game.city.reputation = 1.0
	game.event_manager.active_events.append(game.event_database.build_runtime_event("moradias_enchente", 1, 1, 1))
	game.open_problem("moradias_enchente")
	await process_frame
	game._current_problem_popup._on_option_pressed(0)
	await process_frame
	check(game.city.outcome == "impeachment", "Erro pode levar a impeachment imediato ao zerar a reputação.")
	check(game._modal != null and game._current_problem_popup == null, "Fim durante problema fecha o problema e exibe apenas o resultado final.")
	check(game.city.solved_count == 1 and game.city.correct_count == 0, "Resposta incorreta permanece no histórico.")
	var service := root.get_node("SettingsService")
	service.update("locale", "en")
	check(TranslationServer.translate("Jogar") == "Play", "Tradução inglesa importada.")
	var definition: Dictionary = game.event_database.get_event("municipal_1_2")
	check(game._problem_description(definition).contains("square park"), "Problema parametrizado é traduzido após criação.")
	service.update("locale", "pt_BR")
	check(game._problem_description(definition).contains("praça quadrada"), "Problema parametrizado volta ao português sem alterar conteúdo salvo.")
	var city := CityState.new()
	city.start("Obras", "medium")
	city.construct("health", 0)
	city.apply_problem({"id": "municipal_1_1", "category": "common", "construction_days_saved": 5}, true)
	check(int(city.projects[0].due) == 15, "Resposta de obra reduz o prazo em cinco dias.")
	var invalid := {"schema_version": 99, "time": game.time_manager.get_save_data(), "events": {}}
	check(not _save.write_slot(2, invalid), "Schema desconhecido é rejeitado.")
	check(not _save.load_slot(0), "Slot fora dos três disponíveis é rejeitado.")

func _same(a: Variant, b: Variant) -> bool:
	if (a is float or a is int) and (b is float or b is int):
		return is_equal_approx(float(a), float(b))
	if a is Array and b is Array:
		if a.size() != b.size():
			return false
		for i in range(a.size()):
			if not _same(a[i], b[i]):
				return false
		return true
	if a is Dictionary and b is Dictionary:
		if a.size() != b.size():
			return false
		for key in a:
			if not b.has(key) or not _same(a[key], b[key]):
				return false
		return true
	return a == b
