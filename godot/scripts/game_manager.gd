extends Node

const URGENT_DEADLINE_SECONDS := 180.0
const PROBLEM_SCENE := preload("res://scenes/ui/problem_template.tscn")

@onready var event_database: EventDatabase = $EventDatabase
@onready var event_manager: EventManager = $EventManager
@onready var time_manager: TimeManager = $TimeManager
@onready var hud: GameHUD = $CanvasLayer/HUD
@onready var pause_menu: GamePauseMenu = $CanvasLayer/PauseMenu
@onready var problem_layer: Control = $CanvasLayer/ProblemLayer
@onready var return_dialog: ConfirmationDialog = $ReturnToMenuDialog

var city := CityState.new()
var visuals: CityVisuals
var _placement_area := ""
var _placement_bar: PanelContainer
var _placement_text: Label
var _modal: Control
var _last_refresh := 0.0
var _current_problem_id := ""
var _current_problem_popup: ProblemTemplate
var _current_problem_runtime_event: Dictionary = {}

func _ready() -> void:
	hud.theme = SettingsService.game_theme
	return_dialog.theme = hud.theme
	hud.investment_requested.connect(_invest)
	hud.construction_requested.connect(_construct)
	hud.housing_requested.connect(func(): _begin_placement("home"))
	hud.skip_requested.connect(_skip_to_next)
	hud.map_center_requested.connect($Camera2D.reset_view)
	city.start(String(SaveManager.new_game_options.name), String(SaveManager.new_game_options.difficulty))
	city.campaign_event.connect(_on_campaign_event)
	city.building_completed.connect(_on_building_completed)
	hud.bind_time_manager(time_manager)
	hud.menu_requested.connect(_on_menu_requested)
	hud.panels_changed.connect(_on_panels_changed)
	hud.problem_open_requested.connect(open_problem)
	pause_menu.resume_requested.connect(_on_resume_requested)
	pause_menu.exit_requested.connect(_on_exit_requested)
	pause_menu.save_requested.connect(_on_save_requested)
	return_dialog.confirmed.connect(_on_return_confirmed)
	return_dialog.canceled.connect(_on_return_canceled)
	event_database.register_default_problems()
	event_manager.setup(time_manager, event_database)
	event_manager.event_triggered.connect(_on_event_triggered)
	event_manager.event_resolved.connect(_on_event_resolved)
	event_manager.event_expired.connect(_on_event_expired)
	var saved_game := SaveManager.consume_pending_save()
	if not saved_game.is_empty():
		city.load_save_data(saved_game.get("city", {}))
		time_manager.load_save_data(saved_game.get("time", {}))
		if not saved_game.has("city"):
			city.completed_months = (time_manager.current_year - 1) * 12 + time_manager.current_month - 1
			city.term = 2 if city.completed_months >= 48 else 1
			city.last_day = GameRules.date_index(time_manager.current_day, time_manager.current_month, time_manager.current_year)
			if city.completed_months >= 96:
				city.outcome = "completed"
		event_manager.load_save_data(saved_game.get("events", {}))
		event_database.load_usage_save_data(saved_game.get("event_database_usage", {}))
		_mark_saved_events_as_used()
	event_manager.common_events_per_month = int(city.profile().common)
	event_manager.optional_events_per_month = 1
	event_manager.important_events_per_month = 1
	time_manager.day_passed.connect(_on_game_day)
	time_manager.month_passed.connect(_on_game_month)
	hud.bind_city(city)
	$Ground.hide()
	$Road.hide()
	RenderingServer.set_default_clear_color(Color("243d39"))
	visuals = CityVisuals.new()
	visuals.name = "CityVisuals"
	visuals.origin = $Camera2D.position
	visuals.z_index = 4
	add_child(visuals)
	visuals.bind(city)
	visuals.lot_selected.connect(_place_building)
	visuals.placement_cancelled.connect(_cancel_placement)
	_create_placement_bar()
	event_manager.enforce_one_urgent_per_month()
	event_manager.start_system(time_manager.current_month, time_manager.current_year)
	_restore_urgent_deadlines()
	_refresh_problem_tabs()
	if city.outcome != "playing":
		time_manager.hold("ended")
		call_deferred("_on_campaign_event", city.outcome)
	elif saved_game.is_empty():
		call_deferred("_show_briefing")
	elif SaveManager.recovered_backup:
		hud.show_notice(tr("Partida recuperada do backup anterior."))
	elif saved_game.has("migrated_from"):
		hud.show_notice(tr("Save antigo recuperado. O estado da cidade foi inicializado porque não existia nesta versão."))
	if OS.get_cmdline_user_args().has("--freeze"):
		time_manager.set_process(false)
		set_process(false)

