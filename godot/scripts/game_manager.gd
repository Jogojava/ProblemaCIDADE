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

var _was_paused_before_menu := false
var _was_paused_before_panel := false
var _current_problem_id := ""
var _current_problem_popup: ProblemTemplate
var _current_problem_runtime_event: Dictionary = {}

func _ready() -> void:
	return_dialog.theme = hud.theme
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
		time_manager.load_save_data(saved_game.get("time", {}))
		event_manager.load_save_data(saved_game.get("events", {}))
		event_database.load_usage_save_data(saved_game.get("event_database_usage", {}))
		_mark_saved_events_as_used()
	event_manager.enforce_one_urgent_per_month()
	event_manager.start_system(time_manager.current_month, time_manager.current_year)
	_restore_urgent_deadlines()
	_refresh_problem_tabs()

func _process(delta: float) -> void:
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

	_refresh_problem_tabs()

func _input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	if _current_problem_popup != null and is_instance_valid(_current_problem_popup):
		if event.keycode == KEY_ESCAPE or event.keycode == KEY_SPACE:
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
	if not _current_problem_id.is_empty():
		return
	var runtime_event := _find_active_event(event_id)
	if runtime_event.is_empty():
		return
	var problem_data := event_database.get_event(event_id)
	if problem_data.is_empty():
		return

	_current_problem_id = event_id
	_current_problem_runtime_event = runtime_event
	if String(runtime_event.get("category", "")) == EventManager.CATEGORY_URGENT:
		if float(runtime_event.get("deadline_remaining_seconds", URGENT_DEADLINE_SECONDS)) <= 0.0:
			event_manager.expire_event_immediately(event_id)
			return
		runtime_event["deadline_phase"] = "solving"
		runtime_event["deadline_remaining_seconds"] = URGENT_DEADLINE_SECONDS

	time_manager.set_challenge_active(true)
	hud.set_problem_mode(true)
	var popup := PROBLEM_SCENE.instantiate() as ProblemTemplate
	popup.theme = hud.theme
	_current_problem_popup = popup
	problem_layer.add_child(popup)
	popup.answer_selected.connect(_on_problem_answer_selected)
	var payload: Dictionary = problem_data.get("payload", {})
	var input_placeholder := String(payload.get("placeholder", "Digite sua resposta"))
	var problem_image := _resolve_problem_image(problem_data.get("image", null))
	await popup.configure(
		String(problem_data.get("title", "Problema")),
		String(problem_data.get("description", "")),
		problem_image,
		payload.get("options", []),
		bool(problem_data.get("allow_board", true)),
		String(problem_data.get("interaction_type", EventDatabase.INTERACTION_CHOICE)),
		input_placeholder,
		String(problem_data.get("category", EventDatabase.CATEGORY_COMMON))
	)

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
		if deadline_is_active:
			runtime_event["deadline_phase"] = "queued"
			continue
		time_manager.set_speed(TimeManager.Speed.NORMAL)
		var phase := String(runtime_event.get("deadline_phase", "opening"))
		if phase != "solving":
			phase = "opening"
			runtime_event["deadline_remaining_seconds"] = URGENT_DEADLINE_SECONDS
		elif not runtime_event.has("deadline_remaining_seconds"):
			runtime_event["deadline_remaining_seconds"] = URGENT_DEADLINE_SECONDS
		runtime_event["deadline_phase"] = phase
		deadline_is_active = true

func _on_event_triggered(runtime_event: Dictionary) -> void:
	if String(runtime_event.get("category", "")) == EventManager.CATEGORY_URGENT:
		time_manager.set_speed(TimeManager.Speed.NORMAL)
		runtime_event["deadline_phase"] = "queued"
		runtime_event["deadline_remaining_seconds"] = URGENT_DEADLINE_SECONDS
		_activate_next_urgent_deadline()
	_refresh_problem_tabs()

func _on_event_resolved(runtime_event: Dictionary) -> void:
	if String(runtime_event.get("category", "")) == EventManager.CATEGORY_URGENT:
		_activate_next_urgent_deadline()
	_refresh_problem_tabs()

func _on_event_expired(runtime_event: Dictionary) -> void:
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

func _on_menu_requested() -> void:
	if not _current_problem_id.is_empty() or return_dialog.visible or pause_menu.visible:
		return
	hud.close_panels()
	_was_paused_before_menu = time_manager.paused
	time_manager.pause_game()
	pause_menu.open_menu()

func _on_resume_requested() -> void:
	pause_menu.close_menu()
	if not _was_paused_before_menu:
		time_manager.resume_game()

func _on_panels_changed(is_open: bool) -> void:
	if is_open:
		_was_paused_before_panel = time_manager.paused
		time_manager.pause_game()
	elif not _was_paused_before_panel:
		time_manager.resume_game()

func _on_exit_requested() -> void:
	if return_dialog.visible:
		return
	return_dialog.popup_centered(Vector2i(520, 180))

func _on_save_requested() -> void:
	var slot := SaveManager.get_next_slot()
	if SaveManager.save_game(time_manager, event_manager, slot, event_database):
		pause_menu.saves_button.text = "Salvo no slot %d" % slot
		pause_menu.saves_button.tooltip_text = "Calendário e problemas salvos."

func _on_return_canceled() -> void:
	return_dialog.hide()
	pause_menu.exit_button.grab_focus()

func _on_return_confirmed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
