class_name RouteGraph
extends Control

var distances: Dictionary = {}:
	set(value):
		distances = value if value != null else {}
		queue_redraw()

func _init() -> void:
	custom_minimum_size = Vector2(440, 230)

func set_graph_data(data: Dictionary) -> void:
	distances = data

func _draw() -> void:
	if not size.is_finite() or size.x <= 1.0 or size.y <= 1.0:
		return
	var font := get_theme_default_font()
	if font == null:
		font = ThemeDB.fallback_font
	if distances.get("nodes") is Array and distances.get("edges") is Array:
		_draw_dynamic_graph(font, distances.get("nodes"), distances.get("edges"), _as_string(distances.get("legend", ""), "").strip_edges())
		return
	_draw_legacy_graph(font)

func _is_dark_mode() -> bool:
	var settings := get_node_or_null("/root/SettingsService")
	return settings != null and bool(settings.call("is_dark_mode"))

func _draw_legacy_graph(font: Font) -> void:
	var dark := _is_dark_mode()
	var points := [Vector2(45, size.y / 2), Vector2(size.x / 2, 40), Vector2(size.x / 2, size.y - 40), Vector2(size.x - 45, size.y / 2)]
	var connections := [[0, 1, _as_int(distances.get("a", 0))], [1, 3, 4], [0, 2, _as_int(distances.get("b", 0))], [2, 3, 7]]
	for connection in connections:
		var from: Vector2 = points[connection[0]]
		var to: Vector2 = points[connection[1]]
		draw_line(from, to, Color("5d8999") if dark else Color("7b9da6"), 3, true)
		draw_string(font, (from + to) / 2 + Vector2(-16, -10), "%d km" % connection[2], HORIZONTAL_ALIGNMENT_LEFT, 100, 20, Color("e6f0f4") if dark else Color("20383f"))
	for i in range(points.size()):
		draw_circle(points[i], 23, Color("1f7c91") if dark else Color("17687b"))
		draw_string(font, points[i] + Vector2(-8, 8), ["P", "A", "B", "H"][i], HORIZONTAL_ALIGNMENT_LEFT, 40, 23, Color.WHITE)

func _draw_dynamic_graph(font: Font, nodes: Array, edges: Array, legend: String) -> void:
	var dark := _is_dark_mode()
	if not legend.is_empty():
		draw_string(font, Vector2(12.0, 20.0), tr(legend), HORIZONTAL_ALIGNMENT_LEFT, maxf(1.0, size.x - 24.0), 13, Color("b4cdd8") if dark else Color("2d4c56"))
	if nodes.is_empty():
		return
	var node_count := nodes.size()
	var node_radius := 16.0 if node_count > 4 else 23.0
	var node_font_size := 17 if node_count > 4 else 23
	var edge_font_size := 13 if node_count > 4 else 18
	var line_width := 2.5 if node_count > 4 else 3.0
	var pad_left := maxf(26.0, node_radius + 10.0)
	var pad_right := pad_left
	var pad_top := 36.0 if not legend.is_empty() else maxf(24.0, node_radius + 8.0)
	var pad_bottom := maxf(24.0, node_radius + 8.0)
	var usable := Vector2(maxf(1.0, size.x - pad_left - pad_right), maxf(1.0, size.y - pad_top - pad_bottom))

	var node_entries: Array[Dictionary] = []
	var node_positions: Dictionary = {}
	for i in range(node_count):
		if not nodes[i] is Dictionary:
			continue
		var node: Dictionary = nodes[i]
		var node_id := _as_string(node.get("id", str(i)), str(i))
		if node_id.strip_edges().is_empty():
			node_id = str(i)
		var node_label := _as_string(node.get("label", node_id), node_id)
		if node_label.strip_edges().is_empty():
			node_label = node_id
		var fallback_pos := _fallback_pos(i, node_count)
		var norm_pos := _to_vector2(node.get("pos", null), fallback_pos)
		if not norm_pos.is_finite():
			norm_pos = fallback_pos
		var pixel_pos := Vector2(
			pad_left + clampf(norm_pos.x, 0.0, 1.0) * usable.x,
			pad_top + clampf(norm_pos.y, 0.0, 1.0) * usable.y
		)
		if not pixel_pos.is_finite():
			continue
		node_positions[node_id] = pixel_pos
		node_entries.append({"label": node_label, "pos": pixel_pos})

	var resolved_edges: Array[Dictionary] = []
	for edge_item in edges:
		if not edge_item is Dictionary:
			continue
		var edge: Dictionary = edge_item
		var from_id := _as_string(edge.get("from", ""), "")
		var to_id := _as_string(edge.get("to", ""), "")
		if from_id.strip_edges().is_empty() or to_id.strip_edges().is_empty():
			continue
		if not node_positions.has(from_id) or not node_positions.has(to_id):
			continue
		var from_pos: Vector2 = node_positions[from_id]
		var to_pos: Vector2 = node_positions[to_id]
		if not from_pos.is_finite() or not to_pos.is_finite():
			continue
		if not from_pos.is_equal_approx(to_pos):
			draw_line(from_pos, to_pos, Color("7b9da6"), line_width, true)
		var label_raw := _as_string(edge.get("label", ""), "")
		if not label_raw.is_empty():
			resolved_edges.append({
				"from": from_pos,
				"to": to_pos,
				"label": tr(label_raw),
				"offset": _to_vector2(edge.get("label_offset", null), Vector2(0.0, -12.0))
			})

	var pill_style := StyleBoxFlat.new()
	pill_style.bg_color = Color(0.11, 0.19, 0.25, 0.94) if dark else Color(0.97, 0.99, 1.0, 0.92)
	pill_style.border_color = Color("3a5e70") if dark else Color("9ab6be")
	pill_style.set_border_width_all(1)
	pill_style.set_corner_radius_all(6)

	for edge in resolved_edges:
		var label_text: String = edge.label
		var text_size := font.get_string_size(label_text, HORIZONTAL_ALIGNMENT_LEFT, -1, edge_font_size)
		if not text_size.is_finite():
			continue
		var pad_x := 5.0
		var pad_y := 2.0
		var pill_size := Vector2(maxf(1.0, text_size.x + pad_x * 2.0), maxf(1.0, text_size.y + pad_y * 2.0))
		var offset: Vector2 = edge.offset if (edge.offset as Vector2).is_finite() else Vector2(0.0, -12.0)
		var center: Vector2 = (edge.from + edge.to) * 0.5 + offset
		if not center.is_finite():
			center = (edge.from + edge.to) * 0.5
		var min_x := pill_size.x * 0.5 + 2.0
		var max_x := size.x - pill_size.x * 0.5 - 2.0
		center.x = clampf(center.x, min_x, max_x) if min_x <= max_x else size.x * 0.5
		var min_y := pill_size.y * 0.5 + 2.0
		var max_y := size.y - pill_size.y * 0.5 - 2.0
		center.y = clampf(center.y, min_y, max_y) if min_y <= max_y else size.y * 0.5
		var pill_rect := Rect2(center - pill_size * 0.5, pill_size)
		if not pill_rect.position.is_finite() or not pill_rect.size.is_finite():
			continue
		draw_style_box(pill_style, pill_rect)
		var text_pos := Vector2(
			pill_rect.position.x + pad_x,
			pill_rect.position.y + pad_y + font.get_ascent(edge_font_size)
		)
		if text_pos.is_finite():
			draw_string(font, text_pos, label_text, HORIZONTAL_ALIGNMENT_LEFT, -1, edge_font_size, Color("e6f0f4") if dark else Color("20383f"))

	for entry in node_entries:
		var pos: Vector2 = entry.pos
		if not pos.is_finite():
			continue
		var label_text: String = entry.label
		draw_circle(pos, node_radius, Color("17687b"))
		draw_arc(pos, node_radius, 0.0, TAU, 32, Color("0f4d5c"), 1.5, true)
		var text_size := font.get_string_size(label_text, HORIZONTAL_ALIGNMENT_LEFT, -1, node_font_size)
		var text_pos := Vector2(
			pos.x - text_size.x * 0.5,
			pos.y - text_size.y * 0.5 + font.get_ascent(node_font_size)
		)
		if text_pos.is_finite():
			draw_string(font, text_pos, label_text, HORIZONTAL_ALIGNMENT_LEFT, -1, node_font_size, Color.WHITE)

