extends Node

@onready var event_database = $EventDatabase
@onready var event_manager = $EventManager

@onready var time_manager: TimeManager = $TimeManager
@onready var hud: GameHUD = $CanvasLayer/HUD
@onready var return_dialog: ConfirmationDialog = $ReturnToMenuDialog
@onready var pause_menu: GamePauseMenu = $CanvasLayer/PauseMenu

var _was_paused_before_menu := false
var _was_paused_before_panel := false

func _ready() -> void:
	return_dialog.theme = hud.theme
	hud.bind_time_manager(time_manager)
	hud.menu_requested.connect(_on_menu_requested)
	hud.panels_changed.connect(_on_panels_changed)
	pause_menu.resume_requested.connect(_on_resume_requested)
	pause_menu.exit_requested.connect(_on_exit_requested)
	return_dialog.confirmed.connect(_on_return_confirmed)
	return_dialog.canceled.connect(_on_return_canceled)

func _input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
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

func _on_menu_requested() -> void:
	if return_dialog.visible or pause_menu.visible:
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

func _on_return_canceled() -> void:
	return_dialog.hide()
	pause_menu.exit_button.grab_focus()

func _on_return_confirmed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

# Existing upstream event test helpers; scheduling is unchanged.
func _register_test_events() -> void:
	event_database.register_event("teste_comum_01", {
		"title": "Buraco na rua",
		"description": "Moradores pedem solução.",
		"category": "common",
		"interaction_type": "choice",
		"availability_duration_days": 5,
		"payload": {
			"options": [
				{"id": "resolver", "text": "Mandar equipe"},
				{"id": "adiar", "text": "Adiar"}
			]
		}
	})

func _connect_event_signals() -> void:
	event_manager.event_scheduled.connect(_on_event_scheduled)
	event_manager.event_triggered.connect(_on_event_triggered)
	event_manager.event_expired.connect(_on_event_expired)

func _on_event_scheduled(event_id: String, category: String, day: int, month: int, year: int) -> void:
	print("Agendado: ", event_id, " | ", category, " | ", day, "/", month, "/", year)

func _on_event_triggered(runtime_event: Dictionary) -> void:
	print("Disparado: ", runtime_event)

func _on_event_expired(runtime_event: Dictionary) -> void:
	print("Expirado: ", runtime_event)
