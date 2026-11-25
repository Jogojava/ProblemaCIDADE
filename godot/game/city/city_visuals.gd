class_name CityVisuals
extends Node2D

signal lot_selected(lot: Dictionary)
signal placement_cancelled()
signal map_expanded(new_radius: int)

const BLOCK_STRIDE := 6
const INITIAL_MAP_RADIUS := 14
const MAP_RADIUS_STEP := 4
const MAX_MAP_RADIUS := 50
const POPULATION_GROWTH_PER_EXPANSION := 400
const HALF_TILE := Vector2(64, 40)

const GRASS_PATH := "res://assets/city/ground/tile_grass.png"
const ROAD_LINE_PATH := "res://assets/city/ground/road_line.png"
const ROAD_INTERSECTION_PATH := "res://assets/city/ground/road_intersection.png"
const LAKE_PATH := "res://assets/city/ground/lake.png"
const CONSTRUCTION_SHEET_PATH := "res://assets/city/buildings/construction_sheet.png"
const TREE_PATHS := [
	"res://assets/city/ground/tree_1.png",
	"res://assets/city/ground/tree_2.png",
	"res://assets/city/ground/tree_3.png",
]
const CULTURE_PATHS := [
	"res://assets/city/buildings/culture_1.png",
	"res://assets/city/buildings/culture_2.png",
]
const BUILDING_PATHS := {
	"hall": "res://assets/city/buildings/prefeitura.png",
	"education": "res://assets/city/buildings/education.png",
	"health": "res://assets/city/buildings/health.png",
	"water": "res://assets/city/buildings/water.png",
	"security": "res://assets/city/buildings/security.png",
	"social": "res://assets/city/buildings/social.png",
}
const HOUSE_PATHS := [
	"res://assets/city/buildings/house_1.png",
	"res://assets/city/buildings/house_2.png",
	"res://assets/city/buildings/house_3.png",
	"res://assets/city/buildings/house_4.png",
	"res://assets/city/buildings/house_5.png",
]
const APARTMENT_PATHS := [
	"res://assets/city/buildings/apartment_1.png",
	"res://assets/city/buildings/apartment_2.png",
	"res://assets/city/buildings/apartment_3.png",
	"res://assets/city/buildings/apartment_4.png",
	"res://assets/city/buildings/apartment_5.png",
]
const NPC_PATHS := [
	"res://assets/chara/npc1.png",
	"res://assets/chara/npc2.png",
	"res://assets/chara/npc3.png",
	"res://assets/chara/npc4.png",
	"res://assets/chara/npc5.png",
	"res://assets/chara/npc6.png",
	"res://assets/chara/npc7.png",
	"res://assets/chara/npc8.png",
	"res://assets/chara/npc9.png",
]
const VEHICLE_SPECS := [
	{"path": "res://assets/vehicles/car_1.png", "width": 44.0, "min_speed": 1.65, "max_speed": 2.35},
	{"path": "res://assets/vehicles/car_2.png", "width": 48.0, "min_speed": 1.65, "max_speed": 2.35},
	{"path": "res://assets/vehicles/car_3.png", "width": 46.0, "min_speed": 1.60, "max_speed": 2.25},
	{"path": "res://assets/vehicles/car_4.png", "width": 42.0, "min_speed": 1.60, "max_speed": 2.25},
	{"path": "res://assets/vehicles/car_5.png", "width": 50.0, "min_speed": 1.75, "max_speed": 2.45},
	{"path": "res://assets/vehicles/car_6.png", "width": 48.0, "min_speed": 1.45, "max_speed": 2.00},
	{"path": "res://assets/vehicles/car_7.png", "width": 48.0, "min_speed": 1.55, "max_speed": 2.15},
	{"path": "res://assets/vehicles/taxi.png", "width": 48.0, "min_speed": 1.70, "max_speed": 2.40},
	{"path": "res://assets/vehicles/truck_1.png", "width": 52.0, "min_speed": 1.35, "max_speed": 1.85},
	{"path": "res://assets/vehicles/truck_2.png", "width": 58.0, "min_speed": 1.20, "max_speed": 1.65},
	{"path": "res://assets/vehicles/bus_1.png", "width": 64.0, "min_speed": 1.15, "max_speed": 1.55},
	{"path": "res://assets/vehicles/bus_2.png", "width": 64.0, "min_speed": 1.15, "max_speed": 1.55},
]
const SIDEWALK_OFFSET := 0.38
const VEHICLE_LANE_OFFSET := 0.14
const NIGHT_WORLD_TINT := Color(0.28, 0.34, 0.52, 1.0)

static var _used_rect_cache: Dictionary = {}
static var _night_path_cache: Dictionary = {}
static var _night_off_path_cache: Dictionary = {}

var _textures: Dictionary = {}
var _construction_anim_time := 0.0
var _construction_frame := 0
var _lake_anchors: Array[Vector2i] = []
var _lake_tiles: Dictionary = {}
var _tree_coords: Array[Vector2i] = []
var _tree_tiles: Dictionary = {}
var _npcs: Array[Dictionary] = []
var _vehicles: Array[Dictionary] = []
var _npc_rng := RandomNumberGenerator.new()
var _npc_redraw_accum := 0.0
var _night_lights_root: Node2D
var _light_texture: GradientTexture2D
var _light_material: CanvasItemMaterial
var _residence_lights: Array[Dictionary] = []
var _lit_buildings: Dictionary = {}
var _light_swap_timer := 0.0
var _last_light_structure_count := -1
var state: CityState
var time_manager: TimeManager
var origin := Vector2(1056, 1780)
var map_radius := INITIAL_MAP_RADIUS
var _next_population_expansion := 0
var placing := false
var placement_area := ""
var hovered := Vector2i(999, 999)
var lots: Array[Dictionary] = []

func _init() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_npc_rng.randomize()

func _ready() -> void:
	var settings := get_node_or_null("/root/SettingsService")
	if settings != null and settings.has_signal("changed"):
		settings.connect("changed", _on_settings_changed)
	_sync_night_lights()

func _on_settings_changed() -> void:
	_sync_night_lights()
	queue_redraw()

func _is_night_mode() -> bool:
	var settings := get_node_or_null("/root/SettingsService")
	return settings != null and bool(settings.call("is_dark_mode"))

