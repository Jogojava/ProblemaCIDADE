extends Camera2D

@export var zoom_step := 0.1
@export var min_zoom := 0.25
@export var max_zoom := 2.0

var dragging := false
var build_mode := false
var _start_position: Vector2
var _start_zoom: Vector2

func _ready() -> void:
	_start_position = position
	_start_zoom = zoom

func reset_view() -> void:
	position = _start_position
	zoom = _start_zoom

func _input(event: InputEvent) -> void:
	# A release over the HUD must also end a drag that started on the map.
	if event is InputEventMouseButton and event.button_index in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_MIDDLE] and not event.pressed:
		dragging = false

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE or (event.button_index == MOUSE_BUTTON_LEFT and not build_mode):
			dragging = event.pressed

		if event.pressed:
			var before := get_global_mouse_position()
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				var z = min(zoom.x + zoom_step, max_zoom)
				zoom = Vector2(z, z)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				var z = max(zoom.x - zoom_step, min_zoom)
				zoom = Vector2(z, z)
			force_update_scroll()
			position += before - get_global_mouse_position()

	elif event is InputEventMouseMotion and dragging:
		position -= event.relative / zoom.x
		position = position.clamp(_start_position - Vector2(1800, 1300), _start_position + Vector2(1800, 1300))
