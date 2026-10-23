extends Control
class_name GameHUD

signal menu_requested()
signal investment_requested(area: String, amount: float)
signal construction_requested(area: String)
signal housing_requested()
signal skip_requested()
signal map_center_requested()
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
var _sidebar_panel: PanelContainer
var _problem_list: VBoxContainer
var _housing_button: Button
var _city: CityState
var _investment_mode: OptionButton
var _chart: ProjectionChart
var _projection_key := "funds"
var _city_label: Label
var _notice_label: Label

func _ready() -> void:
	_setup_sidebar()
	_setup_city_panels()
	_apply_layout()
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
		button.text = tr(title)
		button.tooltip_text = "%s • %s" % [tr(_category_label(category)), tr(title)]
		_style_problem_button(button, category)
		_problem_list.add_child(button)
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
		DeboraDesign.marker(button, category)
		count_label.text = str(category_events.size())
		count_badge.visible = true
		button.tooltip_text = "%s · %d" % [tr(_category_label(category)), category_events.size()]

func _update_sidebar_layout() -> void:
	if not is_node_ready() or _sidebar_panel == null:
		return
	var categories := [EventDatabase.CATEGORY_IMPORTANT, EventDatabase.CATEGORY_COMMON, EventDatabase.CATEGORY_OPTIONAL]
	var category_buttons := [high_button, medium_button, low_button]
	var count_badges := [high_count, medium_count, low_count]
	var expanded := _sidebar_expanded and not _hovered_category.is_empty()
	_sidebar_panel.visible = expanded
	occurrences.size = Vector2(570 if expanded else 126, 400 if expanded else 270)
	for index in range(categories.size()):
		var button: Button = category_buttons[index]
		var badge: PanelContainer = count_badges[index]
		button.position = Vector2(0, index * 92)
		button.size = Vector2(84, 72)
		button.add_theme_font_size_override("font_size", 28)
		DeboraDesign.marker(button, categories[index])
		badge.position = Vector2(88, index * 92 + 22)
		badge.visible = true
		badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for event_id in _problem_buttons:
		var button: Button = _problem_buttons[event_id]
		button.visible = expanded and String(_problem_button_categories[event_id]) == _hovered_category
		button.custom_minimum_size = Vector2(360, 64)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.text = tr(String(_problem_button_titles[event_id]))
		button.mouse_filter = Control.MOUSE_FILTER_STOP
	var heading := _sidebar_panel.get_node("Content/Heading") as Label
	heading.text = tr(_category_label(_hovered_category))
	var empty := _sidebar_panel.get_node("Content/Empty") as Label
	empty.visible = (_events_by_category.get(_hovered_category, []) as Array).is_empty()

func _update_urgent_alert(runtime_event: Dictionary) -> void:
	_urgent_event_id = String(runtime_event.get("event_id", ""))
	problem_tabs.visible = not _urgent_event_id.is_empty() and not _problem_mode
	if _urgent_event_id.is_empty():
		urgent_open_button.text = "Problema urgente"
		return
	var phase := String(runtime_event.get("deadline_phase", "opening"))
	var remaining := maxf(0.0, float(runtime_event.get("deadline_remaining_seconds", 180.0)))
	var urgent_count := 0
	for event_category in _problem_button_categories.values():
		if String(event_category) == EventDatabase.CATEGORY_URGENT:
			urgent_count += 1
	var title := String(runtime_event.get("title", "Problema urgente"))
	urgent_open_button.text = "%s  (%d)" % [title, urgent_count]
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
	funds_button.disabled = active
	reputation_button.disabled = active
	$TimeDock/TimeControls/SkipButton.disabled = active
	normal_button.disabled = active
	if active and _time_manager != null:
		normal_button.set_pressed_no_signal(true)
		fast_button.set_pressed_no_signal(false)
		very_fast_button.set_pressed_no_signal(false)
	if not active:
		_update_urgent_alert(_find_urgent_event())

