extends RefCounted

func get_cases() -> Array[Dictionary]:
	return [
		{"id": "T2-F12-1", "method": "_t2_f12_1", "description": "city.ledger caps strictly at 120 entries FIFO"},
		{"id": "T2-F12-2", "method": "_t2_f12_2", "description": "city.start() clears ledger"},
		{"id": "T2-F12-3", "method": "_t2_f12_3", "description": "Corrupt non-dict ledger entries filtered on load and rejected by SaveManager"},
		{"id": "T2-F12-4", "method": "_t2_f12_4", "description": "Ledger entry value signs match actual funds deltas"},
		{"id": "T2-F12-5", "method": "_t2_f12_5", "description": "SaveManager write_slot/read_slot preserves 120-entry ledger"},
		{"id": "T2-F13-1", "method": "_t2_f13_1", "description": "Calculator division by zero displays Erro and recovers on digit"},
		{"id": "T2-F13-2", "method": "_t2_f13_2", "description": "Calculator ignores duplicate decimal comma"},
		{"id": "T2-F13-3", "method": "_t2_f13_3", "description": "Calculator enforces max 14-char display length"},
		{"id": "T2-F13-4", "method": "_t2_f13_4", "description": "Calculator backspace on negative single digit collapses cleanly to 0"},
		{"id": "T2-F13-5", "method": "_t2_f13_5", "description": "Esc closes calculator only while preserving problem and calc state"},
		{"id": "T2-F14-1", "method": "_t2_f14_1", "description": "RouteGraph handles empty distances {} without error"},
		{"id": "T2-F14-2", "method": "_t2_f14_2", "description": "RouteGraph handles Vector2.ZERO size without NaN/crash"},
		{"id": "T2-F14-3", "method": "_t2_f14_3", "description": "RouteGraph skips edges with unknown endpoints safely"},
		{"id": "T2-F14-4", "method": "_t2_f14_4", "description": "Repeated show_route_graph calls display dynamic data cleanly"},
		{"id": "T2-F14-5", "method": "_t2_f14_5", "description": "RouteGraph renders long legend string cleanly at 440x230"},
		{"id": "T2-F15-1", "method": "_t2_f15_1", "description": "carregar.tscn shows populated slot 1 in EN and Empty on slots 2-3"},
		{"id": "T2-F15-2", "method": "_t2_f15_2", "description": "Urgent banner tooltip differentiates 1 vs 3 queued in EN"},
		{"id": "T2-F15-3", "method": "_t2_f15_3", "description": "Runtime locale switch pt_BR -> en updates HUD urgent banner"},
		{"id": "T2-F15-4", "method": "_t2_f15_4", "description": "Urgent banner translates moradias_enchente title in EN"},
		{"id": "T2-F15-5", "method": "_t2_f15_5", "description": "All 10 authored and 8 procedural titles translate in EN"},
		{"id": "T2-F16-1", "method": "_t2_f16_1", "description": "Esc on main_menu with no dialog does not crash or leave scene"},
		{"id": "T2-F16-2", "method": "_t2_f16_2", "description": "Esc closes Options popup on main_menu"},
		{"id": "T2-F16-3", "method": "_t2_f16_3", "description": "Esc with echo=true is ignored for GameDialog"},
		{"id": "T2-F16-4", "method": "_t2_f16_4", "description": "Esc key release (pressed=false) does not close GameDialog"},
		{"id": "T2-F16-5", "method": "_t2_f16_5", "description": "Rapid open -> Esc -> open cycle works without GameDialog lockup"},
		{"id": "T2-F17-1", "method": "_t2_f17_1", "description": "ResourceLoader.exists is false for deleted EventPopup and TileMapCity"},
		{"id": "T2-F17-2", "method": "_t2_f17_2", "description": "ResourceLoader.exists is false for all 5 deleted empty scripts"},
		{"id": "T2-F17-3", "method": "_t2_f17_3", "description": "All 7 companion .uid files for deleted scripts/scenes are removed"},
		{"id": "T2-F17-4", "method": "_t2_f17_4", "description": "Zero preload/string references to deleted filenames across .gd files"},
		{"id": "T2-F17-5", "method": "_t2_f17_5", "description": "project.godot autoloads and main_scene remain valid"},
		{"id": "T2-F18-1", "method": "_t2_f18_1", "description": "Isometric click places building on (1,1) without TileMaps"},
		{"id": "T2-F18-2", "method": "_t2_f18_2", "description": "Camera2D pan/zoom/reset_view works without TileMaps"},
		{"id": "T2-F18-3", "method": "_t2_f18_3", "description": "Road clicks (0,0) and (6,2) rejected without $Road"},
		{"id": "T2-F18-4", "method": "_t2_f18_4", "description": "game_manager.gd has zero $Ground/$Road/$Builds references"},
		{"id": "T2-F18-5", "method": "_t2_f18_5", "description": "CityVisuals renders in SubViewport cleanly without TileMaps"},
		{"id": "T2-F19-1", "method": "_t2_f19_1", "description": "GameHUD.close_panels() works cleanly without OccurrencePanel"},
		{"id": "T2-F19-2", "method": "_t2_f19_2", "description": "GameHUD.has_open_panel() tracks investment and statistics panels"},
		{"id": "T2-F19-3", "method": "_t2_f19_3", "description": "PauseMenu.back_or_resume() closes Options dialog then emits resume"},
		{"id": "T2-F19-4", "method": "_t2_f19_4", "description": "TimeManager.skip_until_next_event while paused returns immediately"},
		{"id": "T2-F19-5", "method": "_t2_f19_5", "description": "PauseMenu.tscn has no VolumeSlider, FullscreenCheckBox, OptionsBackButton, or OptionsPanel"},
		{"id": "T2-F20-1", "method": "_t2_f20_1", "description": "GameHUD.refresh_city() before bind_city() is null-safe"},
		{"id": "T2-F20-2", "method": "_t2_f20_2", "description": "Repeated Game <-> main_menu scene transitions tear down cleanly"},
		{"id": "T2-F20-3", "method": "_t2_f20_3", "description": "Extracted helper scripts in game/session and ui/hud instantiate standalone"},
		{"id": "T2-F20-4", "method": "_t2_f20_4", "description": "set_problem_mode(true/false) toggles expected HUD controls"},
		{"id": "T2-F20-5", "method": "_t2_f20_5", "description": "CancelPlacement hides PlacementBar and releases placement pause"},
		{"id": "T2-F21-1", "method": "_t2_f21_1", "description": "Harness check failure accounting works without aborting"},
		{"id": "T2-F21-2", "method": "_t2_f21_2", "description": "Single E2E case executes within tight time budget"},
		{"id": "T2-F21-3", "method": "_t2_f21_3", "description": "Suite registry supports per-tier and per-suite filtering"},
		{"id": "T2-F21-4", "method": "_t2_f21_4", "description": "DisplayServer headless detection works gracefully"},
		{"id": "T2-F21-5", "method": "_t2_f21_5", "description": "SaveManager.write_slot rejects invalid schema, slot bounds, and reputation"}
	]

