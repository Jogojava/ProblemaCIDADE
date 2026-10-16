class_name UIFactory
extends RefCounted

static func label(text_value: String, font_size: int = 24) -> Label:
	var result := Label.new()
	result.text = text_value
	result.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result.add_theme_font_size_override("font_size", font_size)
	result.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return result

static func button(text_value: String, action: Callable, hint: String = "") -> Button:
	var result := Button.new()
	result.text = text_value
	result.custom_minimum_size.y = 56
	result.tooltip_text = hint if not hint.is_empty() else text_value
	result.pressed.connect(action)
	return result

static func dialog(parent: Node, title: String, width: float = 760.0) -> Dictionary:
	var overlay := Control.new()
	overlay.name = "GameDialog"
	parent.add_child(overlay)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var shade := ColorRect.new()
	shade.color = Color(0.025, 0.07, 0.09, 0.82)
	overlay.add_child(shade)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var center := CenterContainer.new()
	overlay.add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(width, 0)
	center.add_child(panel)
	var margin := MarginContainer.new()
	for side in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 28)
	panel.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 16)
	margin.add_child(column)
	column.add_child(label(title, 34))
	return {"overlay": overlay, "content": column}