func _night_sprite_path(day_path: String) -> String:
	if _night_path_cache.has(day_path):
		return String(_night_path_cache[day_path])
	var candidate := day_path.replace(".png", "_night.png")
	var resolved := candidate if (day_path.ends_with(".png") and ResourceLoader.exists(candidate)) else ""
	_night_path_cache[day_path] = resolved
	return resolved

func _night_off_sprite_path(day_path: String) -> String:
	if _night_off_path_cache.has(day_path):
		return String(_night_off_path_cache[day_path])
	var candidate := day_path.replace(".png", "_night_off.png")
	var resolved := candidate if (day_path.ends_with(".png") and ResourceLoader.exists(candidate)) else ""
	_night_off_path_cache[day_path] = resolved
	return resolved

func _ensure_light_texture() -> GradientTexture2D:
	if _light_texture != null:
		return _light_texture
	var grad := Gradient.new()
	grad.offsets = PackedFloat32Array([0.0, 0.28, 0.62, 1.0])
	grad.colors = PackedColorArray([
		Color(1.0, 0.94, 0.72, 1.0),
		Color(1.0, 0.82, 0.45, 0.50),
		Color(1.0, 0.70, 0.30, 0.14),
		Color(1.0, 0.62, 0.20, 0.0),
	])
	_light_texture = GradientTexture2D.new()
	_light_texture.gradient = grad
	_light_texture.width = 128
	_light_texture.height = 128
	_light_texture.fill = GradientTexture2D.FILL_RADIAL
	_light_texture.fill_from = Vector2(0.5, 0.5)
	_light_texture.fill_to = Vector2(0.5, 0.0)
	return _light_texture

func _ensure_light_material() -> CanvasItemMaterial:
	if _light_material != null:
		return _light_material
	_light_material = CanvasItemMaterial.new()
	_light_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_light_material.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	return _light_material

func _add_night_light(pos: Vector2, scale_val: float, alpha: float, tint: Color = Color("ffdca0")) -> Sprite2D:
	if _night_lights_root == null:
		return null
	var light := Sprite2D.new()
	light.texture = _ensure_light_texture()
	light.material = _ensure_light_material()
	light.position = pos
	light.scale = Vector2(scale_val, scale_val)
	light.modulate = Color(tint.r, tint.g, tint.b, alpha)
	light.visible = alpha > 0.005
	_night_lights_root.add_child(light)
	return light

func _sync_night_lights() -> void:
	_residence_lights.clear()
	_lit_buildings.clear()
	_light_swap_timer = 0.0
	if _night_lights_root != null and is_instance_valid(_night_lights_root):
		_night_lights_root.queue_free()
		_night_lights_root = null
	if state == null or not is_inside_tree() or not _is_night_mode():
		_last_light_structure_count = -1
		return
	_last_light_structure_count = state.residences.size() + state.buildings.size()
	_night_lights_root = Node2D.new()
	_night_lights_root.name = "NightLights"
	_night_lights_root.z_index = 20
	add_child(_night_lights_root)

	# Prefeitura (always uses prefeitura_night.png + warm glow)
	var hall_base := _structure_base({"lot": state.town_hall, "area": "hall"})
	var hall_key := Vector2i(int(state.town_hall.get("x", -1)), int(state.town_hall.get("y", -1)))
	_lit_buildings[hall_key] = true
	_add_night_light(hall_base + Vector2(0.0, 18.0), 2.4, 0.44, Color("ffe1a0"))
	_add_night_light(hall_base + Vector2(0.0, -102.0), 1.3, 0.36, Color("8ae6ff"))

	# Subtle warm streetlights at road intersections
	for x in range(-map_radius, map_radius + 1):
		if posmod(x, BLOCK_STRIDE) != 0:
			continue
		for y in range(-map_radius, map_radius + 1):
			if posmod(y, BLOCK_STRIDE) != 0:
				continue
			var ibase := point({"x": x, "y": y})
			_add_night_light(ibase + Vector2(0.0, -4.0), 1.35, 0.26, Color("ffd996"))

	# Public buildings (~80% lit with *_night.png + glow; unlit ones have NO glow)
	for building in state.buildings:
		var area := String(building.get("area", ""))
		var bbase := _structure_base(building)
		var bpath := _building_sprite_path(area, building.lot, int(building.get("variant", 0)))
		if _night_sprite_path(bpath).is_empty():
			continue
		var bx := int(building.lot.get("x", 0))
		var by := int(building.lot.get("y", 0))
		var bkey := Vector2i(bx, by)
		var lit := posmod(absi(bx * 11 + by * 17), 5) != 0
		_lit_buildings[bkey] = lit
		var tint := Color("9ad8ff") if area == "security" else (Color("d4f2ff") if area == "health" else Color("ffdca0"))
		var light_pos := bbase + (Vector2(0.0, -34.0) if area == "security" else Vector2(0.0, -28.0))
		var base_alpha := 0.36
		var light := _add_night_light(light_pos, 1.85, base_alpha if lit else 0.0, tint)
		if light != null:
			_residence_lights.append({"light": light, "key": bkey, "base_alpha": base_alpha, "lit": lit})

	# Apartments and houses (~80% lit with *_night.png + glow; unlit or without *_night.png have NO glow)
	for home in state.residences:
		var area := String(home.get("area", "home"))
		var hpath := _building_sprite_path(area, home.lot, int(home.get("variant", 0)))
		if _night_sprite_path(hpath).is_empty():
			continue
		var lx := int(home.lot.get("x", 0))
		var ly := int(home.lot.get("y", 0))
		var hkey := Vector2i(lx, ly)
		var hbase := _structure_base(home)
		var is_apt := area == "apartment"
		var lit := posmod(absi(lx * 11 + ly * 17), 5) != 0
		_lit_buildings[hkey] = lit
		var base_alpha := 0.34 if is_apt else 0.30
		var light_pos := hbase + (Vector2(0.0, -56.0) if is_apt else Vector2(0.0, -16.0))
		var light_scale := 1.70 if is_apt else 1.0
		var tint := Color("ffd480") if is_apt else Color("ffdc94")
		var light := _add_night_light(light_pos, light_scale, base_alpha if lit else 0.0, tint)
		if light != null:
			_residence_lights.append({"light": light, "key": hkey, "base_alpha": base_alpha, "lit": lit})