func _process(delta: float) -> void:
	if time_manager.paused or city.outcome != "playing":
		return
	city.played_seconds += delta
	var expired_ids: Array[String] = []
	for runtime_event in event_manager.active_events:
		if String(runtime_event.get("category", "")) != EventManager.CATEGORY_URGENT:
			continue
		var deadline_phase := String(runtime_event.get("deadline_phase", "opening"))
		if deadline_phase == "answered" or deadline_phase == "queued":
			continue
		var speed_multiplier := time_manager.get_game_speed_multiplier()
		var remaining := maxf(0.0, float(runtime_event.get("deadline_remaining_seconds", URGENT_DEADLINE_SECONDS)) - delta * speed_multiplier)
		runtime_event["deadline_remaining_seconds"] = remaining
		if remaining <= 0.0:
			expired_ids.append(String(runtime_event.get("event_id", "")))

	for event_id in expired_ids:
		event_manager.expire_event_immediately(event_id)

	_last_refresh += delta
	if _last_refresh > 0.15:
		_last_refresh = 0.0
		_refresh_problem_tabs()

func _input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	if not _placement_area.is_empty():
		if event.keycode == KEY_ESCAPE:
			_cancel_placement()
		get_viewport().set_input_as_handled()
		return
	if _modal != null or city.outcome != "playing":
		return
	if _current_problem_popup != null and is_instance_valid(_current_problem_popup):
		if event.keycode == KEY_ESCAPE:
			_current_problem_popup.dismiss()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_SPACE:
			get_viewport().set_input_as_handled()
		return
	if return_dialog.visible:
		return
	if pause_menu.visible:
		if event.keycode == KEY_ESCAPE:
			pause_menu.back_or_resume()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_SPACE:
			get_viewport().set_input_as_handled()
		return
	if event.keycode == KEY_SPACE:
		if not hud.has_open_panel():
			time_manager.toggle_pause()
		get_viewport().set_input_as_handled()
	elif event.keycode == KEY_ESCAPE:
		if not hud.close_panels():
			_on_menu_requested()
		get_viewport().set_input_as_handled()

func open_problem(event_id: String) -> void:
	if not _placement_area.is_empty():
		return
	if not _current_problem_id.is_empty() or _modal != null or pause_menu.visible or city.outcome != "playing":
		return
	var runtime_event := _find_active_event(event_id)
	if runtime_event.is_empty():
		return
	var problem_data := event_database.get_event(event_id)
	if problem_data.is_empty():
		return

	hud.close_panels()
	_current_problem_id = event_id
	_current_problem_runtime_event = runtime_event
	if String(runtime_event.get("category", "")) == EventManager.CATEGORY_URGENT:
		if float(runtime_event.get("deadline_remaining_seconds", URGENT_DEADLINE_SECONDS)) <= 0.0:
			event_manager.expire_event_immediately(event_id)
			return
		runtime_event["deadline_phase"] = "solving"
		runtime_event["deadline_remaining_seconds"] = float(runtime_event.get("deadline_remaining_seconds", URGENT_DEADLINE_SECONDS))

	time_manager.set_challenge_active(true)
	hud.set_problem_mode(true)
	var popup := PROBLEM_SCENE.instantiate() as ProblemTemplate
	popup.theme = hud.theme
	_current_problem_popup = popup
	problem_layer.add_child(popup)
	popup.answer_selected.connect(_on_problem_answer_selected)
	popup.close_requested.connect(_on_problem_close_requested)
	var payload: Dictionary = problem_data.get("payload", {})
	var input_placeholder := String(payload.get("placeholder", "Digite sua resposta"))
	var problem_image := _resolve_problem_image(problem_data.get("image", null))
	await popup.configure(
		tr(String(problem_data.get("title", "Problema"))),
		_problem_description(problem_data),
		problem_image,
		payload.get("options", []),
		bool(problem_data.get("allow_board", true)),
		String(problem_data.get("interaction_type", EventDatabase.INTERACTION_CHOICE)),
		input_placeholder,
		String(problem_data.get("category", EventDatabase.CATEGORY_COMMON))
	)
	if problem_data.has("graph"):
		popup.show_route_graph(problem_data.graph)
	popup.restore_draft(runtime_event.get("draft_strokes", []), String(runtime_event.get("draft_answer", "")))

