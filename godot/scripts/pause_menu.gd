class_name GamePauseMenu
extends Control

const CREDITS_SCENE := preload("res://scenes/ui/creditos.tscn")

signal resume_requested()
signal exit_requested()
signal save_requested()

@onready var resume_button: Button = %ResumeButton
@onready var exit_button: Button = %ExitButton
@onready var options_button: Button = %OptionsButton
@onready var credits_button: Button = %CreditsButton
@onready var saves_button: Button = %SavesButton
@onready var brand_logo: TextureRect = %BrandLogo

@onready var _main_panel: PanelContainer = %MainPanel
@onready var _credits_panel: PanelContainer = %CreditsPanel
@onready var _credits_back_button: Button = %CreditsBackButton

var detail_visible: bool = false
var _settings_dialog: Control
var _credits_popup: Control


func _ready() -> void:
	_crop_brand_logo()
	resume_button.pressed.connect(func() -> void: resume_requested.emit())
	saves_button.pressed.connect(func() -> void: save_requested.emit())
	exit_button.pressed.connect(func() -> void: exit_requested.emit())
	options_button.pressed.connect(_open_options)
	credits_button.pressed.connect(_open_credits)
	_credits_back_button.pressed.connect(_show_main_menu)
	close_menu()


func _crop_brand_logo() -> void:
	if brand_logo == null or brand_logo.texture == null or brand_logo.texture is AtlasTexture:
		return
	var img := brand_logo.texture.get_image()
	if img != null:
		var used := img.get_used_rect()
		if used.size.x > 0 and used.size.y > 0:
			var atlas := AtlasTexture.new()
			atlas.atlas = brand_logo.texture
			atlas.region = Rect2(used.position, used.size)
			brand_logo.texture = atlas


func open_menu() -> void:
	show()
	_show_main_menu()


func close_menu() -> void:
	if is_instance_valid(_settings_dialog):
		_settings_dialog.queue_free()
	_settings_dialog = null
	if is_instance_valid(_credits_popup):
		_credits_popup.queue_free()
	_credits_popup = null
	hide()
	detail_visible = false
	_main_panel.show()
	_credits_panel.hide()


func back_or_resume() -> void:
	if is_instance_valid(_settings_dialog):
		_settings_dialog.queue_free()
		_settings_dialog = null
		_show_main_menu()
		return
	if is_instance_valid(_credits_popup):
		_credits_popup.queue_free()
		_credits_popup = null
		_show_main_menu()
		return
	if detail_visible:
		_show_main_menu()
	else:
		resume_requested.emit()


func _show_main_menu() -> void:
	if is_instance_valid(_credits_popup):
		_credits_popup.queue_free()
	_credits_popup = null
	detail_visible = false
	_main_panel.show()
	_credits_panel.hide()
	if is_visible_in_tree():
		resume_button.grab_focus()


func _open_options() -> void:
	if is_instance_valid(_settings_dialog):
		return
	detail_visible = true
	_main_panel.hide()
	_credits_panel.hide()
	var dialog := UIFactory.dialog(self, tr("Opções"), 880)
	_settings_dialog = dialog.overlay
	SettingsService.build_options(dialog.content)
	dialog.content.add_child(UIFactory.button(tr("Voltar"), back_or_resume))


func _open_credits() -> void:
	if is_instance_valid(_credits_popup):
		return
	detail_visible = true
	_main_panel.hide()
	_credits_panel.hide()
	var popup := CREDITS_SCENE.instantiate() as Control
	popup.set("popup_mode", true)
	popup.theme = SettingsService.game_theme
	popup.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	popup.connect("close_requested", _show_main_menu)
	_credits_popup = popup
	add_child(popup)