func _update_night_lights(delta: float) -> void:
	if _residence_lights.is_empty():
		return
	_light_swap_timer += delta
	if _light_swap_timer >= 2.0:
		_light_swap_timer = 0.0
		var lit_indices: Array[int] = []
		var off_indices: Array[int] = []
		for i in range(_residence_lights.size()):
			if bool(_residence_lights[i]["lit"]):
				lit_indices.append(i)
			else:
				off_indices.append(i)
		if not lit_indices.is_empty() and not off_indices.is_empty():
			var turn_off_idx := lit_indices[_npc_rng.randi_range(0, lit_indices.size() - 1)]
			var turn_on_idx := off_indices[_npc_rng.randi_range(0, off_indices.size() - 1)]
			_residence_lights[turn_off_idx]["lit"] = false
			_residence_lights[turn_on_idx]["lit"] = true
			_lit_buildings[_residence_lights[turn_off_idx]["key"]] = false
			_lit_buildings[_residence_lights[turn_on_idx]["key"]] = true
			queue_redraw()
	for entry in _residence_lights:
		var light: Sprite2D = entry["light"]
		if not is_instance_valid(light):
			continue
		var target := float(entry["base_alpha"]) if bool(entry["lit"]) else 0.0
		if not is_equal_approx(light.modulate.a, target):
			light.modulate.a = move_toward(light.modulate.a, target, delta * 0.75)
			light.visible = light.modulate.a > 0.005

func _process(delta: float) -> void:
	if state == null:
		return
	if time_manager != null and time_manager.paused:
		return
	if not _residence_lights.is_empty():
		_update_night_lights(delta)
	var needs_redraw := false
	if not state.projects.is_empty():
		_construction_anim_time += delta
		var next_frame := int(floor(_construction_anim_time * 4.5)) % 4
		if next_frame != _construction_frame:
			_construction_frame = next_frame
			needs_redraw = true
	if not _npcs.is_empty() or not _vehicles.is_empty():
		if not _npcs.is_empty():
			_update_npcs(delta)
		if not _vehicles.is_empty():
			_update_vehicles(delta)
		_npc_redraw_accum += delta
		if _npc_redraw_accum >= 0.033:
			_npc_redraw_accum = 0.0
			needs_redraw = true
	if needs_redraw:
		queue_redraw()

func _get_sprite_entry(path: String) -> Dictionary:
	var tex: Texture2D = _textures.get(path, null) as Texture2D
	if tex == null and not _textures.has(path):
		tex = load(path) as Texture2D
		_textures[path] = tex
	if tex == null:
		return {}
	var src_rect: Rect2
	if _used_rect_cache.has(path):
		src_rect = _used_rect_cache[path]
	else:
		src_rect = Rect2(Vector2.ZERO, tex.get_size())
		var img := tex.get_image()
		if img != null:
			var used := img.get_used_rect()
			if used.size.x > 0 and used.size.y > 0:
				src_rect = Rect2(used.position, used.size)
		_used_rect_cache[path] = src_rect
	return {"texture": tex, "src_rect": src_rect}

func _draw_sprite_entry(entry: Dictionary, dest: Rect2, flip_h: bool = false, modulate: Color = Color.WHITE) -> void:
	if entry.is_empty():
		return
	var tex: Texture2D = entry["texture"]
	var src_rect: Rect2 = entry["src_rect"]
	if flip_h:
		draw_set_transform(Vector2(dest.position.x + dest.size.x * 0.5, dest.position.y + dest.size.y * 0.5), 0.0, Vector2(-1.0, 1.0))
		draw_texture_rect_region(tex, Rect2(-dest.size * 0.5, dest.size), src_rect, modulate)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	else:
		draw_texture_rect_region(tex, dest, src_rect, modulate)

func _building_sprite_path(area: String, lot: Dictionary, variant: int) -> String:
	if BUILDING_PATHS.has(area):
		return String(BUILDING_PATHS[area])
	var lx := int(lot.get("x", 0))
	var ly := int(lot.get("y", 0))
	if area == "culture":
		var cidx := posmod(absi(lx * 13 + ly * 29 + variant), CULTURE_PATHS.size())
		return CULTURE_PATHS[cidx]
	var idx := posmod(absi(lx * 31 + ly * 17 + variant * 13), 5)
	if area == "apartment":
		return APARTMENT_PATHS[idx % APARTMENT_PATHS.size()]
	return HOUSE_PATHS[idx % HOUSE_PATHS.size()]

func _should_flip_building(lot: Dictionary, area: String, sprite_path: String = "") -> bool:
	if area == "hall":
		return false
	var lx := int(lot.get("x", 0))
	var ly := int(lot.get("y", 0))
	var size := 1 if area == "home" else CityState.BUILDING_FOOTPRINT_SIZE
	var flip := false
	var road_br := _road(lx + size, ly)
	var road_bl := _road(lx, ly + size)
	if road_br and not road_bl:
		flip = true
	elif road_bl and not road_br:
		flip = false
	else:
		var road_tl := _road(lx - 1, ly)
		var road_tr := _road(lx, ly - 1)
		if road_tr and not road_tl:
			flip = true
		elif road_tl and not road_tr:
			flip = false
		else:
			flip = posmod(absi(lx * 7 + ly * 11), 2) == 1
	if area == "security" or area == "water" or sprite_path.ends_with("/house_1.png") or sprite_path.ends_with("/house_2.png") or sprite_path.ends_with("/house_3.png") or sprite_path.ends_with("/house_5.png"):
		return not flip
	return flip

func bind(city: CityState) -> void:
	state = city
	_lake_anchors.clear()
	_lake_tiles.clear()
	_tree_coords.clear()
	_tree_tiles.clear()
	_npcs.clear()
	_vehicles.clear()
	map_radius = _required_radius_for_city(city)
	_generate_lots()
	city.configure_lots(lots)
	_rebuild_nature_layout()
	_populate_npcs()
	_populate_vehicles()
	_sync_night_lights()
	_next_population_expansion = city.population + POPULATION_GROWTH_PER_EXPANSION
	city.changed.connect(_on_city_changed)
	queue_redraw()

