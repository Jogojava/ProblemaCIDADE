extends Control

func _ready() -> void:
	$Menu/VBoxContainer/jogar.pressed.connect(_on_btjogar_pressed)
	$Menu/VBoxContainer/continuar.pressed.connect(_on_btjogar_pressed)

func _process(delta: float) -> void:
	pass

func _on_btjogar_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game/Game.tscn")
