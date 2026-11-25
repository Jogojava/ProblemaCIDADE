extends Node
class_name TimeManager

signal second_tick(total_game_seconds: int)
signal day_passed(day: int, month: int, year: int)
signal month_passed(month: int, year: int)
signal year_passed(year: int)
signal paused_changed(is_paused: bool)
signal speed_changed(new_speed: int)

enum Speed {
	NORMAL,
	FAST,
	VERY_FAST
}

@export var days_per_month: int = 30
@export var months_per_year: int = 12

@export var normal_month_duration_real_seconds: float = 60.0
@export var fast_month_duration_real_seconds: float = 30.0
@export var very_fast_month_duration_real_seconds: float = 10.0
@export var problem_month_duration_real_seconds: float = 360.0

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
var _suppress_next_hitch: bool = false


func _process(delta: float) -> void:
	if paused:
		return

	var effective_delta := delta
	if _suppress_next_hitch:
		_suppress_next_hitch = false
		effective_delta = minf(delta, 0.05)

	_accumulated_real_time += effective_delta

	var seconds_per_game_day := _get_real_seconds_per_game_day()

	while not paused and _accumulated_real_time >= seconds_per_game_day:
		_accumulated_real_time -= seconds_per_game_day
		_advance_one_day()
		seconds_per_game_day = _get_real_seconds_per_game_day()


func _get_current_month_duration_real_seconds() -> float:
	if challenge_active:
		return problem_month_duration_real_seconds

	match current_speed:
		Speed.FAST:
			return fast_month_duration_real_seconds
		Speed.VERY_FAST:
			return very_fast_month_duration_real_seconds
		_:
			return normal_month_duration_real_seconds

func _get_real_seconds_per_game_day() -> float:
	var month_duration := _get_current_month_duration_real_seconds()
	return maxf(0.001, month_duration / float(maxi(1, days_per_month)))

func get_day_progress() -> float:
	var seconds_per_game_day := _get_real_seconds_per_game_day()
	if seconds_per_game_day <= 0.0:
		return 0.0
	return clampf(_accumulated_real_time / seconds_per_game_day, 0.0, 1.0)

func _rescale_accumulated_time(previous_seconds_per_day: float) -> void:
	if previous_seconds_per_day <= 0.0:
		_accumulated_real_time = 0.0
		return
	var day_fraction := clampf(_accumulated_real_time / previous_seconds_per_day, 0.0, 0.999999)
	_accumulated_real_time = day_fraction * _get_real_seconds_per_game_day()

func suppress_next_delta_hitch() -> void:
	_suppress_next_hitch = true

func get_game_speed_multiplier() -> float:
	var current_month_duration := _get_current_month_duration_real_seconds()
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
	var previous_seconds_per_day := _get_real_seconds_per_game_day()
	current_speed = requested_speed
	_rescale_accumulated_time(previous_seconds_per_day)
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
	if challenge_active == value:
		return
	var previous_seconds_per_day := _get_real_seconds_per_game_day()
	challenge_active = value
	_rescale_accumulated_time(previous_seconds_per_day)
	speed_changed.emit(current_speed)

func skip_until_next_event(event_checker: Callable) -> void:
	if not event_checker.is_valid():
		return

	# Bounded simulation: pass actual game days, including income, projects and elections.
	# Never bypass an existing manual pause or a modal dialog.
	if paused:
		return
	var skipped_any := false
	for _day in range(360):
		if event_checker.call() or paused:
			break
		_advance_one_day()
		skipped_any = true
	if skipped_any:
		_accumulated_real_time = 0.0

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
	challenge_active = false
	paused = _manual_paused
	_accumulated_real_time = clampf(float(data.get("accumulated_real_time", 0.0)), 0.0, _get_real_seconds_per_game_day() * 0.999999)
	_total_game_seconds = data.get("total_game_seconds", 0)
	_suppress_next_hitch = false

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
	challenge_active = false
	_manual_paused = false
	_pause_reasons.clear()
	_suppress_next_hitch = false

	paused_changed.emit(paused)
	speed_changed.emit(current_speed)