func _required_radius_for_city(city: CityState) -> int:
	var max_coord := INITIAL_MAP_RADIUS
	for collection in [city.residences, city.buildings, city.projects]:
		for item in collection:
			if not (item is Dictionary):
				continue
			var lot: Variant = item.get("lot", {})
			if lot is Dictionary and lot.has("x") and lot.has("y"):
				var extra := CityState.BUILDING_FOOTPRINT_SIZE - 1 if String(item.get("area", "home")) != "home" else 0
				max_coord = maxi(max_coord, absi(int(lot.x)) + extra)
				max_coord = maxi(max_coord, absi(int(lot.y)) + extra)
	if max_coord <= INITIAL_MAP_RADIUS:
		return INITIAL_MAP_RADIUS
	var steps := ceili(float(max_coord - INITIAL_MAP_RADIUS) / float(MAP_RADIUS_STEP))
	return clampi(INITIAL_MAP_RADIUS + steps * MAP_RADIUS_STEP, INITIAL_MAP_RADIUS, MAX_MAP_RADIUS)

func _generate_lots() -> void:
	lots.clear()
	for x in range(-map_radius, map_radius + 1):
		for y in range(-map_radius, map_radius + 1):
			if not _road(x, y):
				lots.append({"x": x, "y": y})

func expand_map() -> bool:
	if map_radius >= MAX_MAP_RADIUS:
		return false
	map_radius = mini(MAX_MAP_RADIUS, map_radius + MAP_RADIUS_STEP)
	_generate_lots()
	if state != null:
		state.configure_lots(lots)
		_rebuild_nature_layout()
		_populate_npcs()
		_populate_vehicles()
		_sync_night_lights()
	map_expanded.emit(map_radius)
	queue_redraw()
	return true

func _road_lines() -> Array[int]:
	var lines: Array[int] = []
	var max_k := floori(float(map_radius) / float(BLOCK_STRIDE))
	for k in range(-max_k, max_k + 1):
		lines.append(k * BLOCK_STRIDE)
	return lines

func _populate_npcs() -> void:
	var road_lines := _road_lines()
	if road_lines.is_empty():
		return
	var target_count := clampi(floori(float(map_radius) * 3.0), 36, 110)
	var limit := float(map_radius) - 0.5
	while _npcs.size() < target_count:
		var axis := _npc_rng.randi_range(0, 1)
		var road_coord := road_lines[_npc_rng.randi_range(0, road_lines.size() - 1)]
		var side := -1 if _npc_rng.randi_range(0, 1) == 0 else 1
		var dir := -1 if _npc_rng.randi_range(0, 1) == 0 else 1
		var along := _npc_rng.randf_range(-limit, limit)
		var pos := Vector2(along, float(road_coord) + float(side) * SIDEWALK_OFFSET) if axis == 0 else Vector2(float(road_coord) + float(side) * SIDEWALK_OFFSET, along)
		var next_turn := _next_intersection(along, dir)
		_npcs.append({
			"pos": pos,
			"axis": axis,
			"road_coord": road_coord,
			"side": side,
			"dir": dir,
			"next_turn": next_turn,
			"speed": _npc_rng.randf_range(0.55, 1.05),
			"sprite_idx": _npc_rng.randi_range(0, NPC_PATHS.size() - 1),
			"bob_phase": _npc_rng.randf_range(0.0, TAU),
		})

func _next_intersection(along: float, dir: int) -> int:
	var stride := float(BLOCK_STRIDE)
	if dir > 0:
		return int(ceil(along / stride)) * BLOCK_STRIDE
	return int(floor(along / stride)) * BLOCK_STRIDE

func _update_npcs(delta: float) -> void:
	var speed_mult := 1.0
	if time_manager != null:
		speed_mult = clampf(time_manager.get_game_speed_multiplier(), 0.35, 3.0)
	var limit := float(map_radius) - 0.4
	for npc in _npcs:
		var pos: Vector2 = npc["pos"]
		var axis: int = int(npc["axis"])
		var dir: int = int(npc["dir"])
		var side: int = int(npc["side"])
		var road_coord: int = int(npc["road_coord"])
		var next_turn: int = int(npc["next_turn"])
		var step := float(npc["speed"]) * speed_mult * delta
		npc["bob_phase"] = fmod(float(npc["bob_phase"]) + step * 11.0, TAU)
		var along := pos.x if axis == 0 else pos.y
		var new_along := along + float(dir) * step
		var corner_side := -dir
		var turn_target := float(next_turn) + float(corner_side) * SIDEWALK_OFFSET
		var reached_corner := (dir > 0 and along <= turn_target and new_along >= turn_target) or (dir < 0 and along >= turn_target and new_along <= turn_target)
		if reached_corner:
			var inside_perp := absi(next_turn) <= map_radius - 1
			var will_turn := inside_perp and (_npc_rng.randf() < 0.45 or absf(float(next_turn + dir * BLOCK_STRIDE)) > limit)
			if will_turn:
				var new_axis := 1 - axis
				var new_road := next_turn
				var new_side := corner_side
				var new_dir := side
				if absf(float(road_coord + new_dir * BLOCK_STRIDE)) > limit:
					new_dir = -new_dir
				var snapped_perp := float(road_coord) + float(side) * SIDEWALK_OFFSET
				npc["axis"] = new_axis
				npc["road_coord"] = new_road
				npc["side"] = new_side
				npc["dir"] = new_dir
				npc["next_turn"] = road_coord + new_dir * BLOCK_STRIDE
				npc["pos"] = Vector2(snapped_perp, float(new_road) + float(new_side) * SIDEWALK_OFFSET) if new_axis == 0 else Vector2(float(new_road) + float(new_side) * SIDEWALK_OFFSET, snapped_perp)
				continue
			npc["next_turn"] = next_turn + dir * BLOCK_STRIDE
		if new_along > limit:
			new_along = limit
			npc["dir"] = -1
			npc["next_turn"] = _next_intersection(new_along, -1)
		elif new_along < -limit:
			new_along = -limit
			npc["dir"] = 1
			npc["next_turn"] = _next_intersection(new_along, 1)
		if axis == 0:
			npc["pos"] = Vector2(new_along, float(road_coord) + float(side) * SIDEWALK_OFFSET)
		else:
			npc["pos"] = Vector2(float(road_coord) + float(side) * SIDEWALK_OFFSET, new_along)

