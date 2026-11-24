extends Control
class_name ProblemTemplate

signal answer_selected(option_id: String)
signal close_requested()

@onready var title_label: Label = $Center/Panel/Margin/Content/Title
@onready var category_badge: PanelContainer = $Center/Panel/Margin/Content/Header/CategoryBadge
@onready var category_label: Label = $Center/Panel/Margin/Content/Header/CategoryBadge/Category
@onready var description_label: Label = $Center/Panel/Margin/Content/StatementCard/StatementMargin/StatementContent/Description
@onready var answer_heading: Label = $Center/Panel/Margin/Content/Body/Answers/AnswerHeading
@onready var answer_hint: Label = $Center/Panel/Margin/Content/Body/Answers/AnswerHint
@onready var illustration_panel: Panel = $Center/Panel/Margin/Content/Body/Illustration
@onready var illustration: TextureRect = $Center/Panel/Margin/Content/Body/Illustration/Texture
@onready var board_overlay: Control = $BoardOverlay
@onready var drawing_area: Control = $BoardOverlay/DrawingArea
@onready var answers_container: VBoxContainer = $Center/Panel/Margin/Content/Body/Answers
@onready var answer_input: LineEdit = $Center/Panel/Margin/Content/Body/Answers/AnswerInput
@onready var submit_button: Button = $Center/Panel/Margin/Content/Body/Answers/SubmitButton
@onready var calculator_overlay: Control = $CalculatorOverlay
@onready var calculator_display: LineEdit = $CalculatorOverlay/Center/Panel/Margin/Content/Display
@onready var calculator_keys: GridContainer = $CalculatorOverlay/Center/Panel/Margin/Content/Keys
@onready var urgent_deadline: PanelContainer = $UrgentDeadline
@onready var urgent_deadline_button: Button = $UrgentDeadline/Row/UrgentOpenButton
@onready var urgent_deadline_phase: Label = $UrgentDeadline/Row/UrgentTimer/Phase
@onready var urgent_deadline_progress: ProgressBar = $UrgentDeadline/Row/UrgentTimer/TimerRow/Progress
@onready var urgent_deadline_countdown: Label = $UrgentDeadline/Row/UrgentTimer/TimerRow/Countdown

var _option_ids: Array[String] = ["sim", "nao", "opcao_3", "opcao_4"]
var _calculator_value := "0"
var _calculator_stored_value := 0.0
var _calculator_operator := ""
var _calculator_replace_value := true
var _draft_snapshot: Array = []

func _ready() -> void:
	_apply_popup_styles()
	var option_buttons: Array[Button] = _get_option_buttons()
	for index in range(option_buttons.size()):
		option_buttons[index].pressed.connect(_on_option_pressed.bind(index))
	$Center/Panel/Margin/Content/Body/ProblemTools/BoardButton.pressed.connect(_show_board)
	$Center/Panel/Margin/Content/Body/ProblemTools/CalculatorButton.pressed.connect(_show_calculator)
	$Center/Panel/Margin/Content/Header/CloseButton.pressed.connect(func(): close_requested.emit())
	$BoardOverlay/Toolbar/Content/ClearButton.pressed.connect(_clear_board)
	$BoardOverlay/Toolbar/Content/CloseButton.pressed.connect(_hide_board)
	$CalculatorOverlay/Center/Panel/Margin/Content/Header/CloseButton.pressed.connect(_hide_calculator)
	for key_button in calculator_keys.get_children():
		if key_button is Button:
			key_button.pressed.connect(_on_calculator_key_pressed.bind(key_button.text))
	submit_button.pressed.connect(_submit_typed_answer)
	answer_input.text_submitted.connect(func(_text: String): _submit_typed_answer())

func _input(event: InputEvent) -> void:
	if not visible or not calculator_overlay.visible:
		return
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	var key_event := event as InputEventKey
	if key_event.ctrl_pressed or key_event.alt_pressed or key_event.meta_pressed:
		return
	if key_event.keycode == KEY_ESCAPE:
		return
	var mapped_key := _map_calculator_key(key_event)
	if mapped_key.is_empty():
		return
	_on_calculator_key_pressed(mapped_key)
	get_viewport().set_input_as_handled()

