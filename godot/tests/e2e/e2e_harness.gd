extends RefCounted

var checks: int = 0
var failures: int = 0
var case_checks: int = 0
var case_failures: int = 0
var current_suite: String = ""
var current_case: String = ""
var case_failure_messages: Array[String] = []
var all_failure_lines: Array[String] = []

func begin_suite(suite_name: String) -> void:
	current_suite = suite_name
	checks = 0
	failures = 0

func begin_case(case_id: String) -> void:
	current_case = case_id
	case_checks = 0
	case_failures = 0
	case_failure_messages.clear()

func end_case() -> bool:
	return case_failures == 0

func _record_fail(msg: String) -> void:
	failures += 1
	case_failures += 1
	case_failure_messages.append(msg)
	all_failure_lines.append("E2E_FAIL suite=%s case=%s msg=%s" % [current_suite, current_case, msg])

func check(cond: bool, msg: String) -> bool:
	checks += 1
	case_checks += 1
	if not cond:
		_record_fail(msg)
	return cond

func check_true(cond: bool, msg: String) -> bool:
	return check(cond == true, msg)

func check_false(cond: bool, msg: String) -> bool:
	return check(cond == false, msg)

func check_eq(actual: Variant, expected: Variant, msg: String) -> bool:
	var ok := false
	if typeof(actual) == typeof(expected):
		ok = actual == expected
	elif (actual is int or actual is float) and (expected is int or expected is float):
		ok = absf(float(actual) - float(expected)) <= 0.0001
	else:
		ok = str(actual) == str(expected)
	if not ok:
		return check(false, "%s (got=%s expected=%s)" % [msg, str(actual), str(expected)])
	return check(true, msg)

func check_ne(actual: Variant, unexpected: Variant, msg: String) -> bool:
	var same := false
	if typeof(actual) == typeof(unexpected):
		same = actual == unexpected
	elif (actual is int or actual is float) and (unexpected is int or unexpected is float):
		same = absf(float(actual) - float(unexpected)) <= 0.0001
	if same:
		return check(false, "%s (unexpectedly equal to %s)" % [msg, str(unexpected)])
	return check(true, msg)

func check_approx(actual: float, expected: float, tol: float, msg: String) -> bool:
	var ok := is_finite(actual) and absf(actual - expected) <= tol
	if not ok:
		return check(false, "%s (got=%s expected=%s tol=%s)" % [msg, str(actual), str(expected), str(tol)])
	return check(true, msg)

func check_gt(actual: float, bound: float, msg: String) -> bool:
	if not (is_finite(actual) and actual > bound):
		return check(false, "%s (got=%s expected > %s)" % [msg, str(actual), str(bound)])
	return check(true, msg)

func check_lt(actual: float, bound: float, msg: String) -> bool:
	if not (is_finite(actual) and actual < bound):
		return check(false, "%s (got=%s expected < %s)" % [msg, str(actual), str(bound)])
	return check(true, msg)

func check_contains(haystack: String, needle: String, msg: String) -> bool:
	if not haystack.contains(needle):
		return check(false, "%s (missing '%s' in '%s')" % [msg, needle, haystack.left(120)])
	return check(true, msg)

func check_not_contains(haystack: String, needle: String, msg: String) -> bool:
	if haystack.contains(needle):
		return check(false, "%s (unexpected '%s' in '%s')" % [msg, needle, haystack.left(120)])
	return check(true, msg)

func await_frames(tree: SceneTree, count: int = 2) -> void:
	for _i in range(maxi(1, count)):
		await tree.process_frame

func boot_scene(tree: SceneTree, scene_path: String, freeze_process: bool = false) -> Node:
	var err := tree.change_scene_to_file(scene_path)
	if err != OK:
		return null
	await await_frames(tree, 3)
	var scene := tree.current_scene
	if scene != null and freeze_process:
		scene.set_process(false)
		var tm: Variant = scene.get("time_manager")
		if tm is Node:
			(tm as Node).set_process(false)
	return scene

func cleanup_scene(tree: SceneTree) -> void:
	if tree.current_scene != null and is_instance_valid(tree.current_scene):
		tree.current_scene.queue_free()
	var keep := {"SettingsService": true, "SaveManager": true}
	for child in tree.root.get_children():
		if not keep.has(child.name) and is_instance_valid(child):
			child.queue_free()
	await await_frames(tree, 2)

func start_new_game(tree: SceneTree, city_name: String = "Cidade E2E", difficulty: String = "medium", close_briefing: bool = true, freeze_process: bool = true) -> Node:
	var save_mgr := tree.root.get_node_or_null("SaveManager")
	if save_mgr != null and save_mgr.has_method("start_new"):
		save_mgr.call("start_new", city_name, difficulty)
	var game := await boot_scene(tree, "res://scenes/game/Game.tscn", freeze_process)
	if game == null:
		return null
	await await_frames(tree, 2)
	if close_briefing and game.get("_modal") != null and game.has_method("_close_dialog"):
		game.call("_close_dialog")
		await await_frames(tree, 2)
	return game