func _populate_vehicles() -> void:
	var road_lines := _road_lines()
	if road_lines.is_empty():
		return
	var target_count := clampi(floori(float(map_radius) * 1.6), 18, 55)
	var limit := float(map_radius) - 0.5
	while _vehicles.size() < target_count:
		var axis := _npc_rng.randi_range(0, 1)
		var road_coord := road_lines[_npc_rng.randi_range(0, road_lines.size() - 1)]
		var along := _npc_rng.randf_range(-limit, limit)
		var spec_idx := _npc_rng.randi_range(0, VEHICLE_SPECS.size() - 1)
		var spec: Dictionary = VEHICLE_SPECS[spec_idx]
		var lane := VEHICLE_LANE_OFFSET if axis == 0 else -VEHICLE_LANE_OFFSET
		var pos := Vector2(along, float(road_coord) + lane) if axis == 0 else Vector2(float(road_coord) + lane, along)
		_vehicles.append({
			"pos": pos,
			"axis": axis,
			"road_coord": road_coord,
			"next_turn": _next_intersection(along, 1),
			"speed": _npc_rng.randf_range(float(spec["min_speed"]), float(spec["max_speed"])),
			"spec_idx": spec_idx,
		})

func _update_vehicles(delta: float) -> void:
	var speed_mult := 1.0
	if time_manager != null:
		speed_mult = clampf(time_manager.get_game_speed_multiplier(), 0.35, 3.0)
	var limit := float(map_radius) + 0.4
	var road_lines := _road_lines()
	for i in range(_vehicles.size()):
		var vehicle: Dictionary = _vehicles[i]
		var pos: Vector2 = vehicle["pos"]
		var axis: int = int(vehicle["axis"])
		var road_coord: int = int(vehicle["road_coord"])
		var next_turn: int = int(vehicle["next_turn"])
		var along := pos.x if axis == 0 else pos.y
		var base_speed := float(vehicle["speed"])
		# Simple spacing so vehicles on the same road do not stack on top of each other.
		var blocked := false
		for j in range(_vehicles.size()):
			if i == j:
				continue
			var other: Dictionary = _vehicles[j]
			if int(other["axis"]) == axis and int(other["road_coord"]) == road_coord:
				var other_pos: Vector2 = other["pos"]
				var other_along := other_pos.x if axis == 0 else other_pos.y
				var gap := other_along - along
				if gap > 0.0 and gap < 1.05:
					blocked = true
					break
		var effective_speed := base_speed * (0.25 if blocked else 1.0)
		var step := effective_speed * speed_mult * delta
		var new_along := along + step
		var turn_target := float(next_turn) + (-VEHICLE_LANE_OFFSET if axis == 0 else VEHICLE_LANE_OFFSET)
		if along <= turn_target and new_along >= turn_target:
			var inside_perp := absi(next_turn) <= map_radius - 1
			if inside_perp and _npc_rng.randf() < 0.35:
				var new_axis := 1 - axis
				var new_road := next_turn
				var new_lane := VEHICLE_LANE_OFFSET if new_axis == 0 else -VEHICLE_LANE_OFFSET
				var start_perp := float(road_coord) + (VEHICLE_LANE_OFFSET if axis == 0 else -VEHICLE_LANE_OFFSET)
				vehicle["axis"] = new_axis
				vehicle["road_coord"] = new_road
				vehicle["next_turn"] = road_coord + BLOCK_STRIDE
				vehicle["pos"] = Vector2(start_perp, float(new_road) + new_lane) if new_axis == 0 else Vector2(float(new_road) + new_lane, start_perp)
				continue
			vehicle["next_turn"] = next_turn + BLOCK_STRIDE
		if new_along > limit:
			new_along = -limit
			if not road_lines.is_empty():
				road_coord = road_lines[_npc_rng.randi_range(0, road_lines.size() - 1)]
				vehicle["road_coord"] = road_coord
			vehicle["next_turn"] = _next_intersection(new_along, 1)
		var lane := VEHICLE_LANE_OFFSET if axis == 0 else -VEHICLE_LANE_OFFSET
		vehicle["pos"] = Vector2(new_along, float(road_coord) + lane) if axis == 0 else Vector2(float(road_coord) + lane, new_along)

func _rebuild_nature_layout() -> void:
	if state == null:
		return
	# Preserve already-placed nature obstacles that remain free of buildings,
	# then add a modest number of lakes (2x2) and trees (1x1) on empty lots
	# and block them so no construction can be built there.
	var has_lake_sprite := ResourceLoader.exists(LAKE_PATH)
	var max_lakes := clampi(floori(float(map_radius) / 7.0), 2, 7) if has_lake_sprite else 0
	var max_trees := clampi(floori(float(map_radius) * 1.15), 14, 55)

	if has_lake_sprite and _lake_anchors.size() < max_lakes:
		var fallback_lake := Vector2i(999, 999)
		for x in range(-map_radius, map_radius):
			if _lake_anchors.size() >= max_lakes:
				break
			for y in range(-map_radius, map_radius):
				if _lake_anchors.size() >= max_lakes:
					break
				var coord := Vector2i(x, y)
				if _lake_tiles.has(coord) or _tree_tiles.has(coord):
					continue
				if not state.can_build_footprint({"x": x, "y": y}):
					continue
				if state._blocks_town_hall_view(coord):
					continue
				var too_close := false
				for existing in _lake_anchors:
					if absi(x - existing.x) < 8 and absi(y - existing.y) < 8:
						too_close = true
						break
				if too_close:
					continue
				if fallback_lake.x == 999 and absi(x) >= 3 and absi(y) >= 3:
					fallback_lake = coord
				if posmod(absi(x * 37 + y * 53), 41) != 0:
					continue
				_add_lake_anchor(coord)
		if _lake_anchors.is_empty() and fallback_lake.x != 999:
			_add_lake_anchor(fallback_lake)

	if _tree_coords.size() < max_trees:
		for stride_mod in [13, 7]:
			if _tree_coords.size() >= max_trees:
				break
			for x in range(-map_radius, map_radius + 1):
				if _tree_coords.size() >= max_trees:
					break
				for y in range(-map_radius, map_radius + 1):
					if _tree_coords.size() >= max_trees:
						break
					if _road(x, y):
						continue
					var coord := Vector2i(x, y)
					if _lake_tiles.has(coord) or _tree_tiles.has(coord):
						continue
					if not state.can_build_coord(coord) or state._blocks_town_hall_view(coord):
						continue
					if posmod(absi(x * 19 + y * 31), stride_mod) != 0:
						continue
					var near_tree := false
					for existing in _tree_coords:
						if absi(x - existing.x) <= 2 and absi(y - existing.y) <= 2:
							near_tree = true
							break
					if near_tree:
						continue
					_tree_coords.append(coord)
					_tree_tiles[coord] = true

	var blocked: Array[Vector2i] = []
	for tile in _lake_tiles.keys():
		blocked.append(tile as Vector2i)
	for tile in _tree_tiles.keys():
		blocked.append(tile as Vector2i)
	state.set_nature_obstacles(blocked)

