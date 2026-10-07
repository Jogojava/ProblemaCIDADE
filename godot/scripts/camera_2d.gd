extends Camera2D

@export var zoom_step := 0.1
@export var min_zoom := 0.25
@export var max_zoom := 2.0

var dragging := false

func _input(event: InputEvent) -> void:
	# A release over the HUD must also end a drag that started on the map.
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		dragging = false

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed

		if event.pressed:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				var z = min(zoom.x + zoom_step, max_zoom)
				zoom = Vector2(z, z)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				var z = max(zoom.x - zoom_step, min_zoom)
				zoom = Vector2(z, z)

	elif event is InputEventMouseMotion and dragging:
		position -= event.relative / zoom.x
