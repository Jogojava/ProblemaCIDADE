class_name SkyBackground
extends CanvasLayer

const SKY_TEXTURE_PATH := "res://assets/city/sky/background_sky.jpeg"
const NIGHT_SKY_TEXTURE_PATH := "res://assets/city/sky/night_sky.jpeg"
const CLOUD_PATHS := [
	"res://assets/city/sky/small_cloud.png",
	"res://assets/city/sky/medium_cloud.png",
	"res://assets/city/sky/big_cloud.png",
]

const CLOUD_LAYOUTS := [
	{"kind": 2, "x_ratio": 0.08, "y_ratio": 0.08, "width": 360.0, "speed": 14.0, "alpha": 0.88},
	{"kind": 0, "x_ratio": 0.32, "y_ratio": 0.16, "width": 200.0, "speed": 26.0, "alpha": 0.82},
	{"kind": 1, "x_ratio": 0.62, "y_ratio": 0.06, "width": 290.0, "speed": 19.0, "alpha": 0.86},
	{"kind": 2, "x_ratio": 0.86, "y_ratio": 0.22, "width": 340.0, "speed": 12.0, "alpha": 0.80},
	{"kind": 1, "x_ratio": 0.18, "y_ratio": 0.42, "width": 260.0, "speed": 22.0, "alpha": 0.76},
	{"kind": 0, "x_ratio": 0.50, "y_ratio": 0.34, "width": 190.0, "speed": 30.0, "alpha": 0.78},
	{"kind": 1, "x_ratio": 0.78, "y_ratio": 0.54, "width": 280.0, "speed": 18.0, "alpha": 0.74},
	{"kind": 0, "x_ratio": 0.12, "y_ratio": 0.72, "width": 210.0, "speed": 24.0, "alpha": 0.72},
	{"kind": 2, "x_ratio": 0.58, "y_ratio": 0.78, "width": 330.0, "speed": 15.0, "alpha": 0.76},
]

var _clouds: Array[Dictionary] = []
var _viewport_size := Vector2(1920.0, 1080.0)
var _sky_rect: TextureRect
var _day_sky_tex: Texture2D
var _night_sky_tex: Texture2D

func _init() -> void:
	layer = -10
	name = "SkyBackground"

func _ready() -> void:
	var root_control := Control.new()
	root_control.name = "SkyRoot"
	root_control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root_control)

	_day_sky_tex = load(SKY_TEXTURE_PATH) as Texture2D
	if ResourceLoader.exists(NIGHT_SKY_TEXTURE_PATH):
		_night_sky_tex = load(NIGHT_SKY_TEXTURE_PATH) as Texture2D

	_sky_rect = TextureRect.new()
	_sky_rect.name = "SkyTexture"
	_sky_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_sky_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sky_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_sky_rect.stretch_mode = TextureRect.STRETCH_SCALE
	_sky_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_sky_rect.texture = _day_sky_tex
	root_control.add_child(_sky_rect)

	var cloud_textures: Array[Texture2D] = []
	for path in CLOUD_PATHS:
		cloud_textures.append(load(path) as Texture2D)

	var vp := get_viewport()
	if vp != null:
		var visible_size := vp.get_visible_rect().size
		if visible_size.x > 0.0 and visible_size.y > 0.0:
			_viewport_size = visible_size
		vp.size_changed.connect(_on_viewport_resized)

	for i in range(CLOUD_LAYOUTS.size()):
		var cfg: Dictionary = CLOUD_LAYOUTS[i]
		var tex: Texture2D = cloud_textures[int(cfg["kind"]) % cloud_textures.size()]
		if tex == null:
			continue
		var cloud := TextureRect.new()
		cloud.name = "Cloud_%d" % i
		cloud.texture = tex
		cloud.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		cloud.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		cloud.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		cloud.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cloud.modulate = Color(1.0, 1.0, 1.0, float(cfg["alpha"]))
		var tex_size := tex.get_size()
		var w := float(cfg["width"])
		var h := w * (tex_size.y / maxf(1.0, tex_size.x))
		cloud.size = Vector2(w, h)
		cloud.position = Vector2(_viewport_size.x * float(cfg["x_ratio"]), _viewport_size.y * float(cfg["y_ratio"]))
		root_control.add_child(cloud)
		_clouds.append({
			"node": cloud,
			"speed": float(cfg["speed"]),
			"y_ratio": float(cfg["y_ratio"]),
			"alpha": float(cfg["alpha"]),
		})

	var settings := get_node_or_null("/root/SettingsService")
	if settings != null and settings.has_signal("changed"):
		settings.connect("changed", _apply_theme)
	_apply_theme()

func _apply_theme() -> void:
	var settings := get_node_or_null("/root/SettingsService")
	var dark := settings != null and bool(settings.call("is_dark_mode"))
	if _sky_rect != null:
		_sky_rect.texture = _night_sky_tex if (dark and _night_sky_tex != null) else _day_sky_tex
	for entry in _clouds:
		var cloud: TextureRect = entry["node"]
		var base_alpha := float(entry.get("alpha", 0.85))
		cloud.modulate = Color(0.42, 0.52, 0.72, base_alpha * 0.72) if dark else Color(1.0, 1.0, 1.0, base_alpha)

func _on_viewport_resized() -> void:
	var vp := get_viewport()
	if vp == null:
		return
	var next_size := vp.get_visible_rect().size
	if next_size.x <= 0.0 or next_size.y <= 0.0:
		return
	var x_scale := next_size.x / maxf(1.0, _viewport_size.x)
	_viewport_size = next_size
	for entry in _clouds:
		var cloud: TextureRect = entry["node"]
		cloud.position.x *= x_scale
		cloud.position.y = _viewport_size.y * float(entry["y_ratio"])

func _process(delta: float) -> void:
	var wrap_margin := 80.0
	for entry in _clouds:
		var cloud: TextureRect = entry["node"]
		cloud.position.x += float(entry["speed"]) * delta
		if cloud.position.x > _viewport_size.x + wrap_margin:
			cloud.position.x = -cloud.size.x - wrap_margin
