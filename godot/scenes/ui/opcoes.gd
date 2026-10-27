extends Control

signal close_requested()

var popup_mode := false

func _ready() -> void:
	for child in $Center.get_children():
		child.queue_free()
	if popup_mode:
		$Background.hide()
	var dialog := UIFactory.dialog(self, tr("Opções"), 880)
	var column: VBoxContainer = dialog.content
	SettingsService.build_options(column)
	column.add_child(UIFactory.button(tr("Voltar"), _go_back))

func _go_back() -> void:
	if popup_mode:
		close_requested.emit()
	else:
		get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