func send_key(tree: SceneTree, keycode: int, unicode: int = 0, physical_keycode: int = 0, pressed: bool = true, echo: bool = false, shift: bool = false, ctrl: bool = false, alt: bool = false) -> void:
	var ev := InputEventKey.new()
	ev.keycode = keycode as Key
	ev.physical_keycode = (physical_keycode if physical_keycode != 0 else keycode) as Key
	ev.unicode = unicode
	ev.pressed = pressed
	ev.echo = echo
	ev.shift_pressed = shift
	ev.ctrl_pressed = ctrl
	ev.alt_pressed = alt
	tree.root.push_input(ev)

func send_key_tap(tree: SceneTree, keycode: int, unicode: int = 0, physical_keycode: int = 0, shift: bool = false) -> void:
	send_key(tree, keycode, unicode, physical_keycode, true, false, shift, false, false)
	await await_frames(tree, 1)
	send_key(tree, keycode, 0, physical_keycode, false, false, shift, false, false)
	await await_frames(tree, 1)

func type_text(tree: SceneTree, text: String) -> void:
	for i in range(text.length()):
		var ch := text.substr(i, 1)
		var code := text.unicode_at(i)
		var kc := _char_to_keycode(ch)
		await send_key_tap(tree, kc, code, kc, ch != ch.to_lower() and ch == ch.to_upper())

func _char_to_keycode(ch: String) -> int:
	if ch == " ":
		return KEY_SPACE
	var up := ch.to_upper()
	var u := up.unicode_at(0)
	if u >= 65 and u <= 90:
		return KEY_A + (u - 65)
	if u >= 48 and u <= 57:
		return KEY_0 + (u - 48)
	match ch:
		",": return KEY_COMMA
		".": return KEY_PERIOD
		"-": return KEY_MINUS
		"+": return KEY_PLUS
		"/": return KEY_SLASH
		"*": return KEY_ASTERISK
		"=": return KEY_EQUAL
		_: return KEY_NONE

func press_button(button: BaseButton) -> void:
	if button != null and is_instance_valid(button) and not button.disabled:
		button.pressed.emit()

func send_mouse_motion(tree: SceneTree, pos: Vector2, relative: Vector2 = Vector2.ZERO) -> void:
	var ev := InputEventMouseMotion.new()
	ev.position = pos
	ev.global_position = pos
	ev.relative = relative
	tree.root.push_input(ev)

func send_mouse_button(tree: SceneTree, pos: Vector2, button_index: int = MOUSE_BUTTON_LEFT, pressed: bool = true) -> void:
	var ev := InputEventMouseButton.new()
	ev.position = pos
	ev.global_position = pos
	ev.button_index = button_index as MouseButton
	ev.pressed = pressed
	tree.root.push_input(ev)

func srgb_to_linear(c: float) -> float:
	if c <= 0.04045:
		return c / 12.92
	return pow((c + 0.055) / 1.055, 2.4)

func relative_luminance(col: Color) -> float:
	return 0.2126 * srgb_to_linear(col.r) + 0.7152 * srgb_to_linear(col.g) + 0.0722 * srgb_to_linear(col.b)

func contrast_ratio(c1: Color, c2: Color) -> float:
	var l1 := relative_luminance(c1)
	var l2 := relative_luminance(c2)
	var hi := maxf(l1, l2)
	var lo := minf(l1, l2)
	return (hi + 0.05) / (lo + 0.05)

func extract_stylebox_bg(sb: StyleBox, fallback: Color = Color(0.9, 0.95, 0.97, 1.0)) -> Color:
	if sb is StyleBoxFlat:
		return (sb as StyleBoxFlat).bg_color
	if sb is StyleBoxTexture:
		var sbt := sb as StyleBoxTexture
		if sbt.texture != null:
			var img := sbt.texture.get_image()
			if img != null and not img.is_empty():
				var cx := img.get_width() / 2
				var cy := img.get_height() / 2
				var px := img.get_pixel(cx, cy) * sbt.modulate_color
				return px
	return fallback

func find_button_by_text(root_node: Node, text_substr: String) -> Button:
	if root_node == null:
		return null
	if root_node is Button:
		var b := root_node as Button
		if b.text.contains(text_substr):
			return b
	for child in root_node.get_children():
		var found := find_button_by_text(child, text_substr)
		if found != null:
			return found
	return null

