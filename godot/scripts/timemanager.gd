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

var _accumulated_real_time: float = 0.0
var _total_game_seconds: int = 0

var _skip_until_event: bool = false
var _event_checker: Callable = Callable()

func _process(delta: float) -> void:
	if paused:
		return

	_accumulated_real_time += delta

	var seconds_per_game_day := _get_real_seconds_per_game_day()

	while _accumulated_real_time >= seconds_per_game_day:
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

	return month_duration / float(days_per_month)

func _advance_one_day() -> void:
	current_day += 1
	_total_game_seconds += 86400
	second_tick.emit(_total_game_seconds)

	if current_day > days_per_month:
		current_day = 1
		current_month += 1
		month_passed.emit(current_month, current_year)

	if current_month > months_per_year:
		current_month = 1
		current_year += 1
		year_passed.emit(current_year)

	day_passed.emit(current_day, current_month, current_year)

func set_speed(speed: int) -> void:
	current_speed = clampi(speed, Speed.NORMAL, Speed.VERY_FAST)
	speed_changed.emit(current_speed)

func pause_game() -> void:
	if paused:
		return
	paused = true
	paused_changed.emit(paused)

func resume_game() -> void:
	if not paused:
		return
	paused = false
	paused_changed.emit(paused)

func toggle_pause() -> void:
	paused = not paused
	paused_changed.emit(paused)

func skip_until_next_event(event_checker: Callable) -> void:
	if not event_checker.is_valid():
		return

	_event_checker = event_checker
	_skip_until_event = true
	paused = false
	skip_started.emit()
	paused_changed.emit(paused)

func stop_skip() -> void:
	_skip_until_event = false

func get_date_text() -> String:
	return "%d anos, %d meses e %d dias" % [current_year, current_month, current_day]

func get_save_data() -> Dictionary:
	return {
		"current_day": current_day,
		"current_month": current_month,
		"current_year": current_year,
		"current_speed": current_speed,
		"paused": paused,
		"accumulated_real_time": _accumulated_real_time,
		"total_game_seconds": _total_game_seconds
	}

func load_save_data(data: Dictionary) -> void:
	current_day = data.get("current_day", 1)
	current_month = data.get("current_month", 1)
	current_year = data.get("current_year", 1)
	current_speed = data.get("current_speed", Speed.NORMAL)
	paused = data.get("paused", false)
	_accumulated_real_time = data.get("accumulated_real_time", 0.0)
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

	paused_changed.emit(paused)
	speed_changed.emit(current_speed)
