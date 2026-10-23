class_name CityVisuals
extends Node2D

signal lot_selected(lot: Dictionary)
signal placement_cancelled()

const MAP_RADIUS := 12
const HALF_TILE := Vector2(64, 40)
var state: CityState
var origin := Vector2(1056, 1780)
var placing := false
var placement_area := ""
var hovered := Vector2i(999, 999)
var lots: Array[Dictionary] = []

func bind(city: CityState) -> void:
	state = city
	for x in range(-MAP_RADIUS, MAP_RADIUS + 1):
		for y in range(-MAP_RADIUS, MAP_RADIUS + 1):
			if not _road(x, y):
				lots.append({"x": x, "y": y})
	city.configure_lots(lots)
	city.changed.connect(queue_redraw)
	queue_redraw()

func _road(x: int, y: int) -> bool:
	return x == 0 or y == 0 or absi(x) == 6 or absi(y) == 6

func point(lot: Dictionary) -> Vector2:
	return origin + Vector2((float(lot.x) - float(lot.y)) * HALF_TILE.x, (float(lot.x) + float(lot.y)) * HALF_TILE.y)

func lot_at(world: Vector2) -> Dictionary:
	var delta := world - origin
	return {"x": roundi((delta.x / HALF_TILE.x + delta.y / HALF_TILE.y) / 2.0), "y": roundi((delta.y / HALF_TILE.y - delta.x / HALF_TILE.x) / 2.0)}

func begin_placement(area: String) -> void:
	placement_area = area
	placing = true
	hovered = Vector2i(999, 999)
	queue_redraw()

func end_placement() -> void:
	placing = false
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if not placing:
		return
	if event is InputEventMouseMotion:
		var lot := lot_at(get_global_transform_with_canvas().affine_inverse() * event.position)
		hovered = Vector2i(int(lot.x), int(lot.y))
		queue_redraw()
	elif event is InputEventMouseButton and event.button_index in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT]:
		get_viewport().set_input_as_handled()
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_RIGHT:
				placement_cancelled.emit()
			else:
				lot_selected.emit(lot_at(get_global_transform_with_canvas().affine_inverse() * event.position))

func _diamond(base: Vector2, inset := 0.0) -> PackedVector2Array:
	return PackedVector2Array([base + Vector2(-64 + inset, 0), base + Vector2(0, -40 + inset), base + Vector2(64 - inset, 0), base + Vector2(0, 40 - inset)])

func _draw() -> void:
	# All lots, previews and buildings share the same isometric transform.
	for depth in range(-MAP_RADIUS * 2, MAP_RADIUS * 2 + 1):
		for x in range(-MAP_RADIUS, MAP_RADIUS + 1):
			var y := depth - x
			if absi(y) > MAP_RADIUS:
				continue
			var base := point({"x": x, "y": y})
			var road := _road(x, y)
			var shade := posmod(x * 7 + y * 13, 4)
			var color := Color("334a50") if road else Color("73945b").lightened(shade * 0.018)
			draw_colored_polygon(_diamond(base), color)
			if not road:
				draw_polyline(_closed(_diamond(base)), Color(0.27, 0.39, 0.22, 0.12), 1)
				if placing and state.can_build({"x": x, "y": y}):
					draw_polyline(_closed(_diamond(base, 3)), Color(0.8, 1, 0.76, 0.35), 1.5)
				if not placing and state != null and state.can_build({"x": x, "y": y}) and posmod(x * 19 + y * 31, 17) == 0:
					_tree(base + Vector2(15, -3))
			elif not _road(x - 1, y) or not _road(x, y - 1):
				draw_polyline(_closed(_diamond(base, 3)), Color("52676a"), 3)
			if road and x != 0 and y == 0 and posmod(x, 2) == 1:
				draw_line(base + Vector2(-16, -10), base + Vector2(16, 10), Color("bec9ad"), 2)
	if state == null:
		return
	var objects: Array[Dictionary] = []
	objects.append({"lot": state.town_hall, "area": "hall"})
	for home in state.residences:
		objects.append({"lot": home.lot, "area": "home", "variant": home.variant})
	for building in state.buildings:
		objects.append(building)
	for project in state.projects:
		var item := project.duplicate()
		item["construction"] = true
		objects.append(item)
	objects.sort_custom(func(a: Dictionary, b: Dictionary): return point(a.lot).y < point(b.lot).y)
	for item in objects:
		_draw_structure(point(item.lot), String(item.get("area", "home")), int(item.get("variant", 0)), bool(item.get("construction", false)))
	if placing and hovered != Vector2i(999, 999):
		var lot := {"x": hovered.x, "y": hovered.y}
		var valid := state.can_build(lot)
		var base := point(lot)
		var tint := Color("a3e9ac") if valid else Color("f18170")
		draw_colored_polygon(_diamond(base, 2), Color(tint, 0.55))
		draw_polyline(_closed(_diamond(base, 2)), tint, 3)
		if valid:
			_draw_structure(base, placement_area, 0, true)