func _map_calculator_key(event: InputEventKey) -> String:
	if event.unicode > 0:
		var ch := String.chr(event.unicode)
		if ch.length() == 1 and ch >= "0" and ch <= "9":
			return ch
		match ch:
			",", ".":
				return ","
			"+":
				return "+"
			"-":
				return "−"
			"*":
				return "×"
			"/":
				return "÷"
			"%":
				return "%"
			"=":
				return "="
			"c", "C":
				return "C"
	match event.keycode:
		KEY_0, KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9:
			return str(event.keycode - KEY_0)
		KEY_KP_0, KEY_KP_1, KEY_KP_2, KEY_KP_3, KEY_KP_4, KEY_KP_5, KEY_KP_6, KEY_KP_7, KEY_KP_8, KEY_KP_9:
			return str(event.keycode - KEY_KP_0)
		KEY_COMMA, KEY_PERIOD, KEY_KP_PERIOD:
			return ","
		KEY_PLUS, KEY_KP_ADD:
			return "+"
		KEY_MINUS, KEY_KP_SUBTRACT:
			return "−"
		KEY_ASTERISK, KEY_KP_MULTIPLY:
			return "×"
		KEY_SLASH, KEY_KP_DIVIDE:
			return "÷"
		KEY_PERCENT:
			return "%"
		KEY_ENTER, KEY_KP_ENTER, KEY_EQUAL:
			return "="
		KEY_BACKSPACE:
			return "⌫"
		KEY_C, KEY_DELETE:
			return "C"
		_:
			return ""

func configure(problem_title: String, problem_description: String, problem_image: Texture2D = null, options: Array = [], allow_board: bool = true, interaction_type: String = "choice", input_placeholder: String = "Digite sua resposta", category: String = "common") -> void:
	if not is_node_ready():
		await ready
	title_label.text = problem_title
	urgent_deadline.hide()
	description_label.text = problem_description
	category_label.text = tr("PROBLEMA %s") % tr(_category_label(category)).to_upper()
	_apply_category_style(category)
	illustration.texture = problem_image
	illustration_panel.visible = problem_image != null
	answers_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL if problem_image == null else Control.SIZE_FILL
	$Center/Panel/Margin/Content/Body/ProblemTools/BoardButton.visible = allow_board
	_hide_board()
	_hide_calculator(false)
	_reset_calculator()
	answer_input.clear()
	answer_input.placeholder_text = input_placeholder
	answer_input.visible = interaction_type == "number_input" or interaction_type == "text_input"
	submit_button.visible = answer_input.visible
	answer_heading.text = "DIGITE SUA RESPOSTA" if answer_input.visible else "ESCOLHA UMA RESPOSTA"
	answer_hint.text = "Confira os dados do enunciado antes de enviar." if answer_input.visible else "Selecione a alternativa que considera correta."
	var option_buttons: Array[Button] = _get_option_buttons()
	_option_ids.clear()
	for index in range(option_buttons.size()):
		var button := option_buttons[index]
		_option_ids.append("")
		if index >= options.size() or not options[index] is Dictionary:
			button.hide()
			continue
		var option: Dictionary = options[index]
		button.text = tr(String(option.get("text", "Opção %d" % (index + 1))))
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.tooltip_text = button.text
		_option_ids[index] = String(option.get("id", option.get("text", "opcao_%d" % (index + 1))))
		button.show()
		button.disabled = false
	if answer_input.visible:
		for button in option_buttons:
			button.hide()
		answer_input.grab_focus()
	elif not option_buttons.is_empty():
		option_buttons[0].grab_focus()

func set_urgent_deadline(seconds: float, title: String, urgent_count: int, phase: String, total_seconds: float = 180.0) -> void:
	urgent_deadline.show()
	urgent_deadline_button.text = tr("%s  (%d)") % [tr(title), maxi(1, urgent_count)]
	urgent_deadline_phase.text = tr("PARA RESPONDER") if phase == "solving" else tr("PARA ABRIR")
	urgent_deadline_progress.max_value = maxf(1.0, total_seconds)
	urgent_deadline_progress.value = clampf(seconds, 0.0, urgent_deadline_progress.max_value)
	var whole_seconds := maxi(0, ceili(seconds))
	urgent_deadline_countdown.text = "%02d:%02d" % [floori(float(whole_seconds) / 60.0), whole_seconds % 60]