func _add_lake_anchor(anchor: Vector2i) -> void:
	_lake_anchors.append(anchor)
	for dx in range(2):
		for dy in range(2):
			_lake_tiles[Vector2i(anchor.x + dx, anchor.y + dy)] = true

func _on_city_changed() -> void:
	while state != null and state.population >= _next_population_expansion and map_radius < MAX_MAP_RADIUS:
		_next_population_expansion += POPULATION_GROWTH_PER_EXPANSION
		if not expand_map():
			break
	if state != null and _is_night_mode() and (state.residences.size() + state.buildings.size()) != _last_light_structure_count:
		_sync_night_lights()
	queue_redraw()

func _road(x: int, y: int) -> bool:
	return posmod(x, BLOCK_STRIDE) == 0 or posmod(y, BLOCK_STRIDE) == 0

func point(lot: Dictionary) -> Vector2:
	return origin + Vector2((float(lot.x) - float(lot.y)) * HALF_TILE.x, (float(lot.x) + float(lot.y)) * HALF_TILE.y)

func lot_at(world: Vector2) -> Dictionary:
	var delta := world - origin
	return {"x": roundi((delta.x / HALF_TILE.x + delta.y / HALF_TILE.y) / 2.0), "y": roundi((delta.y / HALF_TILE.y - delta.x / HALF_TILE.x) / 2.0)}

func begin_placement(area: String) -> void:
	placement_area = area
	placing = true
	while not _has_available_plot(area) and expand_map():
		pass
	hovered = Vector2i(999, 999)
	queue_redraw()

func _has_available_plot(area: String) -> bool:
	if state == null:
		return false
	for lot in lots:
		var available := state.can_build(lot) if area == "home" else state.can_build_footprint(lot)
		if available:
			return true
	return false

func end_placement() -> void:
	placing = false
	hovered = Vector2i(999, 999)
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if not placing:
		return
	if event is InputEventMouseMotion:
		var lot := lot_at(get_global_transform_with_canvas().affine_inverse() * event.position)
		var next_hovered := Vector2i(int(lot.x), int(lot.y))
		if next_hovered != hovered:
			hovered = next_hovered
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
	var grass_sprite := _get_sprite_entry(GRASS_PATH)
	var road_line_sprite := _get_sprite_entry(ROAD_LINE_PATH)
	var road_inter_sprite := _get_sprite_entry(ROAD_INTERSECTION_PATH)
	var lake_sprite := _get_sprite_entry(LAKE_PATH) if ResourceLoader.exists(LAKE_PATH) else {}
	var dark := _is_night_mode()
	var world_tint := NIGHT_WORLD_TINT if dark else Color.WHITE
	var tile_size := HALF_TILE * 2.0 + Vector2(2.0, 1.5)
	var tile_offset := HALF_TILE + Vector2(1.0, 0.75)
	for depth in range(-map_radius * 2, map_radius * 2 + 1):
		for x in range(-map_radius, map_radius + 1):
			var y := depth - x
			if absi(y) > map_radius:
				continue
			var base := point({"x": x, "y": y})
			var tile_rect := Rect2(base - tile_offset, tile_size)
			var is_road_x := posmod(x, BLOCK_STRIDE) == 0
			var is_road_y := posmod(y, BLOCK_STRIDE) == 0
			var road := is_road_x or is_road_y
			if not road:
				var shade := posmod(x * 7 + y * 13, 4)
				if not grass_sprite.is_empty():
					_draw_sprite_entry(grass_sprite, tile_rect, posmod(x + y, 2) == 1, world_tint.darkened(shade * 0.02))
				else:
					draw_colored_polygon(_diamond(base), (Color("73945b").lightened(shade * 0.018)) * world_tint)
					draw_polyline(_closed(_diamond(base)), Color(0.27, 0.39, 0.22, 0.12), 1)
				if placing and state != null:
					var lot := {"x": x, "y": y}
					var placement_valid := state.can_build(lot) if placement_area == "home" else state.can_build_footprint(lot)
					if placement_valid:
						draw_polyline(_closed(_diamond(base, 3)), Color(0.8, 1, 0.76, 0.45), 1.5)
			else:
				if is_road_x and is_road_y and not road_inter_sprite.is_empty():
					_draw_sprite_entry(road_inter_sprite, tile_rect, false, world_tint)
				elif not road_line_sprite.is_empty():
					# road_line.png runs top-left to bottom-right (along X axis, when y % stride == 0).
					# Flip horizontally for roads running top-right to bottom-left (along Y axis, when x % stride == 0).
					_draw_sprite_entry(road_line_sprite, tile_rect, is_road_x and not is_road_y, world_tint)
				else:
					draw_colored_polygon(_diamond(base), Color("334a50") * world_tint)
					if not _road(x - 1, y) or not _road(x, y - 1):
						draw_polyline(_closed(_diamond(base, 3)), Color("52676a") * world_tint, 3)
					if posmod(x, BLOCK_STRIDE) != 0 and y == 0 and posmod(x, 2) == 1:
						draw_line(base + Vector2(-16, -10), base + Vector2(16, 10), Color("bec9ad") * world_tint, 2)
	if not lake_sprite.is_empty():
		var lake_src: Vector2 = lake_sprite["src_rect"].size
		for anchor in _lake_anchors:
			var lbase := point({"x": anchor.x + 0.5, "y": anchor.y + 0.5})
			var lw := 240.0
			var lh := lw * (lake_src.y / maxf(1.0, lake_src.x))
			var ldest := Rect2(Vector2(lbase.x - lw * 0.5, lbase.y + HALF_TILE.y * 1.9 - lh), Vector2(lw, lh))
			_draw_sprite_entry(lake_sprite, ldest, posmod(absi(anchor.x + anchor.y), 2) == 1, world_tint)
	if state == null:
		return
	var objects: Array[Dictionary] = []
	objects.append({"lot": state.town_hall, "area": "hall"})
	for home in state.residences:
		objects.append({"lot": home.lot, "area": home.get("area", "home"), "variant": home.get("variant", 0), "residents": home.get("residents", 0)})
	for building in state.buildings:
		objects.append(building)
	for project in state.projects:
		var item := project.duplicate()
		item["construction"] = true
		objects.append(item)
	for coord in _tree_coords:
		objects.append({"lot": {"x": coord.x, "y": coord.y}, "area": "tree"})
	for npc in _npcs:
		var npos: Vector2 = npc["pos"]
		objects.append({"lot": {"x": npos.x, "y": npos.y}, "area": "npc", "npc": npc})
	for vehicle in _vehicles:
		var vpos: Vector2 = vehicle["pos"]
		objects.append({"lot": {"x": vpos.x, "y": vpos.y}, "area": "vehicle", "vehicle": vehicle})
	objects.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var ba := _structure_base(a)
		var bb := _structure_base(b)
		if not is_equal_approx(ba.y, bb.y):
			return ba.y < bb.y
		return ba.x < bb.x
	)
	for item in objects:
		var area := String(item.get("area", "home"))
		var base := _structure_base(item)
		if area == "tree":
			_tree(base + Vector2(0, 10), int(item.lot.x), int(item.lot.y))
		elif area == "npc":
			_draw_npc(base, item["npc"])
		elif area == "vehicle":
			_draw_vehicle(base, item["vehicle"])
		else:
			_draw_structure(base, area, int(item.get("variant", 0)), bool(item.get("construction", false)), item.lot, false)
	if placing and hovered != Vector2i(999, 999):
		var anchor := {"x": hovered.x, "y": hovered.y}
		var is_home := placement_area == "home"
		var valid := state.can_build(anchor) if is_home else state.can_build_footprint(anchor)
		var base := point(anchor)
		if not is_home:
			base = point({"x": hovered.x + 0.5, "y": hovered.y + 0.5})
		var tint := Color("a3e9ac") if valid else Color("f18170")
		var footprint_centers: Array[Vector2] = [base]
		if not is_home:
			footprint_centers.clear()
			for x in range(CityState.BUILDING_FOOTPRINT_SIZE):
				for y in range(CityState.BUILDING_FOOTPRINT_SIZE):
					footprint_centers.append(point({"x": hovered.x + x, "y": hovered.y + y}))
		for footprint_center in footprint_centers:
			draw_colored_polygon(_diamond(footprint_center, 2), Color(tint, 0.55))
			draw_polyline(_closed(_diamond(footprint_center, 2)), tint, 3)
		if valid:
			_draw_structure(base, placement_area, 0, true, anchor, true)

