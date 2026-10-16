class_name DeboraDesign
extends RefCounted

const ROOT := "res://assets/ui/debora/"

static func skin(asset: String, tint := Color.WHITE, sliced := false) -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = load(ROOT + asset + ".png")
	style.modulate_color = tint
	if sliced:
		for side in [SIDE_LEFT, SIDE_RIGHT, SIDE_TOP, SIDE_BOTTOM]:
			style.set_texture_margin(side, 8)
			style.set_content_margin(side, 12)
	return style

static func button(button_node: Button, asset: String, baked_text := false) -> void:
	button_node.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	for state in ["normal", "hover", "pressed", "disabled"]:
		var tint := Color.WHITE
		if state == "hover": tint = Color(1.15, 1.15, 1.15)
		if state == "pressed": tint = Color(0.75, 0.75, 0.75)
		if state == "disabled": tint = Color(0.55, 0.55, 0.55, 0.7)
		button_node.add_theme_stylebox_override(state, skin(asset, tint, not baked_text))
	for state in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_disabled_color"]:
		button_node.add_theme_color_override(state, Color.TRANSPARENT if baked_text else Color.WHITE)
	button_node.add_theme_constant_override("outline_size", 0)

static func marker(button_node: Button, category: String) -> void:
	button_node.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	button_node.icon = load(ROOT + category + ".png")
	button_node.expand_icon = true
	button_node.add_theme_constant_override("icon_max_width", 64)
	button_node.text = ""
	for state in ["normal", "hover", "pressed", "disabled"]:
		button_node.add_theme_stylebox_override(state, StyleBoxEmpty.new())
