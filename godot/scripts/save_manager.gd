extends Node

const SLOT_COUNT := 3
const SCHEMA_VERSION := 2
const SAVE_DIR := "user://saves"
var save_dir := SAVE_DIR
var pending_save: Dictionary = {}
var new_game_options := {"name": "Vila Esperança", "difficulty": "medium"}
var active_slot := 0
var last_error := ""
var recovered_backup := false

func _ready() -> void:
	if OS.get_cmdline_user_args().has("--test"):
		save_dir = "user://verification_saves"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(save_dir))

func slot_path(slot: int) -> String:
	return "%s/slot_%d.json" % [save_dir, slot]

func _read_file(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var parser := JSON.new()
	if parser.parse(FileAccess.get_file_as_string(path)) != OK:
		return {}
	var parsed: Variant = parser.data
	if not parsed is Dictionary or not _valid(parsed):
		return {}
	var result: Dictionary = parsed.duplicate(true)
	if int(result.get("schema_version", 1)) == 1:
		result["schema_version"] = SCHEMA_VERSION
		result["migrated_from"] = 1
	return result

func _valid(data: Dictionary) -> bool:
	var version := int(data.get("schema_version", 1))
	if version < 1 or version > SCHEMA_VERSION:
		return false
	if not data.get("time") is Dictionary or not data.get("events") is Dictionary:
		return false
	var calendar: Dictionary = data.time
	for key in ["current_day", "current_month", "current_year"]:
		if not calendar.get(key) is float and not calendar.get(key) is int:
			return false
	if int(calendar.current_day) < 1 or int(calendar.current_day) > 30 or int(calendar.current_month) < 1 or int(calendar.current_month) > 12 or int(calendar.current_year) < 1 or int(calendar.current_year) > 9:
		return false
	for key in ["active_events", "scheduled_events", "resolved_events", "expired_events"]:
		if not data.events.get(key, []) is Array:
			return false
		for item in data.events.get(key, []):
			if not item is Dictionary or not item.get("event_id") is String:
				return false
	if data.has("city"):
		if not data.city is Dictionary:
			return false
		for key in ["funds", "reputation"]:
			var value: Variant = data.city.get(key)
			if not (value is float or value is int) or not is_finite(float(value)):
				return false
		if not data.city.get("indicators", {}) is Dictionary:
			return false
		if not GameRules.DIFFICULTIES.has(String(data.city.get("difficulty", "medium"))):
			return false
		if not ["playing", "completed", "not_reelected", "impeachment"].has(String(data.city.get("outcome", "playing"))):
			return false
		if float(data.city.reputation) < 0 or float(data.city.reputation) > 100:
			return false
		for value in data.city.get("indicators", {}).values():
			if not (value is float or value is int) or not is_finite(float(value)) or float(value) < 0 or float(value) > 100:
				return false
		for key in ["projects", "buildings", "history", "ledger"]:
			if not data.city.get(key, []) is Array:
				return false
			for item in data.city.get(key, []):
				if not item is Dictionary:
					return false
		for project in data.city.get("projects", []) + data.city.get("buildings", []):
			if not GameRules.AREAS.has(String(project.get("area", ""))) or not project.get("due") is float and not project.get("due") is int:
				return false
	return true

func read_slot(slot: int) -> Dictionary:
	if slot < 1 or slot > SLOT_COUNT:
		return {}
	var result := _read_file(slot_path(slot))
	if result.is_empty():
		result = _read_file(slot_path(slot) + ".backup")
	return result

func has_any_save() -> bool:
	for slot in range(1, SLOT_COUNT + 1):
		if not read_slot(slot).is_empty():
			return true
	return false

func get_next_slot() -> int:
	for slot in range(1, SLOT_COUNT + 1):
		if read_slot(slot).is_empty():
			return slot
	return active_slot if active_slot > 0 else 1

func save_game(time_manager: Node, event_manager: Node, slot: int = 1, event_database: Node = null, city: CityState = null) -> bool:
	var data := {"schema_version": SCHEMA_VERSION, "date": Time.get_datetime_string_from_system(), "time": time_manager.get_save_data(), "events": event_manager.get_save_data()}
	if event_database != null:
		data["event_database_usage"] = event_database.get_usage_save_data()
	if city != null:
		data["city"] = city.get_save_data()
	return write_slot(slot, data)

func write_slot(slot: int, data: Dictionary) -> bool:
	last_error = ""
	if slot < 1 or slot > SLOT_COUNT or not _valid(data):
		last_error = "Dados de salvamento inválidos."
		return false
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(save_dir))
	var path := slot_path(slot)
	var temporary := path + ".tmp"
	var file := FileAccess.open(temporary, FileAccess.WRITE)
	if file == null:
		last_error = "Não foi possível gravar o salvamento."
		return false
	file.store_string(JSON.stringify(data))
	file.flush()
	var error := file.get_error()
	file.close()
	if error != OK or _read_file(temporary).is_empty():
		last_error = "A verificação do arquivo temporário falhou."
		return false
	if not _read_file(path).is_empty():
		error = DirAccess.copy_absolute(path, path + ".backup")
		if error != OK:
			last_error = "Não foi possível preservar o backup anterior."
			return false
	error = DirAccess.rename_absolute(temporary, path)
	if error != OK:
		last_error = "Não foi possível concluir o salvamento."
		return false
	active_slot = slot
	return true

func load_slot(slot: int) -> bool:
	recovered_backup = false
	if slot < 1 or slot > SLOT_COUNT:
		return false
	pending_save = _read_file(slot_path(slot))
	if pending_save.is_empty():
		pending_save = _read_file(slot_path(slot) + ".backup")
		recovered_backup = not pending_save.is_empty()
	if pending_save.is_empty():
		last_error = "Salvamento vazio ou inválido."
		return false
	active_slot = slot
	return true

func consume_pending_save() -> Dictionary:
	var result := pending_save
	pending_save = {}
	return result

func start_new(name_value: String, difficulty_value: String) -> void:
	pending_save = {}
	active_slot = 0
	new_game_options = {"name": name_value, "difficulty": difficulty_value}

func delete_slot(slot: int) -> void:
	if slot < 1 or slot > SLOT_COUNT:
		return
	for suffix in ["", ".backup", ".tmp"]:
		var path: String = slot_path(slot) + String(suffix)
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)