func _resolve_problem_image(image_value: Variant) -> Texture2D:
	if image_value is Texture2D:
		return image_value
	if not image_value is String:
		return null
	var image_path := String(image_value).strip_edges()
	if image_path.is_empty():
		return null
	if not ResourceLoader.exists(image_path):
		push_warning("Imagem do problema não encontrada: %s" % image_path)
		return null
	var loaded_image := load(image_path)
	if loaded_image is Texture2D:
		return loaded_image
	push_warning("O recurso de imagem do problema não é uma Texture2D: %s" % image_path)
	return null

func _problem_description(definition: Dictionary) -> String:
	if definition.has("description_pattern"):
		return tr(String(definition.description_pattern)) % definition.get("description_values", [])
	return tr(String(definition.get("description", "")))

func _on_problem_answer_selected(answer: String) -> void:
	if _current_problem_id.is_empty() or _current_problem_popup == null:
		return
	var problem_data := event_database.get_event(_current_problem_id)
	if problem_data.is_empty():
		return
	var is_correct := _is_answer_correct(problem_data, answer)
	_current_problem_runtime_event["answer_correct"] = is_correct
	_current_problem_runtime_event["submitted_answer"] = answer
	_current_problem_runtime_event["deadline_phase"] = "answered"
	if event_manager.resolve_event(_current_problem_id):
		print("Problema '%s': %s" % [_current_problem_id, "acertou" if is_correct else "errou"])
		_close_current_problem()
		_show_answer_feedback(problem_data, is_correct)

func _is_answer_correct(problem_data: Dictionary, answer: String) -> bool:
	var interaction_type := String(problem_data.get("interaction_type", EventDatabase.INTERACTION_CHOICE))
	var payload: Dictionary = problem_data.get("payload", {})
	if interaction_type == EventDatabase.INTERACTION_NUMBER_INPUT:
		var normalized := answer.strip_edges().replace(",", ".")
		if not normalized.is_valid_float():
			return false
		var expected := float(payload.get("correct_value", 0.0))
		return absf(float(normalized) - expected) <= float(payload.get("tolerance", 0.01))
	var accepted: Array = problem_data.get("accepted_answers", payload.get("accepted_answers", []))
	if not accepted.is_empty():
		for accepted_answer in accepted:
			if _answers_match(answer, accepted_answer):
				return true
		return false
	return _answers_match(answer, problem_data.get("correct_answer", ""))

func _answers_match(answer: String, expected: Variant) -> bool:
	return answer.strip_edges().to_lower() == String(expected).strip_edges().to_lower()

func _find_active_event(event_id: String) -> Dictionary:
	for runtime_event in event_manager.active_events:
		if String(runtime_event.get("event_id", "")) == event_id:
			return runtime_event
	return {}

func _restore_urgent_deadlines() -> void:
	var deadline_is_active := false
	for runtime_event in event_manager.active_events:
		if String(runtime_event.get("category", "")) != EventManager.CATEGORY_URGENT:
			continue
		runtime_event["deadline_phase"] = "queued" if deadline_is_active else "opening"
		if not runtime_event.has("deadline_remaining_seconds"):
			runtime_event["deadline_remaining_seconds"] = URGENT_DEADLINE_SECONDS
		deadline_is_active = true

func _on_event_triggered(runtime_event: Dictionary) -> void:
	if String(runtime_event.get("category", "")) == EventManager.CATEGORY_URGENT:
		time_manager.set_speed(TimeManager.Speed.NORMAL)
		runtime_event["deadline_phase"] = "queued"
		runtime_event["deadline_remaining_seconds"] = URGENT_DEADLINE_SECONDS
		_activate_next_urgent_deadline()
	_refresh_problem_tabs()

func _on_event_resolved(runtime_event: Dictionary) -> void:
	var definition := event_database.get_event(String(runtime_event.get("event_id", "")))
	city.apply_problem(definition, bool(runtime_event.get("answer_correct", false)), false, String(runtime_event.get("submitted_answer", "")))
	if String(runtime_event.get("category", "")) == EventManager.CATEGORY_URGENT:
		_activate_next_urgent_deadline()
	_refresh_problem_tabs()