func _structure_base(item: Dictionary) -> Vector2:
	var area := String(item.get("area", "home"))
	var lot: Dictionary = item.lot
	if area == "hall":
		return point({"x": int(lot.x) - 1.0, "y": int(lot.y) - 1.0})
	if area != "home" and area != "tree" and area != "npc" and area != "vehicle":
		return point({"x": int(lot.x) + 0.5, "y": int(lot.y) + 0.5})
	return point(lot)

func _draw_vehicle(base: Vector2, vehicle: Dictionary) -> void:
	var spec_idx := int(vehicle.get("spec_idx", 0)) % VEHICLE_SPECS.size()
	var spec: Dictionary = VEHICLE_SPECS[spec_idx]
	var entry := _get_sprite_entry(String(spec["path"]))
	if entry.is_empty():
		return
	var src_size: Vector2 = entry["src_rect"].size
	var target_w := float(spec["width"])
	var target_h := target_w * (src_size.y / maxf(1.0, src_size.x))
	var flip_h := int(vehicle.get("axis", 0)) == 1
	if _is_night_mode():
		var light_tex := _ensure_light_texture()
		var beam_pos := base + (Vector2(-24.0, 10.0) if flip_h else Vector2(24.0, 10.0))
		var beam_size := Vector2(76.0, 52.0)
		draw_texture_rect(light_tex, Rect2(beam_pos - beam_size * 0.5, beam_size), false, Color(1.0, 0.96, 0.78, 0.85))
	var dest := Rect2(Vector2(base.x - target_w * 0.5, base.y + 10.0 - target_h), Vector2(target_w, target_h))
	_draw_sprite_entry(entry, dest, flip_h, NIGHT_WORLD_TINT if _is_night_mode() else Color.WHITE)

func _draw_npc(base: Vector2, npc: Dictionary) -> void:
	var idx := int(npc.get("sprite_idx", 0)) % NPC_PATHS.size()
	var entry := _get_sprite_entry(NPC_PATHS[idx])
	if entry.is_empty():
		return
	var src_size: Vector2 = entry["src_rect"].size
	var target_h := 28.0
	var target_w := target_h * (src_size.x / maxf(1.0, src_size.y))
	var bob := absf(sin(float(npc.get("bob_phase", 0.0)))) * 3.0
	var axis := int(npc.get("axis", 0))
	var dir := int(npc.get("dir", 1))
	var moving_left := (axis == 0 and dir < 0) or (axis == 1 and dir > 0)
	draw_colored_polygon(PackedVector2Array([
		base + Vector2(-7, 0), base + Vector2(0, -3.5), base + Vector2(7, 0), base + Vector2(0, 3.5)
	]), Color(0.08, 0.14, 0.12, 0.28))
	var dest := Rect2(Vector2(base.x - target_w * 0.5, base.y - target_h - bob), Vector2(target_w, target_h))
	_draw_sprite_entry(entry, dest, moving_left, NIGHT_WORLD_TINT if _is_night_mode() else Color.WHITE)

func _structure_sort_y(item: Dictionary) -> float:
	# Exact isometric depth of the footprint center (origin.y + (cx + cy) * HALF_TILE.y).
	# Ensures 2x2 buildings, 3x2 town hall, and construction sites never tie with 1x1 houses directly in front of them.
	return _structure_base(item).y