func show_route_graph(distances: Dictionary) -> void:
	answers_container.size_flags_horizontal = Control.SIZE_FILL
	var graph := RouteGraph.new()
	graph.distances = distances
	graph.custom_minimum_size = Vector2(440, 230)
	illustration_panel.show()
	illustration.hide()
	illustration_panel.add_child(graph)
	graph.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func _apply_popup_styles() -> void:
	var image_style := StyleBoxFlat.new()
	image_style.bg_color = Color("e6f0f1")
	image_style.set_corner_radius_all(10)
	illustration_panel.add_theme_stylebox_override("panel", image_style)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.98, 0.99, 1.0, 1.0)
	panel_style.border_color = Color(0.45, 0.58, 0.65, 1.0)
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(22)
	panel_style.shadow_color = Color(0.02, 0.08, 0.12, 0.35)
	panel_style.shadow_size = 18
	panel_style.shadow_offset = Vector2(0, 8)
	$Center/Panel.add_theme_stylebox_override("panel", panel_style)
	var deadline_style := StyleBoxFlat.new()
	deadline_style.bg_color = Color("edf3f0")
	deadline_style.border_color = Color("b7d0d1")
	deadline_style.set_border_width_all(2)
	deadline_style.set_corner_radius_all(24)
	deadline_style.content_margin_left = 14
	deadline_style.content_margin_right = 14
	deadline_style.content_margin_top = 8
	deadline_style.content_margin_bottom = 8
	urgent_deadline.add_theme_stylebox_override("panel", deadline_style)
	urgent_deadline_button.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	urgent_deadline_button.icon = load(DeboraDesign.ROOT + EventDatabase.CATEGORY_URGENT + ".png")
	urgent_deadline_button.expand_icon = true
	urgent_deadline_button.add_theme_constant_override("icon_max_width", 28)
	urgent_deadline_button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	urgent_deadline_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var urgent_accent := Color(0.78, 0.2, 0.18)
	var urgent_normal := StyleBoxFlat.new()
	urgent_normal.bg_color = urgent_accent.darkened(0.5)
	urgent_normal.border_color = urgent_accent
	urgent_normal.set_border_width_all(2)
	urgent_normal.set_corner_radius_all(8)
	var urgent_hover := urgent_normal.duplicate() as StyleBoxFlat
	urgent_hover.bg_color = urgent_accent.darkened(0.3)
	urgent_deadline_button.add_theme_stylebox_override("normal", urgent_normal)
	urgent_deadline_button.add_theme_stylebox_override("hover", urgent_hover)
	urgent_deadline_button.add_theme_stylebox_override("pressed", urgent_hover)
	for state in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		urgent_deadline_button.add_theme_color_override(state, Color.WHITE)
	var deadline_fill := StyleBoxFlat.new()
	deadline_fill.bg_color = Color("e23b32")
	deadline_fill.set_corner_radius_all(6)
	var deadline_background := StyleBoxFlat.new()
	deadline_background.bg_color = Color("354b52")
	deadline_background.set_corner_radius_all(6)
	urgent_deadline_progress.add_theme_stylebox_override("fill", deadline_fill)
	urgent_deadline_progress.add_theme_stylebox_override("background", deadline_background)

	var statement_style := StyleBoxFlat.new()
	statement_style.bg_color = Color(0.91, 0.96, 0.98, 1.0)
	statement_style.border_color = Color(0.76, 0.85, 0.89, 1.0)
	statement_style.set_border_width_all(1)
	statement_style.set_corner_radius_all(14)
	$Center/Panel/Margin/Content/StatementCard.add_theme_stylebox_override("panel", statement_style)

	var input_style := StyleBoxFlat.new()
	input_style.bg_color = Color.WHITE
	input_style.border_color = Color(0.6, 0.7, 0.75, 1.0)
	input_style.set_border_width_all(2)
	input_style.set_corner_radius_all(10)
	answer_input.add_theme_stylebox_override("normal", input_style)
	answer_input.add_theme_stylebox_override("focus", input_style)

	var option_normal := StyleBoxFlat.new()
	option_normal.bg_color = Color(0.94, 0.97, 0.98, 1.0)
	option_normal.border_color = Color(0.57, 0.69, 0.75, 1.0)
	option_normal.set_border_width_all(2)
	option_normal.set_corner_radius_all(12)
	var option_hover := option_normal.duplicate() as StyleBoxFlat
	option_hover.bg_color = Color(0.84, 0.94, 0.98, 1.0)
	option_hover.border_color = Color(0.2, 0.61, 0.76, 1.0)
	for button in _get_option_buttons():
		button.add_theme_stylebox_override("normal", option_normal)
		button.add_theme_stylebox_override("hover", option_hover)
		button.add_theme_stylebox_override("pressed", option_hover)
		button.add_theme_font_size_override("font_size", 22)
		button.custom_minimum_size = Vector2(button.custom_minimum_size.x, 70)
		button.add_theme_color_override("font_color", Color(0.13, 0.22, 0.27, 1.0))
		button.add_theme_color_override("font_focus_color", Color(0.13, 0.22, 0.27, 1.0))
		button.add_theme_color_override("font_hover_color", Color(0.13, 0.22, 0.27, 1.0))
		button.add_theme_color_override("font_pressed_color", Color(0.13, 0.22, 0.27, 1.0))

	var board_normal := StyleBoxFlat.new()
	board_normal.bg_color = Color(0.87, 0.94, 0.97, 1.0)
	board_normal.border_color = Color(0.34, 0.62, 0.72, 1.0)
	board_normal.set_border_width_all(2)
	board_normal.set_corner_radius_all(12)
	for tool_button in [$Center/Panel/Margin/Content/Body/ProblemTools/BoardButton, $Center/Panel/Margin/Content/Body/ProblemTools/CalculatorButton]:
		tool_button.add_theme_stylebox_override("normal", board_normal)
		tool_button.add_theme_stylebox_override("hover", option_hover)
		tool_button.add_theme_stylebox_override("pressed", option_hover)
		tool_button.add_theme_font_size_override("font_size", 19)
		tool_button.add_theme_color_override("font_color", Color(0.13, 0.22, 0.27, 1.0))
		tool_button.add_theme_color_override("font_focus_color", Color(0.13, 0.22, 0.27, 1.0))
		tool_button.add_theme_color_override("font_hover_color", Color(0.13, 0.22, 0.27, 1.0))
		tool_button.add_theme_color_override("font_pressed_color", Color(0.13, 0.22, 0.27, 1.0))
	var calculator_panel_style := StyleBoxFlat.new()
	calculator_panel_style.bg_color = Color("f7fafb")
	calculator_panel_style.border_color = Color("53727c")
	calculator_panel_style.set_border_width_all(2)
	calculator_panel_style.set_corner_radius_all(18)
	$CalculatorOverlay/Center/Panel.add_theme_stylebox_override("panel", calculator_panel_style)
	var display_style := StyleBoxFlat.new()
	display_style.bg_color = Color("18343f")
	display_style.border_color = Color("41616b")
	display_style.set_border_width_all(2)
	display_style.set_corner_radius_all(10)
	calculator_display.add_theme_stylebox_override("normal", display_style)
	calculator_display.add_theme_stylebox_override("read_only", display_style)
	calculator_display.add_theme_stylebox_override("focus", display_style)
	calculator_display.add_theme_color_override("font_color", Color("f5fbfc"))
	calculator_display.add_theme_color_override("font_uneditable_color", Color("f5fbfc"))
	calculator_display.add_theme_color_override("caret_color", Color("f5fbfc"))
	var key_normal := StyleBoxFlat.new()
	key_normal.bg_color = Color("edf3f5")
	key_normal.border_color = Color("a8bec5")
	key_normal.set_border_width_all(1)
	key_normal.set_corner_radius_all(10)
	var key_hover := key_normal.duplicate() as StyleBoxFlat
	key_hover.bg_color = Color("d8e8ec")
	key_hover.border_color = Color("658792")
	var utility_normal := key_normal.duplicate() as StyleBoxFlat
	utility_normal.bg_color = Color("dbe7ea")
	var utility_hover := key_hover.duplicate() as StyleBoxFlat
	utility_hover.bg_color = Color("c6dbe0")
	var operator_normal := key_normal.duplicate() as StyleBoxFlat
	operator_normal.bg_color = Color("236b78")
	operator_normal.border_color = Color("18515c")
	var operator_hover := operator_normal.duplicate() as StyleBoxFlat
	operator_hover.bg_color = Color("2d8290")
	for key_button in calculator_keys.get_children():
		if key_button is Button:
			var button_style := key_normal
			var button_hover_style := key_hover
			var button_color := Color("18313a")
			if ["C", "⌫", "%", "±"].has(key_button.text):
				button_style = utility_normal
				button_hover_style = utility_hover
			elif ["+", "−", "×", "÷", "="].has(key_button.text):
				button_style = operator_normal
				button_hover_style = operator_hover
				button_color = Color.WHITE
			key_button.add_theme_stylebox_override("normal", button_style)
			key_button.add_theme_stylebox_override("hover", button_hover_style)
			key_button.add_theme_stylebox_override("pressed", button_hover_style)
			key_button.add_theme_font_size_override("font_size", 22)
			key_button.add_theme_color_override("font_color", button_color)
			key_button.add_theme_color_override("font_focus_color", button_color)
			key_button.add_theme_color_override("font_hover_color", button_color)
			key_button.add_theme_color_override("font_pressed_color", button_color)
			key_button.custom_minimum_size = Vector2(76, 58)