func _on_event_expired(runtime_event: Dictionary) -> void:
	var definition := event_database.get_event(String(runtime_event.get("event_id", "")))
	city.apply_problem(definition, false, true)
	hud.show_notice(tr("Prazo encerrado: %s. Consulte os indicadores da cidade.") % tr(String(definition.get("title", "Problema"))))
	if String(runtime_event.get("category", "")) == EventManager.CATEGORY_URGENT:
		_activate_next_urgent_deadline()
	if String(runtime_event.get("event_id", "")) == _current_problem_id:
		_close_current_problem()
	_refresh_problem_tabs()

func _activate_next_urgent_deadline() -> void:
	for runtime_event in event_manager.active_events:
		if String(runtime_event.get("category", "")) != EventManager.CATEGORY_URGENT:
			continue
		var phase := String(runtime_event.get("deadline_phase", "queued"))
		if phase == "opening" or phase == "solving":
			return
	for runtime_event in event_manager.active_events:
		if String(runtime_event.get("category", "")) == EventManager.CATEGORY_URGENT:
			runtime_event["deadline_phase"] = "opening"
			runtime_event["deadline_remaining_seconds"] = URGENT_DEADLINE_SECONDS
			return

func _refresh_problem_tabs() -> void:
	if hud != null and is_instance_valid(hud):
		hud.update_problem_tabs(event_manager.get_active_events())

func _mark_saved_events_as_used() -> void:
	for scheduled_event in event_manager.scheduled_events:
		event_database.mark_event_used(String(scheduled_event.get("event_id", "")))
	for runtime_event in event_manager.active_events:
		event_database.mark_event_used(String(runtime_event.get("event_id", "")))
	for runtime_event in event_manager.resolved_events:
		event_database.mark_event_used(String(runtime_event.get("event_id", "")))
	for runtime_event in event_manager.expired_events:
		event_database.mark_event_used(String(runtime_event.get("event_id", "")))

func _format_countdown(seconds: float) -> String:
	var total_seconds := maxi(0, ceili(seconds))
	return "%02d:%02d" % [floori(float(total_seconds) / 60.0), total_seconds % 60]

func _close_current_problem() -> void:
	if _current_problem_popup != null and is_instance_valid(_current_problem_popup):
		_current_problem_popup.queue_free()
	_current_problem_popup = null
	_current_problem_id = ""
	_current_problem_runtime_event = {}
	time_manager.set_challenge_active(false)
	hud.set_problem_mode(false)
	_refresh_problem_tabs()

func _on_problem_close_requested() -> void:
	if _current_problem_popup == null:
		return
	_current_problem_runtime_event["draft_strokes"] = _current_problem_popup.export_draft()
	_current_problem_runtime_event["draft_answer"] = _current_problem_popup.answer_input.text
	if String(_current_problem_runtime_event.get("deadline_phase", "")) == "solving":
		_current_problem_runtime_event["deadline_phase"] = "opening"
	_close_current_problem()

func _on_menu_requested() -> void:
	if not _placement_area.is_empty():
		_cancel_placement()
	if not _current_problem_id.is_empty() or return_dialog.visible or pause_menu.visible or _modal != null or city.outcome != "playing":
		return
	hud.close_panels()
	time_manager.hold("menu")
	pause_menu.open_menu()

func _on_resume_requested() -> void:
	pause_menu.close_menu()
	time_manager.release("menu")

func _on_panels_changed(is_open: bool) -> void:
	if is_open:
		time_manager.hold("panel")
	else:
		time_manager.release("panel")

func _on_exit_requested() -> void:
	if return_dialog.visible:
		return
	return_dialog.popup_centered(Vector2i(520, 180))

func _on_save_requested() -> void:
	if _modal != null:
		return
	_show_save_slots()

func _on_return_canceled() -> void:
	return_dialog.hide()
	pause_menu.exit_button.grab_focus()

func _on_return_confirmed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

func _on_game_day(day: int, month: int, year: int) -> void:
	if city.outcome == "playing":
		city.advance_day(GameRules.date_index(day, month, year))

func _on_game_month(_month: int, _year: int) -> void:
	city.advance_month()

