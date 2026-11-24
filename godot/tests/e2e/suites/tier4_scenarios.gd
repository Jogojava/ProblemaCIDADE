extends RefCounted

func get_cases() -> Array[Dictionary]:
	return [
		{"id": "T4-01", "method": "_t4_01", "description": "Full 96-month campaign with re-election, checkpoints, and victory"},
		{"id": "T4-02", "method": "_t4_02", "description": "Bilingual mid-game switch and reload (pt_BR <-> en)"},
		{"id": "T4-03", "method": "_t4_03", "description": "Urgent deadline pauses only while closed during a paused game"},
		{"id": "T4-04", "method": "_t4_04", "description": "City growth, housing placement, and 30-building cap"},
		{"id": "T4-05", "method": "_t4_05", "description": "Save/backup corruption and compact usage recovery"},
		{"id": "T4-06", "method": "_t4_06", "description": "Problem-solving toolkit session (Calculator + Board + text_input)"},
		{"id": "T4-07", "method": "_t4_07", "description": "Hard difficulty impeachment and defeat paths"},
		{"id": "T4-08", "method": "_t4_08", "description": "Term-1 electoral defeat (not_reelected)"},
		{"id": "T4-09", "method": "_t4_09", "description": "Construction acceleration chain and non-obra isolation"},
		{"id": "T4-10", "method": "_t4_10", "description": "Build-mode stress and zero-wasted-redraw verification"},
		{"id": "T4-11", "method": "_t4_11", "description": "Menu navigation, Esc handling, and options round-trip"},
		{"id": "T4-12", "method": "_t4_12", "description": "Full 10-authored problem catalog walkthrough"}
	]

func run_case(h: RefCounted, tree: SceneTree, case_info: Dictionary) -> void:
	await call(String(case_info["method"]), h, tree)

func _answer_event_via_ui(h: RefCounted, tree: SceneTree, game: Node, ev: Dictionary, correct: bool = true) -> void:
	var id := String(ev["event_id"])
	var ed: Node = game.get("event_database")
	var def: Dictionary = ed.call("get_event", id)
	game.call("open_problem", id)
	await h.call("await_frames", tree, 1)
	var popup: Control = game.get("_current_problem_popup")
	if popup == null:
		return
	var itype := String(def.get("interaction_type", "choice"))
	var payload: Dictionary = def.get("payload", {})
	if itype == "number_input":
		var val := float(payload.get("correct_value", 0))
		popup.get("answer_input").text = str(val if correct else val + 999)
		popup.call("_submit_typed_answer")
	else:
		var target := String(def.get("correct_answer", ""))
		if def.has("accepted_answers"):
			target = String(def["accepted_answers"][0])
		var opts: Array = payload.get("options", [])
		for i in range(opts.size()):
			var oid := String(opts[i].get("id", ""))
			if (correct and oid == target) or (not correct and oid != target):
				popup.call("_on_option_pressed", i)
				break
	await h.call("await_frames", tree, 1)
	if game.get("_modal") != null:
		game.call("_close_dialog")