func _style_problem_button(button: Button, category: String) -> void:
	button.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	button.icon = load(DeboraDesign.ROOT + category + ".png")
	button.expand_icon = true
	button.add_theme_constant_override("icon_max_width", 28)
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
	button.add_theme_color_override("font_pressed_color", Color.WHITE)
	button.add_theme_color_override("font_focus_color", Color.WHITE)

func _on_problem_button_pressed(event_id: String) -> void:
	problem_open_requested.emit(event_id)

func _on_urgent_button_pressed() -> void:
	if not _urgent_event_id.is_empty() and not _problem_mode:
		problem_open_requested.emit(_urgent_event_id)

func _on_sidebar_mouse_entered() -> void:
	pass

func _on_sidebar_mouse_exited() -> void:
	call_deferred("_check_sidebar_pointer")

func _check_sidebar_pointer() -> void:
	if not occurrences.get_global_rect().has_point(get_global_mouse_position()):
		_sidebar_expanded = false
		_hovered_category = ""
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
	date_label.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	date_label.text = tr("Dia %d / Mês %d / Ano %d") % [_time_manager.current_day, _time_manager.current_month, _time_manager.current_year]
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

func _setup_sidebar() -> void:
	theme = SettingsService.game_theme
	_sidebar_panel = PanelContainer.new()
	_sidebar_panel.name = "ProblemList"
	_sidebar_panel.position = Vector2(144, 0)
	_sidebar_panel.custom_minimum_size = Vector2(410, 0)
	_sidebar_panel.size = Vector2(410, 380)
	occurrences.add_child(_sidebar_panel)
	var column := VBoxContainer.new()
	column.name = "Content"
	column.add_theme_constant_override("separation", 12)
	_sidebar_panel.add_child(column)
	var heading := UIFactory.label("", 24)
	heading.name = "Heading"
	column.add_child(heading)
	var empty := UIFactory.label(tr("Nenhum problema nesta categoria."), 21)
	empty.name = "Empty"
	column.add_child(empty)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(370, 280)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(scroll)
	_problem_list = VBoxContainer.new()
	_problem_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_problem_list.add_theme_constant_override("separation", 10)
	scroll.add_child(_problem_list)
	_sidebar_panel.hide()
	for pair in [[high_button, "important"], [medium_button, "common"], [low_button, "optional"]]:
		pair[0].pressed.connect(_on_category_mouse_entered.bind(pair[1]))
		pair[0].focus_entered.connect(_on_category_mouse_entered.bind(pair[1]))
	for badge in [high_count_label, medium_count_label, low_count_label]:
		badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_update_sidebar_layout()

