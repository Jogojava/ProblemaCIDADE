extends RefCounted

const EXPECTED_SITE_COMMIT := "c004bfe0cdc46a324092b83b6a675f8a6926df09"

func get_cases() -> Array[Dictionary]:
	return [
		{"id": "T2-F01-1", "method": "_t2_f01_1", "description": "site branch has zero diff vs baseline commit"},
		{"id": "T2-F01-2", "method": "_t2_f01_2", "description": "Zero orphan .uid files without matching resource"},
		{"id": "T2-F01-3", "method": "_t2_f01_3", "description": "Headless Game.tscn --quit exits 0 without errors"},
		{"id": "T2-F01-4", "method": "_t2_f01_4", "description": "Every scene in res://scenes/ instantiates cleanly"},
		{"id": "T2-F01-5", "method": "_t2_f01_5", "description": "All E2E scripts under res://tests/e2e/ parse cleanly"},
		{"id": "T2-F02-1", "method": "_t2_f02_1", "description": "test_mode == true leaves SettingsService._music null"},
		{"id": "T2-F02-2", "method": "_t2_f02_2", "description": "Music volume 0.0 clamps cleanly to -80 dB without NaN/-INF"},
		{"id": "T2-F02-3", "method": "_t2_f02_3", "description": "Music volume 100.0 equals 0.0 dB"},
		{"id": "T2-F02-4", "method": "_t2_f02_4", "description": "Scene round-trip main_menu->Game->main_menu creates no duplicate players"},
		{"id": "T2-F02-5", "method": "_t2_f02_5", "description": "Lobby soundtrack MP3 loads as valid AudioStream"},
		{"id": "T2-F03-1", "method": "_t2_f03_1", "description": "Esc closing urgent returns phase to opening and keeps ticking"},
		{"id": "T2-F03-2", "method": "_t2_f03_2", "description": "Urgent problem expires while open, closes popup, and applies penalty"},
		{"id": "T2-F03-3", "method": "_t2_f03_3", "description": "Expiring urgent #1 activates queued urgent #2 with 180s"},
		{"id": "T2-F03-4", "method": "_t2_f03_4", "description": "Urgent forces speed to NORMAL"},
		{"id": "T2-F03-5", "method": "_t2_f03_5", "description": "Manual pause freezes an unopened urgent deadline"},
		{"id": "T2-F04-1", "method": "_t2_f04_1", "description": "Leading/trailing spaces in text_input are trimmed cleanly"},
		{"id": "T2-F04-2", "method": "_t2_f04_2", "description": "Whitespace-only text_input submission is rejected"},
		{"id": "T2-F04-3", "method": "_t2_f04_3", "description": "Space while calculator open neither types in answer_input nor toggles pause"},
		{"id": "T2-F04-4", "method": "_t2_f04_4", "description": "Space while drawing board open does not toggle city pause"},
		{"id": "T2-F04-5", "method": "_t2_f04_5", "description": "Space with unfocused answer_input in text_input does not crash or unpause"},
		{"id": "T2-F05-1", "method": "_t2_f05_1", "description": "Disabled BoardButton/CalculatorButton/Option buttons preserve readable contrast"},
		{"id": "T2-F05-2", "method": "_t2_f05_2", "description": "Focused BoardButton maintains >= 4.5:1 font_focus_color contrast"},
		{"id": "T2-F05-3", "method": "_t2_f05_3", "description": "SettingsService white Button color does not bleed into Board/CalculatorButton"},
		{"id": "T2-F05-4", "method": "_t2_f05_4", "description": "Calculator operator keys (white) and digit/utility keys (dark ink) meet contrast"},
		{"id": "T2-F05-5", "method": "_t2_f05_5", "description": "HUD urgent_open_button maintains high contrast white-on-red across states"},
		{"id": "T2-F06-1", "method": "_t2_f06_1", "description": "Out-of-bounds coordinates return false for can_build and can_build_coord"},
		{"id": "T2-F06-2", "method": "_t2_f06_2", "description": "Boundary perimeter grass corners return true when unoccupied"},
		{"id": "T2-F06-3", "method": "_t2_f06_3", "description": "Road and town_hall coordinates return false"},
		{"id": "T2-F06-4", "method": "_t2_f06_4", "description": "Malformed dicts rejected safely and float JSON coords normalized"},
		{"id": "T2-F06-5", "method": "_t2_f06_5", "description": "Mouse motion outside placement mode triggers 0 redraws"},
		{"id": "T2-F07-1", "method": "_t2_f07_1", "description": "Year 9 month 12 usage JSON stays compact (< 15 KB)"},
		{"id": "T2-F07-2", "method": "_t2_f07_2", "description": "load_usage_save_data drops invalid IDs and deduplicates valid ones"},
		{"id": "T2-F07-3", "method": "_t2_f07_3", "description": "ensure_months_through is idempotent on repeated calls"},
		{"id": "T2-F07-4", "method": "_t2_f07_4", "description": "ensure_months_through handles invalid month/year bounds safely"},
		{"id": "T2-F07-5", "method": "_t2_f07_5", "description": "load_usage_save_data restores custom non-default definitions"},
		{"id": "T2-F08-1", "method": "_t2_f08_1", "description": "Wrong supply route option fails _is_answer_correct"},
		{"id": "T2-F08-2", "method": "_t2_f08_2", "description": "Month 96 supply route generates valid distinct routes"},
		{"id": "T2-F08-3", "method": "_t2_f08_3", "description": "Supply route generation is deterministic across fresh EventDatabases"},
		{"id": "T2-F08-4", "method": "_t2_f08_4", "description": "Re-invoking ensure_month_content preserves existing municipal_3_4"},
		{"id": "T2-F08-5", "method": "_t2_f08_5", "description": "Supply route PT and EN formatting causes no specifier mismatch"},
		{"id": "T2-F09-1", "method": "_t2_f09_1", "description": "Wrong answer grants 0 construction_days_saved"},
		{"id": "T2-F09-2", "method": "_t2_f09_2", "description": "Expired problem grants 0 construction_days_saved"},
		{"id": "T2-F09-3", "method": "_t2_f09_3", "description": "Construction bonus clamps due date to last_day + 1"},
		{"id": "T2-F09-4", "method": "_t2_f09_4", "description": "Construction bonus with 0 active projects is safe and records 0"},
		{"id": "T2-F09-5", "method": "_t2_f09_5", "description": "Negative or zero construction_days_saved never extends project due date"},
		{"id": "T2-F10-1", "method": "_t2_f10_1", "description": "Authored service effects clamp strictly within [0.0, 100.0]"},
		{"id": "T2-F10-2", "method": "_t2_f10_2", "description": "Optional authored problem expiration applies zero funds/rep/indicator delta"},
		{"id": "T2-F10-3", "method": "_t2_f10_3", "description": "Urgent authored problem expiration applies funds, rep, and service penalties"},
		{"id": "T2-F10-4", "method": "_t2_f10_4", "description": "Unknown indicator key in effects is ignored without crash"},
		{"id": "T2-F10-5", "method": "_t2_f10_5", "description": "Failing urgent authored problem at low reputation triggers impeachment"},
		{"id": "T2-F11-1", "method": "_t2_f11_1", "description": "validate_event_structure rejects number_input missing correct_value"},
		{"id": "T2-F11-2", "method": "_t2_f11_2", "description": "validate_event_structure rejects choice with empty options"},
		{"id": "T2-F11-3", "method": "_t2_f11_3", "description": "validate_event_structure rejects invalid category"},
		{"id": "T2-F11-4", "method": "_t2_f11_4", "description": "validate_event_structure rejects unknown interaction_type"},
		{"id": "T2-F11-5", "method": "_t2_f11_5", "description": "validate_event_structure rejects text_input missing accepted_answers"}
	]

