class_name ProjectionChart
extends Control

var series: Dictionary = {}

func _draw() -> void:
	var bounds := Rect2(Vector2(26, 16), size - Vector2(50, 44))
	if bounds.size.y <= 0:
		return
	draw_style_box(_background(), Rect2(Vector2.ZERO, size))
	if not bool(series.get("ready", false)):
		draw_string(ThemeDB.fallback_font, Vector2(24, 58), tr("Dados insuficientes: são necessárias 12 observações mensais."), HORIZONTAL_ALIGNMENT_LEFT, size.x - 40, 20, Color("43626d"))
		return
	var historical: Array = series.history
	var forecast: Array = series.forecast
	var values: Array = historical.duplicate()
	values.append_array(forecast)
	var low := float(values.min())
	var high := float(values.max())
	var span := maxf(1.0, high - low)
	for i in range(4):
		var y := bounds.position.y + bounds.size.y * i / 3.0
		draw_line(Vector2(bounds.position.x, y), Vector2(bounds.end.x, y), Color("c9dbda"))
	var points := PackedVector2Array()
	for i in range(values.size()):
		points.append(Vector2(bounds.position.x + bounds.size.x * i / 17.0, bounds.end.y - (float(values[i]) - low) / span * bounds.size.y))
	draw_polyline(PackedVector2Array(Array(points).slice(0, 12)), Color("176c81"), 3, true)
	for i in range(11, 17):
		draw_dashed_line(points[i], points[i + 1], Color("b0669c"), 3, 7)
	draw_string(ThemeDB.fallback_font, Vector2(30, 34), "%.0f" % high, HORIZONTAL_ALIGNMENT_LEFT, 160, 16, Color("43626d"))
	draw_string(ThemeDB.fallback_font, Vector2(30, bounds.end.y - 5), "%.0f" % low, HORIZONTAL_ALIGNMENT_LEFT, 160, 16, Color("43626d"))
	draw_string(ThemeDB.fallback_font, Vector2(26, size.y - 8), tr("12 observações · linha contínua: histórico · tracejada: estimativa de 6 meses"), HORIZONTAL_ALIGNMENT_LEFT, size.x - 45, 16, Color("43626d"))

func _background() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("e9f1f0")
	style.set_corner_radius_all(12)
	return style
