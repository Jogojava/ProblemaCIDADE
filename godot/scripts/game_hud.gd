extends Control
class_name GameHUD

signal menu_requested()
signal panels_changed(is_open: bool)
signal problem_open_requested(event_id: String)

@onready var date_label: Label = $Calendar/DateLabel
@onready var menu_button: Button = $MenuButton
@onready var pause_button: Button = $TimeDock/TimeControls/PauseButton
@onready var normal_button: Button = $TimeDock/TimeControls/NormalButton
@onready var fast_button: Button = $TimeDock/TimeControls/FastButton
@onready var very_fast_button: Button = $TimeDock/TimeControls/VeryFastButton
@onready var status_label: Label = $TimeDock/StatusLabel
@onready var funds_button: Button = $FundsButton
@onready var reputation_button: Button = $ReputationButton
@onready var investment_panel: PanelContainer = $InvestmentPanel
@onready var statistics_panel: PanelContainer = $StatisticsPanel
@onready var occurrence_panel: PanelContainer = $OccurrencePanel
@onready var problem_tabs: PanelContainer = $UrgentAlertLayer/ProblemTabs
@onready var urgent_open_button: Button = $UrgentAlertLayer/ProblemTabs/UrgentLayout/UrgentOpenButton
@onready var urgent_progress: ProgressBar = $UrgentAlertLayer/ProblemTabs/UrgentLayout/UrgentTimer/UrgentTimerRow/UrgentProgress
@onready var urgent_countdown: Label = $UrgentAlertLayer/ProblemTabs/UrgentLayout/UrgentTimer/UrgentTimerRow/UrgentCountdown
@onready var urgent_phase: Label = $UrgentAlertLayer/ProblemTabs/UrgentLayout/UrgentTimer/UrgentPhase
@onready var occurrences: Control = $Occurrences
@onready var high_button: Button = $Occurrences/HighButton
@onready var medium_button: Button = $Occurrences/MediumButton
@onready var low_button: Button = $Occurrences/LowButton
@onready var high_count: PanelContainer = $Occurrences/HighCount
@onready var medium_count: PanelContainer = $Occurrences/MediumCount
@onready var low_count: PanelContainer = $Occurrences/LowCount
@onready var high_count_label: Label = $Occurrences/HighCount/Value
@onready var medium_count_label: Label = $Occurrences/MediumCount/Value
@onready var low_count_label: Label = $Occurrences/LowCount/Value

var _time_manager: TimeManager
var _pause_icon := preload("res://assets/ui/hud/pause.svg")
var _play_icon := preload("res://assets/ui/hud/play.svg")
var _problem_button_ids: Array[String] = []
var _problem_button_categories: Dictionary = {}
var _problem_buttons: Dictionary = {}
var _problem_button_titles: Dictionary = {}
var _events_by_category: Dictionary = {}
var _last_problem_events: Array[Dictionary] = []
var _urgent_event_id := ""
var _hovered_category := ""
var _sidebar_expanded := false
var _problem_mode := false

