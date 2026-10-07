class_name GamePauseMenu
extends Control

signal resume_requested()
signal exit_requested()

@onready var resume_button: Button = %ResumeButton
@onready var exit_button: Button = %ExitButton
@onready var options_button: Button = %OptionsButton
@onready var credits_button: Button = %CreditsButton
@onready var saves_button: Button = %SavesButton

@onready var _main_panel: PanelContainer = %MainPanel
@onready var _options_panel: PanelContainer = %OptionsPanel
@onready var _credits_panel: PanelContainer = %CreditsPanel
@onready var _volume_slider: HSlider = %VolumeSlider
@onready var _volume_value: Label = %VolumeValue
@onready var _fullscreen_checkbox: CheckBox = %FullscreenCheckBox
@onready var _options_back_button: Button = %OptionsBackButton
@onready var _credits_back_button: Button = %CreditsBackButton

var detail_visible: bool = false
var _master_bus_index: int = -1


func _ready() -> void:
	resume_button.pressed.connect(func() -> void: resume_requested.emit())
	exit_button.pressed.connect(func() -> void: exit_requested.emit())
	options_button.pressed.connect(_open_options)
	credits_button.pressed.connect(_open_credits)
	_options_back_button.pressed.connect(_show_main_menu)
	_credits_back_button.pressed.connect(_show_main_menu)
	_volume_slider.value_changed.connect(_on_volume_changed)
	_fullscreen_checkbox.toggled.connect(_on_fullscreen_toggled)
	close_menu()


func open_menu() -> void:
	show()
	_show_main_menu()


func close_menu() -> void:
	hide()
	detail_visible = false
	_main_panel.show()
	_options_panel.hide()
	_credits_panel.hide()


func back_or_resume() -> void:
	if detail_visible:
		_show_main_menu()
	else:
		resume_requested.emit()


func _show_main_menu() -> void:
	detail_visible = false
	_main_panel.show()
	_options_panel.hide()
	_credits_panel.hide()
	if is_visible_in_tree():
		resume_button.grab_focus()


func _open_options() -> void:
	_sync_options()
	detail_visible = true
	_main_panel.hide()
	_credits_panel.hide()
	_options_panel.show()
	if _volume_slider.editable:
		_volume_slider.grab_focus()
	else:
		_fullscreen_checkbox.grab_focus()


func _open_credits() -> void:
	detail_visible = true
	_main_panel.hide()
	_options_panel.hide()
	_credits_panel.show()
	_credits_back_button.grab_focus()


func _sync_options() -> void:
	_master_bus_index = AudioServer.get_bus_index("Master")
	_volume_slider.editable = _master_bus_index >= 0
	if _master_bus_index >= 0:
		var volume := db_to_linear(AudioServer.get_bus_volume_db(_master_bus_index)) * 100.0
		if AudioServer.is_bus_mute(_master_bus_index):
			volume = 0.0
		_volume_slider.set_value_no_signal(clampf(volume, 0.0, 100.0))
		_volume_value.text = "%d%%" % roundi(_volume_slider.value)
	else:
		_volume_value.text = "Indisponível"
	var window_mode := DisplayServer.window_get_mode()
	_fullscreen_checkbox.set_pressed_no_signal(
		window_mode == DisplayServer.WINDOW_MODE_FULLSCREEN
		or window_mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
	)


func _on_volume_changed(value: float) -> void:
	_volume_value.text = "%d%%" % roundi(value)
	if _master_bus_index < 0:
		return
	AudioServer.set_bus_volume_db(_master_bus_index, linear_to_db(maxf(value / 100.0, 0.0001)))
	AudioServer.set_bus_mute(_master_bus_index, value <= 0.0)


func _on_fullscreen_toggled(enabled: bool) -> void:
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_FULLSCREEN if enabled else DisplayServer.WINDOW_MODE_WINDOWED
	)