func run_case(h: RefCounted, tree: SceneTree, case_info: Dictionary) -> void:
	await call(String(case_info["method"]), h, tree)

func _new_db() -> Node:
	var s := load("res://scripts/eventdatabase.gd") as GDScript
	var db: Node = s.new()
	db.call("register_default_problems")
	return db

func _t2_f01_1(h: RefCounted, _tree: SceneTree) -> void:
	var res: Dictionary = h.call("run_git", ["diff", EXPECTED_SITE_COMMIT, "site"])
	h.call("check_eq", res["exit_code"], 0, "git diff site succeeds")
	h.call("check_eq", String(res["output"]), "", "site branch diff vs baseline is empty")

func _t2_f01_2(h: RefCounted, _tree: SceneTree) -> void:
	var uids: Array = h.call("scan_files_recursive", "res://", ".uid")
	for u in uids:
		var path := String(u)
		if path.begins_with("res://.godot"):
			continue
		var base := path.left(path.length() - 4)
		h.call("check_true", FileAccess.file_exists(base), "Orphan .uid check: base exists for %s" % path)

func _t2_f01_3(h: RefCounted, _tree: SceneTree) -> void:
	var res: Dictionary = h.call("run_godot_subprocess", ["--scene", "res://scenes/game/Game.tscn", "--quit"])
	h.call("check_eq", res["exit_code"], 0, "Game.tscn --quit exits 0")
	var out := String(res["output"])
	h.call("check_not_contains", out, "SCRIPT ERROR:", "No SCRIPT ERROR on Game.tscn --quit")
	h.call("check_not_contains", out, "Parse Error:", "No Parse Error on Game.tscn --quit")

func _t2_f01_4(h: RefCounted, _tree: SceneTree) -> void:
	var scenes: Array = h.call("scan_files_recursive", "res://scenes", ".tscn")
	h.call("check_gt", float(scenes.size()), 3.0, "Found scenes under res://scenes")
	for s in scenes:
		var packed := load(String(s)) as PackedScene
		h.call("check_true", packed != null, "Scene loads: %s" % s)
		if packed != null:
			var inst := packed.instantiate()
			h.call("check_true", inst != null, "Scene instantiates: %s" % s)
			if inst != null:
				inst.free()