func _ready() -> void:
	menu_button.pressed.connect(func(): menu_requested.emit())
	pause_button.pressed.connect(_on_pause_pressed)
	normal_button.pressed.connect(_on_speed_pressed.bind(TimeManager.Speed.NORMAL))
	fast_button.pressed.connect(_on_speed_pressed.bind(TimeManager.Speed.FAST))
	very_fast_button.pressed.connect(_on_speed_pressed.bind(TimeManager.Speed.VERY_FAST))
	funds_button.pressed.connect(_toggle_panel.bind(investment_panel))
	reputation_button.pressed.connect(_toggle_panel.bind(statistics_panel))
	urgent_open_button.pressed.connect(_on_urgent_button_pressed)
	_style_problem_button(urgent_open_button, EventDatabase.CATEGORY_URGENT)
	var timer_fill := StyleBoxFlat.new()
	timer_fill.bg_color = Color(0.84, 0.12, 0.1)
	timer_fill.set_corner_radius_all(8)
	var timer_background := StyleBoxFlat.new()
	timer_background.bg_color = Color(0.12, 0.14, 0.16)
	timer_background.set_corner_radius_all(8)
	urgent_progress.add_theme_stylebox_override("fill", timer_fill)
	urgent_progress.add_theme_stylebox_override("background", timer_background)
	for badge in [high_count, medium_count, low_count]:
		var badge_style := StyleBoxFlat.new()
		badge_style.bg_color = Color(0.1, 0.14, 0.17, 0.95)
		badge_style.set_corner_radius_all(14)
		badge.add_theme_stylebox_override("panel", badge_style)
	occurrences.mouse_entered.connect(_on_sidebar_mouse_entered)
	occurrences.mouse_exited.connect(_on_sidebar_mouse_exited)
	high_button.mouse_entered.connect(_on_category_mouse_entered.bind(EventDatabase.CATEGORY_IMPORTANT))
	medium_button.mouse_entered.connect(_on_category_mouse_entered.bind(EventDatabase.CATEGORY_COMMON))
	low_button.mouse_entered.connect(_on_category_mouse_entered.bind(EventDatabase.CATEGORY_OPTIONAL))
	for panel in [investment_panel, statistics_panel, occurrence_panel]:
		panel.get_node("Content/Header/CloseButton").pressed.connect(close_panels)
	set_city_indicators()

func bind_time_manager(manager: TimeManager) -> void:
	_time_manager = manager
	manager.day_passed.connect(_on_day_passed)
	manager.paused_changed.connect(_on_paused_changed)
	manager.speed_changed.connect(_on_speed_changed)
	_refresh_date()
	_on_paused_changed(manager.paused)
	_on_speed_changed(manager.current_speed)

# Numbers in the planning are examples. Missing model data must not appear
# as an actual zero balance or approval rating.
func set_city_indicators(funds: Variant = null, reputation: Variant = null) -> void:
	$FundsLabel.text = "R$ —" if funds == null else "R$ %.2f" % float(funds)
	$ReputationInfo/ValueLabel.text = "—" if reputation == null else "%d%%" % roundi(clampf(float(reputation), 0.0, 100.0))
	$ReputationInfo/ReputationBar.value = 0.0 if reputation == null else clampf(float(reputation), 0.0, 100.0)
	funds_button.tooltip_text = "Investimentos • saldo ainda não definido." if funds == null else "Abrir investimentos."
	reputation_button.tooltip_text = "Reputação e finanças • ainda não há registros." if reputation == null else "Consultar reputação e finanças."

func close_panels() -> bool:
	var was_open := investment_panel.visible or statistics_panel.visible or occurrence_panel.visible
	investment_panel.hide()
	statistics_panel.hide()
	$StatisticsScrim.hide()
	occurrence_panel.hide()
	if was_open:
		panels_changed.emit(false)
	return was_open

func has_open_panel() -> bool:
	return investment_panel.visible or statistics_panel.visible or occurrence_panel.visible

func update_problem_tabs(events: Array[Dictionary]) -> void:
	var event_ids: Array[String] = []
	var categories_by_id: Dictionary = {}
	var next_events_by_category := {
		EventDatabase.CATEGORY_IMPORTANT: [],
		EventDatabase.CATEGORY_COMMON: [],
		EventDatabase.CATEGORY_OPTIONAL: []
	}
	var urgent_event: Dictionary = {}
	for runtime_event in events:
		var event_id := String(runtime_event.get("event_id", ""))
		if not event_id.is_empty():
			event_ids.append(event_id)
		var category := String(runtime_event.get("category", EventDatabase.CATEGORY_COMMON))
		categories_by_id[event_id] = category
		if category == EventDatabase.CATEGORY_URGENT:
			if urgent_event.is_empty():
				urgent_event = runtime_event
		elif next_events_by_category.has(category):
			next_events_by_category[category].append(runtime_event)
	var problems_changed := event_ids != _problem_button_ids or categories_by_id != _problem_button_categories
	if problems_changed:
		_rebuild_problem_buttons(events, categories_by_id)
	_problem_button_ids = event_ids
	_problem_button_categories = categories_by_id
	_events_by_category = next_events_by_category
	_last_problem_events = events.duplicate()
	if problems_changed:
		_update_category_counts()
		_update_sidebar_layout()
	_update_urgent_alert(urgent_event)

