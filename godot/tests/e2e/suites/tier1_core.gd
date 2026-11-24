extends RefCounted

const EXPECTED_SITE_COMMIT := "c004bfe0cdc46a324092b83b6a675f8a6926df09"
const AUTHORED_IDS := [
	"aura_travessia", "merenda_escolar", "transporte_proporcional", "juros_bancos",
	"rota_medicamentos", "moradias_enchente", "verba_imss", "rota_presidio",
	"pesquisa_satisfacao", "obras_combinacoes"
]

func get_cases() -> Array[Dictionary]:
	return [
		{"id": "T1-F01-1", "method": "_t1_f01_1", "description": "Git branch main active and site untouched"},
		{"id": "T1-F01-2", "method": "_t1_f01_2", "description": "Headless Godot quit exits 0 with no script/parse errors"},
		{"id": "T1-F01-3", "method": "_t1_f01_3", "description": "All primary scenes load and instantiate cleanly"},
		{"id": "T1-F01-4", "method": "_t1_f01_4", "description": "All GDScript files under project load validly"},
		{"id": "T1-F01-5", "method": "_t1_f01_5", "description": "Integration test_campaign.gd passes and test_city_layout.gd has no parse errors"},
		{"id": "T1-F02-1", "method": "_t1_f02_1", "description": "SettingsService creates and plays _music on Music bus when not in test_mode"},
		{"id": "T1-F02-2", "method": "_t1_f02_2", "description": "main_menu.tscn has zero AudioStreamPlayer children"},
		{"id": "T1-F02-3", "method": "_t1_f02_3", "description": "Music bus exists, sends to Master, and reflects values.music"},
		{"id": "T1-F02-4", "method": "_t1_f02_4", "description": "SettingsService._music.finished is connected for looping"},
		{"id": "T1-F02-5", "method": "_t1_f02_5", "description": "SettingsService.update('muted') toggles Master bus mute"},
		{"id": "T1-F03-1", "method": "_t1_f03_1", "description": "Urgent event triggers with opening phase and NORMAL speed"},
		{"id": "T1-F03-2", "method": "_t1_f03_2", "description": "Space pauses urgent deadline while problem is closed"},
		{"id": "T1-F03-3", "method": "_t1_f03_3", "description": "Prior manual pause freezes unopened urgent deadline"},
		{"id": "T1-F03-4", "method": "_t1_f03_4", "description": "Open urgent deadline continues while game is paused"},
		{"id": "T1-F03-5", "method": "_t1_f03_5", "description": "Briefing PT and EN text reflects urgent deadlines continuing"},
		{"id": "T1-F04-1", "method": "_t1_f04_1", "description": "text_input problem focuses editable answer_input"},
		{"id": "T1-F04-2", "method": "_t1_f04_2", "description": "Space in focused text_input inserts space instead of pausing"},
		{"id": "T1-F04-3", "method": "_t1_f04_3", "description": "Multi-word text_input submission preserves internal spaces"},
		{"id": "T1-F04-4", "method": "_t1_f04_4", "description": "Space toggles pause on city view when no LineEdit is focused"},
		{"id": "T1-F04-5", "method": "_t1_f04_5", "description": "Space does not unpause choice problem when answer_input is hidden"},
		{"id": "T1-F05-1", "method": "_t1_f05_1", "description": "BoardButton font colors have dark ink luminance across all states"},
		{"id": "T1-F05-2", "method": "_t1_f05_2", "description": "CalculatorButton font colors have dark ink luminance across all states"},
		{"id": "T1-F05-3", "method": "_t1_f05_3", "description": "BoardButton and CalculatorButton pressed styleboxes have light bg"},
		{"id": "T1-F05-4", "method": "_t1_f05_4", "description": "BoardButton and CalculatorButton WCAG contrast >= 4.5:1 across states"},
		{"id": "T1-F05-5", "method": "_t1_f05_5", "description": "Option1..4 and calculator_keys maintain >= 4.5:1 WCAG contrast"},
		{"id": "T1-F06-1", "method": "_t1_f06_1", "description": "CityState.can_build_coord matches can_build across all 625 grid coords"},
		{"id": "T1-F06-2", "method": "_t1_f06_2", "description": "CityVisuals configures 484 grass lots; town_hall and 18 initial homes blocked"},
		{"id": "T1-F06-3", "method": "_t1_f06_3", "description": "can_build_coord stays synchronized after construct, place_home, and growth"},
		{"id": "T1-F06-4", "method": "_t1_f06_4", "description": "CityVisuals mouse motion within same tile triggers zero extra redraws"},
		{"id": "T1-F06-5", "method": "_t1_f06_5", "description": "CityVisuals mouse motion to different tile updates hovered and redraws once"},
		{"id": "T1-F07-1", "method": "_t1_f07_1", "description": "EventDatabase.get_usage_save_data omits default and municipal_* definitions"},
		{"id": "T1-F07-2", "method": "_t1_f07_2", "description": "EventDatabase.get_usage_save_data preserves custom event definitions"},
		{"id": "T1-F07-3", "method": "_t1_f07_3", "description": "EventDatabase.ensure_months_through generates all deterministic months"},
		{"id": "T1-F07-4", "method": "_t1_f07_4", "description": "EventDatabase usage save/load round-trips municipal and authored IDs"},
		{"id": "T1-F07-5", "method": "_t1_f07_5", "description": "Full SaveManager 24-month save omits municipal_* definitions and reloads cleanly"},
		{"id": "T1-F08-1", "method": "_t1_f08_1", "description": "Supply routes correct_answer varies across months (both a and b)"},
		{"id": "T1-F08-2", "method": "_t1_f08_2", "description": "Supply routes option order varies across months"},
		{"id": "T1-F08-3", "method": "_t1_f08_3", "description": "Supply routes km/cost/time math and explanation match correct_answer"},
		{"id": "T1-F08-4", "method": "_t1_f08_4", "description": "Supply routes graph data matches description distances"},
		{"id": "T1-F08-5", "method": "_t1_f08_5", "description": "Supply routes PT and EN descriptions/explanations format without raw placeholders"},
		{"id": "T1-F09-1", "method": "_t1_f09_1", "description": "CityState.apply_problem applies explicit construction_days_saved"},
		{"id": "T1-F09-2", "method": "_t1_f09_2", "description": "obras_combinacoes does not apply hidden 5-day obra bonus"},
		{"id": "T1-F09-3", "method": "_t1_f09_3", "description": "CityState.last_result records applied construction_days_saved"},
		{"id": "T1-F09-4", "method": "_t1_f09_4", "description": "municipal_1_1 declares construction_days_saved == 5 and mentions bonus"},
		{"id": "T1-F09-5", "method": "_t1_f09_5", "description": "Feedback UI displays 5-day construction bonus in PT and EN"},
		{"id": "T1-F10-1", "method": "_t1_f10_1", "description": "All 10 authored problems have positive service effects in GameRules.AREAS"},
		{"id": "T1-F10-2", "method": "_t1_f10_2", "description": "All 10 authored problems have negative failure_effects in GameRules.AREAS"},
		{"id": "T1-F10-3", "method": "_t1_f10_3", "description": "Authored expiration_effects are empty for optional and negative for non-optional"},
		{"id": "T1-F10-4", "method": "_t1_f10_4", "description": "rota_medicamentos applies choice_effects for rota_a and rota_b cleanly"},
		{"id": "T1-F10-5", "method": "_t1_f10_5", "description": "CityState indicators change by exact authored success/failure/expiration deltas"},
		{"id": "T1-F11-1", "method": "_t1_f11_1", "description": "validate_event_structure passes for all 8 procedural municipal_1_0..7 events"},
		{"id": "T1-F11-2", "method": "_t1_f11_2", "description": "validate_event_structure passes for all 10 authored problems"},
		{"id": "T1-F11-3", "method": "_t1_f11_3", "description": "validate_event_structure accepts minimal number_input without prompt"},
		{"id": "T1-F11-4", "method": "_t1_f11_4", "description": "validate_event_structure accepts valid choice event"},
		{"id": "T1-F11-5", "method": "_t1_f11_5", "description": "validate_event_structure accepts valid text_input event"}
	]