func _invest(area: String, amount: float) -> void:
	var error := city.invest(area, amount)
	hud.show_notice(tr(error) if not error.is_empty() else tr("Investimento aplicado em %s.") % tr(GameRules.AREA_NAMES[area]))

func _construct(area: String) -> void:
	_begin_placement(area)

func _place_building(lot: Dictionary) -> void:
	if _placement_area.is_empty():
		return
	var index := GameRules.date_index(time_manager.current_day, time_manager.current_month, time_manager.current_year)
	var area := _placement_area
	var error := city.place_home(lot) if area == "home" else city.construct(area, index, lot)
	if not error.is_empty():
		_placement_text.text = tr(error) + " · " + tr("Escolha outro lote ou cancele.")
		return
	_cancel_placement()
	hud.show_notice(tr("Moradia construída. A posição foi registrada na cidade.") if area == "home" else tr("Obra iniciada: %s. Conclusão em 20 dias.") % tr(GameRules.BUILDING_NAMES[area]))

func _on_building_completed(project: Dictionary) -> void:
	hud.show_notice(tr("Obra concluída: %s. Serviços e reputação atualizados.") % tr(GameRules.BUILDING_NAMES[project.area]))

func _skip_to_next() -> void:
	if _modal != null or pause_menu.visible or not _current_problem_id.is_empty() or city.outcome != "playing":
		return
	hud.close_panels()
	if time_manager.paused:
		hud.show_notice(tr("Retome o tempo antes de avançar até uma ocorrência."))
		return
	time_manager.skip_until_next_event(func(): return event_manager.has_active_event() or city.outcome != "playing")
	if event_manager.has_active_event() and _modal == null:
		open_problem(String(event_manager.active_events[0].event_id))

func _dialog(title: String, width: float = 800.0) -> VBoxContainer:
	time_manager.hold("dialog")
	hud.set_problem_mode(true)
	var dialog := UIFactory.dialog(problem_layer, title, width)
	_modal = dialog.overlay
	return dialog.content

func _close_dialog() -> void:
	if is_instance_valid(_modal):
		_modal.queue_free()
	_modal = null
	time_manager.release("dialog")
	hud.set_problem_mode(false)

func _show_briefing() -> void:
	var column := _dialog(tr("Sua gestão começa agora"), 900)
	column.add_child(UIFactory.label(tr("Administre a cidade por quatro anos e alcance pelo menos 50% de reputação para a reeleição. Complete o segundo mandato para concluir a campanha.")))
	column.add_child(UIFactory.label(tr("Resolva problemas pela barra lateral, confira as explicações e invista em serviços ou obras pelo botão de dinheiro. Obras custam R$ 35.000 e levam 20 dias.")))
	column.add_child(UIFactory.label(tr("Abaixo de 10% de reputação por três meses, ou ao chegar a zero, ocorre impeachment. Os valores são regras desta simulação.")))
	column.add_child(UIFactory.label(tr("Use as velocidades ou avance até a próxima ocorrência. Espaço pausa; Esc abre o menu. Problemas, painéis e menus pausam o calendário e os prazos."), 22))
	column.add_child(UIFactory.button(tr("Iniciar mandato"), _close_dialog))

func _show_answer_feedback(definition: Dictionary, correct: bool) -> void:
	if city.outcome != "playing":
		return
	SettingsService.play_feedback(correct)
	var column := _dialog(tr("Resposta correta") if correct else tr("Vamos conferir o resultado"), 920)
	column.add_child(UIFactory.label(tr(String(definition.get("explanation", ""))), 25))
	var result: Dictionary = city.last_result
	column.add_child(UIFactory.label(tr("Consequências: R$ %+.0f · reputação %+.1f pontos.") % [float(result.get("funds", 0)), float(result.get("reputation", 0))]))
	column.add_child(UIFactory.button(tr("Continuar gestão"), _close_dialog))