func _fallback_pos(index: int, count: int) -> Vector2:
	if count <= 1:
		return Vector2(0.5, 0.5)
	var angle := -PI * 0.5 + TAU * float(index) / float(count)
	return Vector2(0.5 + 0.42 * cos(angle), 0.5 + 0.40 * sin(angle))

func _as_string(value: Variant, fallback: String = "") -> String:
	if value == null:
		return fallback
	if value is String:
		return value
	if value is StringName:
		return String(value)
	if value is int or value is bool:
		return str(value)
	if value is float:
		return str(value) if is_finite(value) else fallback
	return fallback

func _as_int(value: Variant, fallback: int = 0) -> int:
	if value is int:
		return value
	if value is float:
		return int(value) if is_finite(value) else fallback
	if value is String:
		var trimmed: String = (value as String).strip_edges()
		if trimmed.is_valid_int():
			return trimmed.to_int()
		if trimmed.is_valid_float():
			var parsed: float = trimmed.to_float()
			return int(parsed) if is_finite(parsed) else fallback
	return fallback

func _is_finite_number(value: Variant) -> bool:
	if value is int:
		return true
	if value is float:
		return is_finite(value)
	return false

func _to_vector2(value: Variant, fallback: Vector2) -> Vector2:
	var safe_fallback := fallback if fallback.is_finite() else Vector2.ZERO
	if value is Vector2:
		return value if value.is_finite() else safe_fallback
	if value is Vector2i:
		return Vector2(value)
	if value is Dictionary and value.has("x") and value.has("y"):
		var vx: Variant = value.get("x")
		var vy: Variant = value.get("y")
		if _is_finite_number(vx) and _is_finite_number(vy):
			var vec := Vector2(float(vx), float(vy))
			return vec if vec.is_finite() else safe_fallback
		return safe_fallback
	if value is Array and value.size() >= 2:
		var ax: Variant = value[0]
		var ay: Variant = value[1]
		if _is_finite_number(ax) and _is_finite_number(ay):
			var vec := Vector2(float(ax), float(ay))
			return vec if vec.is_finite() else safe_fallback
		return safe_fallback
	return safe_fallback