func run_case(h: RefCounted, tree: SceneTree, case_info: Dictionary) -> void:
	await call(String(case_info["method"]), h, tree)

func _new_db() -> Node:
	var s := load("res://scripts/eventdatabase.gd") as GDScript
	var db: Node = s.new()
	db.call("register_default_problems")
	return db

func _t1_f01_1(h: RefCounted, _tree: SceneTree) -> void:
	var br: Dictionary = h.call("run_git", ["branch", "--show-current"])
	h.call("check_eq", br["exit_code"], 0, "git branch command succeeds")
	h.call("check_eq", br["output"], "main", "Current git branch must be main")
	var sr: Dictionary = h.call("run_git", ["rev-parse", "site"])
	h.call("check_eq", sr["exit_code"], 0, "git rev-parse site succeeds")
	h.call("check_eq", sr["output"], EXPECTED_SITE_COMMIT, "site branch must remain at expected commit")

func _t1_f01_2(h: RefCounted, _tree: SceneTree) -> void:
	var res: Dictionary = h.call("run_godot_subprocess", ["--quit"])
	h.call("check_eq", res["exit_code"], 0, "Godot headless --quit exits 0")
	var out := String(res["output"])
	h.call("check_not_contains", out, "SCRIPT ERROR:", "No SCRIPT ERROR during headless boot")
	h.call("check_not_contains", out, "Parse Error:", "No Parse Error during headless boot")

func _t1_f01_3(h: RefCounted, _tree: SceneTree) -> void:
	var paths := [
		"res://scenes/ui/main_menu.tscn",
		"res://scenes/ui/carregar.tscn",
		"res://scenes/ui/opcoes.tscn",
		"res://scenes/ui/creditos.tscn",
		"res://scenes/game/Game.tscn",
		"res://scenes/ui/HUD.tscn",
		"res://scenes/ui/PauseMenu.tscn",
		"res://scenes/ui/problem_template.tscn"
	]
	for p in paths:
		var exists := ResourceLoader.exists(p)
		h.call("check_true", exists, "Scene exists: %s" % p)
		if exists:
			var packed := load(p) as PackedScene
			h.call("check_true", packed != null, "PackedScene loads: %s" % p)
			if packed != null:
				var inst := packed.instantiate()
				h.call("check_true", inst != null, "Scene instantiates: %s" % p)
				if inst != null:
					inst.free()

func _t1_f01_4(h: RefCounted, _tree: SceneTree) -> void:
	var dirs := ["res://core", "res://game", "res://scenes", "res://scripts", "res://ui"]
	var total := 0
	for d in dirs:
		var files: Array = h.call("scan_files_recursive", d, ".gd")
		for f in files:
			total += 1
			var scr := load(String(f))
			h.call("check_true", scr is GDScript, "GDScript loads validly: %s" % f)
	h.call("check_gt", float(total), 5.0, "Scanned multiple project GDScript files")

func _t1_f01_5(h: RefCounted, _tree: SceneTree) -> void:
	var res: Dictionary = h.call("run_godot_subprocess", ["--script", "res://tests/integration/test_campaign.gd", "--", "--test"])
	var out := String(res["output"])
	h.call("check_not_contains", out, "SCRIPT ERROR:", "test_campaign.gd has no SCRIPT ERROR")
	h.call("check_not_contains", out, "Parse Error:", "test_campaign.gd has no Parse Error")
	h.call("check_eq", res["exit_code"], 0, "test_campaign.gd exits 0 with 0 failures")
	var layout_res: Dictionary = h.call("run_godot_subprocess", ["--script", "res://tests/integration/test_city_layout.gd", "--", "--test"])
	var layout_out := String(layout_res["output"])
	h.call("check_not_contains", layout_out, "SCRIPT ERROR:", "test_city_layout.gd has no SCRIPT ERROR")
	h.call("check_not_contains", layout_out, "Parse Error:", "test_city_layout.gd has no Parse Error")

func _t1_f02_1(h: RefCounted, tree: SceneTree) -> void:
	var settings := tree.root.get_node_or_null("SettingsService")
	h.call("check_true", settings != null, "SettingsService autoload exists")
	if settings == null:
		return
	if bool(settings.get("test_mode")):
		var res: Dictionary = h.call("run_godot_subprocess", ["--script", "res://tests/e2e/e2e_runner.gd", "--", "--probe-audio"])
		h.call("check_eq", res["exit_code"], 0, "Non-test boot creates playing _music on Music bus")
	else:
		var music: Variant = settings.get("_music")
		h.call("check_true", music is AudioStreamPlayer, "_music AudioStreamPlayer created in non-test mode")
		if music is AudioStreamPlayer:
			var p := music as AudioStreamPlayer
			h.call("check_eq", p.bus, "Music", "_music routed to Music bus")
			h.call("check_true", p.playing, "_music is playing")

