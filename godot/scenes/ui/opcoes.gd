extends Control

const SETTINGS_PATH := "user://settings.cfg"

@onready var volume_slider: HSlider = $Center/Panel/Margin/Content/VolumeSlider
@onready var volume_value: Label = $Center/Panel/Margin/Content/VolumeHeading/VolumeValue
@onready var fullscreen_checkbox: CheckBox = $Center/Panel/Margin/Content/FullscreenCheckBox

var _master_bus := -1

func _ready() -> void:
	_master_bus = AudioServer.get_bus_index("Master")
	var config := ConfigFile.new()
	config.load(SETTINGS_PATH)
	var volume := float(config.get_value("audio", "volume", 100.0))
	volume_slider.value = volume
	volume_slider.editable = _master_bus >= 0
	_apply_volume(volume)
	var fullscreen := bool(config.get_value("display", "fullscreen", false))
	fullscreen_checkbox.button_pressed = fullscreen
	_apply_fullscreen(fullscreen)
	volume_slider.value_changed.connect(_on_volume_changed)
	fullscreen_checkbox.toggled.connect(_on_fullscreen_toggled)
	$Center/Panel/Margin/Content/BackButton.pressed.connect(_go_back)
	$Center/Panel/Margin/Content/BackButton.grab_focus()

func _on_volume_changed(value: float) -> void:
	_apply_volume(value)
	_save_settings(value, fullscreen_checkbox.button_pressed)

func _apply_volume(value: float) -> void:
	volume_value.text = "%d%%" % roundi(value)
	if _master_bus >= 0:
		AudioServer.set_bus_volume_db(_master_bus, linear_to_db(maxf(value / 100.0, 0.0001)))
		AudioServer.set_bus_mute(_master_bus, value <= 0.0)

func _on_fullscreen_toggled(enabled: bool) -> void:
	_apply_fullscreen(enabled)
	_save_settings(volume_slider.value, enabled)

func _apply_fullscreen(enabled: bool) -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if enabled else DisplayServer.WINDOW_MODE_WINDOWED)

func _save_settings(volume: float, fullscreen: bool) -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "volume", volume)
	config.set_value("display", "fullscreen", fullscreen)
	config.save(SETTINGS_PATH)

func _go_back() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