func _rebuild_problem_buttons(events: Array[Dictionary], categories_by_id: Dictionary) -> void:
	for button in _problem_buttons.values():
		if is_instance_valid(button):
			button.queue_free()
	_problem_buttons.clear()
	_problem_button_titles.clear()
	for runtime_event in events:
		var event_id := String(runtime_event.get("event_id", ""))
		var category := String(categories_by_id.get(event_id, ""))
		if event_id.is_empty() or category == EventDatabase.CATEGORY_URGENT:
			continue
		var button := Button.new()
		button.custom_minimum_size = Vector2(312, 68)
		button.size = Vector2(312, 68)
		button.add_theme_font_size_override("font_size", 19)
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.text_overrun_behavior = 3
		button.pressed.connect(_on_problem_button_pressed.bind(event_id))
		button.mouse_entered.connect(_on_category_mouse_entered.bind(category))
		var title := String(runtime_event.get("title", "Problema"))
		button.text = "!   " + title
		button.tooltip_text = "%s • %s" % [_category_label(category), title]
		_style_problem_button(button, category)
		occurrences.add_child(button)
		_problem_buttons[event_id] = button
		_problem_button_titles[event_id] = title

func _update_category_counts() -> void:
	var categories := [EventDatabase.CATEGORY_IMPORTANT, EventDatabase.CATEGORY_COMMON, EventDatabase.CATEGORY_OPTIONAL]
	var category_buttons := [high_button, medium_button, low_button]
	var count_labels := [high_count_label, medium_count_label, low_count_label]
	for index in range(categories.size()):
		var category: String = categories[index]
		var button: Button = category_buttons[index]
		var count_label: Label = count_labels[index]
		var count_badge: PanelContainer = [high_count, medium_count, low_count][index]
		var category_events: Array = _events_by_category.get(category, [])
		button.text = ("!  %d" % category_events.size()) if _sidebar_expanded else "!"
		count_label.text = str(category_events.size())
		count_badge.visible = not _sidebar_expanded
		button.tooltip_text = "%s • %d problema(s)" % [_category_label(category), category_events.size()]