func _setup_city_panels() -> void:
	_city_label = UIFactory.label("", 25)
	add_child(_city_label)
	_city_label.position = Vector2(260, 34)
	_city_label.size = Vector2(900, 40)
	_city_label.add_theme_color_override("font_color", Color.WHITE)
	_city_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_notice_label = UIFactory.label("", 22)
	add_child(_notice_label)
	_notice_label.position = Vector2(230, 96)
	_notice_label.size = Vector2(1100, 54)
	_notice_label.add_theme_color_override("font_color", Color("f1dc9c"))
	_notice_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var skip := UIFactory.button("", func(): skip_requested.emit(), tr("Até a próxima ocorrência: avançar os dias até o próximo problema, mantendo receitas, obras e eleições."))
	skip.name = "SkipButton"
	skip.custom_minimum_size = Vector2(84, 84)
	skip.icon = preload("res://assets/ui/hud/skip_next.svg")
	skip.expand_icon = true
	skip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	$TimeDock/TimeControls.add_child(skip)
	$TimeDock.offset_left = -234
	$TimeDock.offset_right = 234
	$TimeDock.offset_top = -134
	$TimeDock.offset_bottom = -16
	$Footer.offset_top = -160
	var center_button := UIFactory.button("⌖", func(): map_center_requested.emit(), tr("Restaurar posição e zoom da câmera"))
	center_button.name = "CenterMapButton"
	center_button.position = Vector2(136, 28)
	center_button.size = Vector2(84, 84)
	center_button.add_theme_font_size_override("font_size", 36)
	add_child(center_button)
	_housing_button = UIFactory.button("", func(): housing_requested.emit())
	_housing_button.name = "HousingButton"
	_housing_button.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	_housing_button.offset_left = -520
	_housing_button.offset_right = -32
	_housing_button.offset_top = 140
	_housing_button.offset_bottom = 206
	add_child(_housing_button)
	_investment_mode = OptionButton.new()
	_investment_mode.add_item(tr("Investir em serviços"))
	_investment_mode.add_item(tr("Construir instalação · R$ 35.000 · 20 dias"))
	_investment_mode.add_theme_font_size_override("font_size", 22)
	$InvestmentPanel/Content.add_child(_investment_mode)
	$InvestmentPanel/Content.move_child(_investment_mode, 1)
	_investment_mode.item_selected.connect(func(index: int):
		$InvestmentPanel/Content/AmountSlider.visible = index == 0
		refresh_city())
	$InvestmentPanel/Content.add_theme_constant_override("separation", 10)
	$InvestmentPanel/Content/Header/Title.add_theme_font_size_override("font_size", 32)
	var slider := $InvestmentPanel/Content/AmountSlider as HSlider
	slider.min_value = 5000
	slider.max_value = 50000
	slider.step = 5000
	slider.value = 10000
	slider.editable = true
	slider.value_changed.connect(func(value: float): $InvestmentPanel/Content/AmountLabel.text = tr("Valor: R$ %.0f") % value)
	for area in GameRules.AREAS:
		var cell_name: String = {"education": "Education", "health": "Health", "water": "Water", "security": "Security", "culture": "Culture", "social": "Social"}[area]
		var cell := $InvestmentPanel/Content/Categories.get_node(cell_name + "Cell")
		var button := cell.get_node(cell_name + "Button") as Button
		button.custom_minimum_size = Vector2(230, 60)
		button.pressed.connect(_request_investment.bind(area))
		cell.get_node("Label").add_theme_font_size_override("font_size", 21)
	$InvestmentPanel/Content/EmptyBalance.add_theme_font_size_override("font_size", 20)
	$StatisticsPanel.offset_top = -370
	$StatisticsPanel.offset_bottom = 370
	$StatisticsPanel/Content.add_theme_constant_override("separation", 10)
	$StatisticsPanel/Content/Header/Title.add_theme_font_size_override("font_size", 32)
	var selector := OptionButton.new()
	for heading in ["Saldo", "Reputação", "Educação", "Saúde", "Segurança", "Desemprego", "Fome", "Saneamento", "Cultura", "Assistência social"]:
		selector.add_item(tr(heading))
	selector.item_selected.connect(func(index: int):
		_projection_key = ["funds", "reputation", "education", "health", "security", "unemployment", "hunger", "water", "culture", "social"][index]
		refresh_city())
	$StatisticsPanel/Content.add_child(selector)
	_chart = ProjectionChart.new()
	_chart.custom_minimum_size = Vector2(0, 200)
	$StatisticsPanel/Content.add_child(_chart)
	$StatisticsPanel/Content.add_child(UIFactory.label(tr("Estimativa por tendência linear; não é uma garantia. Reage às decisões futuras."), 19))
	$StatisticsPanel/Content/Description.add_theme_font_size_override("font_size", 22)
	for node_name in ["EconomyEmpty", "ApprovalEmpty"]:
		$StatisticsPanel/Content.get_node(node_name).add_theme_font_size_override("font_size", 22)

func _request_investment(area: String) -> void:
	if _investment_mode.selected == 1:
		construction_requested.emit(area)
	else:
		investment_requested.emit(area, $InvestmentPanel/Content/AmountSlider.value)

func bind_city(city: CityState) -> void:
	_city = city
	city.changed.connect(refresh_city)
	refresh_city()