func _apply_category_style(category: String) -> void:
	var accent := Color(0.25, 0.62, 0.78, 1.0)
	match category:
		"common": accent = Color(0.36, 0.66, 0.27, 1.0)
		"important": accent = Color(0.88, 0.67, 0.12, 1.0)
		"urgent": accent = Color(0.78, 0.2, 0.18, 1.0)
	var badge_style := StyleBoxFlat.new()
	badge_style.bg_color = accent
	badge_style.border_color = accent.darkened(0.2)
	badge_style.set_border_width_all(1)
	badge_style.set_corner_radius_all(18)
	category_badge.add_theme_stylebox_override("panel", badge_style)
	category_label.add_theme_color_override("font_color", Color.WHITE)

func _category_label(category: String) -> String:
	match category:
		"optional": return "Opcional"
		"common": return "Comum"
		"important": return "Prioritário"
		"urgent": return "Urgente"
		_: return "Comum"

func _get_option_buttons() -> Array[Button]:
	return [
		$Center/Panel/Margin/Content/Body/Answers/Option1,
		$Center/Panel/Margin/Content/Body/Answers/Option2,
		$Center/Panel/Margin/Content/Body/Answers/Option3,
		$Center/Panel/Margin/Content/Body/Answers/Option4
	]

func _on_option_pressed(index: int) -> void:
	if index < _option_ids.size() and not _option_ids[index].is_empty():
		answer_selected.emit(_option_ids[index])