func _closed(polygon: PackedVector2Array) -> PackedVector2Array:
	var result := polygon.duplicate()
	result.append(polygon[0])
	return result

func _draw_structure(base: Vector2, area: String, variant: int, construction: bool, lot: Dictionary = {}, preview: bool = false) -> void:
	var home := area == "home"
	if construction and not preview:
		var sheet_entry := _get_sprite_entry(CONSTRUCTION_SHEET_PATH)
		if not sheet_entry.is_empty():
			var tex: Texture2D = sheet_entry["texture"]
			var cell := tex.get_size() * 0.5
			var col := _construction_frame % 2
			var row := _construction_frame / 2
			var src_rect := Rect2(Vector2(col * cell.x, row * cell.y), cell)
			var target_w := 120.0 if home else 248.0
			var target_h := target_w * (cell.y / maxf(1.0, cell.x))
			var anchor_bottom_y := base.y + (HALF_TILE.y * 0.95 if home else HALF_TILE.y * 1.92)
			var dest := Rect2(Vector2(base.x - target_w * 0.5, anchor_bottom_y - target_h), Vector2(target_w, target_h))
			draw_texture_rect_region(tex, dest, src_rect, NIGHT_WORLD_TINT if _is_night_mode() else Color.WHITE)
			return
	var sprite_path := _building_sprite_path(area, lot, variant)
	var active_path := sprite_path
	var using_night_asset := false
	if not construction and _is_night_mode():
		var lot_key := Vector2i(int(lot.get("x", 0)), int(lot.get("y", 0)))
		var is_lit := area == "hall" or bool(_lit_buildings.get(lot_key, false))
		if is_lit:
			var night_path := _night_sprite_path(sprite_path)
			if not night_path.is_empty():
				active_path = night_path
				using_night_asset = true
		else:
			var night_off_path := _night_off_sprite_path(sprite_path)
			if not night_off_path.is_empty():
				active_path = night_off_path
				using_night_asset = true
	var sprite_entry := _get_sprite_entry(active_path)
	if not sprite_entry.is_empty():
		var src_size: Vector2 = sprite_entry["src_rect"].size
		var is_park := sprite_path.ends_with("/culture_2.png")
		var target_w := 116.0 if home else (316.0 if area == "hall" else (248.0 if is_park else (204.0 if area == "water" else (228.0 if area == "apartment" else 236.0))))
		var target_h := target_w * (src_size.y / maxf(1.0, src_size.x))
		var anchor_bottom_y := base.y + (HALF_TILE.y * 0.92 if home else (HALF_TILE.y * 2.50 if area == "hall" else (HALF_TILE.y * 1.95 if is_park else (HALF_TILE.y * 1.72 if area == "water" else HALF_TILE.y * 1.85))))
		var flip_h := _should_flip_building(lot, area, sprite_path)
		var x_offset := (-10.0 if not flip_h else 10.0) if sprite_path.ends_with("/apartment_5.png") else 0.0
		var dest := Rect2(Vector2(base.x + x_offset - target_w * 0.5, anchor_bottom_y - target_h), Vector2(target_w, target_h))
		if construction:
			_draw_sprite_entry(sprite_entry, dest, flip_h, Color(1.0, 1.0, 1.0, 0.5))
			return
		var building_tint := Color.WHITE if (not _is_night_mode() or using_night_asset) else NIGHT_WORLD_TINT
		_draw_sprite_entry(sprite_entry, dest, flip_h, building_tint)
		if area == "hall":
			draw_string(ThemeDB.fallback_font, base + Vector2(-42, HALF_TILE.y * 2.75), tr("Prefeitura"), HORIZONTAL_ALIGNMENT_LEFT, 120, 17, Color("f5f1dc"))
		return
	var colors := [Color("e2c29a"), Color("cbd4bf"), Color("a5c4ca"), Color("e4ceaa")]
	var accent: Color = {"education": Color("e9bf59"), "health": Color("d37871"), "water": Color("63b3cc"), "security": Color("6e8bbb"), "culture": Color("ac86b8"), "social": Color("a2bd7c"), "hall": Color("5aa5a0"), "apartment": Color("9baec0")}.get(area, colors[variant % 4])
	var h := 40.0 + variant * 8 if home else (110.0 if area == "apartment" else 92.0)
	var width := 32.0 if home else 54.0
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
		var symbol: String = {"health": "+", "education": "E", "water": "~", "security": "S", "culture": "C", "social": "A", "hall": "P", "apartment": "A"}.get(area, "")
		draw_string(ThemeDB.fallback_font, base + Vector2(11, -h + 23), symbol, HORIZONTAL_ALIGNMENT_LEFT, 25, 14, Color.WHITE)
		if area == "hall":
			draw_string(ThemeDB.fallback_font, base + Vector2(-48, 39), tr("Prefeitura"), HORIZONTAL_ALIGNMENT_LEFT, 120, 17, Color("f5f1dc"))

func _tree(base: Vector2, x: int = 0, y: int = 0) -> void:
	var idx := posmod(absi(x * 11 + y * 23), TREE_PATHS.size())
	var entry := _get_sprite_entry(TREE_PATHS[idx])
	if not entry.is_empty():
		draw_ellipse_shadow(base)
		var src_size: Vector2 = entry["src_rect"].size
		var tw := 64.0
		var th := tw * (src_size.y / maxf(1.0, src_size.x))
		var dest := Rect2(Vector2(base.x - tw * 0.5, base.y + 4.0 - th), Vector2(tw, th))
		_draw_sprite_entry(entry, dest, posmod(absi(x * 5 + y * 7), 2) == 1, NIGHT_WORLD_TINT if _is_night_mode() else Color.WHITE)
		return
	draw_ellipse_shadow(base)
	draw_line(base, base + Vector2(0, -24), Color("77654b"), 5)
	draw_circle(base + Vector2(0, -29), 19, Color("436e53"))
	draw_circle(base + Vector2(-5, -35), 15, Color("5b8962"))
	draw_circle(base + Vector2(-10, -38), 7, Color("79965d"))

func draw_ellipse_shadow(base: Vector2) -> void:
	draw_colored_polygon(PackedVector2Array([base + Vector2(-18, 0), base + Vector2(0, -8), base + Vector2(26, 3), base + Vector2(4, 12)]), Color(0.16, 0.27, 0.14, 0.22))