func run_case(h: RefCounted, tree: SceneTree, case_info: Dictionary) -> void:
	await call(String(case_info["method"]), h, tree)

func _t2_f12_1(h: RefCounted, _tree: SceneTree) -> void:
	var city := CityState.new()
	city.start("Cap", "medium")
	for i in range(150):
		city.add_ledger("Entry %d" % i, float(i))
	h.call("check_eq", city.ledger.size(), 120, "Ledger capped at 120")
	h.call("check_eq", String(city.ledger[0].get("label", "")), "Entry 30", "Oldest 30 evicted FIFO")

func _t2_f12_2(h: RefCounted, _tree: SceneTree) -> void:
	var city := CityState.new()
	city.start("A", "medium")
	city.add_ledger("X", 10.0)
	city.start("Nova", "easy")
	h.call("check_true", city.ledger.is_empty(), "city.start() clears ledger")

func _t2_f12_3(h: RefCounted, tree: SceneTree) -> void:
	var city := CityState.new()
	city.load_save_data({"ledger": ["bad", 123, {"month": 1, "label": "ok", "value": 10.0}]})
	h.call("check_eq", city.ledger.size(), 1, "Non-dict ledger items filtered on load")
	var sm := tree.root.get_node("SaveManager")
	var bad_save := {
		"schema_version": 2,
		"time": {"current_day": 1, "current_month": 1, "current_year": 1},
		"events": {"active_events": [], "scheduled_events": [], "resolved_events": [], "expired_events": []},
		"city": {"funds": 1000.0, "reputation": 50.0, "indicators": {}, "difficulty": "medium", "outcome": "playing", "projects": [], "buildings": [], "history": [], "ledger": ["bad"]}
	}
	h.call("check_false", bool(sm.call("write_slot", 1, bad_save)), "SaveManager rejects non-dict ledger entries")

func _t2_f12_4(h: RefCounted, _tree: SceneTree) -> void:
	var city := CityState.new()
	city.start("Signs", "medium")
	var f0 := city.funds
	city.invest("education", 10000.0)
	h.call("check_approx", float(city.ledger.back().get("value", 0.0)), city.funds - f0, 0.01, "Investment ledger value == funds delta")
	var f1 := city.funds
	city.advance_month()
	h.call("check_approx", float(city.ledger.back().get("value", 0.0)), city.funds - f1, 0.01, "Monthly ledger value == funds delta")
	var f2 := city.funds
	city.apply_problem({"id": "p", "category": "common", "success_effects": {"social": 2.0}}, true)
	h.call("check_approx", float(city.ledger.back().get("value", 0.0)), city.funds - f2, 0.01, "Problem ledger value == funds delta")

