extends Node

const SLOT_COUNT := 3
const SAVE_DIR := "user://saves"
var pending_save: Dictionary = {}

func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SAVE_DIR))

func slot_path(slot: int) -> String:
	return "%s/slot_%d.json" % [SAVE_DIR, slot]

func read_slot(slot: int) -> Dictionary:
	if slot < 1 or slot > SLOT_COUNT:
		return {}
	var file := FileAccess.open(slot_path(slot), FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	return parsed if parsed is Dictionary else {}

func has_any_save() -> bool:
	for slot in range(1, SLOT_COUNT + 1):
		if not read_slot(slot).is_empty():
			return true
	return false

func get_next_slot() -> int:
	for slot in range(1, SLOT_COUNT + 1):
		if read_slot(slot).is_empty():
			return slot
	var oldest_slot := 1
	var oldest_date := "9999"
	for slot in range(1, SLOT_COUNT + 1):
		var date := String(read_slot(slot).get("date", ""))
		if date < oldest_date:
			oldest_date = date
			oldest_slot = slot
	return oldest_slot

func save_game(time_manager: Node, event_manager: Node, slot: int = 1, event_database: Node = null) -> bool:
	if slot < 1 or slot > SLOT_COUNT:
		return false
	var data := {"date": Time.get_datetime_string_from_system(), "time": time_manager.get_save_data(), "events": event_manager.get_save_data()}
	if event_database != null and event_database.has_method("get_usage_save_data"):
		data["event_database_usage"] = event_database.get_usage_save_data()
	var file := FileAccess.open(slot_path(slot), FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(data))
	return true

func load_slot(slot: int) -> bool:
	pending_save = read_slot(slot)
	return not pending_save.is_empty()

func consume_pending_save() -> Dictionary:
	var result := pending_save
	pending_save = {}
	return result

func delete_slot(slot: int) -> void:
	if slot >= 1 and slot <= SLOT_COUNT and FileAccess.file_exists(slot_path(slot)):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(slot_path(slot)))
