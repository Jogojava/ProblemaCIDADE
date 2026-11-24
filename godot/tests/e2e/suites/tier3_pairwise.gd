extends RefCounted

func get_cases() -> Array[Dictionary]:
	return [
		{"id": "T3-01", "method": "_t3_01", "description": "F06+F07: O(1) lot occupancy and compact save/reload"},
		{"id": "T3-02", "method": "_t3_02", "description": "F03+F15: Urgent anti-exploit with EN/PT urgent banner"},
		{"id": "T3-03", "method": "_t3_03", "description": "F04+F13: text_input Space + calculator persistence/keys"},
		{"id": "T3-04", "method": "_t3_04", "description": "F04+F03: Urgent text_input Space typing while deadline ticks"},
		{"id": "T3-05", "method": "_t3_05", "description": "F08+F14: Supply route variance across months with RouteGraph"},
		{"id": "T3-06", "method": "_t3_06", "description": "F14+F05+F13: rota_presidio graph, button contrast, and calculator"},
		{"id": "T3-07", "method": "_t3_07", "description": "F09+F10: obras_combinacoes isolated vs municipal_1_1 bonus + effects"},
		{"id": "T3-08", "method": "_t3_08", "description": "F09+F15: municipal_1_1 5-day bonus feedback in English"},
		{"id": "T3-09", "method": "_t3_09", "description": "F07+F08+F11: 18-month compact reload + supply route validation"},
		{"id": "T3-10", "method": "_t3_10", "description": "F06+F18+F20: HUD build mode, zero extra redraws, no legacy TileMaps"},
		{"id": "T3-11", "method": "_t3_11", "description": "F15+F07+F16: Save slot 1, Esc GameDialog, carregar EN labels"},
		{"id": "T3-12", "method": "_t3_12", "description": "F02+F19: PauseMenu dynamic Opcoes updates Music/Mute without OptionsPanel"},
		{"id": "T3-13", "method": "_t3_13", "description": "F03+F19: SkipButton opens pending urgent without _skip_until_event"},
		{"id": "T3-14", "method": "_t3_14", "description": "F10+F12: rota_medicamentos rota_b applies choice_effects and ledger"},
		{"id": "T3-15", "method": "_t3_15", "description": "F11+F10+F08: Validate all 10 authored + 96 procedural events"},
		{"id": "T3-16", "method": "_t3_16", "description": "F05+F15: Translated EN buttons maintain >= 4.5:1 WCAG contrast"},
		{"id": "T3-17", "method": "_t3_17", "description": "F13+F15: Calculator comma decimal and numpad across pt_BR and en"},
		{"id": "T3-18", "method": "_t3_18", "description": "F06+F20: Esc cancels placement cleanly without modifying lots"},
		{"id": "T3-19", "method": "_t3_19", "description": "F07+F12: 48-month advance caps ledger at 120 and omits procedural defs"},
		{"id": "T3-20", "method": "_t3_20", "description": "F03+F10: Urgent authored problems expire under timer with penalties"},
		{"id": "T3-21", "method": "_t3_21", "description": "F14+F20: Close and reopen rota_presidio renders RouteGraph cleanly"},
		{"id": "T3-22", "method": "_t3_22", "description": "F01+F17+F18: Full menu->Game->PauseMenu->menu cycle with clean tree"},
		{"id": "T3-23", "method": "_t3_23", "description": "F04+F20: Esc saves text_input draft with spaces and restores on reopen"},
		{"id": "T3-24", "method": "_t3_24", "description": "F09+F06: Construction bonus finishes project on day 15 and keeps lot occupied"}
	]

func run_case(h: RefCounted, tree: SceneTree, case_info: Dictionary) -> void:
	await call(String(case_info["method"]), h, tree)