func _closed(polygon: PackedVector2Array) -> PackedVector2Array:
	var result := polygon.duplicate()
	result.append(polygon[0])
	return result

func _draw_structure(base: Vector2, area: String, variant: int, construction: bool) -> void:
	var home := area == "home"
	var colors := [Color("e2c29a"), Color("cbd4bf"), Color("a5c4ca"), Color("e4ceaa")]
	var accent: Color = {"education": Color("e9bf59"), "health": Color("d37871"), "water": Color("63b3cc"), "security": Color("6e8bbb"), "culture": Color("ac86b8"), "social": Color("a2bd7c"), "hall": Color("5aa5a0")}.get(area, colors[variant % 4])
	var h := 40.0 + variant * 8 if home else 68.0
	var width := 32.0 if home else 42.0
	var a := base + Vector2(-width, 0)
	var b := base + Vector2(0, width * 0.62)
	var c := base + Vector2(width, 0)
	var d := base + Vector2(0, -width * 0.62)
	var up := Vector2(0, -h)
	draw_colored_polygon(PackedVector2Array([a + Vector2(4, 12), b + Vector2(17, 8), c + Vector2(28, 7), d + Vector2(10, 8)]), Color(0.08, 0.15, 0.12, 0.22))
	draw_colored_polygon(_diamond(base, 11), Color("c3bb9d"))
	if construction:
		draw_colored_polygon(PackedVector2Array([a, b, c, d]), Color("c9ab71"))
		for support in [a, b, c, d]:
			draw_line(support, support + Vector2(0, -42), Color("e9c475"), 4)
		draw_line(a + Vector2(0, -42), c + Vector2(0, -42), Color("f5d18b"), 4)
		draw_line(a, c + Vector2(0, -42), Color("f5d18b"), 2)
		return
	var wall: Color = colors[variant % 4] if home else Color("e8e1cd")
	draw_colored_polygon(PackedVector2Array([a, b, b + up, a + up]), wall)
	draw_colored_polygon(PackedVector2Array([b, c, c + up, b + up]), wall.darkened(0.22))
	var peak := Vector2(0, -18 if home else -8)
	draw_colored_polygon(PackedVector2Array([a + up, d + up + peak, c + up, b + up + peak]), accent.darkened(0.2))
	draw_colored_polygon(PackedVector2Array([a + up, b + up, c + up, b + up + peak]), accent)
	for i in range(2):
		draw_rect(Rect2(base + Vector2(-width + 10 + 13 * i, -h + 18 + i * 6), Vector2(7, 10)), Color("55797d"))
	draw_rect(Rect2(base + Vector2(8, -18), Vector2(9, 20)), Color("5e665b"))
	if not home:
		draw_circle(base + Vector2(16, -h + 18), 7, accent)
		var symbol: String = {"health": "+", "education": "E", "water": "~", "security": "S", "culture": "C", "social": "A", "hall": "P"}.get(area, "")
		draw_string(ThemeDB.fallback_font, base + Vector2(11, -h + 23), symbol, HORIZONTAL_ALIGNMENT_LEFT, 25, 14, Color.WHITE)
		if area == "hall":
			draw_string(ThemeDB.fallback_font, base + Vector2(-48, 39), tr("Prefeitura"), HORIZONTAL_ALIGNMENT_LEFT, 120, 17, Color("f5f1dc"))

func _tree(base: Vector2) -> void:
	draw_ellipse_shadow(base)
	draw_line(base, base + Vector2(0, -24), Color("77654b"), 5)
	draw_circle(base + Vector2(0, -29), 19, Color("436e53"))
	draw_circle(base + Vector2(-5, -35), 15, Color("5b8962"))
	draw_circle(base + Vector2(-10, -38), 7, Color("79965d"))

func draw_ellipse_shadow(base: Vector2) -> void:
	draw_colored_polygon(PackedVector2Array([base + Vector2(-18, 0), base + Vector2(0, -8), base + Vector2(26, 3), base + Vector2(4, 12)]), Color(0.16, 0.27, 0.14, 0.22))
