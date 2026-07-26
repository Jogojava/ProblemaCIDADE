extends Control

func _ready() -> void:
	$Menu/VBoxContainer/jogar.pressed.connect(_on_btjogar_pressed)
	$Menu/VBoxContainer/continuar.pressed.connect(_on_btcontinuar_pressed)
	$Menu/VBoxContainer/opcoes.pressed.connect(_on_btopcoes_pressed)
	$Menu/VBoxContainer/creditos.pressed.connect(_on_btcreditos_pressed)

func _process(delta: float) -> void:
	pass

func _on_btjogar_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game/Game.tscn")

func _on_btcontinuar_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/carregar.tscn")
	
func _on_btopcoes_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/opcoes.tscn")
	
func _on_btcreditos_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/creditos.tscn")
