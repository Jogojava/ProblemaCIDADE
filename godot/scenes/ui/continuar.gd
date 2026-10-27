extends Control

signal close_requested()

var popup_mode := false

func _ready() -> void:
	if popup_mode:
		$Background.hide()
		_add_popup_backdrop()
	for slot in range(1, SaveManager.SLOT_COUNT + 1):
		var row: HBoxContainer = $Center/Panel/Margin/Content/Slots.get_node("Slot%d" % slot)
		row.get_node("LoadButton").pressed.connect(_load_slot.bind(slot))
		row.get_node("DeleteButton").pressed.connect(_delete_slot.bind(slot))
	$Center/Panel/Margin/Content/BackButton.pressed.connect(_go_back)
	$Center/Panel/Margin/Content/BackButton.grab_focus()
	_refresh_slots()

func _add_popup_backdrop() -> void:
	var shade := ColorRect.new()
	shade.name = "PopupBackdrop"
	shade.color = Color(0.025, 0.055, 0.075, 0.78)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)
	move_child(shade, 0)

func _refresh_slots() -> void:
	for slot in range(1, SaveManager.SLOT_COUNT + 1):
		var row: HBoxContainer = $Center/Panel/Margin/Content/Slots.get_node("Slot%d" % slot)
		var data := SaveManager.read_slot(slot)
		var info := row.get_node("Info") as Label
		info.text = "Slot %d • %s" % [slot, _slot_description(data)]
		info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		info.custom_minimum_size.x = 440
		row.get_node("LoadButton").disabled = data.is_empty()
		row.get_node("DeleteButton").disabled = data.is_empty()

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
		_refresh_slots()
		dialog.overlay.queue_free()))
	dialog.content.add_child(UIFactory.button(tr("Cancelar"), func(): dialog.overlay.queue_free()))

func _go_back() -> void:
	if popup_mode:
		close_requested.emit()
	else:
		get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
