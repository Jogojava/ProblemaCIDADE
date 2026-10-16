@tool
extends Control

var strokes: Array[PackedVector2Array] = []
var active_stroke := PackedVector2Array()
var _drawing := false

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_drawing = true
			active_stroke = PackedVector2Array([event.position])
		else:
			_finish_stroke()
		accept_event()
		queue_redraw()
	elif event is InputEventMouseMotion and _drawing and (event.button_mask & MOUSE_BUTTON_MASK_LEFT) != 0:
		active_stroke.append(event.position)
		accept_event()
		queue_redraw()

func _draw() -> void:
	# Keep the question visible beneath a drawing surface spanning the viewport.
	draw_rect(Rect2(Vector2.ZERO, size), Color(1.0, 1.0, 1.0, 0.08), true)
	for stroke in strokes:
		if stroke.size() > 1:
			_draw_stroke(stroke)
	if active_stroke.size() > 1:
		_draw_stroke(active_stroke)

func _draw_stroke(points: PackedVector2Array) -> void:
	draw_polyline(points, Color(1, 1, 1, 0.92), 8.0, true)
	draw_polyline(points, Color("#146b98"), 4.0, true)

func _input(event: InputEvent) -> void:
	if _drawing and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		_finish_stroke()

func _finish_stroke() -> void:
	if active_stroke.size() > 1:
		strokes.append(active_stroke)
	active_stroke = PackedVector2Array()
	_drawing = false
	queue_redraw()

func export_strokes() -> Array:
	var result: Array = []
	for stroke in strokes:
		var points: Array = []
		for point in stroke:
			points.append([point.x, point.y])
		result.append(points)
	return result

func import_strokes(data: Array) -> void:
	clear()
	for stroke in data:
		if not stroke is Array:
			continue
		var points := PackedVector2Array()
		for point in stroke:
			if point is Array and point.size() == 2:
				points.append(Vector2(float(point[0]), float(point[1])))
		if points.size() > 1:
			strokes.append(points)
	queue_redraw()

func clear() -> void:
	strokes.clear()
	active_stroke.clear()
	_drawing = false
	queue_redraw()
