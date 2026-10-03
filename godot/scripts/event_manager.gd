extends Node
class_name EventManager

const CATEGORY_OPTIONAL := "optional"
const CATEGORY_COMMON := "common"
const CATEGORY_IMPORTANT := "important"
const CATEGORY_URGENT := "urgent"

signal event_scheduled(event_id: String, category: String, day: int, month: int, year: int)
signal event_triggered(runtime_event: Dictionary)
signal event_resolved(runtime_event: Dictionary)
signal event_expired(runtime_event: Dictionary)
signal monthly_schedule_created(month: int, year: int, created_counts: Dictionary)

@export var optional_events_per_month: int = 0
@export var common_events_per_month: int = 2
@export var important_events_per_month: int = 0
@export var urgent_events_per_month: int = 0

@export var min_day_for_optional: int = 2
@export var max_day_for_optional: int = 28

@export var min_day_for_common: int = 2
@export var max_day_for_common: int = 28

@export var min_day_for_important: int = 5
@export var max_day_for_important: int = 25

@export var min_day_for_urgent: int = 10
@export var max_day_for_urgent: int = 25

var can_trigger_event: bool = true

var scheduled_events: Array[Dictionary] = []
var active_events: Array[Dictionary] = []
var resolved_events: Array[Dictionary] = []
var expired_events: Array[Dictionary] = []

var _rng := RandomNumberGenerator.new()
var _time_manager: Node = null
var _event_database: Node = null

var _last_scheduled_month: int = -1
var _last_scheduled_year: int = -1

func _ready() -> void:
	_rng.randomize()

func setup(time_manager: Node, event_database: Node) -> void:
	_time_manager = time_manager
	_event_database = event_database

	if _time_manager != null:
		if not _time_manager.day_passed.is_connected(_on_day_passed):
			_time_manager.day_passed.connect(_on_day_passed)

		if not _time_manager.month_passed.is_connected(_on_month_passed):
			_time_manager.month_passed.connect(_on_month_passed)

func start_system(current_month: int, current_year: int) -> void:
	_create_month_schedule(current_month, current_year)

func _on_month_passed(month: int, year: int) -> void:
	_create_month_schedule(month, year)

func _on_day_passed(day: int, month: int, year: int) -> void:
	if can_trigger_event:
		_trigger_scheduled_for_day(day, month, year)

	_update_active_event_expiration(day, month, year)

func _trigger_scheduled_for_day(day: int, month: int, year: int) -> void:
	var triggered_today: Array[Dictionary] = []

	for scheduled in scheduled_events:
		if scheduled.get("day", -1) == day \
		and scheduled.get("month", -1) == month \
		and scheduled.get("year", -1) == year:
			triggered_today.append(scheduled)

	for scheduled in triggered_today:
		scheduled_events.erase(scheduled)

		var event_id := String(scheduled.get("event_id", ""))
		if event_id.is_empty():
			continue

		if _event_database == null:
			continue

		var runtime_event = _event_database.call("build_runtime_event", event_id, day, month, year)

		if typeof(runtime_event) != TYPE_DICTIONARY:
			continue

		if runtime_event.is_empty():
			continue

		active_events.append(runtime_event)
		event_triggered.emit(runtime_event)

func _update_active_event_expiration(day: int, month: int, year: int) -> void:
	var to_expire: Array[Dictionary] = []

	for runtime_event in active_events:
		if _is_event_expired(runtime_event, day, month, year):
			to_expire.append(runtime_event)

	for runtime_event in to_expire:
		active_events.erase(runtime_event)
		runtime_event["status"] = "expired"
		expired_events.append(runtime_event)
		event_expired.emit(runtime_event)

func _is_event_expired(runtime_event: Dictionary, current_day: int, current_month: int, current_year: int) -> bool:
	if not runtime_event.has("expires_on"):
		return false

	var expires_on = runtime_event.get("expires_on", null)
	if expires_on == null:
		return false

	if typeof(expires_on) != TYPE_DICTIONARY:
		return false

	var exp_day: int = int(expires_on.get("day", -1))
	var exp_month: int = int(expires_on.get("month", -1))
	var exp_year: int = int(expires_on.get("year", -1))

	if current_year > exp_year:
		return true

	if current_year == exp_year and current_month > exp_month:
		return true

	if current_year == exp_year and current_month == exp_month and current_day > exp_day:
		return true

	return false