func _update_sidebar_layout() -> void:
	if not is_node_ready():
		return
	var categories := [EventDatabase.CATEGORY_IMPORTANT, EventDatabase.CATEGORY_COMMON, EventDatabase.CATEGORY_OPTIONAL]
	var category_buttons := [high_button, medium_button, low_button]
	var count_badges := [high_count, medium_count, low_count]
	# Keep the category hitboxes fixed while expanding. Moving them under the
	# pointer caused mouse_entered to alternate between categories indefinitely.
	var icon_step := 92.0
	var category_first_row := {
		EventDatabase.CATEGORY_IMPORTANT: 0,
		EventDatabase.CATEGORY_COMMON: 2,
		EventDatabase.CATEGORY_OPTIONAL: 6
	}
	for index in range(categories.size()):
		var button: Button = category_buttons[index]
		var count_badge: PanelContainer = count_badges[index]
		button.position = Vector2(0, icon_step * index)
		button.size = Vector2(84, 72)
		button.add_theme_font_size_override("font_size", 38 if not _sidebar_expanded else 24)
		button.z_index = (10 if categories[index] == _hovered_category else 0) + index
		count_badge.position = Vector2(88, icon_step * index + 22)
		count_badge.size = Vector2(38, 28)
		count_badge.z_index = 20
		count_badge.visible = not _sidebar_expanded
	for event_id in _problem_buttons.keys():
		var button: Button = _problem_buttons[event_id]
		var category := String(_problem_button_categories.get(event_id, ""))
		var category_events: Array = _events_by_category.get(category, [])
		var row_index := 0
		for runtime_event in category_events:
			if String(runtime_event.get("event_id", "")) == String(event_id):
				break
			row_index += 1
		var first_row := int(category_first_row.get(category, 0))
		if _sidebar_expanded:
			button.visible = _hovered_category.is_empty() or category == _hovered_category
			button.custom_minimum_size = Vector2(312, 68)
			button.size = Vector2(312, 68)
			button.position = Vector2(96, (first_row + row_index) * 76)
			button.text = "!   " + String(_problem_button_titles.get(event_id, "Problema"))
			button.add_theme_font_size_override("font_size", 19)
			button.mouse_filter = Control.MOUSE_FILTER_STOP
		else:
			# Show the problem markers as a compact overlapping stack while the
			# sidebar is closed, with enough of each icon exposed to identify it.
			button.visible = true
			button.custom_minimum_size = Vector2(42, 44)
			button.size = Vector2(42, 44)
			var category_index := categories.find(category)
			button.position = Vector2(132, icon_step * category_index + 14 + row_index * 24)
			button.text = "!"
			button.add_theme_font_size_override("font_size", 22)
			button.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _update_urgent_alert(runtime_event: Dictionary) -> void:
	_urgent_event_id = String(runtime_event.get("event_id", ""))
	problem_tabs.visible = not _urgent_event_id.is_empty()
	if _urgent_event_id.is_empty():
		urgent_open_button.text = "!  Problema urgente"
		return
	var phase := String(runtime_event.get("deadline_phase", "opening"))
	var remaining := maxf(0.0, float(runtime_event.get("deadline_remaining_seconds", 180.0)))
	var urgent_count := 0
	for event_category in _problem_button_categories.values():
		if String(event_category) == EventDatabase.CATEGORY_URGENT:
			urgent_count += 1
	var title := String(runtime_event.get("title", "Problema urgente"))
	urgent_open_button.text = "!  %s  (%d)" % [title, urgent_count]
	urgent_open_button.tooltip_text = "Abrir problema urgente%s" % (" • %d na fila" % urgent_count if urgent_count > 1 else "")
	urgent_phase.text = "PARA RESPONDER" if phase == "solving" else "PARA ABRIR"
	urgent_countdown.text = _format_countdown(remaining)
	urgent_progress.max_value = 180.0
	urgent_progress.value = remaining
	urgent_open_button.disabled = _problem_mode

func set_problem_mode(active: bool) -> void:
	_problem_mode = active
	occurrences.visible = not active
	if active:
		_sidebar_expanded = false
		_hovered_category = ""
		_update_sidebar_layout()
	menu_button.disabled = active
	pause_button.disabled = active
	fast_button.disabled = active
	very_fast_button.disabled = active
	normal_button.disabled = false
	if active and _time_manager != null:
		normal_button.set_pressed_no_signal(true)
		fast_button.set_pressed_no_signal(false)
		very_fast_button.set_pressed_no_signal(false)
	if not active:
		_update_urgent_alert(_find_urgent_event())

func _style_problem_button(button: Button, category: String) -> void:
	var accent := Color(0.25, 0.72, 0.9)
	match category:
		"common": accent = Color(0.36, 0.66, 0.27)
		"important": accent = Color(0.88, 0.67, 0.12)
		"urgent": accent = Color(0.78, 0.2, 0.18)
	var normal := StyleBoxFlat.new()
	normal.bg_color = accent.darkened(0.5)
	normal.border_color = accent
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(8)
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = accent.darkened(0.3)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", hover)
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_color_override("font_hover_color", Color.WHITE)

func _on_problem_button_pressed(event_id: String) -> void:
	problem_open_requested.emit(event_id)

func _on_urgent_button_pressed() -> void:
	if not _urgent_event_id.is_empty() and not _problem_mode:
		problem_open_requested.emit(_urgent_event_id)