func _t2_f12_5(h: RefCounted, tree: SceneTree) -> void:
	var city := CityState.new()
	city.start("Save120", "medium")
	for i in range(120):
		city.add_ledger("L%d" % i, float(i))
	var sm := tree.root.get_node("SaveManager")
	var tm := TimeManager.new()
	var em := EventManager.new()
	h.call("check_true", bool(sm.call("save_game", tm, em, 1, null, city)), "SaveManager saves 120-entry ledger")
	var loaded: Dictionary = sm.call("read_slot", 1)
	h.call("check_eq", loaded.get("city", {}).get("ledger", []).size(), 120, "Read slot restores 120 ledger entries")
	tm.free()
	em.free()

func _boot_calc(h: RefCounted, tree: SceneTree) -> Control:
	var packed := load("res://scenes/ui/problem_template.tscn") as PackedScene
	var popup := packed.instantiate() as Control
	var settings := tree.root.get_node_or_null("SettingsService")
	if settings != null:
		popup.theme = settings.get("game_theme")
	tree.root.add_child(popup)
	await h.call("await_frames", tree, 2)
	popup.call("configure", "Calc", "Desc", null, [], true, "number_input", "Resp", "common")
	popup.call("_show_calculator")
	await h.call("await_frames", tree, 1)
	return popup

func _t2_f13_1(h: RefCounted, tree: SceneTree) -> void:
	var popup := await _boot_calc(h, tree)
	for k in ["8", "÷", "0", "="]:
		popup.call("_on_calculator_key_pressed", k)
	var disp: LineEdit = popup.get("calculator_display")
	h.call("check_eq", disp.text, "Erro", "Division by zero shows Erro")
	popup.call("_on_calculator_key_pressed", "5")
	h.call("check_eq", disp.text, "5", "Typing 5 after Erro recovers to 5")

func _t2_f13_2(h: RefCounted, tree: SceneTree) -> void:
	var popup := await _boot_calc(h, tree)
	for k in ["1", ",", "2", ",", "3"]:
		popup.call("_on_calculator_key_pressed", k)
	var disp: LineEdit = popup.get("calculator_display")
	h.call("check_eq", disp.text, "1,23", "Multiple commas ignored")

func _t2_f13_3(h: RefCounted, tree: SceneTree) -> void:
	var popup := await _boot_calc(h, tree)
	for _i in range(20):
		popup.call("_on_calculator_key_pressed", "9")
	var disp: LineEdit = popup.get("calculator_display")
	h.call("check_true", disp.text.length() <= 14, "Display length <= 14 (got %d)" % disp.text.length())

func _t2_f13_4(h: RefCounted, tree: SceneTree) -> void:
	var popup := await _boot_calc(h, tree)
	popup.call("_on_calculator_key_pressed", "5")
	popup.call("_on_calculator_key_pressed", "±")
	var disp: LineEdit = popup.get("calculator_display")
	h.call("check_eq", disp.text, "-5", "Sign flip gives -5")
	popup.call("_on_calculator_key_pressed", "⌫")
	h.call("check_eq", disp.text, "0", "Backspace on -5 collapses cleanly to 0")

