extends Control
class_name ProblemTemplate

signal answer_selected(option_id: String)

@onready var title_label: Label = $Center/Panel/Margin/Content/Title
@onready var category_badge: PanelContainer = $Center/Panel/Margin/Content/Header/CategoryBadge
@onready var category_label: Label = $Center/Panel/Margin/Content/Header/CategoryBadge/Category
@onready var description_label: Label = $Center/Panel/Margin/Content/StatementCard/StatementMargin/StatementContent/Description
@onready var answer_heading: Label = $Center/Panel/Margin/Content/Body/Answers/AnswerHeading
@onready var answer_hint: Label = $Center/Panel/Margin/Content/Body/Answers/AnswerHint
@onready var illustration_panel: Panel = $Center/Panel/Margin/Content/Body/Illustration
@onready var illustration: TextureRect = $Center/Panel/Margin/Content/Body/Illustration/Texture
@onready var board_overlay: PanelContainer = $BoardOverlay
@onready var drawing_area: Control = $BoardOverlay/Center/Panel/Margin/Content/DrawingArea
@onready var answers_container: VBoxContainer = $Center/Panel/Margin/Content/Body/Answers
@onready var answer_input: LineEdit = $Center/Panel/Margin/Content/Body/Answers/AnswerInput
@onready var submit_button: Button = $Center/Panel/Margin/Content/Body/Answers/SubmitButton

var _option_ids: Array[String] = ["sim", "nao", "opcao_3", "opcao_4"]

func _ready() -> void:
	_apply_popup_styles()
	var option_buttons: Array[Button] = _get_option_buttons()
	for index in range(option_buttons.size()):
		option_buttons[index].pressed.connect(_on_option_pressed.bind(index))
	$Center/Panel/Margin/Content/Body/BoardButton.pressed.connect(_show_board)
	$BoardOverlay/Center/Panel/Margin/Content/Header/ClearButton.pressed.connect(_clear_board)
	$BoardOverlay/Center/Panel/Margin/Content/Header/CloseButton.pressed.connect(_hide_board)
	submit_button.pressed.connect(_submit_typed_answer)
	answer_input.text_submitted.connect(func(_text: String): _submit_typed_answer())

func configure(problem_title: String, problem_description: String, problem_image: Texture2D = null, options: Array = [], allow_board: bool = true, interaction_type: String = "choice", input_placeholder: String = "Digite sua resposta", category: String = "common") -> void:
	if not is_node_ready():
		await ready
	title_label.text = problem_title
	description_label.text = problem_description
	category_label.text = "PROBLEMA %s" % _category_label(category).to_upper()
	_apply_category_style(category)
	illustration.texture = problem_image
	illustration_panel.visible = problem_image != null
	answers_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL if problem_image == null else Control.SIZE_FILL
	$Center/Panel/Margin/Content/Body/BoardButton.visible = allow_board
	_hide_board()
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
		button.text = String(option.get("text", "Opção %d" % (index + 1)))
		_option_ids[index] = String(option.get("id", option.get("text", "opcao_%d" % (index + 1))))
		button.show()
		button.disabled = false
	if answer_input.visible:
		for button in option_buttons:
			button.hide()

func _apply_popup_styles() -> void:
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.98, 0.99, 1.0, 1.0)
	panel_style.border_color = Color(0.45, 0.58, 0.65, 1.0)
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(22)
	panel_style.shadow_color = Color(0.02, 0.08, 0.12, 0.35)
	panel_style.shadow_size = 18
	panel_style.shadow_offset = Vector2(0, 8)
	$Center/Panel.add_theme_stylebox_override("panel", panel_style)

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

	var board_normal := StyleBoxFlat.new()
	board_normal.bg_color = Color(0.87, 0.94, 0.97, 1.0)
	board_normal.border_color = Color(0.34, 0.62, 0.72, 1.0)
	board_normal.set_border_width_all(2)
	board_normal.set_corner_radius_all(12)
	$Center/Panel/Margin/Content/Body/BoardButton.add_theme_stylebox_override("normal", board_normal)
	$Center/Panel/Margin/Content/Body/BoardButton.add_theme_stylebox_override("hover", option_hover)
	$Center/Panel/Margin/Content/Body/BoardButton.add_theme_font_size_override("font_size", 19)
	$Center/Panel/Margin/Content/Body/BoardButton.add_theme_color_override("font_color", Color(0.13, 0.22, 0.27, 1.0))

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
	board_overlay.show()
	$Center.offset_left = -180.0
	$Center.offset_right = -180.0

func _hide_board() -> void:
	board_overlay.hide()
	$Center.offset_left = 0.0
	$Center.offset_right = 0.0

func _clear_board() -> void:
	if drawing_area.has_method("clear"):
		drawing_area.call("clear")