func refresh_city() -> void:
	if _city == null:
		return
	set_city_indicators(_city.funds, _city.reputation)
	_housing_button.text = tr("População: %d · Moradias: +%d") % [_city.population, _city.housing_requests()]
	_housing_button.add_theme_color_override("font_disabled_color", Color("dce4dc"))
	_housing_button.disabled = _city.housing_requests() <= 0 or _city.outcome != "playing"
	_housing_button.tooltip_text = tr("A cada 150 novos habitantes, escolha onde construir uma moradia. Crescimento de 50 habitantes/mês quando a média dos serviços é de pelo menos 45 pontos. Sem custo adicional.")
	_city_label.text = "%s · %s %d/2 · %s" % [_city.city_name, tr("Mandato"), _city.term, tr(GameRules.DIFFICULTIES[_city.difficulty].name)]
	$InvestmentPanel/Content/AmountLabel.text = (tr("Valor: R$ %.0f") % $InvestmentPanel/Content/AmountSlider.value) if _investment_mode.selected == 0 else tr("Obra: R$ 35.000 · prazo de 20 dias")
	$InvestmentPanel/Content/EmptyBalance.text = tr("Escolha o serviço. Para construir, selecione depois um lote no mapa. Obras: %d/3.") % _city.projects.size()
	for area in GameRules.AREAS:
		var cell_name: String = {"education": "Education", "health": "Health", "water": "Water", "security": "Security", "culture": "Culture", "social": "Social"}[area]
		var cell := $InvestmentPanel/Content/Categories.get_node(cell_name + "Cell")
		var button := cell.get_node(cell_name + "Button") as Button
		button.disabled = _city.outcome != "playing"
		button.text = "%.0f/100" % float(_city.indicators[area])
		button.tooltip_text = "%s · %.0f/100" % [tr(GameRules.AREA_NAMES[area]), float(_city.indicators[area])]
	var description := tr("Mês %d/96 · %d respostas corretas em %d problemas · %d expirados.") % [_city.completed_months, _city.correct_count, _city.solved_count, _city.expired_count]
	$StatisticsPanel/Content/Description.text = description
	var next_funds: Dictionary = _city.projection("funds")
	$StatisticsPanel/Content/EconomyEmpty.text = tr("Saldo: R$ %.0f · Obras concluídas: %d") % [_city.funds, _city.buildings.size()]
	if bool(next_funds.get("ready", false)):
		$StatisticsPanel/Content/EconomyEmpty.text += tr(" · Estimativa em 6 meses: R$ %.0f") % float(next_funds.forecast[-1])
	$StatisticsPanel/Content/ApprovalEmpty.text = tr("Reputação: %.1f%% · Educação: %.0f · Saúde: %.0f · Segurança: %.0f\nDesemprego: %.1f%% · Fome: %.1f%%") % [_city.reputation, _city.indicators.education, _city.indicators.health, _city.indicators.security, _city.indicators.unemployment, _city.indicators.hunger]
	_chart.series = _city.projection(_projection_key)
	_chart.queue_redraw()

func show_notice(message: String) -> void:
	_notice_label.text = message

func _apply_layout() -> void:
	var header := ColorRect.new()
	header.name = "HeaderBackground"
	header.color = Color(0.10, 0.19, 0.20, 0.94)
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(header)
	move_child(header, 0)
	header.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	header.offset_bottom = 126
	$Footer.color = Color("eef1e5")
	$Calendar.offset_top = 26
	$Calendar.offset_bottom = 110
	problem_tabs.offset_top = 140
	problem_tabs.offset_bottom = 250
	$Occurrences.offset_top = 226
	_city_label.size = Vector2(850, 40)
	_notice_label.position = Vector2(260, 78)
	_notice_label.size = Vector2(1030, 38)
	_notice_label.add_theme_font_size_override("font_size", 20)
	for button in [menu_button, funds_button, reputation_button, pause_button, normal_button, fast_button, very_fast_button]:
		button.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
