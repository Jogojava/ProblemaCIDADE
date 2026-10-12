@tool
extends Control

var strokes: Array[PackedVector2Array] = []
var active_stroke := PackedVector2Array()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			active_stroke = PackedVector2Array([event.position])
		else:
			if active_stroke.size() > 1:
				strokes.append(active_stroke)
			active_stroke = PackedVector2Array()
		accept_event()
		queue_redraw()
	elif event is InputEventMouseMotion and (event.button_mask & MOUSE_BUTTON_MASK_LEFT) != 0:
		active_stroke.append(event.position)
		accept_event()
		queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("#fffef8"), true)
	for y in range(38, int(size.y), 36):
		draw_line(Vector2(0, y), Vector2(size.x, y), Color("#d8e4e2"), 1.0)
	for stroke in strokes:
		if stroke.size() > 1:
			draw_polyline(stroke, Color("#18353a"), 4.0, true)
	if active_stroke.size() > 1:
		draw_polyline(active_stroke, Color("#18353a"), 4.0, true)

func clear() -> void:
	strokes.clear()
	active_stroke.clear()
	queue_redraw()