func _t1_f02_2(h: RefCounted, _tree: SceneTree) -> void:
	var packed := load("res://scenes/ui/main_menu.tscn") as PackedScene
	h.call("check_true", packed != null, "main_menu.tscn loads")
	if packed == null:
		return
	var menu := packed.instantiate()
	var count := _count_audio_players(menu)
	h.call("check_eq", count, 0, "main_menu.tscn has 0 AudioStreamPlayer children")
	menu.free()

func _count_audio_players(node: Node) -> int:
	var c := 1 if node is AudioStreamPlayer else 0
	for child in node.get_children():
		c += _count_audio_players(child)
	return c

func _t1_f02_3(h: RefCounted, tree: SceneTree) -> void:
	var idx := AudioServer.get_bus_index("Music")
	h.call("check_true", idx >= 0, "Music bus exists")
	if idx >= 0:
		h.call("check_eq", AudioServer.get_bus_send(idx), "Master", "Music bus sends to Master")
		var settings := tree.root.get_node_or_null("SettingsService")
		if settings != null:
			settings.call("update", "music", 50.0)
			var expected_db := linear_to_db(0.5)
			h.call("check_approx", AudioServer.get_bus_volume_db(idx), expected_db, 0.05, "Music bus volume matches 50%")

func _t1_f02_4(h: RefCounted, tree: SceneTree) -> void:
	var settings := tree.root.get_node_or_null("SettingsService")
	h.call("check_true", settings != null, "SettingsService exists")
	if settings == null:
		return
	var music: Variant = settings.get("_music")
	if music is AudioStreamPlayer:
		var conns := (music as AudioStreamPlayer).finished.get_connections()
		h.call("check_gt", float(conns.size()), 0.0, "_music.finished has loop connection")
	else:
		var scr := FileAccess.get_file_as_string("res://core/settings/settings_service.gd")
		h.call("check_contains", scr, "_music.finished.connect(_music.play)", "settings_service.gd connects _music.finished to _music.play")

func _t1_f02_5(h: RefCounted, tree: SceneTree) -> void:
	var settings := tree.root.get_node_or_null("SettingsService")
	h.call("check_true", settings != null, "SettingsService exists")
	if settings == null:
		return
	var master := AudioServer.get_bus_index("Master")
	h.call("check_true", master >= 0, "Master bus exists")
	settings.call("update", "muted", true)
	h.call("check_true", AudioServer.is_bus_mute(master), "Master muted after update(muted, true)")
	settings.call("update", "muted", false)
	h.call("check_false", AudioServer.is_bus_mute(master), "Master unmuted after update(muted, false)")

func _trigger_urgent(game: Node, event_id: String = "rota_presidio") -> Dictionary:
	var em: Node = game.get("event_manager")
	var ed: Node = game.get("event_database")
	var tm: Node = game.get("time_manager")
	var rt: Dictionary = ed.call("build_runtime_event", event_id, int(tm.get("current_day")), int(tm.get("current_month")), int(tm.get("current_year")), 30, 12)
	em.get("active_events").append(rt)
	em.emit_signal("event_triggered", rt)
	return rt

func _t1_f03_1(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "Urgent1", "medium", true, true)
	h.call("check_true", game != null, "Game loaded")
	if game == null:
		return
	var tm: Node = game.get("time_manager")
	tm.call("set_speed", 2)
	var rt := _trigger_urgent(game, "rota_presidio")
	h.call("check_eq", String(rt.get("deadline_phase", "")), "opening", "Urgent triggers in opening phase")
	h.call("check_eq", int(tm.get("current_speed")), 0, "Urgent forces NORMAL speed")

