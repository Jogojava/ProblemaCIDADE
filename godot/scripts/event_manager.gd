extends Node
class_name EventManager

signal event_scheduled(event_id: String, day: int, month: int, year: int, is_urgent: bool)
signal event_triggered(event_id: String, is_urgent: bool)
signal monthly_schedule_created(month: int, year: int, normal_count: int, urgent_count: int)

@export var normal_events_per_month: int = 2
@export var urgent_event_interval_months: int = 3
@export var min_day_for_normal: int = 2
@export var max_day_for_normal: int = 28
@export var min_day_for_urgent: int = 10
@export var max_day_for_urgent: int = 25

var can_trigger_event: bool = true

var scheduled_events: Array[Dictionary] = []
var pending_events: Array[Dictionary] = []

var _rng := RandomNumberGenerator.new()
var _time_manager: Node = null
var _normal_event_provider: Callable = Callable()
var _urgent_event_provider: Callable = Callable()

var _last_scheduled_month: int = -1
var _last_scheduled_year: int = -1

func _ready() -> void:
	_rng.randomize()

func setup(
	time_manager: Node,
	normal_provider: Callable,
	urgent_provider: Callable
) -> void:
	_time_manager = time_manager
	_normal_event_provider = normal_provider
	_urgent_event_provider = urgent_provider

	if not _time_manager.day_passed.is_connected(_on_day_passed):
		_time_manager.day_passed.connect(_on_day_passed)

	if not _time_manager.month_passed.is_connected(_on_month_passed):
		_time_manager.month_passed.connect(_on_month_passed)

func start_system(current_month: int, current_year: int) -> void:
	_create_month_schedule(current_month, current_year)

func _on_month_passed(month: int, year: int) -> void:
	_create_month_schedule(month, year)

func _on_day_passed(day: int, month: int, year: int) -> void:
	if not can_trigger_event:
		return

	var triggered_today: Array[Dictionary] = []

	for scheduled in scheduled_events:
		if scheduled.day == day and scheduled.month == month and scheduled.year == year:
			triggered_today.append(scheduled)

	for event_data in triggered_today:
		scheduled_events.erase(event_data)
		pending_events.append(event_data)
		event_triggered.emit(event_data.event_id, event_data.is_urgent)

func _create_month_schedule(month: int, year: int) -> void:
	if _last_scheduled_month == month and _last_scheduled_year == year:
		return

	_last_scheduled_month = month
	_last_scheduled_year = year

	_remove_old_scheduled_events(month, year)

	var used_days: Array[int] = []
	var created_normals := 0
	var created_urgents := 0

	for i in range(normal_events_per_month):
		var normal_event_id := _request_event_id(false)
		if normal_event_id.is_empty():
			continue

		var scheduled_day := _pick_unique_day(used_days, min_day_for_normal, max_day_for_normal)
		used_days.append(scheduled_day)

		var event_data := {
			"event_id": normal_event_id,
			"day": scheduled_day,
			"month": month,
			"year": year,
			"is_urgent": false
		}

		scheduled_events.append(event_data)
		created_normals += 1
		event_scheduled.emit(normal_event_id, scheduled_day, month, year, false)

	if month % urgent_event_interval_months == 0:
		var urgent_event_id := _request_event_id(true)
		if not urgent_event_id.is_empty():
			var urgent_day := _pick_unique_day(used_days, min_day_for_urgent, max_day_for_urgent)
			used_days.append(urgent_day)

			var urgent_data := {
				"event_id": urgent_event_id,
				"day": urgent_day,
				"month": month,
				"year": year,
				"is_urgent": true
			}

			scheduled_events.append(urgent_data)
			created_urgents += 1
			event_scheduled.emit(urgent_event_id, urgent_day, month, year, true)

	monthly_schedule_created.emit(month, year, created_normals, created_urgents)

func _request_event_id(is_urgent: bool) -> String:
	var provider := _urgent_event_provider if is_urgent else _normal_event_provider

	if not provider.is_valid():
		return ""

	var result = provider.call()

	if typeof(result) != TYPE_STRING:
		return ""

	return result

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
		var event_year: int = event_data.year
		var event_month: int = event_data.month

		if event_year > current_year:
			filtered.append(event_data)
		elif event_year == current_year and event_month >= current_month:
			filtered.append(event_data)

	scheduled_events = filtered

func has_pending_event() -> bool:
	return not pending_events.is_empty()

func pop_next_event() -> Dictionary:
	if pending_events.is_empty():
		return {}

	return pending_events.pop_front()

func peek_next_event() -> Dictionary:
	if pending_events.is_empty():
		return {}

	return pending_events[0]

func get_pending_count() -> int:
	return pending_events.size()

func get_scheduled_events() -> Array[Dictionary]:
	return scheduled_events.duplicate(true)

func set_event_trigger_enabled(value: bool) -> void:
	can_trigger_event = value

func clear_all() -> void:
	scheduled_events.clear()
	pending_events.clear()
	_last_scheduled_month = -1
	_last_scheduled_year = -1

func get_save_data() -> Dictionary:
	return {
		"can_trigger_event": can_trigger_event,
		"scheduled_events": scheduled_events,
		"pending_events": pending_events,
		"last_scheduled_month": _last_scheduled_month,
		"last_scheduled_year": _last_scheduled_year
	}

func load_save_data(data: Dictionary) -> void:
	can_trigger_event = data.get("can_trigger_event", true)
	scheduled_events = data.get("scheduled_events", [])
	pending_events = data.get("pending_events", [])
	_last_scheduled_month = data.get("last_scheduled_month", -1)
	_last_scheduled_year = data.get("last_scheduled_year", -1)
