extends Control

signal answer_selected(option_id: String)

@onready var title_label: Label = $Center/Panel/Margin/Content/Title
@onready var description_label: Label = $Center/Panel/Margin/Content/Description
@onready var illustration: TextureRect = $Center/Panel/Margin/Content/Body/Illustration/Texture
@onready var image_placeholder: Label = $Center/Panel/Margin/Content/Body/Illustration/Placeholder
@onready var board_overlay: PanelContainer = $BoardOverlay
@onready var drawing_area: Control = $BoardOverlay/Center/Panel/Margin/Content/DrawingArea

var _option_ids: Array[String] = ["sim", "nao", "opcao_3", "opcao_4"]

func _ready() -> void:
	var option_buttons: Array[Button] = _get_option_buttons()
	for index in range(option_buttons.size()):
		option_buttons[index].pressed.connect(_on_option_pressed.bind(index))
	$Center/Panel/Margin/Content/Body/BoardButton.pressed.connect(_show_board)
	$BoardOverlay/Center/Panel/Margin/Content/Header/ClearButton.pressed.connect(_clear_board)
	$BoardOverlay/Center/Panel/Margin/Content/Header/CloseButton.pressed.connect(_hide_board)

func configure(problem_title: String, problem_description: String, problem_image: Texture2D = null, options: Array = [], allow_board: bool = true) -> void:
	if not is_node_ready():
		await ready
	title_label.text = problem_title
	description_label.text = problem_description
	illustration.texture = problem_image
	image_placeholder.visible = problem_image == null
	$Center/Panel/Margin/Content/Body/BoardButton.visible = allow_board
	_hide_board()
	var option_buttons: Array[Button] = _get_option_buttons()
	_option_ids.clear()
	_option_ids.resize(option_buttons.size())
	for index in range(option_buttons.size()):
		var button := option_buttons[index]
		if index >= options.size() or not options[index] is Dictionary:
			button.hide()
			continue
		var option: Dictionary = options[index]
		button.text = String(option.get("text", "Opção %d" % (index + 1)))
		_option_ids[index] = String(option.get("id", option.get("text", "opcao_%d" % (index + 1))))
		button.show()

func _get_option_buttons() -> Array[Button]:
	return [
		$Center/Panel/Margin/Content/Body/Answers/Option1,
		$Center/Panel/Margin/Content/Body/Answers/Option2,
		$Center/Panel/Margin/Content/Body/Answers/Option3,
		$Center/Panel/Margin/Content/Body/Answers/Option4
	]

func _on_option_pressed(index: int) -> void:
	if index < _option_ids.size():
		answer_selected.emit(_option_ids[index])

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
