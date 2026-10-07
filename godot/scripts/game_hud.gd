extends Control
class_name GameHUD

signal menu_requested()
signal panels_changed(is_open: bool)

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

var _time_manager: TimeManager
var _pause_icon := preload("res://assets/ui/hud/pause.svg")
var _play_icon := preload("res://assets/ui/hud/play.svg")

func _ready() -> void:
	menu_button.pressed.connect(func(): menu_requested.emit())
	pause_button.pressed.connect(_on_pause_pressed)
	normal_button.pressed.connect(_on_speed_pressed.bind(TimeManager.Speed.NORMAL))
	fast_button.pressed.connect(_on_speed_pressed.bind(TimeManager.Speed.FAST))
	very_fast_button.pressed.connect(_on_speed_pressed.bind(TimeManager.Speed.VERY_FAST))
	funds_button.pressed.connect(_toggle_panel.bind(investment_panel))
	reputation_button.pressed.connect(_toggle_panel.bind(statistics_panel))
	for panel in [investment_panel, statistics_panel, occurrence_panel]:
		panel.get_node("Content/Header/CloseButton").pressed.connect(close_panels)
	for button in $Occurrences.get_children():
		if button is Button:
			button.pressed.connect(_open_occurrences.bind(button.tooltip_text))
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