func _submit_typed_answer() -> void:
	var answer := answer_input.text.strip_edges()
	if answer.is_empty():
		return
	answer_selected.emit(answer)

func _show_board() -> void:
	_hide_calculator(false)
	drawing_area.import_strokes(_draft_snapshot)
	board_overlay.show()

func _hide_board() -> void:
	_draft_snapshot = drawing_area.export_strokes()
	board_overlay.hide()

func dismiss() -> void:
	if calculator_overlay.visible:
		_hide_calculator()
	elif board_overlay.visible:
		_hide_board()
	else:
		close_requested.emit()

func _show_calculator() -> void:
	_hide_board()
	calculator_overlay.show()
	calculator_display.grab_focus()

func _hide_calculator(restore_focus: bool = true) -> void:
	calculator_overlay.hide()
	if restore_focus and is_inside_tree() and visible and answer_input.visible:
		answer_input.grab_focus()

func _reset_calculator() -> void:
	_calculator_value = "0"
	_calculator_stored_value = 0.0
	_calculator_operator = ""
	_calculator_replace_value = true
	if calculator_display != null:
		calculator_display.text = _calculator_value

func _on_calculator_key_pressed(key: String) -> void:
	if key.length() == 1 and key.is_valid_int():
		if _calculator_replace_value or _calculator_value == "Erro":
			_calculator_value = key
			_calculator_replace_value = false
		elif _calculator_value.length() < 14:
			_calculator_value = key if _calculator_value == "0" else _calculator_value + key
	elif key == ",":
		if _calculator_replace_value or _calculator_value == "Erro":
			_calculator_value = "0,"
			_calculator_replace_value = false
		elif not _calculator_value.contains(",") and _calculator_value.length() < 14:
			_calculator_value += ","
	elif key == "C":
		_reset_calculator()
		return
	elif key == "⌫":
		if _calculator_replace_value or _calculator_value == "Erro":
			_calculator_value = "0"
			_calculator_replace_value = true
		else:
			_calculator_value = _calculator_value.left(_calculator_value.length() - 1)
			if _calculator_value.is_empty() or _calculator_value == "-":
				_calculator_value = "0"
	elif key == "±":
		if _calculator_value != "0" and _calculator_value != "Erro":
			_calculator_value = _calculator_value.substr(1) if _calculator_value.begins_with("-") else "-" + _calculator_value
		_calculator_replace_value = false
	elif key == "%":
		if _calculator_value != "Erro":
			_calculator_value = _format_calculator_number(_calculator_number() / 100.0)
			_calculator_replace_value = true
	elif key in ["+", "−", "×", "÷"]:
		_set_calculator_operator(key)
		return
	elif key == "=":
		if not _calculator_operator.is_empty() and _calculator_value != "Erro":
			if not _calculator_replace_value:
				var result := _calculate(_calculator_stored_value, _calculator_number(), _calculator_operator)
				_calculator_value = _format_calculator_number(result) if is_finite(result) else "Erro"
			else:
				_calculator_value = _format_calculator_number(_calculator_stored_value)
			_calculator_operator = ""
			_calculator_replace_value = true
	calculator_display.text = _calculator_value

