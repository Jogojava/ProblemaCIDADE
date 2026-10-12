extends Control

func _ready() -> void:
	for slot in range(1, SaveManager.SLOT_COUNT + 1):
		var row: HBoxContainer = $Center/Panel/Margin/Content/Slots.get_node("Slot%d" % slot)
		var data := SaveManager.read_slot(slot)
		row.get_node("Info").text = "Slot %d • %s" % [slot, _slot_description(data)]
		row.get_node("LoadButton").disabled = data.is_empty()
		row.get_node("DeleteButton").disabled = data.is_empty()
		row.get_node("LoadButton").pressed.connect(_load_slot.bind(slot))
		row.get_node("DeleteButton").pressed.connect(_delete_slot.bind(slot))
	$Center/Panel/Margin/Content/BackButton.pressed.connect(_go_back)
	$Center/Panel/Margin/Content/BackButton.grab_focus()

func _slot_description(data: Dictionary) -> String:
	if data.is_empty():
		return "Vazio"
	var time_data: Dictionary = data.get("time", {})
	return "Dia %d / Mês %d / Ano %d — %s" % [int(time_data.get("current_day", 1)), int(time_data.get("current_month", 1)), int(time_data.get("current_year", 1)), String(data.get("date", ""))]

func _load_slot(slot: int) -> void:
	if SaveManager.load_slot(slot):
		get_tree().change_scene_to_file("res://scenes/game/Game.tscn")

func _delete_slot(slot: int) -> void:
	SaveManager.delete_slot(slot)
	get_tree().reload_current_scene()

func _go_back() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