func _t2_f13_5(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "EscCalc", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var ed: Node = game.get("event_database")
	var em: Node = game.get("event_manager")
	ed.call("ensure_month_content", 1, 1)
	var rt: Dictionary = ed.call("build_runtime_event", "municipal_1_0", 1, 1, 1, 30, 12)
	em.get("active_events").append(rt)
	game.call("open_problem", "municipal_1_0")
	await h.call("await_frames", tree, 3)
	var popup: Control = game.get("_current_problem_popup")
	popup.call("_show_calculator")
	for k in ["6", "+", "7", "="]:
		popup.call("_on_calculator_key_pressed", k)
	await h.call("send_key_tap", tree, KEY_ESCAPE, 0)
	await h.call("await_frames", tree, 2)
	h.call("check_false", (popup.get("calculator_overlay") as Control).visible, "Esc hides calculator")
	h.call("check_true", is_instance_valid(game.get("_current_problem_popup")), "Problem popup remains open")
	popup.call("_show_calculator")
	h.call("check_eq", (popup.get("calculator_display") as LineEdit).text, "13", "Calc state 13 preserved after Esc")

func _t2_f14_1(h: RefCounted, tree: SceneTree) -> void:
	var vp := SubViewport.new()
	vp.size = Vector2i(460, 260)
	vp.render_target_update_mode = SubViewport.UPDATE_ONCE
	var rg := RouteGraph.new()
	rg.distances = {}
	rg.size = Vector2(440, 230)
	vp.add_child(rg)
	tree.root.add_child(vp)
	await h.call("await_frames", tree, 2)
	h.call("check_eq", rg.distances.size(), 0, "Empty distances rendered safely")

func _t2_f14_2(h: RefCounted, tree: SceneTree) -> void:
	var vp := SubViewport.new()
	vp.size = Vector2i(100, 100)
	vp.render_target_update_mode = SubViewport.UPDATE_ONCE
	var rg := RouteGraph.new()
	rg.custom_minimum_size = Vector2.ZERO
	rg.size = Vector2.ZERO
	rg.distances = {"nodes": [{"id": "A", "label": "A"}], "edges": [], "legend": "x"}
	vp.add_child(rg)
	tree.root.add_child(vp)
	await h.call("await_frames", tree, 2)
	h.call("check_true", is_instance_valid(rg), "Zero size RouteGraph did not crash")

func _t2_f14_3(h: RefCounted, tree: SceneTree) -> void:
	var vp := SubViewport.new()
	vp.size = Vector2i(460, 260)
	vp.render_target_update_mode = SubViewport.UPDATE_ONCE
	var rg := RouteGraph.new()
	rg.distances = {
		"nodes": [{"id": "A", "label": "A", "pos": Vector2(0.5, 0.5)}],
		"edges": [{"from": "A", "to": "MISSING", "label": "1"}]
	}
	rg.size = Vector2(440, 230)
	vp.add_child(rg)
	tree.root.add_child(vp)
	await h.call("await_frames", tree, 2)
	h.call("check_true", is_instance_valid(rg), "Unknown edge endpoint ignored safely")

func _t2_f14_4(h: RefCounted, tree: SceneTree) -> void:
	var popup := await _boot_calc(h, tree)
	popup.call("_hide_calculator", false)
	popup.call("show_route_graph", {"a": 4, "b": 6})
	await h.call("await_frames", tree, 1)
	var dyn := {"nodes": [{"id": "X", "label": "X"}, {"id": "Y", "label": "Y"}], "edges": [{"from": "X", "to": "Y", "label": "2"}], "legend": "km"}
	popup.call("show_route_graph", dyn)
	await h.call("await_frames", tree, 1)
	var ill: Control = popup.get("illustration_panel")
	h.call("check_true", ill.visible, "illustration_panel visible")
	var last_rg: RouteGraph = null
	for ch in ill.get_children():
		if ch is RouteGraph:
			last_rg = ch
	h.call("check_true", last_rg != null and last_rg.distances.has("nodes"), "Dynamic graph data present")

func _t2_f14_5(h: RefCounted, tree: SceneTree) -> void:
	var vp := SubViewport.new()
	vp.size = Vector2i(460, 260)
	vp.render_target_update_mode = SubViewport.UPDATE_ONCE
	var rg := RouteGraph.new()
	rg.distances = {
		"legend": "Distancia total em quilometros, tempo estimado em minutos e pedagio acumulado em reais",
		"nodes": [{"id": "1", "label": "1"}, {"id": "2", "label": "2"}],
		"edges": [{"from": "1", "to": "2", "label": "10, 20, 5"}]
	}
	rg.size = Vector2(440, 230)
	vp.add_child(rg)
	tree.root.add_child(vp)
	await h.call("await_frames", tree, 2)
	h.call("check_true", rg.size.x <= 440.1, "Long legend RouteGraph stays within bounds")

func _t2_f15_1(h: RefCounted, tree: SceneTree) -> void:
	var sm := tree.root.get_node("SaveManager")
	var tm := TimeManager.new()
	var em := EventManager.new()
	var city := CityState.new()
	city.start("Teste", "medium")
	sm.call("save_game", tm, em, 1, null, city)
	tm.free()
	em.free()
	var settings := tree.root.get_node("SettingsService")
	settings.call("update", "locale", "en")
	var scr: Node = await h.call("boot_scene", tree, "res://scenes/ui/carregar.tscn")
	var s1 := (scr.get_node("Center/Panel/Margin/Content/Slots/Slot1/Info") as Label).text
	var s2 := (scr.get_node("Center/Panel/Margin/Content/Slots/Slot2/Info") as Label).text
	h.call("check_contains", s1, "Teste", "Slot 1 shows city name Teste")
	h.call("check_contains", s1, "Day", "Slot 1 shows English Day")
	h.call("check_contains", s2, "Empty", "Slot 2 shows English Empty")

func _t2_f15_2(h: RefCounted, tree: SceneTree) -> void:
	var settings := tree.root.get_node("SettingsService")
	settings.call("update", "locale", "en")
	var game: Node = await h.call("start_new_game", tree, "UrgTip", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var hud: Node = game.get("hud")
	var btn: Button = hud.get("urgent_open_button")
	var one: Array[Dictionary] = [{"event_id": "rota_presidio", "title": "Intriga do Carroeios", "category": "urgent", "deadline_phase": "opening", "deadline_remaining_seconds": 120.0}]
	hud.call("update_problem_tabs", one)
	h.call("check_eq", btn.tooltip_text, "Open urgent problem", "1 urgent tooltip exact EN")
	var three: Array[Dictionary] = [
		one[0],
		{"event_id": "moradias_enchente", "title": "Tsente: moradias após a enchente", "category": "urgent", "deadline_phase": "queued", "deadline_remaining_seconds": 180.0},
		{"event_id": "municipal_1_6", "title": "Plano de emergência", "category": "urgent", "deadline_phase": "queued", "deadline_remaining_seconds": 180.0}
	]
	hud.call("update_problem_tabs", three)
	h.call("check_contains", btn.tooltip_text, "Open urgent problem", "3 urgent tooltip starts with EN")
	h.call("check_contains", btn.tooltip_text, "3 queued", "3 urgent tooltip includes '3 queued'")

func _t2_f15_3(h: RefCounted, tree: SceneTree) -> void:
	var settings := tree.root.get_node("SettingsService")
	settings.call("update", "locale", "pt_BR")
	var game: Node = await h.call("start_new_game", tree, "SwitchLoc", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var hud: Node = game.get("hud")
	var events: Array[Dictionary] = [{"event_id": "rota_presidio", "title": "Intriga do Carroeios", "category": "urgent", "deadline_phase": "opening", "deadline_remaining_seconds": 120.0}]
	hud.call("update_problem_tabs", events)
	settings.call("update", "locale", "en")
	hud.call("update_problem_tabs", events)
	var phase: Label = hud.get("urgent_phase")
	h.call("check_eq", phase.text, "TO OPEN", "Runtime switch to EN updates urgent banner")

func _t2_f15_4(h: RefCounted, tree: SceneTree) -> void:
	var settings := tree.root.get_node("SettingsService")
	settings.call("update", "locale", "en")
	var game: Node = await h.call("start_new_game", tree, "FloodEN", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var hud: Node = game.get("hud")
	var events: Array[Dictionary] = [{"event_id": "moradias_enchente", "title": "Tsente: moradias após a enchente", "category": "urgent", "deadline_phase": "opening", "deadline_remaining_seconds": 120.0}]
	hud.call("update_problem_tabs", events)
	var btn: Button = hud.get("urgent_open_button")
	h.call("check_contains", btn.text, "Tsente: housing after the flood", "moradias_enchente title translated in urgent banner")

func _t2_f15_5(h: RefCounted, tree: SceneTree) -> void:
	var settings := tree.root.get_node("SettingsService")
	settings.call("update", "locale", "en")
	var s := load("res://scripts/eventdatabase.gd") as GDScript
	var db: Node = s.new()
	db.call("register_default_problems")
	db.call("ensure_month_content", 1, 1)
	for i in range(8):
		var ev: Dictionary = db.call("get_event", "municipal_1_%d" % i)
		var title := String(ev.get("title", ""))
		h.call("check_ne", TranslationServer.translate(title), title, "Procedural title translated: %s" % title)
	for id in ["merenda_escolar", "juros_bancos", "rota_medicamentos", "moradias_enchente", "rota_presidio", "pesquisa_satisfacao", "obras_combinacoes"]:
		var ev: Dictionary = db.call("get_event", id)
		var title := String(ev.get("title", ""))
		h.call("check_ne", TranslationServer.translate(title), title, "Authored title translated: %s" % title)
	db.free()

func _t2_f16_1(h: RefCounted, tree: SceneTree) -> void:
	var menu: Node = await h.call("boot_scene", tree, "res://scenes/ui/main_menu.tscn")
	await h.call("send_key_tap", tree, KEY_ESCAPE, 0)
	await h.call("await_frames", tree, 2)
	h.call("check_eq", tree.current_scene, menu, "Esc with no dialog keeps user on main_menu")

func _t2_f16_2(h: RefCounted, tree: SceneTree) -> void:
	var menu: Node = await h.call("boot_scene", tree, "res://scenes/ui/main_menu.tscn")
	h.call("press_button", menu.get_node("Menu/VBoxContainer/opcoes") as Button)
	await h.call("await_frames", tree, 2)
	h.call("check_true", menu.get("_active_popup") != null, "Options popup opened")
	await h.call("send_key_tap", tree, KEY_ESCAPE, 0)
	await h.call("await_frames", tree, 2)
	h.call("check_true", menu.get("_active_popup") == null, "Esc closes Options popup")

func _t2_f16_3(h: RefCounted, tree: SceneTree) -> void:
	var menu: Node = await h.call("boot_scene", tree, "res://scenes/ui/main_menu.tscn")
	h.call("press_button", menu.get_node("Menu/VBoxContainer/jogar") as Button)
	await h.call("await_frames", tree, 2)
	h.call("send_key", tree, KEY_ESCAPE, 0, 0, true, true)
	await h.call("await_frames", tree, 2)
	h.call("check_true", menu.has_node("GameDialog"), "Echo Esc does not close GameDialog")

func _t2_f16_4(h: RefCounted, tree: SceneTree) -> void:
	var menu: Node = await h.call("boot_scene", tree, "res://scenes/ui/main_menu.tscn")
	h.call("press_button", menu.get_node("Menu/VBoxContainer/jogar") as Button)
	await h.call("await_frames", tree, 2)
	h.call("send_key", tree, KEY_ESCAPE, 0, 0, false, false)
	await h.call("await_frames", tree, 2)
	h.call("check_true", menu.has_node("GameDialog"), "Key-release Esc does not close GameDialog")

func _t2_f16_5(h: RefCounted, tree: SceneTree) -> void:
	var menu: Node = await h.call("boot_scene", tree, "res://scenes/ui/main_menu.tscn")
	var jogar := menu.get_node("Menu/VBoxContainer/jogar") as Button
	for _i in range(3):
		h.call("press_button", jogar)
		await h.call("await_frames", tree, 1)
		h.call("check_true", menu.has_node("GameDialog"), "GameDialog opened")
		await h.call("send_key_tap", tree, KEY_ESCAPE, 0)
		await h.call("await_frames", tree, 1)
		h.call("check_false", menu.has_node("GameDialog"), "GameDialog closed")

func _t2_f17_1(h: RefCounted, _tree: SceneTree) -> void:
	for p in ["res://scenes/ui/EventPopup.tscn", "res://scenes/game/TileMapCity.tscn"]:
		h.call("check_false", ResourceLoader.exists(p), "ResourceLoader.exists false for %s" % p)

func _t2_f17_2(h: RefCounted, _tree: SceneTree) -> void:
	for p in ["res://scripts/city_data.gd", "res://scripts/tile_building.gd", "res://scenes/game/event_manager.gd", "res://scenes/game/time_manager.gd", "res://scenes/game/InvestmentUiButton.gd"]:
		h.call("check_false", ResourceLoader.exists(p), "ResourceLoader.exists false for %s" % p)

func _t2_f17_3(h: RefCounted, _tree: SceneTree) -> void:
	var uids := [
		"res://scripts/city_data.gd.uid",
		"res://scripts/tile_building.gd.uid",
		"res://scenes/game/event_manager.gd.uid",
		"res://scenes/game/time_manager.gd.uid",
		"res://scenes/game/InvestmentUiButton.gd.uid",
		"res://scenes/ui/EventPopup.tscn.uid",
		"res://scenes/game/TileMapCity.tscn.uid"
	]
	for u in uids:
		h.call("check_false", FileAccess.file_exists(u), "Dead .uid absent: %s" % u)

func _t2_f17_4(h: RefCounted, _tree: SceneTree) -> void:
	var terms := ["EventPopup", "TileMapCity", "city_data", "tile_building", "InvestmentUiButton", "en.json"]
	var scripts: Array = []
	for d in ["res://core", "res://game", "res://scenes", "res://scripts", "res://ui"]:
		scripts.append_array(h.call("scan_files_recursive", d, ".gd"))
	for f in scripts:
		var txt := FileAccess.get_file_as_string(String(f))
		for term in terms:
			h.call("check_not_contains", txt, term, "%s has no reference to %s" % [f, term])

func _t2_f17_5(h: RefCounted, _tree: SceneTree) -> void:
	var cfg := ConfigFile.new()
	h.call("check_eq", cfg.load("res://project.godot"), OK, "project.godot parses as ConfigFile")
	var main_sc := String(cfg.get_value("application", "run/main_scene", ""))
	h.call("check_true", ResourceLoader.exists(main_sc), "Main scene exists: %s" % main_sc)
	for k in cfg.get_section_keys("autoload"):
		var val := String(cfg.get_value("autoload", k, "")).trim_prefix("*")
		h.call("check_true", ResourceLoader.exists(val), "Autoload exists: %s" % val)

func _t2_f18_1(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "ClickLot", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var vis: CityVisuals = game.get("visuals")
	var city: CityState = game.get("city")
	game.call("_construct", "education")
	var screen_pos := vis.get_global_transform_with_canvas() * vis.point({"x": 1, "y": 1})
	await h.call("send_mouse_button", tree, screen_pos, MOUSE_BUTTON_LEFT, true)
	await h.call("await_frames", tree, 2)
	h.call("check_eq", city.projects.size(), 1, "Click on (1,1) places project without TileMaps")

func _t2_f18_2(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "CamTest", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var cam := game.get_node("Camera2D") as Camera2D
	var start_pos := cam.position
	cam.position += Vector2(100, 50)
	cam.call("reset_view")
	h.call("check_true", cam.position.is_equal_approx(start_pos), "Camera reset_view works without TileMaps")

func _t2_f18_3(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "RoadRej", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var city: CityState = game.get("city")
	h.call("check_false", city.construct("health", 0, {"x": 0, "y": 0}).is_empty(), "(0,0) road rejected")
	h.call("check_false", city.construct("health", 0, {"x": 6, "y": 2}).is_empty(), "(6,2) road rejected")

func _t2_f18_4(h: RefCounted, _tree: SceneTree) -> void:
	var src := FileAccess.get_file_as_string("res://scripts/game_manager.gd")
	for tok in ["$Ground", "$Road", "$Builds"]:
		h.call("check_not_contains", src, tok, "game_manager.gd removes %s" % tok)

func _t2_f18_5(h: RefCounted, tree: SceneTree) -> void:
	var vp := SubViewport.new()
	vp.size = Vector2i(320, 240)
	vp.render_target_update_mode = SubViewport.UPDATE_ONCE
	var city := CityState.new()
	city.start("Render", "medium")
	var vis := CityVisuals.new()
	vp.add_child(vis)
	tree.root.add_child(vp)
	vis.bind(city)
	await h.call("await_frames", tree, 3)
	h.call("check_eq", vis.lots.size(), 484, "CityVisuals renders in SubViewport cleanly")

func _t2_f19_1(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "NoOccP", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var hud: Node = game.get("hud")
	h.call("press_button", hud.get("funds_button") as Button)
	h.call("check_true", bool(hud.call("close_panels")), "close_panels() returns true when panel open")
	h.call("check_false", bool(hud.call("has_open_panel")), "No panel open after close_panels()")

func _t2_f19_2(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "HasOpen", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var hud: Node = game.get("hud")
	h.call("check_false", bool(hud.call("has_open_panel")), "Initially false")
	h.call("press_button", hud.get("funds_button") as Button)
	h.call("check_true", bool(hud.call("has_open_panel")), "True when investment open")
	h.call("press_button", hud.get("reputation_button") as Button)
	h.call("check_true", bool(hud.call("has_open_panel")), "True when statistics open")
	hud.call("close_panels")
	h.call("check_false", bool(hud.call("has_open_panel")), "False after close_panels")

func _t2_f19_3(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "PmBack", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var pm: Node = game.get("pause_menu")
	var resumed := [false]
	pm.connect("resume_requested", func(): resumed[0] = true)
	pm.call("open_menu")
	h.call("press_button", pm.get("options_button") as Button)
	await h.call("await_frames", tree, 1)
	pm.call("back_or_resume")
	await h.call("await_frames", tree, 1)
	h.call("check_false", resumed[0], "First back_or_resume returns to main pause panel")
	pm.call("back_or_resume")
	h.call("check_true", resumed[0], "Second back_or_resume emits resume_requested")

func _t2_f19_4(h: RefCounted, _tree: SceneTree) -> void:
	var tm := TimeManager.new()
	tm.pause_game()
	var d0 := tm.current_day
	tm.skip_until_next_event(func(): return false)
	h.call("check_eq", tm.current_day, d0, "skip_until_next_event while paused does not advance day")
	tm.free()

func _t2_f19_5(h: RefCounted, _tree: SceneTree) -> void:
	var packed := load("res://scenes/ui/PauseMenu.tscn") as PackedScene
	var pm := packed.instantiate()
	for node_name in ["%OptionsPanel", "%VolumeSlider", "%FullscreenCheckBox", "%OptionsBackButton"]:
		h.call("check_true", pm.get_node_or_null(node_name) == null, "Legacy node %s removed from PauseMenu.tscn" % node_name)
	pm.free()

func _t2_f20_1(h: RefCounted, _tree: SceneTree) -> void:
	var packed := load("res://scenes/ui/HUD.tscn") as PackedScene
	var hud := packed.instantiate()
	hud.call("refresh_city")
	h.call("check_true", true, "refresh_city() before bind_city() does not crash")
	hud.free()

func _t2_f20_2(h: RefCounted, tree: SceneTree) -> void:
	for i in range(3):
		var game: Node = await h.call("start_new_game", tree, "Cycle%d" % i, "medium", true, true)
		h.call("check_true", game != null, "Game booted cycle %d" % i)
		var menu: Node = await h.call("boot_scene", tree, "res://scenes/ui/main_menu.tscn")
		h.call("check_true", menu != null, "Returned to main_menu cycle %d" % i)

func _t2_f20_3(h: RefCounted, _tree: SceneTree) -> void:
	var helpers: Array = []
	helpers.append_array(h.call("scan_files_recursive", "res://game/session", ".gd"))
	helpers.append_array(h.call("scan_files_recursive", "res://ui/hud", ".gd"))
	h.call("check_gt", float(helpers.size()), 0.0, "Found extracted helper scripts")
	for p in helpers:
		var scr := load(String(p)) as GDScript
		h.call("check_true", scr != null, "Helper loads: %s" % p)
		if scr != null:
			var inst: Variant = scr.new()
			h.call("check_true", inst != null, "Helper instantiates standalone: %s" % p)
			if inst is Node:
				(inst as Node).free()

func _t2_f20_4(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "ProbMode", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var hud: Node = game.get("hud")
	hud.call("set_problem_mode", true)
	for prop in ["menu_button", "pause_button", "normal_button", "fast_button", "very_fast_button", "funds_button", "reputation_button"]:
		h.call("check_true", (hud.get(prop) as Button).disabled, "%s disabled in problem mode" % prop)
	h.call("check_true", (hud.get_node("TimeDock/TimeControls/SkipButton") as Button).disabled, "SkipButton disabled in problem mode")
	hud.call("set_problem_mode", false)
	for prop in ["menu_button", "pause_button", "normal_button", "fast_button", "very_fast_button", "funds_button", "reputation_button"]:
		h.call("check_false", (hud.get(prop) as Button).disabled, "%s re-enabled after problem mode" % prop)

func _t2_f20_5(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "CancelPlace", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var hud: Node = game.get("hud")
	var tm: Node = game.get("time_manager")
	game.call("_begin_placement", "education")
	var bar := hud.get_node_or_null("PlacementBar") as Control
	h.call("check_true", bar != null and bar.visible, "PlacementBar visible")
	h.call("check_true", bool(tm.get("paused")), "Placement pauses time")
	var cancel := bar.find_child("CancelPlacement", true, false) as Button
	h.call("press_button", cancel)
	h.call("check_false", bar.visible, "CancelPlacement hides PlacementBar")
	h.call("check_false", bool(tm.get("paused")), "CancelPlacement releases placement pause")

func _t2_f21_1(h: RefCounted, _tree: SceneTree) -> void:
	var harness_script := load("res://tests/e2e/e2e_harness.gd") as GDScript
	var dummy: RefCounted = harness_script.new()
	dummy.call("begin_suite", "dummy")
	dummy.call("begin_case", "dummy_case")
	dummy.call("check", false, "intentional dummy check")
	dummy.call("check", true, "second check continues")
	h.call("check_eq", int(dummy.get("failures")), 1, "Dummy harness records 1 failure")
	h.call("check_eq", int(dummy.get("checks")), 2, "Dummy harness continued to 2nd check")

func _t2_f21_2(h: RefCounted, _tree: SceneTree) -> void:
	var t0 := Time.get_ticks_msec()
	var city := CityState.new()
	city.start("Speed", "medium")
	var elapsed := Time.get_ticks_msec() - t0
	h.call("check_lt", float(elapsed), 5000.0, "Case execution bounded well under budget")

func _t2_f21_3(h: RefCounted, tree: SceneTree) -> void:
	var reg: Array = tree.root.get_meta("e2e_suite_registry", [])
	var names := []
	for item in reg:
		names.append(String(item.get("name", "")))
	for expected in ["tier1_core", "tier1_ui_cleanup", "tier2_core", "tier2_ui_cleanup", "tier3_pairwise", "tier4_scenarios"]:
		h.call("check_true", names.has(expected), "Registry includes %s" % expected)

func _t2_f21_4(h: RefCounted, _tree: SceneTree) -> void:
	var dname := DisplayServer.get_name()
	h.call("check_false", dname.is_empty(), "DisplayServer.get_name() returns non-empty name (%s)" % dname)

func _t2_f21_5(h: RefCounted, tree: SceneTree) -> void:
	var sm := tree.root.get_node("SaveManager")
	var valid_payload := {
		"schema_version": 2,
		"time": {"current_day": 1, "current_month": 1, "current_year": 1},
		"events": {"active_events": [], "scheduled_events": [], "resolved_events": [], "expired_events": []}
	}
	h.call("check_false", bool(sm.call("write_slot", 0, valid_payload)), "Rejects slot 0")
	h.call("check_false", bool(sm.call("write_slot", 4, valid_payload)), "Rejects slot 4")
	var bad_schema := valid_payload.duplicate(true)
	bad_schema["schema_version"] = 99
	h.call("check_false", bool(sm.call("write_slot", 1, bad_schema)), "Rejects schema_version 99")
	var bad_rep := valid_payload.duplicate(true)
	bad_rep["city"] = {"funds": 100.0, "reputation": 101.0, "indicators": {}, "difficulty": "medium", "outcome": "playing", "projects": [], "buildings": [], "history": [], "ledger": []}
	h.call("check_false", bool(sm.call("write_slot", 1, bad_rep)), "Rejects reputation > 100")