func _on_campaign_event(kind: String) -> void:
	if _modal != null:
		_close_dialog()
	if kind != "reelected":
		time_manager.hold("ended")
		event_manager.set_event_trigger_enabled(false)
		if not _current_problem_id.is_empty():
			_close_current_problem()
	var titles := {"reelected": "Você foi reeleito", "completed": "Dois mandatos concluídos", "not_reelected": "A reeleição não foi alcançada", "impeachment": "Mandato encerrado por impeachment"}
	var column := _dialog(tr(titles.get(kind, "Fim de mandato")), 940)
	column.add_child(UIFactory.label(tr("Cidade: %s\nMeses de gestão: %d · Reputação: %.1f%% · Saldo: R$ %.0f\nProblemas: %d corretos de %d respondidos · Obras concluídas: %d") % [city.city_name, city.completed_months, city.reputation, city.funds, city.correct_count, city.solved_count, city.buildings.size()]))
	if kind == "reelected":
		column.add_child(UIFactory.label(tr("A população aprovou a continuidade da gestão. Seu próximo objetivo é completar os quatro anos do segundo mandato.")))
		column.add_child(UIFactory.button(tr("Iniciar segundo mandato"), _close_dialog))
	else:
		column.add_child(UIFactory.label(tr("Os indicadores apresentados resultam das regras da simulação e das suas decisões durante a partida."), 22))
		column.add_child(UIFactory.button(tr("Salvar resultado"), func():
			_close_dialog()
			_show_save_slots(true)))
		column.add_child(UIFactory.button(tr("Voltar ao menu"), _on_return_confirmed))

func _show_save_slots(return_to_ending: bool = false) -> void:
	var column := _dialog(tr("Escolha um dos três salvamentos"), 900)
	var status := UIFactory.label(tr("Arquivos existentes só serão substituídos após confirmação."), 22)
	column.add_child(status)
	for slot in range(1, SaveManager.SLOT_COUNT + 1):
		var data := SaveManager.read_slot(slot)
		var description := tr("Vazio") if data.is_empty() else String(data.get("city", {}).get("city_name", "Cidade")) + " · " + String(data.get("date", ""))
		var button := Button.new()
		button.custom_minimum_size.y = 64
		button.text = tr("Slot %d · %s") % [slot, description]
		button.tooltip_text = button.text
		column.add_child(button)
		button.pressed.connect(func():
			if not data.is_empty() and not button.has_meta("confirmed"):
				button.set_meta("confirmed", true)
				button.text = tr("Confirmar substituição do slot %d") % slot
				return
			if SaveManager.save_game(time_manager, event_manager, slot, event_database, city):
				status.text = tr("Partida salva no slot %d.") % slot
				button.text = tr("Slot %d · Salvo") % slot
				button.disabled = true
			else:
				status.text = tr(SaveManager.last_error))
	column.add_child(UIFactory.button(tr("Voltar"), func():
		_close_dialog()
		if return_to_ending:
			_on_campaign_event(city.outcome)))

func _notification(what: int) -> void:
	if not is_node_ready():
		return
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and bool(SettingsService.values.pause_unfocused):
		time_manager.hold("inactive")
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN:
		time_manager.release("inactive")

func _create_placement_bar() -> void:
	_placement_bar = PanelContainer.new()
	_placement_bar.name = "PlacementBar"
	hud.add_child(_placement_bar)
	_placement_bar.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	_placement_bar.offset_left = -590
	_placement_bar.offset_right = 590
	_placement_bar.offset_top = -290
	_placement_bar.offset_bottom = -184
	var row := HBoxContainer.new()
	row.name = "Content"
	row.add_theme_constant_override("separation", 18)
	_placement_bar.add_child(row)
	_placement_text = UIFactory.label("", 23)
	row.add_child(_placement_text)
	var cancel := UIFactory.button(tr("Cancelar"), _cancel_placement)
	cancel.name = "CancelPlacement"
	row.add_child(cancel)
	_placement_bar.hide()

func _begin_placement(area: String) -> void:
	if city.outcome != "playing" or _modal != null or pause_menu.visible or not _current_problem_id.is_empty():
		return
	if area == "home" and city.housing_requests() <= 0:
		hud.show_notice(tr("O crescimento populacional liberará novas moradias."))
		return
	_placement_area = area
	hud.close_panels()
	time_manager.hold("placement")
	$Camera2D.build_mode = true
	visuals.begin_placement(area)
	var title: String = tr("Nova moradia") if area == "home" else tr(GameRules.BUILDING_NAMES[area])
	_placement_text.text = title + " · " + tr("Clique em um lote livre. Verde: disponível · Vermelho: bloqueado. Botão do meio: mover mapa.")
	_placement_bar.show()

func _cancel_placement() -> void:
	_placement_area = ""
	visuals.end_placement()
	$Camera2D.build_mode = false
	_placement_bar.hide()
	time_manager.release("placement")
