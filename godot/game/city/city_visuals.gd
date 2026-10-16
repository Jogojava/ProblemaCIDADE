class_name CityVisuals
extends Node2D

var state: CityState
var origin := Vector2(1056, 1780)

func bind(city: CityState) -> void:
	state = city
	city.changed.connect(queue_redraw)
	queue_redraw()

func _point(x: float, y: float) -> Vector2:
	return origin + Vector2((x - y) * 72, (x + y) * 42)

func _draw() -> void:
	var colors := [Color("d9ac7b"), Color("d8ded4"), Color("94b5c8"), Color("e2c494")]
	for i in range(18):
		var x := float(i % 6 - 3) * 1.6
		var y := float(i / 6 - 2) * 2.2
		_building(_point(x, y), colors[i % 4], 42.0 + (i % 3) * 14, false)
	_building(_point(0, 3), Color("82c7c7"), 90, false)
	draw_string(ThemeDB.fallback_font, _point(0, 3) + Vector2(-58, 30), tr("Prefeitura"), HORIZONTAL_ALIGNMENT_LEFT, 180, 20, Color.WHITE)
	if state == null:
		return
	for i in range(state.buildings.size()):
		var project: Dictionary = state.buildings[i]
		var position_value := _point(float(i % 6 - 3) * 1.7, float(i / 6 + 2) * 1.8)
		_building(position_value, Color("62bec4"), 65, false)
		draw_string(ThemeDB.fallback_font, position_value + Vector2(-50, 32), tr(GameRules.BUILDING_NAMES.get(project.area, "Obra")), HORIZONTAL_ALIGNMENT_LEFT, 200, 17, Color.WHITE)
	for i in range(state.projects.size()):
		_building(_point(float((state.buildings.size() + i) % 6 - 3) * 1.7, float((state.buildings.size() + i) / 6 + 2) * 1.8), Color("f3c65b"), 28, true)

func _building(base: Vector2, color: Color, height: float, construction: bool) -> void:
	var a := base + Vector2(-38, 0)
	var b := base + Vector2(0, 22)
	var c := base + Vector2(38, 0)
	var d := base + Vector2(0, -22)
	var up := Vector2(0, -height)
	draw_colored_polygon(PackedVector2Array([a, b, b + up, a + up]), color.darkened(0.18))
	draw_colored_polygon(PackedVector2Array([b, c, c + up, b + up]), color.darkened(0.35))
	draw_colored_polygon(PackedVector2Array([a + up, b + up, c + up, d + up]), color.lightened(0.15))
	if construction:
		draw_line(a, c + Vector2(0, -50), Color("f8d886"), 4)
	else:
		for i in range(2):
			draw_rect(Rect2(base + Vector2(-24 + 19 * i, -height + 20), Vector2(8, 12)), Color("e7fbf4"))