func _t3_01(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "Pair1", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var city: CityState = game.get("city")
	var vis: CityVisuals = game.get("visuals")
	var placed: Array[Vector2i] = []
	for lot in vis.lots:
		if city.can_build(lot):
			var area := "education" if placed.is_empty() else "health"
			h.call("check_eq", city.construct(area, 0, lot), "", "Construct %s" % area)
			placed.append(Vector2i(int(lot.x), int(lot.y)))
			if placed.size() == 2:
				break
	city.advance_day(20)
	city.advance_month()
	var sm := tree.root.get_node("SaveManager")
	sm.call("save_game", game.get("time_manager"), game.get("event_manager"), 1, game.get("event_database"), city)
	var raw := FileAccess.get_file_as_string(String(sm.call("slot_path", 1)))
	var parsed: Dictionary = JSON.parse_string(raw)
	h.call("check_true", parsed.get("event_database_usage", {}).get("definitions", {}).is_empty(), "Compact save omits municipal_*")
	sm.call("load_slot", 1)
	var reloaded: Node = await h.call("boot_scene", tree, "res://scenes/game/Game.tscn", true)
	var rcity: CityState = reloaded.get("city")
	for c in placed:
		if rcity.has_method("can_build_coord"):
			h.call("check_false", bool(rcity.call("can_build_coord", c)), "Reloaded lot %s remains occupied" % str(c))

func _t3_02(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "Pair2", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var em: Node = game.get("event_manager")
	var ed: Node = game.get("event_database")
	var hud: Node = game.get("hud")
	for id in ["rota_presidio", "moradias_enchente"]:
		var rt: Dictionary = ed.call("build_runtime_event", id, 1, 1, 1, 30, 12)
		em.get("active_events").append(rt)
		em.emit_signal("event_triggered", rt)
	tree.root.get_node("SettingsService").call("update", "locale", "en")
	game.call("_refresh_problem_tabs")
	h.call("check_eq", (hud.get("urgent_phase") as Label).text, "TO OPEN", "Banner shows TO OPEN in EN")
	h.call("check_contains", (hud.get("urgent_open_button") as Button).tooltip_text, "2 queued", "Banner tooltip shows 2 queued")
	game.call("open_problem", "rota_presidio")
	await h.call("await_frames", tree, 3)
	h.call("check_eq", (hud.get("urgent_phase") as Label).text, "TO ANSWER", "Banner shows TO ANSWER when open")
	var rt0: Dictionary = em.get("active_events")[0]
	var rem0 := float(rt0.get("deadline_remaining_seconds", 180.0))
	await h.call("send_key_tap", tree, KEY_ESCAPE, 0)
	await h.call("await_frames", tree, 2)
	game.call("_process", 2.0)
	h.call("check_lt", float(rt0.get("deadline_remaining_seconds", 180.0)), rem0, "Deadline continues ticking after Esc")
	h.call("check_eq", (hud.get("urgent_phase") as Label).text, "TO OPEN", "Banner returns to TO OPEN after Esc")

func _t3_03(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "Pair3", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var ed: Node = game.get("event_database")
	var em: Node = game.get("event_manager")
	ed.call("register_event", "p3_txt", {"title": "T3", "description": "D", "category": "common", "interaction_type": "text_input", "payload": {"prompt": "P", "accepted_answers": ["alpha beta"]}})
	em.get("active_events").append(ed.call("build_runtime_event", "p3_txt", 1, 1, 1, 30, 12))
	game.call("open_problem", "p3_txt")
	await h.call("await_frames", tree, 3)
	var popup: Control = game.get("_current_problem_popup")
	var inp: LineEdit = popup.get("answer_input")
	inp.grab_focus()
	await h.call("type_text", tree, "alpha ")
	popup.call("_show_calculator")
	await h.call("await_frames", tree, 1)
	await h.call("send_key_tap", tree, KEY_6, 54)
	await h.call("send_key_tap", tree, KEY_KP_MULTIPLY, 0)
	await h.call("send_key_tap", tree, KEY_7, 55)
	await h.call("send_key_tap", tree, KEY_ENTER, 0)
	h.call("check_eq", (popup.get("calculator_display") as LineEdit).text, "42", "Calc computes 6*7=42")
	popup.call("_hide_calculator")
	await h.call("await_frames", tree, 1)
	await h.call("type_text", tree, "beta")
	h.call("check_eq", inp.text, "alpha beta", "answer_input preserves 'alpha beta'")
	popup.call("_show_calculator")
	h.call("check_eq", (popup.get("calculator_display") as LineEdit).text, "42", "Calc still holds 42 on reopen")

func _t3_04(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "Pair4", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var ed: Node = game.get("event_database")
	var em: Node = game.get("event_manager")
	ed.call("register_event", "p4_urg_txt", {"title": "U", "description": "D", "category": "urgent", "interaction_type": "text_input", "payload": {"prompt": "P", "accepted_answers": ["um dois"]}})
	var rt: Dictionary = ed.call("build_runtime_event", "p4_urg_txt", 1, 1, 1, 30, 12)
	em.get("active_events").append(rt)
	em.emit_signal("event_triggered", rt)
	game.call("open_problem", "p4_urg_txt")
	await h.call("await_frames", tree, 3)
	var popup: Control = game.get("_current_problem_popup")
	var inp: LineEdit = popup.get("answer_input")
	inp.grab_focus()
	var before := float(rt.get("deadline_remaining_seconds", 180.0))
	await h.call("type_text", tree, "um dois")
	game.call("_process", 2.0)
	h.call("check_eq", inp.text, "um dois", "Urgent text_input accepts spaces")
	h.call("check_lt", float(rt.get("deadline_remaining_seconds", 180.0)), before, "Urgent deadline ticks during text_input")

func _t3_05(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "Pair5", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var ed: Node = game.get("event_database")
	var em: Node = game.get("event_manager")
	ed.call("ensure_months_through", 5, 1)
	var answers := []
	for id in ["municipal_1_4", "municipal_2_4"]:
		var ev: Dictionary = ed.call("get_event", id)
		answers.append(String(ev.get("correct_answer", "")))
		em.get("active_events").append(ed.call("build_runtime_event", id, 1, 1, 1, 30, 12))
		game.call("open_problem", id)
		await h.call("await_frames", tree, 3)
		var popup: Control = game.get("_current_problem_popup")
		var ill: Control = popup.get("illustration_panel")
		h.call("check_true", ill.visible and ill.get_child_count() > 1, "RouteGraph rendered for %s" % id)
		game.call("_on_problem_close_requested")
		await h.call("await_frames", tree, 2)
	h.call("check_ne", answers[0], answers[1], "Consecutive months vary correct_answer")

func _t3_06(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "Pair6", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var ed: Node = game.get("event_database")
	var em: Node = game.get("event_manager")
	em.get("active_events").append(ed.call("build_runtime_event", "rota_presidio", 1, 1, 1, 30, 12))
	game.call("open_problem", "rota_presidio")
	await h.call("await_frames", tree, 3)
	var popup: Control = game.get("_current_problem_popup")
	var bb := popup.get_node("Center/Panel/Margin/Content/Body/ProblemTools/BoardButton") as Button
	var cb := popup.get_node("Center/Panel/Margin/Content/Body/ProblemTools/CalculatorButton") as Button
	for btn in [bb, cb]:
		var bg: Color = h.call("extract_stylebox_bg", btn.get_theme_stylebox("hover"))
		var ratio: float = h.call("contrast_ratio", btn.get_theme_color("font_hover_color"), bg)
		h.call("check_gt", ratio, 4.5, "%s hover contrast >= 4.5" % btn.name)
	popup.call("_show_calculator")
	for k in ["4", "+", "5", "="]:
		popup.call("_on_calculator_key_pressed", k)
	popup.call("_hide_calculator")
	popup.call("_show_calculator")
	h.call("check_eq", (popup.get("calculator_display") as LineEdit).text, "9", "Calculator keeps 9 on rota_presidio")

func _t3_07(h: RefCounted, _tree: SceneTree) -> void:
	var s := load("res://scripts/eventdatabase.gd") as GDScript
	var db: Node = s.new()
	db.call("register_default_problems")
	db.call("ensure_month_content", 1, 1)
	var city := CityState.new()
	city.start("Pair7", "medium")
	city.construct("health", 0)
	var ob: Dictionary = db.call("get_event", "obras_combinacoes")
	var water_before := float(city.indicators["water"])
	city.apply_problem(ob, true)
	h.call("check_eq", int(city.projects[0].due), 20, "obras_combinacoes leaves due at 20")
	h.call("check_gt", float(city.indicators["water"]), water_before, "obras_combinacoes boosts aligned service")
	var edu_before := float(city.indicators["education"])
	var m1: Dictionary = db.call("get_event", "municipal_1_1")
	city.apply_problem(m1, true)
	h.call("check_eq", int(city.projects[0].due), 15, "municipal_1_1 reduces due to 15")
	h.call("check_eq", int(city.last_result.get("construction_days_saved", 0)), 5, "last_result records 5 days saved")
	h.call("check_gt", float(city.indicators["education"]), edu_before, "municipal_1_1 boosts education")
	db.free()

func _t3_08(h: RefCounted, tree: SceneTree) -> void:
	tree.root.get_node("SettingsService").call("update", "locale", "en")
	var game: Node = await h.call("start_new_game", tree, "Pair8", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var city: CityState = game.get("city")
	var ed: Node = game.get("event_database")
	var em: Node = game.get("event_manager")
	ed.call("ensure_month_content", 1, 1)
	city.construct("health", 0, {"x": 1, "y": 1})
	em.get("active_events").append(ed.call("build_runtime_event", "municipal_1_1", 1, 1, 1, 30, 12))
	game.call("open_problem", "municipal_1_1")
	await h.call("await_frames", tree, 3)
	var popup: Control = game.get("_current_problem_popup")
	var ev: Dictionary = ed.call("get_event", "municipal_1_1")
	popup.get("answer_input").text = str(ev["payload"]["correct_value"])
	popup.call("_submit_typed_answer")
	await h.call("await_frames", tree, 2)
	var txt: String = h.call("collect_labels_text", game.get("_modal"))
	h.call("check_contains", txt, "5", "EN feedback displays 5-day bonus")
	h.call("check_contains", txt, "days", "EN feedback displays English days wording")

func _t3_09(h: RefCounted, _tree: SceneTree) -> void:
	var s := load("res://scripts/eventdatabase.gd") as GDScript
	var db1: Node = s.new()
	db1.call("register_default_problems")
	db1.call("ensure_months_through", 6, 2)
	var orig_ev: Dictionary = db1.call("get_event", "municipal_18_4")
	var usage: Dictionary = db1.call("get_usage_save_data")
	db1.free()

	var db2: Node = s.new()
	db2.call("register_default_problems")
	db2.call("ensure_months_through", 6, 2)
	db2.call("load_usage_save_data", usage)
	for i in range(8):
		var ev: Dictionary = db2.call("get_event", "municipal_18_%d" % i)
		h.call("check_true", bool(db2.call("validate_event_structure", ev)), "Reloaded municipal_18_%d validates" % i)
	h.call("check_eq", db2.call("get_event", "municipal_18_4"), orig_ev, "municipal_18_4 identical after compact reload")
	db2.free()

func _t3_10(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "Pair10", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	h.call("check_true", game.get_node_or_null("Ground") == null, "No legacy $Ground")
	var hud: Node = game.get("hud")
	var vis: CityVisuals = game.get("visuals")
	var city: CityState = game.get("city")
	h.call("press_button", hud.get("funds_button") as Button)
	(hud.get("_investment_mode") as OptionButton).select(1)
	(hud.get("_investment_mode") as OptionButton).item_selected.emit(1)
	h.call("press_button", hud.get_node("InvestmentPanel/Content/Categories/EducationCell/EducationButton") as Button)
	await h.call("await_frames", tree, 2)
	var count := [0]
	vis.draw.connect(func(): count[0] += 1)
	var pos := vis.get_global_transform_with_canvas() * vis.point({"x": 1, "y": 1})
	for d in [Vector2.ZERO, Vector2(1, 1), Vector2(-1, 2)]:
		await h.call("send_mouse_motion", tree, pos + d)
		await h.call("await_frames", tree, 1)
	h.call("check_eq", count[0], 1, "Only 1 redraw across 3 same-tile motions")
	await h.call("send_mouse_button", tree, pos, MOUSE_BUTTON_LEFT, true)
	await h.call("await_frames", tree, 2)
	h.call("check_eq", city.projects.size(), 1, "Project placed via CityVisuals")

func _t3_11(h: RefCounted, tree: SceneTree) -> void:
	var sm := tree.root.get_node("SaveManager")
	var tm := TimeManager.new()
	var em := EventManager.new()
	var city := CityState.new()
	city.start("Pair11", "medium")
	sm.call("save_game", tm, em, 1, null, city)
	tm.free()
	em.free()
	tree.root.get_node("SettingsService").call("update", "locale", "en")
	var menu: Node = await h.call("boot_scene", tree, "res://scenes/ui/main_menu.tscn")
	h.call("press_button", menu.get_node("Menu/VBoxContainer/jogar") as Button)
	await h.call("await_frames", tree, 1)
	await h.call("send_key_tap", tree, KEY_ESCAPE, 0)
	await h.call("await_frames", tree, 1)
	h.call("check_false", menu.has_node("GameDialog"), "Esc closed GameDialog")
	h.call("press_button", menu.get_node("Menu/VBoxContainer/continuar") as Button)
	await h.call("await_frames", tree, 2)
	var popup: Node = menu.get("_active_popup")
	h.call("check_true", popup != null, "carregar popup opened")
	if popup != null:
		h.call("check_contains", (popup.get_node("Center/Panel/Margin/Content/Slots/Slot1/Info") as Label).text, "Pair11", "Slot 1 shows Pair11")
		h.call("check_contains", (popup.get_node("Center/Panel/Margin/Content/Slots/Slot2/Info") as Label).text, "Empty", "Slot 2 shows Empty")

func _t3_12(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "Pair12", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var pm: Node = game.get("pause_menu")
	h.call("check_true", pm.get_node_or_null("%OptionsPanel") == null, "No legacy OptionsPanel")
	pm.call("open_menu")
	h.call("press_button", pm.get("options_button") as Button)
	await h.call("await_frames", tree, 1)
	var ss := tree.root.get_node("SettingsService")
	ss.call("update", "music", 25.0)
	ss.call("update", "muted", true)
	pm.call("back_or_resume")
	h.call("check_true", AudioServer.is_bus_mute(AudioServer.get_bus_index("Master")), "Master muted")
	h.call("check_approx", AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")), linear_to_db(0.25), 0.05, "Music bus volume updated")

func _t3_13(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "Pair13", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	h.call("check_false", "_skip_until_event" in game.get("time_manager"), "No dead _skip_until_event")
	var ed: Node = game.get("event_database")
	var em: Node = game.get("event_manager")
	var rt: Dictionary = ed.call("build_runtime_event", "rota_presidio", 1, 1, 1, 30, 12)
	em.get("active_events").append(rt)
	em.emit_signal("event_triggered", rt)
	game.call("_skip_to_next")
	await h.call("await_frames", tree, 3)
	h.call("check_eq", String(game.get("_current_problem_id")), "rota_presidio", "SkipButton opens active urgent immediately")

func _t3_14(h: RefCounted, _tree: SceneTree) -> void:
	var s := load("res://scripts/eventdatabase.gd") as GDScript
	var db: Node = s.new()
	db.call("register_default_problems")
	var city := CityState.new()
	city.start("Pair14", "medium")
	var f0 := city.funds
	var h0 := float(city.indicators["health"])
	var res := city.apply_problem(db.call("get_event", "rota_medicamentos"), true, false, "rota_b")
	var expected_delta := 3.0 * GameRules.EVENT_REWARD_FUNDS - 800.0
	h.call("check_approx", city.funds - f0, expected_delta, 0.01, "Funds reflect reward minus 800")
	h.call("check_approx", float(city.indicators["health"]) - h0, 2.0, 0.01, "Health +2.0 from rota_b")
	h.call("check_approx", float(city.ledger.back().get("value", 0.0)), float(res.get("funds", 0.0)), 0.01, "Ledger matches exact money_delta")
	db.free()

func _t3_15(h: RefCounted, _tree: SceneTree) -> void:
	var s := load("res://scripts/eventdatabase.gd") as GDScript
	var db: Node = s.new()
	db.call("register_default_problems")
	db.call("ensure_months_through", 12, 1)
	for id in db.call("get_all_event_ids"):
		h.call("check_true", bool(db.call("validate_event_structure", db.call("get_event", String(id)))), "Valid event: %s" % id)
	db.free()

func _t3_16(h: RefCounted, tree: SceneTree) -> void:
	tree.root.get_node("SettingsService").call("update", "locale", "en")
	var game: Node = await h.call("start_new_game", tree, "Pair16", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var ed: Node = game.get("event_database")
	var em: Node = game.get("event_manager")
	em.get("active_events").append(ed.call("build_runtime_event", "verba_imss", 1, 1, 1, 30, 12))
	game.call("open_problem", "verba_imss")
	await h.call("await_frames", tree, 3)
	var popup: Control = game.get("_current_problem_popup")
	var opt1 := popup.get_node("Center/Panel/Margin/Content/Body/Answers/Option1") as Button
	var opt2 := popup.get_node("Center/Panel/Margin/Content/Body/Answers/Option2") as Button
	h.call("check_eq", opt1.text, "Yes", "Option1 translated to Yes")
	h.call("check_eq", opt2.text, "No", "Option2 translated to No")
	for btn in [opt1, opt2, popup.get_node("Center/Panel/Margin/Content/Body/ProblemTools/BoardButton") as Button]:
		var bg: Color = h.call("extract_stylebox_bg", btn.get_theme_stylebox("hover"))
		h.call("check_gt", float(h.call("contrast_ratio", btn.get_theme_color("font_hover_color"), bg)), 4.5, "EN button hover contrast >= 4.5")

func _t3_17(h: RefCounted, tree: SceneTree) -> void:
	var ss := tree.root.get_node("SettingsService")
	for loc in ["en", "pt_BR"]:
		ss.call("update", "locale", loc)
		var packed := load("res://scenes/ui/problem_template.tscn") as PackedScene
		var popup := packed.instantiate() as Control
		popup.theme = ss.get("game_theme")
		tree.root.add_child(popup)
		await h.call("await_frames", tree, 2)
		popup.call("configure", "C", "D", null, [], true, "number_input", "R", "common")
		popup.call("_show_calculator")
		await h.call("await_frames", tree, 1)
		await h.call("send_key_tap", tree, KEY_1, 49)
		await h.call("send_key_tap", tree, KEY_COMMA, 44)
		await h.call("send_key_tap", tree, KEY_5, 53)
		await h.call("send_key_tap", tree, KEY_KP_ADD, 0)
		await h.call("send_key_tap", tree, KEY_2, 50)
		await h.call("send_key_tap", tree, KEY_ENTER, 0)
		h.call("check_eq", (popup.get("calculator_display") as LineEdit).text, "3,5", "1,5 + 2 = 3,5 in %s" % loc)
		popup.call("_hide_calculator")
		popup.call("_show_calculator")
		h.call("check_eq", (popup.get("calculator_display") as LineEdit).text, "3,5", "Preserved 3,5 in %s" % loc)
		popup.queue_free()
		await h.call("await_frames", tree, 2)

func _t3_18(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "Pair18", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var city: CityState = game.get("city")
	var tm: Node = game.get("time_manager")
	game.call("_begin_placement", "education")
	await h.call("send_mouse_motion", tree, Vector2(400, 400))
	await h.call("send_key_tap", tree, KEY_ESCAPE, 0)
	h.call("check_eq", String(game.get("_placement_area")), "", "Placement cancelled by Esc")
	h.call("check_false", bool(game.get_node("Camera2D").get("build_mode")), "Camera build_mode false")
	h.call("check_false", bool(tm.get("paused")), "placement pause released")
	h.call("check_true", city.projects.is_empty(), "No project created")

func _t3_19(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "Pair19", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var city: CityState = game.get("city")
	var tm: Node = game.get("time_manager")
	var ed: Node = game.get("event_database")
	var em: Node = game.get("event_manager")
	city.reputation = 60.0
	for _m in range(48):
		city.reputation = 60.0
		city.invest("education", 5000.0)
		city.invest("health", 5000.0)
		city.funds += 20000.0
		tm.call("_advance_one_day")
		for _d in range(29):
			tm.call("_advance_one_day")
		if game.get("_modal") != null:
			game.call("_close_dialog")
	h.call("check_eq", city.term, 2, "Re-elected to term 2 at month 48")
	var sm := tree.root.get_node("SaveManager")
	sm.call("save_game", tm, em, 1, ed, city)
	var raw := FileAccess.get_file_as_string(String(sm.call("slot_path", 1)))
	var parsed: Dictionary = JSON.parse_string(raw)
	h.call("check_eq", parsed.get("city", {}).get("ledger", []).size(), 120, "Saved ledger capped at 120")
	h.call("check_true", parsed.get("event_database_usage", {}).get("definitions", {}).is_empty(), "Procedural defs omitted")

func _t3_20(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "Pair20", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var ed: Node = game.get("event_database")
	var em: Node = game.get("event_manager")
	var city: CityState = game.get("city")
	var expired_events := []
	em.connect("event_expired", func(rt): expired_events.append(rt["event_id"]))
	for id in ["moradias_enchente", "rota_presidio"]:
		var rt: Dictionary = ed.call("build_runtime_event", id, 1, 1, 1, 30, 12)
		em.get("active_events").append(rt)
		em.emit_signal("event_triggered", rt)
	var f0 := city.funds
	var soc0 := float(city.indicators["social"])
	var sec0 := float(city.indicators["security"])
	em.get("active_events")[0]["deadline_remaining_seconds"] = 0.5
	game.call("_process", 1.0)
	em.get("active_events")[0]["deadline_remaining_seconds"] = 0.5
	game.call("_process", 1.0)
	h.call("check_eq", expired_events.size(), 2, "Both urgent authored problems expired")
	h.call("check_lt", city.funds, f0, "Funds penalized")
	h.call("check_lt", float(city.indicators["social"]), soc0, "social penalized")
	h.call("check_lt", float(city.indicators["security"]), sec0, "security penalized")

func _t3_21(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "Pair21", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var ed: Node = game.get("event_database")
	var em: Node = game.get("event_manager")
	var hud: Node = game.get("hud")
	var rt: Dictionary = ed.call("build_runtime_event", "rota_presidio", 1, 1, 1, 30, 12)
	em.get("active_events").append(rt)
	em.emit_signal("event_triggered", rt)
	game.call("open_problem", "rota_presidio")
	await h.call("await_frames", tree, 3)
	h.call("press_button", game.get("_current_problem_popup").get_node("Center/Panel/Margin/Content/Header/CloseButton") as Button)
	await h.call("await_frames", tree, 2)
	h.call("press_button", hud.get("urgent_open_button") as Button)
	await h.call("await_frames", tree, 3)
	var popup: Control = game.get("_current_problem_popup")
	h.call("check_true", popup != null, "rota_presidio reopened via urgent banner")
	if popup != null:
		var ill: Control = popup.get("illustration_panel")
		h.call("check_gt", float(ill.get_child_count()), 1.0, "RouteGraph rendered on reopen")

func _t3_22(h: RefCounted, tree: SceneTree) -> void:
	var m1: Node = await h.call("boot_scene", tree, "res://scenes/ui/main_menu.tscn")
	h.call("check_true", m1 != null, "main_menu booted")
	var game: Node = await h.call("start_new_game", tree, "Pair22", "medium", true, true)
	h.call("check_true", game != null and game.get_node_or_null("Ground") == null, "Game booted cleanly without TileMaps")
	game.call("_on_menu_requested")
	await h.call("await_frames", tree, 1)
	h.call("check_true", (game.get("pause_menu") as Control).visible, "PauseMenu opened")
	game.call("_on_return_confirmed")
	await h.call("await_frames", tree, 3)
	h.call("check_true", tree.current_scene != null and tree.current_scene.name == "TittleScreen", "Returned cleanly to main_menu")

func _t3_23(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "Pair23", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var ed: Node = game.get("event_database")
	var em: Node = game.get("event_manager")
	ed.call("register_event", "p23_txt", {"title": "T23", "description": "D", "category": "common", "interaction_type": "text_input", "payload": {"prompt": "P", "accepted_answers": ["a b"]}})
	em.get("active_events").append(ed.call("build_runtime_event", "p23_txt", 1, 1, 1, 30, 12))
	game.call("open_problem", "p23_txt")
	await h.call("await_frames", tree, 3)
	var popup: Control = game.get("_current_problem_popup")
	popup.get("answer_input").grab_focus()
	await h.call("type_text", tree, "a b")
	await h.call("send_key_tap", tree, KEY_ESCAPE, 0)
	await h.call("await_frames", tree, 2)
	game.call("open_problem", "p23_txt")
	await h.call("await_frames", tree, 3)
	var popup2: Control = game.get("_current_problem_popup")
	h.call("check_eq", (popup2.get("answer_input") as LineEdit).text, "a b", "Draft 'a b' preserved across Esc close/reopen")

func _t3_24(h: RefCounted, _tree: SceneTree) -> void:
	var city := CityState.new()
	city.start("Pair24", "medium")
	var lot := {"x": 2, "y": 2}
	city.configure_lots([lot])
	city.construct("education", 0, lot)
	var edu0 := float(city.indicators["education"])
	city.apply_problem({"id": "municipal_1_1", "category": "common", "construction_days_saved": 5}, true)
	h.call("check_eq", int(city.projects[0].due), 15, "Due reduced to 15")
	for d in range(1, 16):
		city.advance_day(d)
	h.call("check_eq", city.buildings.size(), 1, "Project completed on day 15")
	h.call("check_approx", float(city.indicators["education"]), edu0 + 12.0, 0.01, "Education increased by +12")
	if city.has_method("can_build_coord"):
		h.call("check_false", bool(city.call("can_build_coord", Vector2i(2, 2))), "Completed lot remains occupied")