func _t2_f01_5(h: RefCounted, _tree: SceneTree) -> void:
	var scripts: Array = h.call("scan_files_recursive", "res://tests/e2e", ".gd")
	h.call("check_gt", float(scripts.size()), 5.0, "Found E2E GDScript files")
	for s in scripts:
		var loaded := load(String(s))
		h.call("check_true", loaded is GDScript, "E2E script parses cleanly: %s" % s)

func _t2_f02_1(h: RefCounted, tree: SceneTree) -> void:
	var settings := tree.root.get_node_or_null("SettingsService")
	h.call("check_true", settings != null, "SettingsService exists")
	if settings == null:
		return
	if bool(settings.get("test_mode")):
		h.call("check_true", settings.get("_music") == null, "test_mode == true leaves _music null")
	else:
		var res: Dictionary = h.call("run_godot_subprocess", ["--script", "res://tests/e2e/e2e_runner.gd", "--", "--test", "--probe-test-silent"])
		h.call("check_eq", res["exit_code"], 0, "--test subprocess leaves _music null")

func _t2_f02_2(h: RefCounted, tree: SceneTree) -> void:
	var settings := tree.root.get_node_or_null("SettingsService")
	var idx := AudioServer.get_bus_index("Music")
	settings.call("update", "music", 0.0)
	var db := AudioServer.get_bus_volume_db(idx)
	h.call("check_true", is_finite(db), "Music dB at 0.0 is finite")
	h.call("check_approx", db, linear_to_db(0.0001), 0.05, "Music dB clamps to linear_to_db(0.0001)")

func _t2_f02_3(h: RefCounted, tree: SceneTree) -> void:
	var settings := tree.root.get_node_or_null("SettingsService")
	var idx := AudioServer.get_bus_index("Music")
	settings.call("update", "music", 100.0)
	h.call("check_approx", AudioServer.get_bus_volume_db(idx), 0.0, 0.01, "Music dB at 100.0 equals 0.0 dB")

func _t2_f02_4(h: RefCounted, tree: SceneTree) -> void:
	var menu1: Node = await h.call("boot_scene", tree, "res://scenes/ui/main_menu.tscn")
	h.call("check_eq", _count_audio(menu1), 0, "Initial main_menu has 0 AudioStreamPlayers")
	var game: Node = await h.call("start_new_game", tree, "RoundAudio", "medium", true, true)
	h.call("check_true", game != null, "Game booted")
	var menu2: Node = await h.call("boot_scene", tree, "res://scenes/ui/main_menu.tscn")
	h.call("check_eq", _count_audio(menu2), 0, "Returned main_menu still has 0 AudioStreamPlayers")

func _count_audio(n: Node) -> int:
	if n == null:
		return 0
	var c := 1 if n is AudioStreamPlayer else 0
	for ch in n.get_children():
		c += _count_audio(ch)
	return c

func _t2_f02_5(h: RefCounted, _tree: SceneTree) -> void:
	var path := "res://assets/soundtrack/src_aud_lobby-classic-game.mp3"
	h.call("check_true", ResourceLoader.exists(path), "Soundtrack asset exists")
	var stream := load(path)
	h.call("check_true", stream is AudioStream, "Soundtrack loads as AudioStream")

func _trigger_urgent(game: Node, event_id: String = "rota_presidio") -> Dictionary:
	var em: Node = game.get("event_manager")
	var ed: Node = game.get("event_database")
	var tm: Node = game.get("time_manager")
	var rt: Dictionary = ed.call("build_runtime_event", event_id, int(tm.get("current_day")), int(tm.get("current_month")), int(tm.get("current_year")), 30, 12)
	em.get("active_events").append(rt)
	em.emit_signal("event_triggered", rt)
	return rt

