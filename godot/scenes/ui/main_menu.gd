extends Control

@onready var quit_confirmation: ConfirmationDialog = $QuitConfirmation

func _ready() -> void:
	$SoundButton.pressed.connect(_on_sound_pressed)
	$ExitButton.pressed.connect(_on_exit_pressed)
	quit_confirmation.confirmed.connect(func() -> void: get_tree().quit())
	quit_confirmation.ok_button_text = "Sair"
	quit_confirmation.cancel_button_text = "Continuar jogando"
	_sync_sound_button()
	$Menu/VBoxContainer/jogar.pressed.connect(_on_btjogar_pressed)
	$Menu/VBoxContainer/continuar.pressed.connect(_on_btcontinuar_pressed)
	$Menu/VBoxContainer/opcoes.pressed.connect(_on_btopcoes_pressed)
	$Menu/VBoxContainer/creditos.pressed.connect(_on_btcreditos_pressed)
	$Menu/VBoxContainer/continuar.disabled = false
	$Menu/VBoxContainer/continuar.text = "Partidas salvas"
	$Menu/VBoxContainer/continuar.tooltip_text = "Abrir slots de salvamento."

func _on_exit_pressed() -> void:
	quit_confirmation.popup_centered()

func _on_btjogar_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game/Game.tscn")

func _on_btcontinuar_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/carregar.tscn")
	
func _on_btopcoes_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/opcoes.tscn")
	
func _on_btcreditos_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/creditos.tscn")

func _on_sound_pressed() -> void:
	var master := AudioServer.get_bus_index("Master")
	if master >= 0:
		AudioServer.set_bus_mute(master, not AudioServer.is_bus_mute(master))
	_sync_sound_button()

func _sync_sound_button() -> void:
	var master := AudioServer.get_bus_index("Master")
	var muted := master >= 0 and AudioServer.is_bus_mute(master)
	$SoundButton.text = "Som: desligado" if muted else "Som: ligado"