func _on_sidebar_mouse_entered() -> void:
	_sidebar_expanded = true
	var pointer := occurrences.get_local_mouse_position()
	if pointer.x <= 84.0:
		if pointer.y >= 0.0 and pointer.y < 72.0:
			_hovered_category = EventDatabase.CATEGORY_IMPORTANT
		elif pointer.y >= 92.0 and pointer.y < 164.0:
			_hovered_category = EventDatabase.CATEGORY_COMMON
		elif pointer.y >= 184.0 and pointer.y < 256.0:
			_hovered_category = EventDatabase.CATEGORY_OPTIONAL
	else:
		_hovered_category = ""
	_update_category_counts()
	_update_sidebar_layout()

func _on_sidebar_mouse_exited() -> void:
	_sidebar_expanded = false
	_hovered_category = ""
	_update_category_counts()
	_update_sidebar_layout()

func _on_category_mouse_entered(category: String) -> void:
	_sidebar_expanded = true
	_hovered_category = category
	_update_category_counts()
	_update_sidebar_layout()

func _find_urgent_event() -> Dictionary:
	for runtime_event in _last_problem_events:
		if String(runtime_event.get("category", "")) == EventDatabase.CATEGORY_URGENT:
			return runtime_event
	return {}

func _category_label(category: String) -> String:
	match category:
		"optional": return "Opcional"
		"common": return "Comum"
		"important": return "Prioritário"
		"urgent": return "Urgente"
		_: return "Problema"

func _format_countdown(seconds: float) -> String:
	var total_seconds := maxi(0, ceili(seconds))
	return "%02d:%02d" % [floori(float(total_seconds) / 60.0), total_seconds % 60]

func _toggle_panel(panel: Control) -> void:
	var was_open := panel.visible
	close_panels()
	if not was_open:
		panel.show()
		$StatisticsScrim.visible = panel == statistics_panel
		panels_changed.emit(true)
		panel.get_node("Content/Header/CloseButton").grab_focus()

func _open_occurrences(category: String) -> void:
	var was_open: bool = occurrence_panel.visible and $OccurrencePanel/Content/Header/Title.text == category
	close_panels()
	if not was_open:
		$OccurrencePanel/Content/Header/Title.text = category
		occurrence_panel.show()
		panels_changed.emit(true)
		$OccurrencePanel/Content/Header/CloseButton.grab_focus()

func _on_day_passed(_day: int, _month: int, _year: int) -> void:
	_refresh_date()

func _refresh_date() -> void:
	date_label.text = _time_manager.get_date_text()
	$Calendar/MonthProgress.value = float(_time_manager.current_day - 1) / float(_time_manager.days_per_month) * 100.0

func _on_pause_pressed() -> void:
	if _time_manager != null:
		_time_manager.toggle_pause()

func _on_speed_pressed(speed: int) -> void:
	if _time_manager != null:
		_time_manager.set_speed(speed)

func _on_paused_changed(paused: bool) -> void:
	pause_button.icon = _play_icon if paused else _pause_icon
	pause_button.set_pressed_no_signal(paused)
	pause_button.tooltip_text = "Retomar (Espaço)" if paused else "Pausar (Espaço)"
	_refresh_status()

func _on_speed_changed(speed: int) -> void:
	normal_button.set_pressed_no_signal(speed == TimeManager.Speed.NORMAL)
	fast_button.set_pressed_no_signal(speed == TimeManager.Speed.FAST)
	very_fast_button.set_pressed_no_signal(speed == TimeManager.Speed.VERY_FAST)
	_refresh_status()

func _refresh_status() -> void:
	if _time_manager == null:
		return
	if _time_manager.paused:
		status_label.text = "Tempo pausado"
		return
	match _time_manager.current_speed:
		TimeManager.Speed.NORMAL:
			status_label.text = "1 mês = 3 min"
		TimeManager.Speed.FAST:
			status_label.text = "1 mês = 1 min 30 s"
		TimeManager.Speed.VERY_FAST:
			status_label.text = "1 mês = 30 s"