func _t4_01(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "Campanha96", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var city: CityState = game.get("city")
	var vis: CityVisuals = game.get("visuals")
	var tm: Node = game.get("time_manager")
	var em: Node = game.get("event_manager")
	var ed: Node = game.get("event_database")
	var sm := tree.root.get_node("SaveManager")
	for lot in vis.lots:
		if city.can_build(lot):
			city.construct("education", 0, lot)
			break
	var cp12 := false
	var cp60 := false
	var seen_route_answers := {}
	var bonus_applied := false
	for _day in range(2900):
		if game.get("_modal") != null:
			game.call("_close_dialog")
		tm.call("_advance_one_day")
		for ev in em.call("get_active_events"):
			var eid := String(ev["event_id"])
			if eid.ends_with("_4"):
				var def: Dictionary = ed.call("get_event", eid)
				seen_route_answers[String(def.get("correct_answer", ""))] = true
			if eid.ends_with("_1") and not city.projects.is_empty():
				bonus_applied = true
			await _answer_event_via_ui(h, tree, game, ev, true)
			if eid.ends_with("_1") and bonus_applied and city.last_result.has("construction_days_saved"):
				h.call("check_eq", int(city.last_result["construction_days_saved"]), 5, "Campaign construction bonus recorded")
		if (not cp12 and city.completed_months >= 12) or (not cp60 and city.completed_months >= 60):
			if city.completed_months >= 12 and not cp12:
				cp12 = true
			else:
				cp60 = true
			h.call("check_true", bool(sm.call("save_game", tm, em, 1, ed, city)), "Checkpoint save at month %d" % city.completed_months)
			var raw := FileAccess.get_file_as_string(String(sm.call("slot_path", 1)))
			var parsed: Dictionary = JSON.parse_string(raw)
			h.call("check_true", parsed.get("event_database_usage", {}).get("definitions", {}).is_empty(), "Compact checkpoint omits procedural defs")
			sm.call("load_slot", 1)
			game = await h.call("boot_scene", tree, "res://scenes/game/Game.tscn", true)
			city = game.get("city")
			tm = game.get("time_manager")
			em = game.get("event_manager")
			ed = game.get("event_database")
		if city.outcome != "playing":
			break
	h.call("check_eq", city.outcome, "completed", "96-month campaign completed")
	h.call("check_eq", city.completed_months, 96, "Completed 96 months")
	h.call("check_eq", city.term, 2, "Reached term 2")
	h.call("check_true", city.ledger.size() <= 120, "Ledger bounded <= 120")
	h.call("check_true", seen_route_answers.has("a") and seen_route_answers.has("b"), "Supply routes varied a and b during campaign")

func _t4_02(h: RefCounted, tree: SceneTree) -> void:
	var ss := tree.root.get_node("SettingsService")
	ss.call("update", "locale", "pt_BR")
	var game: Node = await h.call("start_new_game", tree, "Bilingual", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var tm: Node = game.get("time_manager")
	var em: Node = game.get("event_manager")
	var ed: Node = game.get("event_database")
	var city: CityState = game.get("city")
	for _d in range(90):
		tm.call("_advance_one_day")
	ed.call("ensure_month_content", 2, 1)
	var rt: Dictionary = ed.call("build_runtime_event", "rota_presidio", 1, 4, 1, 30, 12)
	em.get("active_events").append(rt)
	em.emit_signal("event_triggered", rt)
	var sm := tree.root.get_node("SaveManager")
	sm.call("save_game", tm, em, 1, ed, city)
	ss.call("update", "locale", "en")
	var scr: Node = await h.call("boot_scene", tree, "res://scenes/ui/carregar.tscn")
	h.call("check_contains", (scr.get_node("Center/Panel/Margin/Content/Slots/Slot2/Info") as Label).text, "Empty", "carregar empty slot shows Empty")
	scr.call("_load_slot", 1)
	await h.call("await_frames", tree, 4)
	var reloaded := tree.current_scene
	reloaded.set_process(false)
	reloaded.get("time_manager").set_process(false)
	var hud: Node = reloaded.get("hud")
	h.call("check_eq", (hud.get("urgent_phase") as Label).text, "TO OPEN", "Reloaded urgent banner in EN")
	reloaded.call("open_problem", "rota_presidio")
	await h.call("await_frames", tree, 3)
	var popup: Control = reloaded.get("_current_problem_popup")
	h.call("check_true", popup != null and (popup.get("illustration_panel") as Control).get_child_count() > 1, "Dynamic RouteGraph rendered on EN reload")

func _t4_03(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "Crisis", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var ed: Node = game.get("event_database")
	var em: Node = game.get("event_manager")
	var city: CityState = game.get("city")
	var rt1: Dictionary = ed.call("build_runtime_event", "rota_presidio", 1, 1, 1, 30, 12)
	em.get("active_events").append(rt1)
	em.emit_signal("event_triggered", rt1)
	await h.call("send_key_tap", tree, KEY_SPACE, 32)
	game.call("open_problem", "rota_presidio")
	await h.call("await_frames", tree, 3)
	var popup: Control = game.get("_current_problem_popup")
	var rg: RouteGraph = null
	for ch in (popup.get("illustration_panel") as Control).get_children():
		if ch is RouteGraph:
			rg = ch
	h.call("check_true", rg != null and rg.distances.get("nodes", []).size() == 8, "rota_presidio 8-node graph rendered")
	await h.call("send_key_tap", tree, KEY_ESCAPE, 0)
	await h.call("await_frames", tree, 2)
	var rem_before := float(rt1.get("deadline_remaining_seconds", 180.0))
	game.call("_process", 5.0)
	h.call("check_approx", float(rt1.get("deadline_remaining_seconds", 180.0)), rem_before, 0.05, "Deadline pauses while closed and game is paused")
	game.call("open_problem", "rota_presidio")
	await h.call("await_frames", tree, 3)
	var sec0 := float(city.indicators["security"])
	var rep0 := city.reputation
	game.get("_current_problem_popup").call("_on_option_pressed", 0)
	await h.call("await_frames", tree, 2)
	h.call("check_gt", float(city.indicators["security"]), sec0, "Security increased after solving rota_presidio")
	h.call("check_gt", city.reputation, rep0, "Reputation increased")
	game.call("_close_dialog")
	var rt2: Dictionary = ed.call("build_runtime_event", "moradias_enchente", 2, 1, 1, 30, 12)
	em.get("active_events").append(rt2)
	em.emit_signal("event_triggered", rt2)
	game.get("time_manager").call("pause_game")
	rt2["deadline_remaining_seconds"] = 1.0
	game.call("open_problem", "moradias_enchente")
	var funds_before := city.funds
	game.call("_process", 1.5)
	h.call("check_lt", city.funds, funds_before, "2nd urgent expires while open during manual pause and applies penalty")

func _t4_04(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "Growth30", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var city: CityState = game.get("city")
	var vis: CityVisuals = game.get("visuals")
	city.funds = 5000000.0
	for area in GameRules.AREAS:
		city.invest(area, 30000.0)
	city.advance_month()
	h.call("check_gt", city.population, GameRules.INITIAL_POPULATION, "Population grew")
	var occupied_set := {}
	for r in city.residences:
		var k := Vector2i(int(r.lot.x), int(r.lot.y))
		h.call("check_false", occupied_set.has(k), "No overlapping residence lot %s" % str(k))
		h.call("check_ne", k, Vector2i(-1, -1), "No home on town_hall")
		occupied_set[k] = true
	city.population += 300
	if city.housing_requests() > 0:
		for lot in vis.lots:
			if city.can_build(lot):
				h.call("check_eq", city.place_home(lot), "", "Manual home placed cleanly")
				break
	for idx in range(30):
		var free_lot := {}
		for lot in vis.lots:
			if city.can_build(lot):
				free_lot = lot
				break
		if free_lot.is_empty():
			break
		var area: String = GameRules.AREAS[idx % GameRules.AREAS.size()]
		city.construct(area, idx * 25, free_lot)
		city.advance_day(idx * 25 + 20)
	h.call("check_eq", city.buildings.size(), 30, "Reached 30 buildings cap")
	for lot in vis.lots:
		if city.can_build(lot):
			h.call("check_false", city.construct("education", 1000, lot).is_empty(), "31st building rejected")
			break

func _t4_05(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "CorruptRec", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var tm: Node = game.get("time_manager")
	var em: Node = game.get("event_manager")
	var ed: Node = game.get("event_database")
	var city: CityState = game.get("city")
	var sm := tree.root.get_node("SaveManager")
	for _m in range(18):
		for _d in range(30):
			tm.call("_advance_one_day")
	h.call("check_true", bool(sm.call("save_game", tm, em, 1, ed, city)), "Initial save slot 1")
	h.call("check_true", bool(sm.call("save_game", tm, em, 1, ed, city)), "Second save creates .backup")
	var p1 := String(sm.call("slot_path", 1))
	var f := FileAccess.open(p1, FileAccess.WRITE)
	f.store_string("{CORRUPTED_JSON")
	f.close()
	h.call("check_true", bool(sm.call("load_slot", 1)), "load_slot recovers from .backup")
	h.call("check_true", bool(sm.get("recovered_backup")), "recovered_backup flag set")
	var reloaded: Node = await h.call("boot_scene", tree, "res://scenes/game/Game.tscn", true)
	var red: Node = reloaded.get("event_database")
	h.call("check_true", bool(red.call("has_event", "municipal_18_4")), "18 months of municipal_* regenerated on backup recovery")

func _t4_06(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "Toolkit", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var ed: Node = game.get("event_database")
	var em: Node = game.get("event_manager")
	var city: CityState = game.get("city")
	em.get("active_events").append(ed.call("build_runtime_event", "merenda_escolar", 1, 1, 1, 30, 12))
	game.call("open_problem", "merenda_escolar")
	await h.call("await_frames", tree, 3)
	var popup: Control = game.get("_current_problem_popup")
	popup.call("_show_calculator")
	await h.call("await_frames", tree, 1)
	for k in ["8", "0", "×", "1", ",", "2", "5", "=", "×", "1", "2", "+", "5", "0", "0", "="]:
		popup.call("_on_calculator_key_pressed", k)
	var disp: LineEdit = popup.get("calculator_display")
	h.call("check_eq", disp.text, "1700", "Calculator computed 1700")
	popup.call("_hide_calculator")
	popup.call("_show_board")
	popup.call("_hide_board")
	popup.call("_show_calculator")
	h.call("check_eq", disp.text, "1700", "Calculator preserved 1700 after board session")
	popup.call("_hide_calculator")
	popup.get("answer_input").text = "1700"
	popup.call("_submit_typed_answer")
	await h.call("await_frames", tree, 2)
	h.call("check_eq", city.correct_count, 1, "merenda_escolar solved with 1700")
	game.call("_close_dialog")
	ed.call("register_event", "t4_txt", {"title": "T4", "description": "D", "category": "common", "interaction_type": "text_input", "payload": {"prompt": "P", "accepted_answers": ["cidade limpa"]}})
	em.get("active_events").append(ed.call("build_runtime_event", "t4_txt", 2, 1, 1, 30, 12))
	game.call("open_problem", "t4_txt")
	await h.call("await_frames", tree, 3)
	var p2: Control = game.get("_current_problem_popup")
	p2.get("answer_input").grab_focus()
	await h.call("type_text", tree, "cidade limpa")
	p2.call("_submit_typed_answer")
	await h.call("await_frames", tree, 2)
	h.call("check_eq", city.correct_count, 2, "text_input solved with spaces")

func _t4_07(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "HardImp", "hard", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var city: CityState = game.get("city")
	var sm := tree.root.get_node("SaveManager")
	h.call("check_approx", city.reputation, 45.0, 0.01, "Hard starts at 45% reputation")
	city.reputation = 8.0
	for _m in range(3):
		city.reputation = 8.0
		city.advance_month()
	h.call("check_eq", city.outcome, "impeachment", "3 crisis months (<10%) triggers impeachment")
	h.call("check_true", bool(game.get("time_manager").get("paused")), "Impeachment halts simulation")
	h.call("check_true", game.get("_modal") != null, "Impeachment ending modal opened")
	sm.call("save_game", game.get("time_manager"), game.get("event_manager"), 1, game.get("event_database"), city)
	sm.call("load_slot", 1)
	var reloaded: Node = await h.call("boot_scene", tree, "res://scenes/game/Game.tscn", true)
	h.call("check_eq", String(reloaded.get("city").get("outcome")), "impeachment", "Reloaded city preserves impeachment outcome")

func _t4_08(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "NotReelected", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var city: CityState = game.get("city")
	for _m in range(47):
		city.reputation = 30.0
		city.funds = 200000.0
		city.advance_month()
	city.reputation = 35.0
	city.advance_month()
	await h.call("await_frames", tree, 2)
	h.call("check_eq", city.outcome, "not_reelected", "Month 48 with <50% rep ends in not_reelected")
	h.call("check_true", bool(game.get("time_manager").get("paused")), "Time paused on electoral defeat")
	h.call("check_true", game.get("_modal") != null, "Ending modal displayed")

func _t4_09(h: RefCounted, _tree: SceneTree) -> void:
	var s := load("res://scripts/eventdatabase.gd") as GDScript
	var db: Node = s.new()
	db.call("register_default_problems")
	db.call("ensure_months_through", 2, 1)
	var city := CityState.new()
	city.start("Chain", "medium")
	for area in ["education", "health", "water"]:
		city.construct(area, 0)
	city.apply_problem(db.call("get_event", "obras_combinacoes"), true)
	for p in city.projects:
		h.call("check_eq", int(p.due), 20, "obras_combinacoes grants 0 bonus")
	city.apply_problem(db.call("get_event", "municipal_1_1"), true)
	for p in city.projects:
		h.call("check_eq", int(p.due), 15, "municipal_1_1 reduces due to 15")
	city.apply_problem(db.call("get_event", "municipal_2_1"), true)
	for p in city.projects:
		h.call("check_eq", int(p.due), 10, "municipal_2_1 reduces due to 10")
	for d in range(1, 11):
		city.advance_day(d)
	h.call("check_eq", city.buildings.size(), 3, "All 3 projects completed on day 10")
	db.free()

func _t4_10(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "StressVis", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var vis: CityVisuals = game.get("visuals")
	var city: CityState = game.get("city")
	game.call("_begin_placement", "education")
	await h.call("await_frames", tree, 2)
	var count := [0]
	vis.draw.connect(func(): count[0] += 1)
	var tiles := [Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1), Vector2i(4, 1), Vector2i(5, 1)]
	for t in tiles:
		var base := vis.get_global_transform_with_canvas() * vis.point({"x": t.x, "y": t.y})
		for j in range(20):
			await h.call("send_mouse_motion", tree, base + Vector2(j % 5, j / 5))
		await h.call("await_frames", tree, 1)
	h.call("check_true", count[0] <= 6, "100 motions across 5 tiles triggered <= 6 redraws (got %d)" % count[0])
	await h.call("send_key_tap", tree, KEY_ESCAPE, 0)
	h.call("check_false", vis.placing, "Esc cancelled placement")
	game.call("_begin_placement", "education")
	var corner_pos := vis.get_global_transform_with_canvas() * vis.point({"x": -12, "y": -12})
	await h.call("send_mouse_button", tree, corner_pos, MOUSE_BUTTON_LEFT, true)
	await h.call("await_frames", tree, 2)
	h.call("check_eq", city.projects.size(), 1, "Placed on corner (-12,-12)")

func _t4_11(h: RefCounted, tree: SceneTree) -> void:
	var menu: Node = await h.call("boot_scene", tree, "res://scenes/ui/main_menu.tscn")
	h.call("press_button", menu.get_node("Menu/VBoxContainer/jogar") as Button)
	await h.call("await_frames", tree, 1)
	await h.call("send_key_tap", tree, KEY_ESCAPE, 0)
	await h.call("await_frames", tree, 1)
	h.call("check_false", menu.has_node("GameDialog"), "Esc closed GameDialog")
	h.call("press_button", menu.get_node("Menu/VBoxContainer/opcoes") as Button)
	await h.call("await_frames", tree, 2)
	var ss := tree.root.get_node("SettingsService")
	ss.call("update", "muted", true)
	ss.call("update", "locale", "en")
	await h.call("send_key_tap", tree, KEY_ESCAPE, 0)
	await h.call("await_frames", tree, 2)
	h.call("check_true", menu.get("_active_popup") == null, "Esc closed opcoes")
	var game: Node = await h.call("start_new_game", tree, "NavRound", "medium", true, true)
	game.call("_on_menu_requested")
	await h.call("await_frames", tree, 1)
	var pm: Node = game.get("pause_menu")
	h.call("check_true", pm.get_node_or_null("%OptionsPanel") == null, "No legacy OptionsPanel in PauseMenu")
	h.call("press_button", pm.get("options_button") as Button)
	await h.call("await_frames", tree, 1)
	await h.call("send_key_tap", tree, KEY_ESCAPE, 0)
	await h.call("await_frames", tree, 1)
	h.call("check_false", pm.has_node("GameDialog"), "Esc closed PauseMenu Options dialog")
	h.call("press_button", pm.get("resume_button") as Button)
	h.call("check_false", (pm as Control).visible, "Resume closed PauseMenu")

func _t4_12(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "Catalog10", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var ed: Node = game.get("event_database")
	var em: Node = game.get("event_manager")
	var city: CityState = game.get("city")
	var authored := [
		"aura_travessia", "merenda_escolar", "transporte_proporcional", "juros_bancos",
		"rota_medicamentos", "moradias_enchente", "verba_imss", "rota_presidio",
		"pesquisa_satisfacao", "obras_combinacoes"
	]
	for id in authored:
		var def: Dictionary = ed.call("get_event", id)
		h.call("check_true", bool(ed.call("validate_event_structure", def)), "Authored %s validates" % id)
		var rt: Dictionary = ed.call("build_runtime_event", id, 1, 1, 1, 30, 12)
		em.get("active_events").append(rt)
		await _answer_event_via_ui(h, tree, game, rt, true)
	h.call("check_eq", city.solved_count, 10, "All 10 authored problems solved")
	h.call("check_eq", city.correct_count, 10, "All 10 authored problems answered correctly")
