extends Control

func _ready() -> void:
	for slot in range(1, SaveManager.SLOT_COUNT + 1):
		var row: HBoxContainer = $Center/Panel/Margin/Content/Slots.get_node("Slot%d" % slot)
		var data := SaveManager.read_slot(slot)
		row.get_node("Info").text = "Slot %d • %s" % [slot, _slot_description(data)]
		row.get_node("Info").autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		row.get_node("Info").custom_minimum_size.x = 440
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
	var city: Dictionary = data.get("city", {})
	return "%s\n%s\n%s" % [String(city.get("city_name", "Cidade")), tr("Dia %d / Mês %d / Ano %d") % [int(time_data.get("current_day", 1)), int(time_data.get("current_month", 1)), int(time_data.get("current_year", 1))], tr("Reputação: %.0f%% · Saldo: R$ %.0f") % [float(city.get("reputation", 0)), float(city.get("funds", 0))]]

func _load_slot(slot: int) -> void:
	if SaveManager.load_slot(slot):
		get_tree().change_scene_to_file("res://scenes/game/Game.tscn")

func _delete_slot(slot: int) -> void:
	if has_node("GameDialog"):
		return
	var dialog := UIFactory.dialog(self, tr("Excluir salvamento?"), 780)
	dialog.content.add_child(UIFactory.label(tr("O slot %d e seu backup serão removidos.") % slot))
	dialog.content.add_child(UIFactory.button(tr("Confirmar exclusão"), func():
		SaveManager.delete_slot(slot)
		get_tree().reload_current_scene()))
	dialog.content.add_child(UIFactory.button(tr("Cancelar"), func(): dialog.overlay.queue_free()))

func _go_back() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