func _create_month_schedule(month: int, year: int) -> void:
	if _last_scheduled_month == month and _last_scheduled_year == year:
		return

	_last_scheduled_month = month
	_last_scheduled_year = year

	_remove_old_scheduled_events(month, year)

	if _event_database != null and _event_database.has_method("reset_all_category_usage"):
		_event_database.call("reset_all_category_usage")

	var used_days: Array[int] = []
	var created_counts := {
		CATEGORY_OPTIONAL: 0,
		CATEGORY_COMMON: 0,
		CATEGORY_IMPORTANT: 0,
		CATEGORY_URGENT: 0
	}

	_schedule_category(
		CATEGORY_OPTIONAL,
		optional_events_per_month,
		min_day_for_optional,
		max_day_for_optional,
		month,
		year,
		used_days,
		created_counts
	)

	_schedule_category(
		CATEGORY_COMMON,
		common_events_per_month,
		min_day_for_common,
		max_day_for_common,
		month,
		year,
		used_days,
		created_counts
	)

	_schedule_category(
		CATEGORY_IMPORTANT,
		important_events_per_month,
		min_day_for_important,
		max_day_for_important,
		month,
		year,
		used_days,
		created_counts
	)

	_schedule_category(
		CATEGORY_URGENT,
		urgent_events_per_month,
		min_day_for_urgent,
		max_day_for_urgent,
		month,
		year,
		used_days,
		created_counts
	)

	monthly_schedule_created.emit(month, year, created_counts)

func _schedule_category(
	category: String,
	amount: int,
	min_day: int,
	max_day: int,
	month: int,
	year: int,
	used_days: Array[int],
	created_counts: Dictionary
) -> void:
	if _event_database == null:
		return

	for i in range(amount):
		if not _event_database.has_method("get_random_event_id_by_category"):
			return

		var result = _event_database.call("get_random_event_id_by_category", category)
		if typeof(result) != TYPE_STRING:
			continue

		var event_id := String(result)
		if event_id.is_empty():
			continue

		var scheduled_day := _pick_unique_day(used_days, min_day, max_day)
		used_days.append(scheduled_day)

		var scheduled_data := {
			"event_id": event_id,
			"category": category,
			"day": scheduled_day,
			"month": month,
			"year": year
		}

		scheduled_events.append(scheduled_data)
		created_counts[category] = int(created_counts.get(category, 0)) + 1
		event_scheduled.emit(event_id, category, scheduled_day, month, year)

func _pick_unique_day(used_days: Array[int], min_day: int, max_day: int) -> int:
	var attempts := 0
	var chosen_day := _rng.randi_range(min_day, max_day)

	while chosen_day in used_days and attempts < 100:
		chosen_day = _rng.randi_range(min_day, max_day)
		attempts += 1

	return chosen_day

func _remove_old_scheduled_events(current_month: int, current_year: int) -> void:
	var filtered: Array[Dictionary] = []

	for event_data in scheduled_events:
		var event_year: int = int(event_data.get("year", -1))
		var event_month: int = int(event_data.get("month", -1))

		if event_year > current_year:
			filtered.append(event_data)
		elif event_year == current_year and event_month >= current_month:
			filtered.append(event_data)

	scheduled_events = filtered

func has_active_event() -> bool:
	return not active_events.is_empty()

func get_active_count() -> int:
	return active_events.size()

func get_active_events() -> Array[Dictionary]:
	return active_events.duplicate(true)

func peek_next_active_event() -> Dictionary:
	if active_events.is_empty():
		return {}

	return active_events[0].duplicate(true)

func pop_next_active_event() -> Dictionary:
	if active_events.is_empty():
		return {}

	return active_events.pop_front()

func resolve_event(event_id: String) -> bool:
	for runtime_event in active_events:
		if String(runtime_event.get("event_id", "")) == event_id:
			active_events.erase(runtime_event)
			runtime_event["status"] = "resolved"
			resolved_events.append(runtime_event)
			event_resolved.emit(runtime_event)
			return true

	return false

func expire_event_immediately(event_id: String) -> bool:
	for runtime_event in active_events:
		if String(runtime_event.get("event_id", "")) == event_id:
			active_events.erase(runtime_event)
			runtime_event["status"] = "expired"
			expired_events.append(runtime_event)
			event_expired.emit(runtime_event)
			return true

	return false

func get_scheduled_events() -> Array[Dictionary]:
	return scheduled_events.duplicate(true)

func get_resolved_events() -> Array[Dictionary]:
	return resolved_events.duplicate(true)

func get_expired_events() -> Array[Dictionary]:
	return expired_events.duplicate(true)

func set_event_trigger_enabled(value: bool) -> void:
	can_trigger_event = value

func clear_all() -> void:
	scheduled_events.clear()
	active_events.clear()
	resolved_events.clear()
	expired_events.clear()
	_last_scheduled_month = -1
	_last_scheduled_year = -1

func get_save_data() -> Dictionary:
	return {
		"can_trigger_event": can_trigger_event,
		"scheduled_events": scheduled_events,
		"active_events": active_events,
		"resolved_events": resolved_events,
		"expired_events": expired_events,
		"last_scheduled_month": _last_scheduled_month,
		"last_scheduled_year": _last_scheduled_year
	}

func load_save_data(data: Dictionary) -> void:
	can_trigger_event = bool(data.get("can_trigger_event", true))
	scheduled_events = data.get("scheduled_events", [])
	active_events = data.get("active_events", [])
	resolved_events = data.get("resolved_events", [])
	expired_events = data.get("expired_events", [])
	_last_scheduled_month = int(data.get("last_scheduled_month", -1))
	_last_scheduled_year = int(data.get("last_scheduled_year", -1))
