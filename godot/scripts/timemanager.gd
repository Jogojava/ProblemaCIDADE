extends Node
class_name TimeManager

signal second_tick(total_game_seconds: int)
signal day_passed(day: int, month: int, year: int)
signal month_passed(month: int, year: int)
signal year_passed(year: int)
signal paused_changed(is_paused: bool)
signal speed_changed(new_speed: int)
signal skip_started()
signal skip_finished()

enum Speed {
	NORMAL,
	FAST,
	VERY_FAST
}

@export var days_per_month: int = 30
@export var months_per_year: int = 12

@export var normal_month_duration_real_seconds: float = 180.0
@export var fast_month_duration_real_seconds: float = 90.0
@export var very_fast_month_duration_real_seconds: float = 30.0

var current_day: int = 1
var current_month: int = 1
var current_year: int = 1

var current_speed: int = Speed.NORMAL
var paused: bool = false
var challenge_active: bool = false
var _manual_paused := false
var _pause_reasons: Dictionary = {}

var _accumulated_real_time: float = 0.0
var _total_game_seconds: int = 0

var _skip_until_event: bool = false
var _event_checker: Callable = Callable()

func _process(delta: float) -> void:
	if paused:
		return

	_accumulated_real_time += delta

	var seconds_per_game_day := _get_real_seconds_per_game_day()

	while not paused and _accumulated_real_time >= seconds_per_game_day:
		_accumulated_real_time -= seconds_per_game_day
		_advance_one_day()

		if _skip_until_event and _event_checker.is_valid():
			if _event_checker.call():
				_skip_until_event = false
				paused = true
				skip_finished.emit()
				paused_changed.emit(paused)
				break

func _get_real_seconds_per_game_day() -> float:
	var month_duration := 0.0

	match current_speed:
		Speed.NORMAL:
			month_duration = normal_month_duration_real_seconds
		Speed.FAST:
			month_duration = fast_month_duration_real_seconds
		Speed.VERY_FAST:
			month_duration = very_fast_month_duration_real_seconds

	return maxf(0.001, month_duration / float(maxi(1, days_per_month)))

func get_game_speed_multiplier() -> float:
	var current_month_duration := normal_month_duration_real_seconds
	match current_speed:
		Speed.FAST:
			current_month_duration = fast_month_duration_real_seconds
		Speed.VERY_FAST:
			current_month_duration = very_fast_month_duration_real_seconds
	if current_month_duration <= 0.0:
		return 1.0
	return maxf(0.0, normal_month_duration_real_seconds) / current_month_duration

func _advance_one_day() -> void:
	current_day += 1
	_total_game_seconds += 86400
	second_tick.emit(_total_game_seconds)
	var month_changed := false

	if current_day > days_per_month:
		current_day = 1
		current_month += 1
		month_changed = true

	if current_month > months_per_year:
		current_month = 1
		current_year += 1
		year_passed.emit(current_year)

	if month_changed:
		month_passed.emit(current_month, current_year)

	day_passed.emit(current_day, current_month, current_year)

func set_speed(speed: int) -> void:
	var requested_speed := clampi(speed, Speed.NORMAL, Speed.VERY_FAST)
	if challenge_active and requested_speed != Speed.NORMAL:
		return
	current_speed = requested_speed
	speed_changed.emit(current_speed)

func pause_game() -> void:
	_manual_paused = true
	_update_pause()

func resume_game() -> void:
	_manual_paused = false
	_update_pause()

func toggle_pause() -> void:
	if challenge_active:
		return
	_manual_paused = not _manual_paused
	_update_pause()

func hold(reason: String) -> void:
	_pause_reasons[reason] = true
	_update_pause()

func release(reason: String) -> void:
	_pause_reasons.erase(reason)
	_update_pause()

func _update_pause() -> void:
	var next := _manual_paused or not _pause_reasons.is_empty()
	if paused != next:
		paused = next
		paused_changed.emit(paused)

func set_challenge_active(value: bool) -> void:
	challenge_active = value
	if challenge_active:
		hold("challenge")
	else:
		release("challenge")

func skip_until_next_event(event_checker: Callable) -> void:
	if not event_checker.is_valid():
		return

	_event_checker = event_checker
	_skip_until_event = true
	skip_started.emit()
	# Bounded simulation: pass actual game days, including income, projects and elections.
	# Never bypass an existing manual pause or a modal dialog.
	if paused:
		_skip_until_event = false
		skip_finished.emit()
		return
	for _day in range(360):
		if _event_checker.call() or paused:
			break
		_advance_one_day()
	_skip_until_event = false
	skip_finished.emit()

func stop_skip() -> void:
	_skip_until_event = false

func get_date_text() -> String:
	return "Dia %d / Mês %d / Ano %d" % [current_day, current_month, current_year]

func get_save_data() -> Dictionary:
	return {
		"current_day": current_day,
		"current_month": current_month,
		"current_year": current_year,
		"current_speed": current_speed,
		"paused": _manual_paused,
		"accumulated_real_time": _accumulated_real_time,
		"total_game_seconds": _total_game_seconds
	}

func load_save_data(data: Dictionary) -> void:
	current_day = clampi(int(data.get("current_day", 1)), 1, days_per_month)
	current_month = clampi(int(data.get("current_month", 1)), 1, months_per_year)
	current_year = maxi(1, int(data.get("current_year", 1)))
	current_speed = clampi(int(data.get("current_speed", Speed.NORMAL)), Speed.NORMAL, Speed.VERY_FAST)
	_manual_paused = bool(data.get("paused", false))
	_pause_reasons.clear()
	paused = _manual_paused
	_accumulated_real_time = maxf(0.0, float(data.get("accumulated_real_time", 0.0)))
	_total_game_seconds = data.get("total_game_seconds", 0)

	paused_changed.emit(paused)
	speed_changed.emit(current_speed)

func set_date(day: int, month: int, year: int) -> void:
	current_day = max(1, day)
	current_month = clampi(month, 1, months_per_year)
	current_year = max(1, year)

func reset_time() -> void:
	current_day = 1
	current_month = 1
	current_year = 1
	current_speed = Speed.NORMAL
	paused = false
	_accumulated_real_time = 0.0
	_total_game_seconds = 0
	_skip_until_event = false
	_event_checker = Callable()
	challenge_active = false
	_manual_paused = false
	_pause_reasons.clear()

	paused_changed.emit(paused)
	speed_changed.emit(current_speed)
