class_name RouteGraph
extends Control

var distances: Dictionary = {}

func _draw() -> void:
	var points := [Vector2(45, size.y / 2), Vector2(size.x / 2, 40), Vector2(size.x / 2, size.y - 40), Vector2(size.x - 45, size.y / 2)]
	var connections := [[0, 1, int(distances.get("a", 0))], [1, 3, 4], [0, 2, int(distances.get("b", 0))], [2, 3, 7]]
	for connection in connections:
		var from: Vector2 = points[connection[0]]
		var to: Vector2 = points[connection[1]]
		draw_line(from, to, Color("7b9da6"), 3, true)
		draw_string(ThemeDB.fallback_font, (from + to) / 2 + Vector2(-16, -10), "%d km" % connection[2], HORIZONTAL_ALIGNMENT_LEFT, 100, 20, Color("20383f"))
	for i in range(points.size()):
		draw_circle(points[i], 23, Color("17687b"))
		draw_string(ThemeDB.fallback_font, points[i] + Vector2(-8, 8), ["P", "A", "B", "H"][i], HORIZONTAL_ALIGNMENT_LEFT, 40, 23, Color.WHITE)
