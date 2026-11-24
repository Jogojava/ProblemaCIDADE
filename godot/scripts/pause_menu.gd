class_name GamePauseMenu
extends Control

signal resume_requested()
signal exit_requested()
signal save_requested()

@onready var resume_button: Button = %ResumeButton
@onready var exit_button: Button = %ExitButton
@onready var options_button: Button = %OptionsButton
@onready var credits_button: Button = %CreditsButton
@onready var saves_button: Button = %SavesButton

@onready var _main_panel: PanelContainer = %MainPanel
@onready var _credits_panel: PanelContainer = %CreditsPanel
@onready var _credits_back_button: Button = %CreditsBackButton

var detail_visible: bool = false
var _settings_dialog: Control


func _ready() -> void:
	resume_button.pressed.connect(func() -> void: resume_requested.emit())
	saves_button.pressed.connect(func() -> void: save_requested.emit())
	exit_button.pressed.connect(func() -> void: exit_requested.emit())
	options_button.pressed.connect(_open_options)
	credits_button.pressed.connect(_open_credits)
	_credits_back_button.pressed.connect(_show_main_menu)
	close_menu()


func open_menu() -> void:
	show()
	_show_main_menu()


func close_menu() -> void:
	if is_instance_valid(_settings_dialog):
		_settings_dialog.queue_free()
	_settings_dialog = null
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
	if detail_visible:
		_show_main_menu()
	else:
		resume_requested.emit()


func _show_main_menu() -> void:
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
	detail_visible = true
	_main_panel.hide()
	_credits_panel.show()
	_credits_back_button.grab_focus()