func collect_labels_text(root_node: Node) -> String:
	if root_node == null:
		return ""
	var parts: Array[String] = []
	_collect_labels_recursive(root_node, parts)
	return "\n".join(parts)

func _collect_labels_recursive(node: Node, parts: Array[String]) -> void:
	if node is Label:
		parts.append((node as Label).text)
	elif node is RichTextLabel:
		parts.append((node as RichTextLabel).text)
	elif node is AcceptDialog:
		parts.append((node as AcceptDialog).dialog_text)
	for child in node.get_children():
		_collect_labels_recursive(child, parts)

func setup_isolated_env(tree: SceneTree, tag: String) -> void:
	var save_dir := "user://e2e_saves_%s" % tag
	var cfg_path := "user://e2e_settings_%s.cfg" % tag
	var save_mgr := tree.root.get_node_or_null("SaveManager")
	if save_mgr != null:
		save_mgr.set("save_dir", save_dir)
		save_mgr.set("pending_save", {})
		save_mgr.set("active_slot", 0)
		save_mgr.set("recovered_backup", false)
		save_mgr.set("last_error", "")
		save_mgr.set("new_game_options", {"name": "Vila Esperança", "difficulty": "medium"})
		var abs_dir := ProjectSettings.globalize_path(save_dir)
		DirAccess.make_dir_recursive_absolute(abs_dir)
		if save_mgr.has_method("delete_slot"):
			for s in range(1, 4):
				save_mgr.call("delete_slot", s)
	var settings := tree.root.get_node_or_null("SettingsService")
	if settings != null:
		settings.set("storage_path", cfg_path)
		var values: Variant = settings.get("values")
		if values is Dictionary:
			values["master"] = 80.0
			values["music"] = 65.0
			values["effects"] = 80.0
			values["muted"] = false
			values["mode"] = 0
			values["resolution"] = 0
			values["quality"] = 1
			values["locale"] = "pt_BR"
			values["pause_unfocused"] = true
		if settings.has_method("apply_settings"):
			settings.call("apply_settings")
	TranslationServer.set_locale("pt_BR")

func cleanup_isolated_env(tree: SceneTree, tag: String) -> void:
	var save_dir := "user://e2e_saves_%s" % tag
	var cfg_path := "user://e2e_settings_%s.cfg" % tag
	var save_mgr := tree.root.get_node_or_null("SaveManager")
	if save_mgr != null and save_mgr.has_method("delete_slot"):
		for s in range(1, 4):
			save_mgr.call("delete_slot", s)
	var abs_dir := ProjectSettings.globalize_path(save_dir)
	if DirAccess.dir_exists_absolute(abs_dir):
		var d := DirAccess.open(abs_dir)
		if d != null:
			d.list_dir_begin()
			var f := d.get_next()
			while not f.is_empty():
				if not d.current_is_dir():
					DirAccess.remove_absolute(abs_dir.path_join(f))
				f = d.get_next()
			d.list_dir_end()
		DirAccess.remove_absolute(abs_dir)
	var abs_cfg := ProjectSettings.globalize_path(cfg_path)
	if FileAccess.file_exists(abs_cfg):
		DirAccess.remove_absolute(abs_cfg)
	TranslationServer.set_locale("pt_BR")

func scan_files_recursive(dir_path: String, ext: String = "") -> Array[String]:
	var results: Array[String] = []
	var d := DirAccess.open(dir_path)
	if d == null:
		return results
	d.list_dir_begin()
	var entry := d.get_next()
	while not entry.is_empty():
		if entry.begins_with("."):
			entry = d.get_next()
			continue
		var full := dir_path.path_join(entry)
		if d.current_is_dir():
			results.append_array(scan_files_recursive(full, ext))
		else:
			if ext.is_empty() or entry.ends_with(ext):
				results.append(full)
		entry = d.get_next()
	d.list_dir_end()
	return results

func get_repo_root() -> String:
	var godot_abs := ProjectSettings.globalize_path("res://")
	return godot_abs.trim_suffix("/").get_base_dir()

func run_git(args: Array) -> Dictionary:
	var output: Array = []
	var full_args := ["-C", get_repo_root()]
	for a in args:
		full_args.append(str(a))
	var code := OS.execute("git", full_args, output, true)
	return {"exit_code": code, "output": "\n".join(output).strip_edges()}

func run_godot_subprocess(args: Array) -> Dictionary:
	var godot_bin := OS.get_executable_path()
	var godot_abs := ProjectSettings.globalize_path("res://").trim_suffix("/")
	var full_args := ["--headless", "--audio-driver", "Dummy", "--path", godot_abs]
	for a in args:
		full_args.append(str(a))
	var output: Array = []
	var code := OS.execute(godot_bin, full_args, output, true)
	return {"exit_code": code, "output": "\n".join(output)}
