extends Node
class_name EventDatabase

const CATEGORY_OPTIONAL := "optional"
const CATEGORY_COMMON := "common"
const CATEGORY_IMPORTANT := "important"
const CATEGORY_URGENT := "urgent"

const INTERACTION_CHOICE := "choice"
const INTERACTION_NUMBER_INPUT := "number_input"
const INTERACTION_TEXT_INPUT := "text_input"

var events: Dictionary = {}

var _rng := RandomNumberGenerator.new()
var _used_ids_by_category: Dictionary = {
	CATEGORY_OPTIONAL: [],
	CATEGORY_COMMON: [],
	CATEGORY_IMPORTANT: [],
	CATEGORY_URGENT: []
}

func _ready() -> void:
	_rng.randomize()

func register_event(event_id: String, data: Dictionary) -> void:
	if event_id.is_empty():
		return

	var event_data := data.duplicate(true)
	event_data["id"] = event_id

	if not event_data.has("category"):
		event_data["category"] = CATEGORY_COMMON

	if not event_data.has("interaction_type"):
		event_data["interaction_type"] = INTERACTION_CHOICE

	if not event_data.has("payload"):
		event_data["payload"] = {}

	if not event_data.has("success_effects"):
		event_data["success_effects"] = {}

	if not event_data.has("failure_effects"):
		event_data["failure_effects"] = {}

	if not event_data.has("expiration_effects"):
		event_data["expiration_effects"] = {}

	if not event_data.has("availability_duration_days"):
		event_data["availability_duration_days"] = null

	events[event_id] = event_data

func has_event(event_id: String) -> bool:
	return events.has(event_id)

func get_event(event_id: String) -> Dictionary:
	if not events.has(event_id):
		return {}
	return events[event_id].duplicate(true)

func remove_event(event_id: String) -> void:
	events.erase(event_id)

	for category in _used_ids_by_category.keys():
		_used_ids_by_category[category].erase(event_id)

func clear_all() -> void:
	events.clear()

	for category in _used_ids_by_category.keys():
		_used_ids_by_category[category].clear()

func get_all_event_ids() -> Array[String]:
	var result: Array[String] = []
	for id in events.keys():
		result.append(String(id))
	return result

func get_events_by_category(category: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []

	for event_data in events.values():
		if String(event_data.get("category", "")) == category:
			result.append(event_data.duplicate(true))

	return result

func get_events_by_interaction_type(interaction_type: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []

	for event_data in events.values():
		if String(event_data.get("interaction_type", "")) == interaction_type:
			result.append(event_data.duplicate(true))

	return result

func get_random_event_id_by_category(category: String) -> String:
	var candidates: Array[String] = []

	for event_id in events.keys():
		var event_data: Dictionary = events[event_id]
		if String(event_data.get("category", "")) == category:
			candidates.append(String(event_id))

	if candidates.is_empty():
		return ""

	var used_ids: Array = _used_ids_by_category.get(category, [])
	var available: Array[String] = []

	for candidate in candidates:
		if not used_ids.has(candidate):
			available.append(candidate)

	if available.is_empty():
		available = candidates.duplicate()
		used_ids.clear()

	var chosen_id := available[_rng.randi_range(0, available.size() - 1)]
	used_ids.append(chosen_id)
	_used_ids_by_category[category] = used_ids
	return chosen_id

func reset_category_usage(category: String) -> void:
	if _used_ids_by_category.has(category):
		_used_ids_by_category[category].clear()

func reset_all_category_usage() -> void:
	for category in _used_ids_by_category.keys():
		_used_ids_by_category[category].clear()

func build_runtime_event(event_id: String, start_day: int, start_month: int, start_year: int) -> Dictionary:
	var base_event := get_event(event_id)
	if base_event.is_empty():
		return {}

	var duration = base_event.get("availability_duration_days", null)
	var expires_on = null

	if duration != null:
		expires_on = {
			"day": start_day + int(duration),
			"month": start_month,
			"year": start_year
		}

	return {
		"event_id": event_id,
		"category": base_event.get("category", CATEGORY_COMMON),
		"interaction_type": base_event.get("interaction_type", INTERACTION_CHOICE),
		"status": "pending",
		"available_from": {
			"day": start_day,
			"month": start_month,
			"year": start_year
		},
		"availability_duration_days": duration,
		"expires_on": expires_on
	}

func validate_event_structure(event_data: Dictionary) -> bool:
	if not event_data.has("id"):
		return false

	if not event_data.has("category"):
		return false

	if not event_data.has("interaction_type"):
		return false

	if not event_data.has("payload"):
		return false

	if not _is_valid_category(String(event_data["category"])):
		return false

	var interaction_type := String(event_data["interaction_type"])

	match interaction_type:
		INTERACTION_CHOICE:
			return _validate_choice_payload(event_data["payload"])
		INTERACTION_NUMBER_INPUT:
			return _validate_number_input_payload(event_data["payload"])
		INTERACTION_TEXT_INPUT:
			return _validate_text_input_payload(event_data["payload"])
		_:
			return false

func _is_valid_category(category: String) -> bool:
	return category == CATEGORY_OPTIONAL \
		or category == CATEGORY_COMMON \
		or category == CATEGORY_IMPORTANT \
		or category == CATEGORY_URGENT

func _validate_choice_payload(payload: Dictionary) -> bool:
	if not payload.has("options"):
		return false

	var options = payload["options"]
	return options is Array and options.size() > 0

func _validate_number_input_payload(payload: Dictionary) -> bool:
	if not payload.has("prompt"):
		return false

	if not payload.has("correct_value"):
		return false

	return true

func _validate_text_input_payload(payload: Dictionary) -> bool:
	if not payload.has("prompt"):
		return false

	if not payload.has("accepted_answers"):
		return false

	var accepted_answers = payload["accepted_answers"]
	return accepted_answers is Array and accepted_answers.size() > 0

func get_save_data() -> Dictionary:
	return {
		"events": events,
		"used_ids_by_category": _used_ids_by_category
	}

func load_save_data(data: Dictionary) -> void:
	events = data.get("events", {})
	_used_ids_by_category = data.get("used_ids_by_category", {
		CATEGORY_OPTIONAL: [],
		CATEGORY_COMMON: [],
		CATEGORY_IMPORTANT: [],
		CATEGORY_URGENT: []
	})