func _t2_f03_1(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "UrgEsc", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var rt := _trigger_urgent(game, "rota_presidio")
	game.call("open_problem", "rota_presidio")
	await h.call("await_frames", tree, 3)
	h.call("check_eq", String(rt.get("deadline_phase", "")), "solving", "Phase is solving while open")
	await h.call("send_key_tap", tree, KEY_ESCAPE, 0)
	await h.call("await_frames", tree, 2)
	h.call("check_eq", String(rt.get("deadline_phase", "")), "opening", "Esc returns phase to opening")
	var before := float(rt.get("deadline_remaining_seconds", 180.0))
	game.call("_process", 3.0)
	h.call("check_approx", float(rt.get("deadline_remaining_seconds", 180.0)), before - 3.0, 0.05, "Urgent timer keeps ticking after Esc")

func _t2_f03_2(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "UrgExp", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var rt := _trigger_urgent(game, "rota_presidio")
	game.call("open_problem", "rota_presidio")
	await h.call("await_frames", tree, 3)
	rt["deadline_remaining_seconds"] = 1.0
	var funds_before := float(game.get("city").get("funds"))
	game.call("_process", 1.5)
	await h.call("await_frames", tree, 2)
	h.call("check_eq", String(game.get("_current_problem_id")), "", "Popup closed on expiration")
	h.call("check_eq", int(game.get("city").get("expired_count")), 1, "expired_count incremented")
	h.call("check_lt", float(game.get("city").get("funds")), funds_before, "Expiration penalty applied")

func _t2_f03_3(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "UrgQueue", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var rt1 := _trigger_urgent(game, "rota_presidio")
	var rt2 := _trigger_urgent(game, "moradias_enchente")
	h.call("check_eq", String(rt1.get("deadline_phase", "")), "opening", "First urgent opening")
	h.call("check_eq", String(rt2.get("deadline_phase", "")), "queued", "Second urgent queued")
	rt1["deadline_remaining_seconds"] = 0.5
	game.call("_process", 1.0)
	h.call("check_eq", String(rt2.get("deadline_phase", "")), "opening", "Second urgent becomes opening after first expires")
	h.call("check_approx", float(rt2.get("deadline_remaining_seconds", 0.0)), 180.0, 0.01, "Second urgent starts at 180.0s")

func _t2_f03_4(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "UrgSpd", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var tm: Node = game.get("time_manager")
	tm.call("set_speed", 2)
	_trigger_urgent(game, "rota_presidio")
	h.call("check_eq", int(tm.get("current_speed")), 0, "Urgent resets speed to NORMAL")

func _t2_f03_5(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "UrgPause", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var tm: Node = game.get("time_manager")
	var rt := _trigger_urgent(game, "rota_presidio")
	tm.call("pause_game")
	var before := float(rt.get("deadline_remaining_seconds", 180.0))
	game.call("_process", 2.5)
	h.call("check_approx", float(rt.get("deadline_remaining_seconds", 180.0)), before, 0.05, "Closed urgent deadline freezes during manual pause")

func _open_text_input(h: RefCounted, tree: SceneTree, game: Node) -> Control:
	var ed: Node = game.get("event_database")
	var em: Node = game.get("event_manager")
	var tm: Node = game.get("time_manager")
	ed.call("register_event", "t2_txt", {
		"title": "Texto BVA",
		"description": "Resp",
		"category": "common",
		"interaction_type": "text_input",
		"payload": {"prompt": "Digite", "accepted_answers": ["resposta"]},
		"success_effects": {"social": 2.0},
		"failure_effects": {"social": -1.0}
	})
	var rt: Dictionary = ed.call("build_runtime_event", "t2_txt", int(tm.get("current_day")), int(tm.get("current_month")), int(tm.get("current_year")), 30, 12)
	em.get("active_events").append(rt)
	game.call("open_problem", "t2_txt")
	await h.call("await_frames", tree, 3)
	return game.get("_current_problem_popup") as Control

func _t2_f04_1(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "TxtTrim", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var popup := await _open_text_input(h, tree, game)
	var inp: LineEdit = popup.get("answer_input")
	inp.text = "  resposta  "
	popup.call("_submit_typed_answer")
	await h.call("await_frames", tree, 2)
	h.call("check_eq", int(game.get("city").get("correct_count")), 1, "Trimmed answer accepted")

func _t2_f04_2(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "TxtBlank", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var popup := await _open_text_input(h, tree, game)
	var inp: LineEdit = popup.get("answer_input")
	inp.text = "   "
	popup.call("_submit_typed_answer")
	await h.call("await_frames", tree, 2)
	h.call("check_eq", int(game.get("city").get("solved_count")), 0, "Whitespace-only answer not submitted")
	h.call("check_true", is_instance_valid(game.get("_current_problem_popup")), "Popup remains open")

func _t2_f04_3(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "TxtCalc", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var popup := await _open_text_input(h, tree, game)
	var tm: Node = game.get("time_manager")
	var paused_before := bool(tm.get("paused"))
	popup.call("_show_calculator")
	await h.call("await_frames", tree, 1)
	await h.call("send_key_tap", tree, KEY_SPACE, 32)
	var inp: LineEdit = popup.get("answer_input")
	h.call("check_eq", inp.text, "", "Space while calculator open does not enter answer_input")
	h.call("check_eq", bool(tm.get("paused")), paused_before, "Space while calculator open does not toggle pause")

func _t2_f04_4(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "TxtBoard", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var popup := await _open_text_input(h, tree, game)
	var tm: Node = game.get("time_manager")
	var paused_before := bool(tm.get("paused"))
	popup.call("_show_board")
	await h.call("await_frames", tree, 1)
	await h.call("send_key_tap", tree, KEY_SPACE, 32)
	h.call("check_eq", bool(tm.get("paused")), paused_before, "Space while board open does not toggle pause")

func _t2_f04_5(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "TxtUnfocus", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var popup := await _open_text_input(h, tree, game)
	var inp: LineEdit = popup.get("answer_input")
	inp.release_focus()
	await h.call("await_frames", tree, 1)
	await h.call("send_key_tap", tree, KEY_SPACE, 32)
	h.call("check_true", bool(game.get("time_manager").get("paused")), "Challenge stays paused when unfocused LineEdit receives Space")

func _boot_prob_template(h: RefCounted, tree: SceneTree) -> Control:
	var packed := load("res://scenes/ui/problem_template.tscn") as PackedScene
	var popup := packed.instantiate() as Control
	var settings := tree.root.get_node_or_null("SettingsService")
	if settings != null:
		popup.theme = settings.get("game_theme")
	tree.root.add_child(popup)
	await h.call("await_frames", tree, 2)
	return popup

func _t2_f05_1(h: RefCounted, tree: SceneTree) -> void:
	var popup := await _boot_prob_template(h, tree)
	for name in ["BoardButton", "CalculatorButton"]:
		var btn := popup.get_node("Center/Panel/Margin/Content/Body/ProblemTools/" + name) as Button
		btn.disabled = true
		var bg: Color = h.call("extract_stylebox_bg", btn.get_theme_stylebox("disabled"))
		var fg := btn.get_theme_color("font_disabled_color")
		h.call("check_ne", fg, bg, "%s disabled font differs from bg" % name)

func _t2_f05_2(h: RefCounted, tree: SceneTree) -> void:
	var popup := await _boot_prob_template(h, tree)
	var btn := popup.get_node("Center/Panel/Margin/Content/Body/ProblemTools/BoardButton") as Button
	btn.grab_focus()
	await h.call("await_frames", tree, 1)
	var bg: Color = h.call("extract_stylebox_bg", btn.get_theme_stylebox("normal"))
	var fg := btn.get_theme_color("font_focus_color")
	var ratio: float = h.call("contrast_ratio", fg, bg)
	h.call("check_gt", ratio, 4.5, "Focused BoardButton font_focus_color contrast >= 4.5")

func _t2_f05_3(h: RefCounted, tree: SceneTree) -> void:
	var popup := await _boot_prob_template(h, tree)
	for name in ["BoardButton", "CalculatorButton"]:
		var btn := popup.get_node("Center/Panel/Margin/Content/Body/ProblemTools/" + name) as Button
		h.call("check_true", btn.has_theme_color_override("font_hover_color"), "%s overrides font_hover_color" % name)
		h.call("check_true", btn.has_theme_color_override("font_focus_color"), "%s overrides font_focus_color" % name)
		h.call("check_true", btn.has_theme_color_override("font_pressed_color"), "%s overrides font_pressed_color" % name)

func _t2_f05_4(h: RefCounted, tree: SceneTree) -> void:
	var popup := await _boot_prob_template(h, tree)
	var keys := popup.get("calculator_keys") as GridContainer
	for b in keys.get_children():
		if b is Button:
			var btn := b as Button
			var bg: Color = h.call("extract_stylebox_bg", btn.get_theme_stylebox("normal"))
			var fg := btn.get_theme_color("font_color")
			var ratio: float = h.call("contrast_ratio", fg, bg)
			h.call("check_gt", ratio, 4.5, "Calc key '%s' contrast >= 4.5" % btn.text)

func _t2_f05_5(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "UrgBtn", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var hud: Node = game.get("hud")
	var btn: Button = hud.get("urgent_open_button")
	var bg: Color = h.call("extract_stylebox_bg", btn.get_theme_stylebox("normal"))
	for state_col in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		var ratio: float = h.call("contrast_ratio", btn.get_theme_color(state_col), bg)
		h.call("check_gt", ratio, 4.5, "urgent_open_button %s contrast >= 4.5" % state_col)

func _t2_f06_1(h: RefCounted, tree: SceneTree) -> void:
	var city := CityState.new()
	city.start("OOB", "medium")
	var vis := CityVisuals.new()
	tree.root.add_child(vis)
	vis.bind(city)
	for c in [Vector2i(-13, 0), Vector2i(13, 0), Vector2i(0, -13), Vector2i(500, 500)]:
		h.call("check_false", city.can_build({"x": c.x, "y": c.y}), "Out of bounds can_build false for %s" % str(c))
		if city.has_method("can_build_coord"):
			h.call("check_false", bool(city.call("can_build_coord", c)), "Out of bounds can_build_coord false for %s" % str(c))

func _t2_f06_2(h: RefCounted, tree: SceneTree) -> void:
	var city := CityState.new()
	city.start("Corners", "medium")
	var vis := CityVisuals.new()
	tree.root.add_child(vis)
	vis.bind(city)
	for c in [Vector2i(-12, -12), Vector2i(12, 12), Vector2i(-12, 12), Vector2i(12, -12)]:
		h.call("check_true", city.can_build({"x": c.x, "y": c.y}), "Perimeter corner %s buildable" % str(c))
		if city.has_method("can_build_coord"):
			h.call("check_true", bool(city.call("can_build_coord", c)), "Perimeter corner coord %s buildable" % str(c))

func _t2_f06_3(h: RefCounted, tree: SceneTree) -> void:
	var city := CityState.new()
	city.start("Roads", "medium")
	var vis := CityVisuals.new()
	tree.root.add_child(vis)
	vis.bind(city)
	for c in [Vector2i(0, 0), Vector2i(6, 1), Vector2i(-6, 2), Vector2i(1, 6), Vector2i(1, -6), Vector2i(-1, -1)]:
		h.call("check_false", city.can_build({"x": c.x, "y": c.y}), "Road/hall %s blocked" % str(c))
		if city.has_method("can_build_coord"):
			h.call("check_false", bool(city.call("can_build_coord", c)), "Road/hall coord %s blocked" % str(c))

func _t2_f06_4(h: RefCounted, tree: SceneTree) -> void:
	var city := CityState.new()
	city.start("FloatLots", "medium")
	var vis := CityVisuals.new()
	tree.root.add_child(vis)
	vis.bind(city)
	h.call("check_false", city.can_build({}), "Empty dict returns false")
	h.call("check_false", city.can_build({"x": 1}), "Missing y dict returns false")
	var float_lot := {"x": 11.0, "y": 11.0}
	h.call("check_true", city.can_build(float_lot), "Float JSON coords buildable")
	h.call("check_eq", city.construct("water", 0, float_lot), "", "Construct with float JSON coords succeeds")
	if city.has_method("can_build_coord"):
		h.call("check_false", bool(city.call("can_build_coord", Vector2i(11, 11))), "Vector2i(11,11) blocked after float construct")

func _t2_f06_5(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "NoPlaceMotion", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var vis: CityVisuals = game.get("visuals")
	await h.call("await_frames", tree, 2)
	var count := [0]
	vis.draw.connect(func(): count[0] += 1)
	for i in range(5):
		await h.call("send_mouse_motion", tree, Vector2(200 + i * 50, 300))
		await h.call("await_frames", tree, 1)
	h.call("check_eq", count[0], 0, "Mouse motion outside placement mode triggers 0 redraws")

func _t2_f07_1(h: RefCounted, _tree: SceneTree) -> void:
	var db := _new_db()
	if db.has_method("ensure_months_through"):
		db.call("ensure_months_through", 12, 9)
	else:
		for y in range(1, 10):
			for m in range(1, 13):
				db.call("ensure_month_content", m, y)
	for idx in range(1, 109):
		db.call("mark_event_used", "municipal_%d_0" % idx)
	var usage: Dictionary = db.call("get_usage_save_data")
	var json_len := JSON.stringify(usage).length()
	h.call("check_lt", float(json_len), 15000.0, "Year 9 month 12 usage JSON < 15 KB (got %d)" % json_len)
	db.free()

func _t2_f07_2(h: RefCounted, _tree: SceneTree) -> void:
	var db := _new_db()
	db.call("load_usage_save_data", {"used_ids_by_category": {"common": ["nonexistent_id", "municipal_2_1", "municipal_2_1"]}})
	var used: Array = db.get("_used_ids_by_category").get("common", [])
	h.call("check_false", used.has("nonexistent_id"), "Invalid ID dropped")
	h.call("check_eq", used.count("municipal_2_1"), 1, "Duplicate valid municipal_2_1 deduplicated")
	h.call("check_true", bool(db.call("has_event", "municipal_2_1")), "municipal_2_1 generated on load")
	db.free()

func _t2_f07_3(h: RefCounted, _tree: SceneTree) -> void:
	var db := _new_db()
	if not db.has_method("ensure_months_through"):
		h.call("check", false, "ensure_months_through missing")
		db.free()
		return
	db.call("ensure_months_through", 6, 2)
	var snap1: Dictionary = db.call("get_event", "municipal_15_4")
	db.call("ensure_months_through", 6, 2)
	var snap2: Dictionary = db.call("get_event", "municipal_15_4")
	h.call("check_eq", snap1, snap2, "ensure_months_through is idempotent")
	db.free()

func _t2_f07_4(h: RefCounted, _tree: SceneTree) -> void:
	var db := _new_db()
	if not db.has_method("ensure_months_through"):
		h.call("check", false, "ensure_months_through missing")
		db.free()
		return
	var before: int = db.call("get_all_event_ids").size()
	db.call("ensure_months_through", 0, 1)
	db.call("ensure_months_through", 1, 0)
	var after: int = db.call("get_all_event_ids").size()
	h.call("check_eq", after, before, "Invalid month/year bounds no-op safely")
	db.free()

func _t2_f07_5(h: RefCounted, _tree: SceneTree) -> void:
	var db := _new_db()
	db.call("load_usage_save_data", {"definitions": {"custom_leg": {"id": "custom_leg", "category": "common", "interaction_type": "choice", "payload": {"options": [{"id": "x", "text": "X"}]}}}})
	h.call("check_true", bool(db.call("has_event", "custom_leg")), "Custom definition loads cleanly")
	db.free()

func _t2_f08_1(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "SupWrong", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var ed: Node = game.get("event_database")
	ed.call("ensure_month_content", 1, 1)
	ed.call("ensure_month_content", 2, 1)
	for id in ["municipal_1_4", "municipal_2_4"]:
		var ev: Dictionary = ed.call("get_event", id)
		var wrong := "b" if String(ev.get("correct_answer", "a")) == "a" else "a"
		h.call("check_false", bool(game.call("_is_answer_correct", ev, wrong)), "Wrong option fails %s" % id)

func _t2_f08_2(h: RefCounted, _tree: SceneTree) -> void:
	var db := _new_db()
	db.call("ensure_month_content", 12, 8)
	var ev: Dictionary = db.call("get_event", "municipal_96_4")
	var g: Dictionary = ev.get("graph", {})
	h.call("check_gt", float(g.get("a", 0)), 0.0, "Month 96 graph.a > 0")
	h.call("check_gt", float(g.get("b", 0)), 0.0, "Month 96 graph.b > 0")
	h.call("check_ne", int(g.get("a", 0)) + 4, int(g.get("b", 0)) + 7, "Month 96 routes have distinct total lengths")
	db.free()

func _t2_f08_3(h: RefCounted, _tree: SceneTree) -> void:
	var db1 := _new_db()
	var db2 := _new_db()
	db1.call("ensure_month_content", 7, 1)
	db2.call("ensure_month_content", 7, 1)
	h.call("check_eq", db1.call("get_event", "municipal_7_4"), db2.call("get_event", "municipal_7_4"), "Supply route deterministic across fresh DBs")
	db1.free()
	db2.free()

func _t2_f08_4(h: RefCounted, _tree: SceneTree) -> void:
	var db := _new_db()
	db.call("ensure_month_content", 3, 1)
	var first: Dictionary = db.call("get_event", "municipal_3_4")
	db.call("ensure_month_content", 3, 1)
	var second: Dictionary = db.call("get_event", "municipal_3_4")
	h.call("check_eq", first, second, "Re-invoking ensure_month_content preserves municipal_3_4")
	db.free()

func _t2_f08_5(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "SupLoc", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var ed: Node = game.get("event_database")
	ed.call("ensure_month_content", 4, 1)
	var ev: Dictionary = ed.call("get_event", "municipal_4_4")
	var settings := tree.root.get_node_or_null("SettingsService")
	for loc in ["pt_BR", "en"]:
		settings.call("update", "locale", loc)
		var desc: String = game.call("_problem_description", ev)
		h.call("check_false", desc.is_empty(), "Formatted description non-empty (%s)" % loc)
		h.call("check_not_contains", desc, "%d", "No raw specifier in description (%s)" % loc)

func _t2_f09_1(h: RefCounted, _tree: SceneTree) -> void:
	var city := CityState.new()
	city.start("BonusWrong", "medium")
	city.construct("health", 0)
	city.apply_problem({"id": "municipal_1_1", "category": "common", "construction_days_saved": 5}, false)
	h.call("check_eq", int(city.projects[0].due), 20, "Wrong answer grants 0 days saved")

func _t2_f09_2(h: RefCounted, _tree: SceneTree) -> void:
	var city := CityState.new()
	city.start("BonusExp", "medium")
	city.construct("health", 0)
	city.apply_problem({"id": "municipal_1_1", "category": "common", "construction_days_saved": 5}, false, true)
	h.call("check_eq", int(city.projects[0].due), 20, "Expired problem grants 0 days saved")

func _t2_f09_3(h: RefCounted, _tree: SceneTree) -> void:
	var city := CityState.new()
	city.start("BonusClamp", "medium")
	city.construct("health", 0)
	city.advance_day(18)
	city.apply_problem({"id": "municipal_1_1", "category": "common", "construction_days_saved": 5}, true)
	h.call("check_eq", int(city.projects[0].due), 19, "Due clamps to last_day + 1 (19)")

func _t2_f09_4(h: RefCounted, _tree: SceneTree) -> void:
	var city := CityState.new()
	city.start("BonusEmpty", "medium")
	var res := city.apply_problem({"id": "municipal_1_1", "category": "common", "construction_days_saved": 5}, true)
	h.call("check_eq", int(res.get("construction_days_saved", 0)), 0, "Zero active projects records 0 days saved")

func _t2_f09_5(h: RefCounted, _tree: SceneTree) -> void:
	var city := CityState.new()
	city.start("BonusNeg", "medium")
	city.construct("health", 0)
	city.apply_problem({"id": "p_neg", "category": "common", "construction_days_saved": -3}, true)
	h.call("check_eq", int(city.projects[0].due), 20, "Negative days_saved does not extend due")
	city.apply_problem({"id": "p_zero", "category": "common", "construction_days_saved": 0}, true)
	h.call("check_eq", int(city.projects[0].due), 20, "Zero days_saved leaves due at 20")

func _t2_f10_1(h: RefCounted, _tree: SceneTree) -> void:
	var db := _new_db()
	var ev: Dictionary = db.call("get_event", "merenda_escolar")
	var city := CityState.new()
	city.start("Clamp", "medium")
	city.indicators["education"] = 99.5
	city.apply_problem(ev, true)
	h.call("check_approx", float(city.indicators["education"]), 100.0, 0.001, "Indicator clamped at 100.0")
	city.indicators["education"] = 0.5
	city.apply_problem(ev, false)
	h.call("check_approx", float(city.indicators["education"]), 0.0, 0.001, "Indicator clamped at 0.0")
	db.free()

func _t2_f10_2(h: RefCounted, _tree: SceneTree) -> void:
	var db := _new_db()
	for id in ["aura_travessia", "pesquisa_satisfacao"]:
		var city := CityState.new()
		city.start("OptExp", "medium")
		var before_f := city.funds
		var before_r := city.reputation
		var before_ind := city.indicators.duplicate(true)
		city.apply_problem(db.call("get_event", id), false, true)
		h.call("check_approx", city.funds, before_f, 0.001, "%s expiration 0 funds delta" % id)
		h.call("check_approx", city.reputation, before_r, 0.001, "%s expiration 0 rep delta" % id)
		h.call("check_eq", city.indicators, before_ind, "%s expiration 0 indicator delta" % id)
	db.free()

func _t2_f10_3(h: RefCounted, _tree: SceneTree) -> void:
	var db := _new_db()
	for pair in [["moradias_enchente", "social"], ["rota_presidio", "security"]]:
		var city := CityState.new()
		city.start("UrgExp", "medium")
		var before_f := city.funds
		var before_r := city.reputation
		var before_s := float(city.indicators[pair[1]])
		city.apply_problem(db.call("get_event", pair[0]), false, true)
		h.call("check_approx", city.funds, before_f - 8000.0, 0.01, "%s expiration funds -8000" % pair[0])
		h.call("check_lt", city.reputation, before_r, "%s expiration rep drops" % pair[0])
		h.call("check_lt", float(city.indicators[pair[1]]), before_s, "%s expiration %s drops" % [pair[0], pair[1]])
	db.free()

func _t2_f10_4(h: RefCounted, _tree: SceneTree) -> void:
	var city := CityState.new()
	city.start("UnknownInd", "medium")
	var keys_before := city.indicators.keys().duplicate()
	city.apply_problem({"id": "u1", "category": "common", "success_effects": {"nonexistent": 50.0}}, true)
	h.call("check_eq", city.indicators.keys(), keys_before, "Unknown indicator key ignored without modifying keys")

func _t2_f10_5(h: RefCounted, _tree: SceneTree) -> void:
	var db := _new_db()
	var city := CityState.new()
	city.start("ImpZero", "medium")
	city.reputation = 1.0
	var events := []
	city.campaign_event.connect(func(k): events.append(k))
	city.apply_problem(db.call("get_event", "rota_presidio"), false)
	h.call("check_approx", city.reputation, 0.0, 0.001, "Reputation dropped to 0.0")
	h.call("check_eq", city.outcome, "impeachment", "Outcome becomes impeachment")
	h.call("check_true", events.has("impeachment"), "campaign_event('impeachment') emitted")
	db.free()

func _t2_f11_1(h: RefCounted, _tree: SceneTree) -> void:
	var db := _new_db()
	h.call("check_false", bool(db.call("validate_event_structure", {"id": "n", "category": "common", "interaction_type": "number_input", "payload": {"placeholder": "x"}})), "Missing correct_value rejected")
	db.free()

func _t2_f11_2(h: RefCounted, _tree: SceneTree) -> void:
	var db := _new_db()
	h.call("check_false", bool(db.call("validate_event_structure", {"id": "c", "category": "common", "interaction_type": "choice", "payload": {"options": []}})), "Empty choice options rejected")
	db.free()

func _t2_f11_3(h: RefCounted, _tree: SceneTree) -> void:
	var db := _new_db()
	h.call("check_false", bool(db.call("validate_event_structure", {"id": "k", "category": "critical", "interaction_type": "choice", "payload": {"options": [{"id": "a", "text": "A"}]}})), "Invalid category rejected")
	db.free()

func _t2_f11_4(h: RefCounted, _tree: SceneTree) -> void:
	var db := _new_db()
	h.call("check_false", bool(db.call("validate_event_structure", {"id": "s", "category": "common", "interaction_type": "slider", "payload": {}})), "Unknown interaction_type rejected")
	db.free()

func _t2_f11_5(h: RefCounted, _tree: SceneTree) -> void:
	var db := _new_db()
	h.call("check_false", bool(db.call("validate_event_structure", {"id": "t", "category": "common", "interaction_type": "text_input", "payload": {"prompt": "Type"}})), "text_input without accepted_answers rejected")
	db.free()
