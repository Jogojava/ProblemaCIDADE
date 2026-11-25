class_name DeboraDesign
extends RefCounted

const ROOT := "res://assets/ui/debora/"

static var _cropped_cache: Dictionary = {}

static func skin(asset: String, tint := Color.WHITE, sliced := false) -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	var tex := load(ROOT + asset + ".png") as Texture2D
	if not sliced and tex != null:
		tex = _cropped_opaque_texture(asset, tex)
	style.texture = tex
	style.modulate_color = tint
	if sliced:
		for side in [SIDE_LEFT, SIDE_RIGHT, SIDE_TOP, SIDE_BOTTOM]:
			style.set_texture_margin(side, 8)
			style.set_content_margin(side, 12)
	return style

static func _cropped_opaque_texture(asset: String, tex: Texture2D) -> Texture2D:
	if _cropped_cache.has(asset):
		return _cropped_cache[asset]
	var img := tex.get_image()
	if img == null:
		_cropped_cache[asset] = tex
		return tex
	var w := img.get_width()
	var h := img.get_height()
	var used := img.get_used_rect()
	var min_x := used.position.x
	var min_y := used.position.y
	var max_x := used.position.x + used.size.x - 1
	var max_y := used.position.y + used.size.y - 1
	# Strip faint semi-transparent halos on small/medium assets like optionseng.png
	# without scanning multi-megapixel canvases in GDScript.
	if w * h <= 1048576 and used.size.x == w and used.size.y == h:
		min_x = w
		min_y = h
		max_x = -1
		max_y = -1
		for y in range(h):
			for x in range(w):
				if img.get_pixel(x, y).a > 0.8:
					if x < min_x: min_x = x
					if x > max_x: max_x = x
					if y < min_y: min_y = y
					if y > max_y: max_y = y
	var result: Texture2D = tex
	if max_x >= min_x and max_y >= min_y and not (min_x == 0 and min_y == 0 and max_x == w - 1 and max_y == h - 1):
		var atlas := AtlasTexture.new()
		atlas.atlas = tex
		atlas.region = Rect2(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)
		result = atlas
	_cropped_cache[asset] = result
	return result

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