func _t1_f03_2(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "Urgent2", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var tm: Node = game.get("time_manager")
	var rt := _trigger_urgent(game, "rota_presidio")
	var before := float(rt.get("deadline_remaining_seconds", 180.0))
	await h.call("send_key_tap", tree, KEY_SPACE, 32)
	game.call("_process", 2.0)
	var after := float(rt.get("deadline_remaining_seconds", 180.0))
	h.call("check_true", bool(tm.get("paused")), "Space pauses the game while urgent problem is closed")
	h.call("check_approx", after, before, 0.05, "Closed urgent deadline freezes while game is paused")

func _t1_f03_3(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "Urgent3", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var tm: Node = game.get("time_manager")
	tm.call("pause_game")
	h.call("check_true", bool(tm.get("paused")), "Manual pause active before urgent")
	var rt := _trigger_urgent(game, "rota_presidio")
	var before := float(rt.get("deadline_remaining_seconds", 180.0))
	game.call("_process", 2.0)
	var after := float(rt.get("deadline_remaining_seconds", 180.0))
	h.call("check_true", bool(tm.get("paused")), "Urgent event does not clear the earlier manual pause")
	h.call("check_approx", after, before, 0.05, "Unopened urgent deadline freezes during manual pause")

func _t1_f03_4(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "Urgent4", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var tm: Node = game.get("time_manager")
	tm.call("pause_game")
	var rt := _trigger_urgent(game, "rota_presidio")
	game.call("open_problem", "rota_presidio")
	await h.call("await_frames", tree, 3)
	var before := float(rt.get("deadline_remaining_seconds", 180.0))
	var popup: Control = game.get("_current_problem_popup")
	var deadline_panel: Control = popup.get_node("UrgentDeadline")
	var deadline_progress: ProgressBar = popup.get("urgent_deadline_progress")
	h.call("check_true", deadline_panel.visible, "Urgent popup displays the deadline above the problem")
	game.call("_process", 2.0)
	var after := float(rt.get("deadline_remaining_seconds", 180.0))
	h.call("check_true", bool(tm.get("paused")), "Opening urgent problem does not change the game's pause state")
	h.call("check_approx", after, before - 2.0, 0.05, "Open urgent deadline decrements by 2.0s")
	h.call("check_approx", deadline_progress.value, after, 0.05, "Popup progress bar stays synchronized with the urgent deadline")

func _t1_f03_5(h: RefCounted, tree: SceneTree) -> void:
	var settings := tree.root.get_node_or_null("SettingsService")
	for loc in ["pt_BR", "en"]:
		if settings != null:
			settings.call("update", "locale", loc)
		var game: Node = await h.call("start_new_game", tree, "Brief_%s" % loc, "medium", false, true)
		h.call("check_true", game != null, "Game loads for briefing (%s)" % loc)
		if game == null:
			continue
		var modal: Node = game.get("_modal")
		h.call("check_true", modal != null, "Briefing modal visible (%s)" % loc)
		if modal != null:
			var text: String = h.call("collect_labels_text", modal)
			h.call("check_not_contains", text, "Problemas, painéis e menus pausam o calendário e os prazos.", "PT briefing must not claim all problems pause deadlines (%s)" % loc)
			h.call("check_not_contains", text, "Problems, panels and menus pause the calendar and deadlines.", "EN briefing must not claim all problems pause deadlines (%s)" % loc)
		await h.call("cleanup_scene", tree)

func _open_custom_text_input(h: RefCounted, tree: SceneTree, game: Node, evt_id: String = "e2e_text_input") -> Control:
	var ed: Node = game.get("event_database")
	var em: Node = game.get("event_manager")
	var tm: Node = game.get("time_manager")
	ed.call("register_event", evt_id, {
		"title": "Texto Teste",
		"description": "Digite a resposta com espaço.",
		"category": "common",
		"interaction_type": "text_input",
		"payload": {"prompt": "Digite", "accepted_answers": ["vila nova", "a b"]},
		"success_effects": {"social": 2.0},
		"failure_effects": {"social": -1.0}
	})
	var rt: Dictionary = ed.call("build_runtime_event", evt_id, int(tm.get("current_day")), int(tm.get("current_month")), int(tm.get("current_year")), 30, 12)
	em.get("active_events").append(rt)
	game.call("open_problem", evt_id)
	await h.call("await_frames", tree, 4)
	return game.get("_current_problem_popup") as Control

func _t1_f04_1(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "Text1", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var popup := await _open_custom_text_input(h, tree, game)
	h.call("check_true", popup != null, "text_input popup opened")
	if popup != null:
		var inp: LineEdit = popup.get("answer_input")
		h.call("check_true", inp.visible, "answer_input visible")
		h.call("check_true", inp.editable, "answer_input editable")
		h.call("check_true", inp.has_focus(), "answer_input has focus")

func _t1_f04_2(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "Text2", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var popup := await _open_custom_text_input(h, tree, game)
	h.call("check_true", popup != null, "Popup opened")
	if popup == null:
		return
	var inp: LineEdit = popup.get("answer_input")
	inp.grab_focus()
	await h.call("await_frames", tree, 1)
	var tm: Node = game.get("time_manager")
	var paused_before := bool(tm.get("paused"))
	await h.call("type_text", tree, "a b")
	h.call("check_eq", inp.text, "a b", "Space inserted into focused LineEdit")
	h.call("check_eq", bool(tm.get("paused")), paused_before, "Time pause state unchanged by Space in LineEdit")

func _t1_f04_3(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "Text3", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var popup := await _open_custom_text_input(h, tree, game)
	if popup == null:
		h.call("check", false, "Popup opened")
		return
	var inp: LineEdit = popup.get("answer_input")
	inp.grab_focus()
	await h.call("await_frames", tree, 1)
	await h.call("type_text", tree, "vila nova")
	h.call("check_eq", inp.text, "vila nova", "Multi-word text typed with space")
	var submit: Button = popup.get("submit_button")
	h.call("press_button", submit)
	await h.call("await_frames", tree, 2)
	var city: Variant = game.get("city")
	h.call("check_eq", int(city.get("correct_count")), 1, "Multi-word submission accepted as correct")

func _t1_f04_4(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "Text4", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var tm: Node = game.get("time_manager")
	h.call("check_false", bool(tm.get("paused")), "Initially unpaused")
	await h.call("send_key_tap", tree, KEY_SPACE, 32)
	h.call("check_true", bool(tm.get("paused")), "Space pauses on city view")
	await h.call("send_key_tap", tree, KEY_SPACE, 32)
	h.call("check_false", bool(tm.get("paused")), "Space resumes on city view")

func _t1_f04_5(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "Text5", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var ed: Node = game.get("event_database")
	var em: Node = game.get("event_manager")
	var tm: Node = game.get("time_manager")
	var rt: Dictionary = ed.call("build_runtime_event", "aura_travessia", 1, 1, 1, 30, 12)
	em.get("active_events").append(rt)
	game.call("open_problem", "aura_travessia")
	await h.call("await_frames", tree, 3)
	h.call("check_true", bool(tm.get("paused")), "Choice problem pauses time")
	await h.call("send_key_tap", tree, KEY_SPACE, 32)
	h.call("check_true", bool(tm.get("paused")), "Space does not unpause choice problem")

func _instantiate_problem_template(tree: SceneTree) -> Control:
	var packed := load("res://scenes/ui/problem_template.tscn") as PackedScene
	var popup := packed.instantiate() as Control
	var settings := tree.root.get_node_or_null("SettingsService")
	if settings != null:
		popup.theme = settings.get("game_theme")
	tree.root.add_child(popup)
	return popup

func _t1_f05_1(h: RefCounted, tree: SceneTree) -> void:
	var popup := _instantiate_problem_template(tree)
	await h.call("await_frames", tree, 2)
	var btn := popup.get_node("Center/Panel/Margin/Content/Body/ProblemTools/BoardButton") as Button
	for color_name in ["font_color", "font_hover_color", "font_focus_color", "font_pressed_color"]:
		var col := btn.get_theme_color(color_name)
		var lum: float = h.call("relative_luminance", col)
		h.call("check_lt", lum, 0.25, "BoardButton %s has dark ink luminance" % color_name)

func _t1_f05_2(h: RefCounted, tree: SceneTree) -> void:
	var popup := _instantiate_problem_template(tree)
	await h.call("await_frames", tree, 2)
	var btn := popup.get_node("Center/Panel/Margin/Content/Body/ProblemTools/CalculatorButton") as Button
	for color_name in ["font_color", "font_hover_color", "font_focus_color", "font_pressed_color"]:
		var col := btn.get_theme_color(color_name)
		var lum: float = h.call("relative_luminance", col)
		h.call("check_lt", lum, 0.25, "CalculatorButton %s has dark ink luminance" % color_name)

func _t1_f05_3(h: RefCounted, tree: SceneTree) -> void:
	var popup := _instantiate_problem_template(tree)
	await h.call("await_frames", tree, 2)
	for name in ["BoardButton", "CalculatorButton"]:
		var btn := popup.get_node("Center/Panel/Margin/Content/Body/ProblemTools/" + name) as Button
		var sb := btn.get_theme_stylebox("pressed")
		h.call("check_true", sb is StyleBoxFlat, "%s pressed stylebox is StyleBoxFlat" % name)
		if sb is StyleBoxFlat:
			var lum: float = h.call("relative_luminance", (sb as StyleBoxFlat).bg_color)
			h.call("check_gt", lum, 0.6, "%s pressed bg_color is light" % name)

func _t1_f05_4(h: RefCounted, tree: SceneTree) -> void:
	var popup := _instantiate_problem_template(tree)
	await h.call("await_frames", tree, 2)
	for name in ["BoardButton", "CalculatorButton"]:
		var btn := popup.get_node("Center/Panel/Margin/Content/Body/ProblemTools/" + name) as Button
		var normal_bg: Color = h.call("extract_stylebox_bg", btn.get_theme_stylebox("normal"))
		for pair in [["font_color", "normal"], ["font_hover_color", "hover"], ["font_pressed_color", "pressed"], ["font_focus_color", "normal"]]:
			var fg := btn.get_theme_color(pair[0])
			var bg: Color = normal_bg if pair[1] == "normal" else h.call("extract_stylebox_bg", btn.get_theme_stylebox(pair[1]), normal_bg)
			var ratio: float = h.call("contrast_ratio", fg, bg)
			h.call("check_gt", ratio, 4.5, "%s %s WCAG contrast >= 4.5 (got %.2f)" % [name, pair[0], ratio])

func _t1_f05_5(h: RefCounted, tree: SceneTree) -> void:
	var popup := _instantiate_problem_template(tree)
	await h.call("await_frames", tree, 2)
	for opt in ["Option1", "Option2", "Option3", "Option4"]:
		var btn := popup.get_node("Center/Panel/Margin/Content/Body/Answers/" + opt) as Button
		var bg: Color = h.call("extract_stylebox_bg", btn.get_theme_stylebox("hover"))
		for c_name in ["font_color", "font_hover_color", "font_focus_color", "font_pressed_color"]:
			var ratio: float = h.call("contrast_ratio", btn.get_theme_color(c_name), bg)
			h.call("check_gt", ratio, 4.5, "%s %s contrast >= 4.5" % [opt, c_name])
	var keys := popup.get("calculator_keys") as GridContainer
	for child in keys.get_children():
		if child is Button:
			var b := child as Button
			var bg: Color = h.call("extract_stylebox_bg", b.get_theme_stylebox("normal"))
			var ratio: float = h.call("contrast_ratio", b.get_theme_color("font_hover_color"), bg)
			h.call("check_gt", ratio, 4.5, "Calc key '%s' hover contrast >= 4.5" % b.text)

func _t1_f06_1(h: RefCounted, tree: SceneTree) -> void:
	var city := CityState.new()
	city.start("Lotes1", "medium")
	var vis := CityVisuals.new()
	tree.root.add_child(vis)
	vis.bind(city)
	h.call("check_true", city.has_method("can_build_coord"), "CityState exposes can_build_coord")
	if city.has_method("can_build_coord"):
		for x in range(-12, 13):
			for y in range(-12, 13):
				var dict_res := city.can_build({"x": x, "y": y})
				var coord_res := bool(city.call("can_build_coord", Vector2i(x, y)))
				if dict_res != coord_res:
					h.call("check", false, "Parity mismatch at (%d,%d)" % [x, y])
					return
		h.call("check", true, "can_build_coord matches can_build on all 625 grid coords")

func _t1_f06_2(h: RefCounted, tree: SceneTree) -> void:
	var city := CityState.new()
	city.start("Lotes2", "medium")
	var vis := CityVisuals.new()
	tree.root.add_child(vis)
	vis.bind(city)
	h.call("check_eq", vis.lots.size(), 484, "484 grass lots configured")
	h.call("check_eq", city.residences.size(), 18, "18 initial homes placed")
	h.call("check_false", city.can_build(city.town_hall), "town_hall blocked")
	for home in city.residences:
		h.call("check_false", city.can_build(home.lot), "Initial home lot blocked")

func _t1_f06_3(h: RefCounted, tree: SceneTree) -> void:
	var city := CityState.new()
	city.start("Lotes3", "medium")
	var vis := CityVisuals.new()
	tree.root.add_child(vis)
	vis.bind(city)
	h.call("check_true", city.has_method("can_build_coord"), "can_build_coord exists")
	var free_lot := {}
	for lot in vis.lots:
		if city.can_build(lot):
			free_lot = lot
			break
	h.call("check_eq", city.construct("health", 0, free_lot), "", "construct succeeds on free lot")
	if city.has_method("can_build_coord"):
		h.call("check_false", bool(city.call("can_build_coord", Vector2i(int(free_lot.x), int(free_lot.y)))), "Constructed lot blocked in can_build_coord")
	city.advance_day(20)
	city.advance_month()
	for home in city.residences:
		if city.has_method("can_build_coord"):
			h.call("check_false", bool(city.call("can_build_coord", Vector2i(int(home.lot.x), int(home.lot.y)))), "Growth home lot blocked")
	city.population += 150
	if city.housing_requests() > 0:
		var home_lot := {}
		for lot in vis.lots:
			if city.can_build(lot):
				home_lot = lot
				break
		h.call("check_eq", city.place_home(home_lot), "", "place_home succeeds")
		if city.has_method("can_build_coord"):
			h.call("check_false", bool(city.call("can_build_coord", Vector2i(int(home_lot.x), int(home_lot.y)))), "Placed home blocked in can_build_coord")

func _t1_f06_4(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "Redraw1", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var vis: CityVisuals = game.get("visuals")
	vis.begin_placement("education")
	await h.call("await_frames", tree, 2)
	var count := [0]
	vis.draw.connect(func(): count[0] += 1)
	var screen_pos := vis.get_global_transform_with_canvas() * vis.point({"x": 1, "y": 1})
	await h.call("send_mouse_motion", tree, screen_pos)
	await h.call("await_frames", tree, 2)
	h.call("check_eq", count[0], 1, "First motion onto (1,1) triggers 1 redraw")
	for offset in [Vector2(2, 1), Vector2(-3, 2), Vector2(4, -2), Vector2(1, 0)]:
		await h.call("send_mouse_motion", tree, screen_pos + offset)
		await h.call("await_frames", tree, 1)
	h.call("check_eq", count[0], 1, "Same-tile mouse motions trigger 0 extra redraws")

func _t1_f06_5(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "Redraw2", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var vis: CityVisuals = game.get("visuals")
	vis.begin_placement("education")
	await h.call("await_frames", tree, 2)
	var count := [0]
	vis.draw.connect(func(): count[0] += 1)
	var pos1 := vis.get_global_transform_with_canvas() * vis.point({"x": 1, "y": 1})
	var pos2 := vis.get_global_transform_with_canvas() * vis.point({"x": 2, "y": 1})
	await h.call("send_mouse_motion", tree, pos1)
	await h.call("await_frames", tree, 2)
	await h.call("send_mouse_motion", tree, pos2)
	await h.call("await_frames", tree, 2)
	h.call("check_eq", vis.hovered, Vector2i(2, 1), "hovered updated to (2,1)")
	h.call("check_eq", count[0], 2, "Cross-tile motion increments draw count by 1")

func _t1_f07_1(h: RefCounted, _tree: SceneTree) -> void:
	var db := _new_db()
	for m in range(1, 13):
		db.call("ensure_month_content", m, 1)
	var usage: Dictionary = db.call("get_usage_save_data")
	var defs: Dictionary = usage.get("definitions", {})
	h.call("check_true", defs.is_empty(), "definitions omits defaults and municipal_* events")
	db.free()

func _t1_f07_2(h: RefCounted, _tree: SceneTree) -> void:
	var db := _new_db()
	db.call("ensure_month_content", 1, 1)
	db.call("register_event", "custom_test_evt", {"category": "common", "interaction_type": "choice", "payload": {"options": [{"id": "a", "text": "A"}]}})
	var usage: Dictionary = db.call("get_usage_save_data")
	var defs: Dictionary = usage.get("definitions", {})
	h.call("check_true", defs.has("custom_test_evt"), "Custom event preserved in definitions")
	h.call("check_false", defs.has("aura_travessia"), "Default event omitted")
	h.call("check_false", defs.has("municipal_1_0"), "Procedural event omitted")
	db.free()

func _t1_f07_3(h: RefCounted, _tree: SceneTree) -> void:
	var db := _new_db()
	h.call("check_true", db.has_method("ensure_months_through"), "ensure_months_through exists")
	if db.has_method("ensure_months_through"):
		db.call("ensure_months_through", 3, 2)
		for idx in range(1, 16):
			for i in range(8):
				h.call("check_true", bool(db.call("has_event", "municipal_%d_%d" % [idx, i])), "Exists municipal_%d_%d" % [idx, i])
	db.free()

func _t1_f07_4(h: RefCounted, _tree: SceneTree) -> void:
	var db1 := _new_db()
	if db1.has_method("ensure_months_through"):
		db1.call("ensure_months_through", 5, 1)
	else:
		db1.call("ensure_month_content", 5, 1)
	db1.call("mark_event_used", "municipal_5_2")
	db1.call("mark_event_used", "aura_travessia")
	var usage: Dictionary = db1.call("get_usage_save_data")
	db1.free()

	var db2 := _new_db()
	db2.call("load_usage_save_data", usage)
	h.call("check_true", bool(db2.call("has_event", "municipal_5_2")), "municipal_5_2 regenerated on load_usage_save_data")
	var used: Dictionary = db2.get("_used_ids_by_category")
	h.call("check_true", used.get("important", []).has("municipal_5_2"), "municipal_5_2 restored in used_ids")
	h.call("check_true", used.get("optional", []).has("aura_travessia"), "aura_travessia restored in used_ids")
	db2.free()

func _t1_f07_5(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "Compact24", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var ed: Node = game.get("event_database")
	var em: Node = game.get("event_manager")
	var tm: Node = game.get("time_manager")
	var city: Variant = game.get("city")
	for _m in range(24):
		for _d in range(30):
			tm.call("_advance_one_day")
	var save_mgr := tree.root.get_node("SaveManager")
	h.call("check_true", bool(save_mgr.call("save_game", tm, em, 1, ed, city)), "Save 24-month game succeeds")
	var raw_json := FileAccess.get_file_as_string(String(save_mgr.call("slot_path", 1)))
	var parsed: Variant = JSON.parse_string(raw_json)
	h.call("check_true", parsed is Dictionary, "Saved JSON parses cleanly")
	if parsed is Dictionary:
		var usage: Dictionary = (parsed as Dictionary).get("event_database_usage", {})
		var defs: Dictionary = usage.get("definitions", {})
		h.call("check_true", defs.is_empty(), "Saved JSON omits municipal_* and default definitions")
	h.call("check_true", bool(save_mgr.call("load_slot", 1)), "Load slot 1 succeeds")
	var reloaded: Node = await h.call("boot_scene", tree, "res://scenes/game/Game.tscn", true)
	h.call("check_true", reloaded != null, "Reloaded Game.tscn cleanly")
	if reloaded != null:
		h.call("check_eq", int(reloaded.get("city").get("completed_months")), 24, "Reloaded completed_months == 24")

func _t1_f08_1(h: RefCounted, _tree: SceneTree) -> void:
	var db := _new_db()
	var seen_a := false
	var seen_b := false
	for m in range(1, 13):
		db.call("ensure_month_content", m, 1)
		var ev: Dictionary = db.call("get_event", "municipal_%d_4" % m)
		var ans := String(ev.get("correct_answer", ""))
		if ans == "a":
			seen_a = true
		elif ans == "b":
			seen_b = true
	h.call("check_true", seen_a and seen_b, "Supply routes correct_answer varies across both 'a' and 'b'")
	db.free()

func _t1_f08_2(h: RefCounted, _tree: SceneTree) -> void:
	var db := _new_db()
	var first_is_correct := false
	var second_is_correct := false
	for m in range(1, 13):
		db.call("ensure_month_content", m, 1)
		var ev: Dictionary = db.call("get_event", "municipal_%d_4" % m)
		var ans := String(ev.get("correct_answer", ""))
		var opts: Array = ev.get("payload", {}).get("options", [])
		if opts.size() >= 2:
			if String(opts[0].get("id", "")) == ans:
				first_is_correct = true
			if String(opts[1].get("id", "")) == ans:
				second_is_correct = true
	h.call("check_true", first_is_correct and second_is_correct, "Correct option appears at both index 0 and index 1 across months")
	db.free()

func _t1_f08_3(h: RefCounted, _tree: SceneTree) -> void:
	var db := _new_db()
	for m in range(1, 13):
		db.call("ensure_month_content", m, 1)
		var ev: Dictionary = db.call("get_event", "municipal_%d_4" % m)
		var g: Dictionary = ev.get("graph", {})
		var tot_a := int(g.get("a", 0)) + 4
		var tot_b := int(g.get("b", 0)) + 7
		var expected_ans := "a" if tot_a < tot_b else "b"
		h.call("check_eq", String(ev.get("correct_answer", "")), expected_ans, "Month %d shorter route matches correct_answer" % m)
		var opts: Array = ev.get("payload", {}).get("options", [])
		for opt in opts:
			var km := tot_a if String(opt.get("id", "")) == "a" else tot_b
			var txt := String(opt.get("text", ""))
			h.call("check_contains", txt, "%d km" % km, "Option km matches")
			h.call("check_contains", txt, "R$ %d" % (km * 2), "Option cost = km*2")
			h.call("check_contains", txt, "%d min" % (km * 2), "Option time = km*2")
		var expl := String(ev.get("explanation", ""))
		var expected_branch := "A" if expected_ans == "a" else "B"
		h.call("check_contains", expl, "rota por %s" % expected_branch, "Explanation names actual shorter branch")
		h.call("check_contains", expl, "%d km menor" % absi(tot_a - tot_b), "Explanation states exact diff km")
	db.free()

func _t1_f08_4(h: RefCounted, _tree: SceneTree) -> void:
	var db := _new_db()
	for m in range(1, 13):
		db.call("ensure_month_content", m, 1)
		var ev: Dictionary = db.call("get_event", "municipal_%d_4" % m)
		var g: Dictionary = ev.get("graph", {})
		var desc := String(ev.get("description", ""))
		h.call("check_contains", desc, "P–A = %d km" % int(g.get("a", 0)), "Description P-A matches graph.a")
		h.call("check_contains", desc, "P–B = %d km" % int(g.get("b", 0)), "Description P-B matches graph.b")
	db.free()

func _t1_f08_5(h: RefCounted, tree: SceneTree) -> void:
	var db := _new_db()
	db.call("ensure_month_content", 2, 1)
	var ev: Dictionary = db.call("get_event", "municipal_2_4")
	var settings := tree.root.get_node_or_null("SettingsService")
	for loc in ["pt_BR", "en"]:
		if settings != null:
			settings.call("update", "locale", loc)
		var desc: String = TranslationServer.translate(String(ev.get("description_pattern", ""))) % ev.get("description_values", [])
		var expl: String = TranslationServer.translate(String(ev.get("explanation_pattern", ""))) % ev.get("explanation_values", []) if ev.has("explanation_pattern") else TranslationServer.translate(String(ev.get("explanation", "")))
		h.call("check_not_contains", desc, "%d", "No raw %%d in description (%s)" % loc)
		h.call("check_not_contains", expl, "%s", "No raw %%s in explanation (%s)" % loc)
		h.call("check_not_contains", expl, "%d", "No raw %%d in explanation (%s)" % loc)
	db.free()

func _t1_f09_1(h: RefCounted, _tree: SceneTree) -> void:
	var city := CityState.new()
	city.start("Obra1", "medium")
	h.call("check_eq", city.construct("health", 0), "", "Construct succeeds")
	city.apply_problem({"id": "municipal_1_1", "category": "common", "construction_days_saved": 5}, true)
	h.call("check_eq", int(city.projects[0].due), 15, "Explicit construction_days_saved reduces due from 20 to 15")

func _t1_f09_2(h: RefCounted, _tree: SceneTree) -> void:
	var db := _new_db()
	var city := CityState.new()
	city.start("Obra2", "medium")
	city.construct("health", 0)
	var ev: Dictionary = db.call("get_event", "obras_combinacoes")
	city.apply_problem(ev, true)
	h.call("check_eq", int(city.projects[0].due), 20, "obras_combinacoes must NOT grant hidden 5-day bonus")
	db.free()

func _t1_f09_3(h: RefCounted, _tree: SceneTree) -> void:
	var city := CityState.new()
	city.start("Obra3", "medium")
	city.construct("health", 0)
	var res := city.apply_problem({"id": "municipal_1_1", "category": "common", "construction_days_saved": 5}, true)
	h.call("check_eq", int(res.get("construction_days_saved", 0)), 5, "Returned result records construction_days_saved == 5")
	h.call("check_eq", int(city.last_result.get("construction_days_saved", 0)), 5, "city.last_result records construction_days_saved == 5")

func _t1_f09_4(h: RefCounted, _tree: SceneTree) -> void:
	var db := _new_db()
	db.call("ensure_month_content", 1, 1)
	var ev: Dictionary = db.call("get_event", "municipal_1_1")
	h.call("check_eq", int(ev.get("construction_days_saved", 0)), 5, "municipal_1_1 declares construction_days_saved == 5")
	h.call("check_contains", String(ev.get("explanation", "")), "5 dias", "municipal_1_1 explanation mentions 5-day bonus")
	db.free()

func _t1_f09_5(h: RefCounted, tree: SceneTree) -> void:
	var settings := tree.root.get_node_or_null("SettingsService")
	for loc in ["pt_BR", "en"]:
		if settings != null:
			settings.call("update", "locale", loc)
		var game: Node = await h.call("start_new_game", tree, "ObraUI_%s" % loc, "medium", true, true)
		if game == null:
			h.call("check", false, "Game loaded")
			continue
		var city: CityState = game.get("city")
		var ed: Node = game.get("event_database")
		var em: Node = game.get("event_manager")
		ed.call("ensure_month_content", 1, 1)
		city.construct("health", 0, {"x": 1, "y": 1})
		var rt: Dictionary = ed.call("build_runtime_event", "municipal_1_1", 1, 1, 1, 30, 12)
		em.get("active_events").append(rt)
		game.call("open_problem", "municipal_1_1")
		await h.call("await_frames", tree, 3)
		var popup: Node = game.get("_current_problem_popup")
		var ev: Dictionary = ed.call("get_event", "municipal_1_1")
		popup.get("answer_input").text = str(ev["payload"]["correct_value"])
		popup.call("_submit_typed_answer")
		await h.call("await_frames", tree, 2)
		var modal: Node = game.get("_modal")
		h.call("check_true", modal != null, "Feedback modal opened (%s)" % loc)
		if modal != null:
			var txt: String = h.call("collect_labels_text", modal)
			h.call("check_contains", txt, "5", "Feedback modal mentions 5-day construction bonus (%s)" % loc)
		await h.call("cleanup_scene", tree)

func _t1_f10_1(h: RefCounted, _tree: SceneTree) -> void:
	var db := _new_db()
	for id in AUTHORED_IDS:
		var ev: Dictionary = db.call("get_event", id)
		var se: Dictionary = ev.get("success_effects", {})
		if id == "rota_medicamentos":
			var ce: Dictionary = ev.get("choice_effects", {})
			h.call("check_false", ce.is_empty(), "rota_medicamentos defines choice_effects")
			for opt_id in ce:
				var eff: Dictionary = ce[opt_id]
				var has_pos_area := false
				for k in eff:
					if GameRules.AREAS.has(k) and float(eff[k]) > 0.0:
						has_pos_area = true
				h.call("check_true", has_pos_area, "rota_medicamentos %s has positive service effect" % opt_id)
		else:
			h.call("check_false", se.is_empty(), "%s has non-empty success_effects" % id)
			for k in se:
				h.call("check_true", GameRules.AREAS.has(k), "%s success_effects key '%s' in GameRules.AREAS" % [id, k])
				h.call("check_gt", float(se[k]), 0.0, "%s success_effects[%s] > 0" % [id, k])
	db.free()

func _t1_f10_2(h: RefCounted, _tree: SceneTree) -> void:
	var db := _new_db()
	for id in AUTHORED_IDS:
		var ev: Dictionary = db.call("get_event", id)
		var fe: Dictionary = ev.get("failure_effects", {})
		h.call("check_false", fe.is_empty(), "%s has non-empty failure_effects" % id)
		for k in fe:
			h.call("check_true", GameRules.AREAS.has(k), "%s failure_effects key '%s' in GameRules.AREAS" % [id, k])
			h.call("check_lt", float(fe[k]), 0.0, "%s failure_effects[%s] < 0" % [id, k])
	db.free()

func _t1_f10_3(h: RefCounted, _tree: SceneTree) -> void:
	var db := _new_db()
	for id in AUTHORED_IDS:
		var ev: Dictionary = db.call("get_event", id)
		var ee: Dictionary = ev.get("expiration_effects", {})
		var cat := String(ev.get("category", ""))
		if cat == "optional":
			h.call("check_true", ee.is_empty(), "Optional %s has empty expiration_effects" % id)
		else:
			h.call("check_false", ee.is_empty(), "Non-optional %s has non-empty expiration_effects" % id)
			for k in ee:
				h.call("check_true", GameRules.AREAS.has(k), "%s expiration_effects key '%s' in GameRules.AREAS" % [id, k])
				h.call("check_lt", float(ee[k]), 0.0, "%s expiration_effects[%s] < 0" % [id, k])
	db.free()

func _t1_f10_4(h: RefCounted, _tree: SceneTree) -> void:
	var db := _new_db()
	var ev: Dictionary = db.call("get_event", "rota_medicamentos")
	for pair in [["rota_a", -600.0, 1.0], ["rota_b", -800.0, 2.0]]:
		var city := CityState.new()
		city.start("Med", "medium")
		var before_funds := city.funds
		var before_health := float(city.indicators["health"])
		city.apply_problem(ev, true, false, pair[0])
		var expected_funds := before_funds + 3.0 * GameRules.EVENT_REWARD_FUNDS + float(pair[1])
		h.call("check_approx", city.funds, expected_funds, 0.01, "rota_medicamentos %s funds delta" % pair[0])
		h.call("check_approx", float(city.indicators["health"]), before_health + float(pair[2]), 0.01, "rota_medicamentos %s health delta" % pair[0])
	db.free()

func _t1_f10_5(h: RefCounted, _tree: SceneTree) -> void:
	var db := _new_db()
	var ev: Dictionary = db.call("get_event", "merenda_escolar")
	var city := CityState.new()
	city.start("Delta", "medium")
	var base_edu := float(city.indicators["education"])
	city.apply_problem(ev, true)
	h.call("check_approx", float(city.indicators["education"]), base_edu + float(ev["success_effects"]["education"]), 0.01, "Success delta matches")
	city.apply_problem(ev, false, false)
	var after_fail := float(city.indicators["education"])
	h.call("check_approx", after_fail, base_edu + float(ev["success_effects"]["education"]) + float(ev["failure_effects"]["education"]), 0.01, "Failure delta matches")
	city.apply_problem(ev, false, true)
	h.call("check_approx", float(city.indicators["education"]), after_fail + float(ev["expiration_effects"]["education"]), 0.01, "Expiration delta matches")
	db.free()

func _t1_f11_1(h: RefCounted, _tree: SceneTree) -> void:
	var db := _new_db()
	db.call("ensure_month_content", 1, 1)
	for i in range(8):
		var id := "municipal_1_%d" % i
		var ev: Dictionary = db.call("get_event", id)
		h.call("check_true", bool(db.call("validate_event_structure", ev)), "Procedural %s validates cleanly" % id)
	db.free()

func _t1_f11_2(h: RefCounted, _tree: SceneTree) -> void:
	var db := _new_db()
	for id in AUTHORED_IDS:
		var ev: Dictionary = db.call("get_event", id)
		h.call("check_true", bool(db.call("validate_event_structure", ev)), "Authored %s validates cleanly" % id)
	db.free()

func _t1_f11_3(h: RefCounted, _tree: SceneTree) -> void:
	var db := _new_db()
	var ok := bool(db.call("validate_event_structure", {"id": "n1", "category": "common", "interaction_type": "number_input", "payload": {"correct_value": 42}}))
	h.call("check_true", ok, "Minimal number_input without prompt validates cleanly")
	db.free()

func _t1_f11_4(h: RefCounted, _tree: SceneTree) -> void:
	var db := _new_db()
	var ok := bool(db.call("validate_event_structure", {"id": "c1", "category": "optional", "interaction_type": "choice", "payload": {"options": [{"id": "a", "text": "A"}, {"id": "b", "text": "B"}]}}))
	h.call("check_true", ok, "Valid choice event passes validation")
	db.free()

func _t1_f11_5(h: RefCounted, _tree: SceneTree) -> void:
	var db := _new_db()
	var ok := bool(db.call("validate_event_structure", {"id": "t1", "category": "important", "interaction_type": "text_input", "payload": {"prompt": "Type", "accepted_answers": ["ok"]}}))
	h.call("check_true", ok, "Valid text_input event passes validation")
	db.free()