func _set_calculator_operator(operator: String) -> void:
	if _calculator_value == "Erro":
		_reset_calculator()
	if not _calculator_operator.is_empty() and not _calculator_replace_value:
		var result := _calculate(_calculator_stored_value, _calculator_number(), _calculator_operator)
		if not is_finite(result):
			_calculator_value = "Erro"
			_calculator_operator = ""
			_calculator_replace_value = true
			calculator_display.text = _calculator_value
			return
		_calculator_value = _format_calculator_number(result)
		_calculator_stored_value = _calculator_number()
	else:
		_calculator_stored_value = _calculator_number()
	_calculator_operator = operator
	_calculator_replace_value = true
	calculator_display.text = _calculator_value

func _calculator_number() -> float:
	return float(_calculator_value.replace(",", ".")) if _calculator_value != "Erro" else 0.0

func _calculate(left: float, right: float, operator: String) -> float:
	match operator:
		"+": return left + right
		"−": return left - right
		"×": return left * right
		"÷": return left / right if right != 0.0 else NAN
	return right

func _format_calculator_number(value: float) -> String:
	var result := String.num(value, 6)
	while result.contains(".") and result.ends_with("0"):
		result = result.left(result.length() - 1)
	if result.ends_with("."):
		result = result.left(result.length() - 1)
	return result.replace(".", ",")

func export_draft() -> Array:
	_draft_snapshot = drawing_area.export_strokes()
	return _draft_snapshot.duplicate(true)

func restore_draft(strokes: Array, answer: String) -> void:
	drawing_area.import_strokes(strokes)
	_draft_snapshot = drawing_area.export_strokes()
	answer_input.text = answer

func _clear_board() -> void:
	if drawing_area.has_method("clear"):
		drawing_area.call("clear")
	_draft_snapshot.clear()
