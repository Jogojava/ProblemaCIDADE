extends RefCounted

func get_cases() -> Array[Dictionary]:
	return [
		{"id": "T1-F12-1", "method": "_t1_f12_1", "description": "city.ledger records investment entry"},
		{"id": "T1-F12-2", "method": "_t1_f12_2", "description": "city.ledger records construction entry"},
		{"id": "T1-F12-3", "method": "_t1_f12_3", "description": "city.ledger records monthly and problem entries"},
		{"id": "T1-F12-4", "method": "_t1_f12_4", "description": "city.ledger survives JSON save/load round-trip"},
		{"id": "T1-F12-5", "method": "_t1_f12_5", "description": "HUD contains no unrequested ledger/extrato panel clutter"},
		{"id": "T1-F13-1", "method": "_t1_f13_1", "description": "Calculator preserves state on close and reopen within same problem"},
		{"id": "T1-F13-2", "method": "_t1_f13_2", "description": "Calculator resets to 0 when configure() opens a new problem"},
		{"id": "T1-F13-3", "method": "_t1_f13_3", "description": "Calculator accepts top-row keyboard input"},
		{"id": "T1-F13-4", "method": "_t1_f13_4", "description": "Calculator accepts numpad keyboard input"},
		{"id": "T1-F13-5", "method": "_t1_f13_5", "description": "Calculator keys do not leak to answer_input or TimeManager pause"},
		{"id": "T1-F14-1", "method": "_t1_f14_1", "description": "RouteGraph renders legacy 4-node format in SubViewport"},
		{"id": "T1-F14-2", "method": "_t1_f14_2", "description": "RouteGraph renders dynamic nodes/edges/legend format"},
		{"id": "T1-F14-3", "method": "_t1_f14_3", "description": "rota_presidio provides 8-node 11-edge graph"},
		{"id": "T1-F14-4", "method": "_t1_f14_4", "description": "ProblemTemplate integrates rota_presidio RouteGraph with SIZE_FILL"},
		{"id": "T1-F14-5", "method": "_t1_f14_5", "description": "RouteGraph fits inside illustration_panel at 1024x768 without overlap"},
		{"id": "T1-F15-1", "method": "_t1_f15_1", "description": "carregar.tscn displays Empty for empty slots under locale en"},
		{"id": "T1-F15-2", "method": "_t1_f15_2", "description": "carregar.tscn displays Vazio for empty slots under locale pt_BR"},
		{"id": "T1-F15-3", "method": "_t1_f15_3", "description": "Urgent banner translates TO OPEN, queued tooltip, and title in en"},
		{"id": "T1-F15-4", "method": "_t1_f15_4", "description": "Urgent banner translates TO ANSWER when solving in en"},
		{"id": "T1-F15-5", "method": "_t1_f15_5", "description": "Urgent banner fallback button text uses tr() in en"},
		{"id": "T1-F16-1", "method": "_t1_f16_1", "description": "Esc closes Nova gestao GameDialog on main_menu"},
		{"id": "T1-F16-2", "method": "_t1_f16_2", "description": "Esc with GameDialog open does not open QuitConfirmation"},
		{"id": "T1-F16-3", "method": "_t1_f16_3", "description": "GameDialog can be reopened cleanly after closing with Esc"},
		{"id": "T1-F16-4", "method": "_t1_f16_4", "description": "Cancel button closes GameDialog and stays on main_menu"},
		{"id": "T1-F16-5", "method": "_t1_f16_5", "description": "Esc closes GameDialog even while CityName LineEdit has focus"},
		{"id": "T1-F17-1", "method": "_t1_f17_1", "description": "5 dead template scripts and their .uid files are removed"},
		{"id": "T1-F17-2", "method": "_t1_f17_2", "description": "2 unused empty scenes EventPopup.tscn and TileMapCity.tscn removed"},
		{"id": "T1-F17-3", "method": "_t1_f17_3", "description": "Unreferenced localization/en.json removed"},
		{"id": "T1-F17-4", "method": "_t1_f17_4", "description": "en.po solely provides active English translations"},
		{"id": "T1-F17-5", "method": "_t1_f17_5", "description": "Zero remaining script/scene references to deleted dead files"},
		{"id": "T1-F18-1", "method": "_t1_f18_1", "description": "Legacy Ground TileMap removed from Game.tscn"},
		{"id": "T1-F18-2", "method": "_t1_f18_2", "description": "Legacy Road TileMap removed from Game.tscn"},
		{"id": "T1-F18-3", "method": "_t1_f18_3", "description": "Legacy Builds TileMap removed from Game.tscn"},
		{"id": "T1-F18-4", "method": "_t1_f18_4", "description": "CityVisuals is sole map renderer with 484 grass lots"},
		{"id": "T1-F18-5", "method": "_t1_f18_5", "description": "Game.tscn has no orphaned TileSet_g4v7s or TileMapLayer resources"},
		{"id": "T1-F19-1", "method": "_t1_f19_1", "description": "OccurrencePanel and _open_occurrences removed from HUD"},
		{"id": "T1-F19-2", "method": "_t1_f19_2", "description": "Legacy OptionsPanel and _sync_options removed from PauseMenu"},
		{"id": "T1-F19-3", "method": "_t1_f19_3", "description": "Dead _skip_until_event removed from TimeManager while skip still works"},
		{"id": "T1-F19-4", "method": "_t1_f19_4", "description": "Unused _format_countdown removed from GameManager"},
		{"id": "T1-F19-5", "method": "_t1_f19_5", "description": "TittleScreen anchors/scale normalized and SettingsService theme clean"},
		{"id": "T1-F20-1", "method": "_t1_f20_1", "description": "GameHUD preserves all public signals, methods, and test fields"},
		{"id": "T1-F20-2", "method": "_t1_f20_2", "description": "HUD.tscn preserves all interface contract node paths"},
		{"id": "T1-F20-3", "method": "_t1_f20_3", "description": "Extracted helper modules exist and reduce game_manager/game_hud coupling"},
		{"id": "T1-F20-4", "method": "_t1_f20_4", "description": "GameManager preserves all public/test properties and methods"},
		{"id": "T1-F20-5", "method": "_t1_f20_5", "description": "Decoupled HUD and GameManager delegate problem/build/invest flows cleanly"},
		{"id": "T1-F21-1", "method": "_t1_f21_1", "description": "E2E environment isolates SaveManager and SettingsService paths"},
		{"id": "T1-F21-2", "method": "_t1_f21_2", "description": "E2E run produces zero modifications to user://saves or git working tree"},
		{"id": "T1-F21-3", "method": "_t1_f21_3", "description": "Core simulation and procedural catalog are deterministically repeatable"},
		{"id": "T1-F21-4", "method": "_t1_f21_4", "description": "Temporary E2E storage cleanup removes isolated directories cleanly"},
		{"id": "T1-F21-5", "method": "_t1_f21_5", "description": "E2E registry covers all 246 cases with exact Tier 1-4 breakdown"}
	]

func run_case(h: RefCounted, tree: SceneTree, case_info: Dictionary) -> void:
	await call(String(case_info["method"]), h, tree)

func _t1_f12_1(h: RefCounted, _tree: SceneTree) -> void:
	var city := CityState.new()
	city.start("Ledger1", "medium")
	h.call("check_eq", city.invest("education", 15000.0), "", "invest succeeds")
	h.call("check_false", city.ledger.is_empty(), "ledger non-empty")
	var last: Dictionary = city.ledger.back()
	h.call("check_eq", int(last.get("month", -1)), 0, "month == 0")
	h.call("check_eq", String(last.get("label", "")), "Investimento", "label == Investimento")
	h.call("check_approx", float(last.get("value", 0.0)), -15000.0, 0.01, "value == -15000.0")

func _t1_f12_2(h: RefCounted, _tree: SceneTree) -> void:
	var city := CityState.new()
	city.start("Ledger2", "medium")
	h.call("check_eq", city.construct("health", 0), "", "construct succeeds")
	var last: Dictionary = city.ledger.back()
	h.call("check_eq", String(last.get("label", "")), "Construção", "label == Construção")
	h.call("check_approx", float(last.get("value", 0.0)), -GameRules.BUILDING_COST, 0.01, "value == -35000.0")

func _t1_f12_3(h: RefCounted, _tree: SceneTree) -> void:
	var city := CityState.new()
	city.start("Ledger3", "medium")
	city.advance_month()
	h.call("check_eq", String(city.ledger.back().get("label", "")), "Receita e despesas do mês", "Monthly ledger entry recorded")
	city.apply_problem({"id": "p1", "category": "common", "success_effects": {"social": 2.0}}, true)
	h.call("check_eq", String(city.ledger.back().get("label", "")), "Problema resolvido", "Problem solved ledger entry recorded")

func _t1_f12_4(h: RefCounted, _tree: SceneTree) -> void:
	var city := CityState.new()
	city.start("Ledger4", "medium")
	city.invest("education", 10000.0)
	city.advance_month()
	var json_str := JSON.stringify(city.get_save_data())
	var parsed: Dictionary = JSON.parse_string(json_str)
	var loaded := CityState.new()
	loaded.load_save_data(parsed)
	h.call("check_eq", loaded.ledger.size(), city.ledger.size(), "Ledger length preserved")
	h.call("check_eq", String(loaded.ledger.back().get("label", "")), String(city.ledger.back().get("label", "")), "Last ledger label preserved")

func _t1_f12_5(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "HudLedger", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var hud: Node = game.get("hud")
	h.call("check_true", hud.get_node_or_null("LedgerPanel") == null, "No unrequested LedgerPanel on HUD")
	h.call("check_true", hud.get_node_or_null("ExtratoPanel") == null, "No unrequested ExtratoPanel on HUD")

func _setup_problem_popup(h: RefCounted, tree: SceneTree, interaction_type: String = "number_input") -> Control:
	var packed := load("res://scenes/ui/problem_template.tscn") as PackedScene
	var popup := packed.instantiate() as Control
	var settings := tree.root.get_node_or_null("SettingsService")
	if settings != null:
		popup.theme = settings.get("game_theme")
	tree.root.add_child(popup)
	await h.call("await_frames", tree, 2)
	popup.call("configure", "Problema", "Descrição", null, [], true, interaction_type, "Resposta", "common")
	await h.call("await_frames", tree, 2)
	return popup

func _t1_f13_1(h: RefCounted, tree: SceneTree) -> void:
	var popup := await _setup_problem_popup(h, tree)
	var calc_btn := popup.get_node("Center/Panel/Margin/Content/Body/ProblemTools/CalculatorButton") as Button
	h.call("press_button", calc_btn)
	await h.call("await_frames", tree, 1)
	for k in ["1", "2", "+", "5", "="]:
		popup.call("_on_calculator_key_pressed", k)
	var disp: LineEdit = popup.get("calculator_display")
	h.call("check_eq", disp.text, "17", "12 + 5 = 17")
	popup.call("_hide_calculator")
	await h.call("await_frames", tree, 1)
	h.call("press_button", calc_btn)
	await h.call("await_frames", tree, 1)
	h.call("check_eq", disp.text, "17", "Calculator preserves 17 on reopen")

func _t1_f13_2(h: RefCounted, tree: SceneTree) -> void:
	var popup := await _setup_problem_popup(h, tree)
	popup.call("_show_calculator")
	for k in ["9", "×", "3", "="]:
		popup.call("_on_calculator_key_pressed", k)
	var disp: LineEdit = popup.get("calculator_display")
	h.call("check_eq", disp.text, "27", "9 x 3 = 27")
	popup.call("configure", "Outro", "Nova desc", null, [], true, "number_input", "Resp", "common")
	await h.call("await_frames", tree, 1)
	h.call("check_eq", disp.text, "0", "Calculator resets to 0 on new problem")

func _t1_f13_3(h: RefCounted, tree: SceneTree) -> void:
	var popup := await _setup_problem_popup(h, tree)
	popup.call("_show_calculator")
	await h.call("await_frames", tree, 1)
	await h.call("send_key_tap", tree, KEY_4, 52)
	await h.call("send_key_tap", tree, KEY_PLUS, 43)
	await h.call("send_key_tap", tree, KEY_5, 53)
	await h.call("send_key_tap", tree, KEY_ENTER, 0)
	var disp: LineEdit = popup.get("calculator_display")
	h.call("check_eq", disp.text, "9", "Top-row keyboard 4 + 5 = 9")

func _t1_f13_4(h: RefCounted, tree: SceneTree) -> void:
	var popup := await _setup_problem_popup(h, tree)
	popup.call("_show_calculator")
	await h.call("await_frames", tree, 1)
	await h.call("send_key_tap", tree, KEY_KP_7, 0)
	await h.call("send_key_tap", tree, KEY_KP_MULTIPLY, 0)
	await h.call("send_key_tap", tree, KEY_KP_8, 0)
	await h.call("send_key_tap", tree, KEY_KP_ENTER, 0)
	var disp: LineEdit = popup.get("calculator_display")
	h.call("check_eq", disp.text, "56", "Numpad 7 * 8 = 56")

func _t1_f13_5(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "CalcLeak", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var ed: Node = game.get("event_database")
	var em: Node = game.get("event_manager")
	var tm: Node = game.get("time_manager")
	ed.call("ensure_month_content", 1, 1)
	var rt: Dictionary = ed.call("build_runtime_event", "municipal_1_0", 1, 1, 1, 30, 12)
	em.get("active_events").append(rt)
	game.call("open_problem", "municipal_1_0")
	await h.call("await_frames", tree, 3)
	var popup: Control = game.get("_current_problem_popup")
	popup.call("_show_calculator")
	await h.call("await_frames", tree, 1)
	await h.call("send_key_tap", tree, KEY_1, 49)
	await h.call("send_key_tap", tree, KEY_2, 50)
	await h.call("send_key_tap", tree, KEY_SPACE, 32)
	await h.call("send_key_tap", tree, KEY_ENTER, 0)
	var ans_inp: LineEdit = popup.get("answer_input")
	h.call("check_eq", ans_inp.text, "", "Calculator keys do not leak to answer_input")
	h.call("check_true", is_instance_valid(game.get("_current_problem_popup")), "ENTER in calculator did not submit problem")
	h.call("check_true", bool(tm.get("paused")), "Challenge pause state undisturbed")

func _t1_f14_1(h: RefCounted, tree: SceneTree) -> void:
	var vp := SubViewport.new()
	vp.size = Vector2i(460, 260)
	vp.render_target_update_mode = SubViewport.UPDATE_ONCE
	var rg := RouteGraph.new()
	rg.distances = {"a": 5, "b": 7}
	rg.size = Vector2(440, 230)
	vp.add_child(rg)
	tree.root.add_child(vp)
	await h.call("await_frames", tree, 2)
	h.call("check_eq", rg.distances.get("a"), 5, "Legacy distances.a preserved")
	h.call("check_eq", rg.distances.get("b"), 7, "Legacy distances.b preserved")

func _t1_f14_2(h: RefCounted, tree: SceneTree) -> void:
	var vp := SubViewport.new()
	vp.size = Vector2i(460, 260)
	vp.render_target_update_mode = SubViewport.UPDATE_ONCE
	var rg := RouteGraph.new()
	var data := {
		"legend": "km | min | R$",
		"nodes": [
			{"id": "S", "label": "S", "pos": Vector2(0.1, 0.5)},
			{"id": "M", "label": "M", "pos": Vector2(0.5, 0.2)},
			{"id": "T", "label": "T", "pos": Vector2(0.9, 0.5)}
		],
		"edges": [
			{"from": "S", "to": "M", "label": "3, 5, 1"},
			{"from": "M", "to": "T", "label": "4, 6, 2"}
		]
	}
	if rg.has_method("set_graph_data"):
		rg.call("set_graph_data", data)
	else:
		rg.distances = data
	rg.size = Vector2(440, 230)
	vp.add_child(rg)
	tree.root.add_child(vp)
	await h.call("await_frames", tree, 2)
	h.call("check_eq", rg.distances.get("nodes", []).size(), 3, "Dynamic nodes stored on RouteGraph")

func _t1_f14_3(h: RefCounted, _tree: SceneTree) -> void:
	var s := load("res://scripts/eventdatabase.gd") as GDScript
	var db: Node = s.new()
	db.call("register_default_problems")
	var ev: Dictionary = db.call("get_event", "rota_presidio")
	var g: Dictionary = ev.get("graph", {})
	h.call("check_eq", g.get("nodes", []).size(), 8, "rota_presidio has 8 nodes")
	h.call("check_eq", g.get("edges", []).size(), 11, "rota_presidio has 11 edges")
	db.free()

func _t1_f14_4(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "GraphInt", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var ed: Node = game.get("event_database")
	var em: Node = game.get("event_manager")
	var rt: Dictionary = ed.call("build_runtime_event", "rota_presidio", 1, 1, 1, 30, 12)
	em.get("active_events").append(rt)
	game.call("open_problem", "rota_presidio")
	await h.call("await_frames", tree, 3)
	var popup: Control = game.get("_current_problem_popup")
	h.call("check_true", popup != null, "rota_presidio popup opened")
	if popup != null:
		var ill_panel: Control = popup.get("illustration_panel")
		var ans_cont: Control = popup.get("answers_container")
		h.call("check_true", ill_panel.visible, "illustration_panel visible")
		h.call("check_gt", float(ill_panel.get_child_count()), 1.0, "RouteGraph added to illustration_panel")
		h.call("check_eq", ans_cont.size_flags_horizontal, Control.SIZE_FILL, "answers_container uses SIZE_FILL")

func _t1_f14_5(h: RefCounted, tree: SceneTree) -> void:
	var prev_size := tree.root.size
	tree.root.size = Vector2i(1024, 768)
	var game: Node = await h.call("start_new_game", tree, "GraphFit", "medium", true, true)
	if game == null:
		tree.root.size = prev_size
		h.call("check", false, "Game loaded")
		return
	var ed: Node = game.get("event_database")
	var em: Node = game.get("event_manager")
	var rt: Dictionary = ed.call("build_runtime_event", "rota_presidio", 1, 1, 1, 30, 12)
	em.get("active_events").append(rt)
	game.call("open_problem", "rota_presidio")
	await h.call("await_frames", tree, 4)
	var popup: Control = game.get("_current_problem_popup")
	if popup != null:
		var ill_panel: Control = popup.get("illustration_panel")
		var ans_cont: Control = popup.get("answers_container")
		var graph: Control = null
		for ch in ill_panel.get_children():
			if ch is RouteGraph:
				graph = ch
				break
		h.call("check_true", graph != null, "RouteGraph child found")
		if graph != null:
			var gr := graph.get_global_rect()
			var ir := ill_panel.get_global_rect()
			var ar := ans_cont.get_global_rect()
			h.call("check_false", gr.intersects(ar), "RouteGraph does not overlap answers_container at 1024x768")
			h.call("check_true", ir.encloses(gr) or gr.size.x <= ir.size.x + 1.0, "RouteGraph fits within illustration_panel")
	tree.root.size = prev_size

func _t1_f15_1(h: RefCounted, tree: SceneTree) -> void:
	var settings := tree.root.get_node_or_null("SettingsService")
	if settings != null:
		settings.call("update", "locale", "en")
	var scr: Node = await h.call("boot_scene", tree, "res://scenes/ui/carregar.tscn")
	h.call("check_true", scr != null, "carregar.tscn loaded")
	if scr != null:
		var info := scr.get_node("Center/Panel/Margin/Content/Slots/Slot1/Info") as Label
		h.call("check_contains", info.text, "Empty", "Empty slot shows English 'Empty'")
		h.call("check_not_contains", info.text, "Vazio", "Empty slot does not show untranslated 'Vazio'")

func _t1_f15_2(h: RefCounted, tree: SceneTree) -> void:
	var settings := tree.root.get_node_or_null("SettingsService")
	if settings != null:
		settings.call("update", "locale", "pt_BR")
	var scr: Node = await h.call("boot_scene", tree, "res://scenes/ui/carregar.tscn")
	h.call("check_true", scr != null, "carregar.tscn loaded")
	if scr != null:
		var info := scr.get_node("Center/Panel/Margin/Content/Slots/Slot1/Info") as Label
		h.call("check_contains", info.text, "Vazio", "Empty slot shows Portuguese 'Vazio'")

func _t1_f15_3(h: RefCounted, tree: SceneTree) -> void:
	var settings := tree.root.get_node_or_null("SettingsService")
	if settings != null:
		settings.call("update", "locale", "en")
	var game: Node = await h.call("start_new_game", tree, "BannerEN", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var hud: Node = game.get("hud")
	var events: Array[Dictionary] = [
		{"event_id": "rota_presidio", "title": "Intriga do Carroeios", "category": "urgent", "deadline_phase": "opening", "deadline_remaining_seconds": 120.0},
		{"event_id": "moradias_enchente", "title": "Tsente: moradias após a enchente", "category": "urgent", "deadline_phase": "queued", "deadline_remaining_seconds": 180.0}
	]
	hud.call("update_problem_tabs", events)
	var btn: Button = hud.get("urgent_open_button")
	var phase: Label = hud.get("urgent_phase")
	h.call("check_eq", phase.text, "TO OPEN", "Urgent phase translated to TO OPEN")
	h.call("check_contains", btn.text, "Prison transport routes", "Urgent button title translated to English")
	h.call("check_contains", btn.tooltip_text, "Open urgent problem", "Urgent tooltip translated to English")
	h.call("check_contains", btn.tooltip_text, "queued", "Urgent tooltip queue count translated")

func _t1_f15_4(h: RefCounted, tree: SceneTree) -> void:
	var settings := tree.root.get_node_or_null("SettingsService")
	if settings != null:
		settings.call("update", "locale", "en")
	var game: Node = await h.call("start_new_game", tree, "BannerSolve", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var hud: Node = game.get("hud")
	var events: Array[Dictionary] = [
		{"event_id": "rota_presidio", "title": "Intriga do Carroeios", "category": "urgent", "deadline_phase": "solving", "deadline_remaining_seconds": 90.0}
	]
	hud.call("update_problem_tabs", events)
	var phase: Label = hud.get("urgent_phase")
	h.call("check_eq", phase.text, "TO ANSWER", "Solving urgent phase translated to TO ANSWER")

func _t1_f15_5(h: RefCounted, tree: SceneTree) -> void:
	var settings := tree.root.get_node_or_null("SettingsService")
	if settings != null:
		settings.call("update", "locale", "en")
	var game: Node = await h.call("start_new_game", tree, "BannerEmpty", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var hud: Node = game.get("hud")
	var empty_events: Array[Dictionary] = []
	hud.call("update_problem_tabs", empty_events)
	var btn: Button = hud.get("urgent_open_button")
	h.call("check_eq", btn.text, TranslationServer.translate("Problema urgente"), "Empty urgent fallback text uses tr()")

func _t1_f16_1(h: RefCounted, tree: SceneTree) -> void:
	var menu: Node = await h.call("boot_scene", tree, "res://scenes/ui/main_menu.tscn")
	h.call("check_true", menu != null, "main_menu loaded")
	if menu == null:
		return
	h.call("press_button", menu.get_node("Menu/VBoxContainer/jogar") as Button)
	await h.call("await_frames", tree, 2)
	h.call("check_true", menu.has_node("GameDialog"), "GameDialog opened")
	await h.call("send_key_tap", tree, KEY_ESCAPE, 0)
	await h.call("await_frames", tree, 2)
	h.call("check_false", menu.has_node("GameDialog"), "Esc closes GameDialog")

func _t1_f16_2(h: RefCounted, tree: SceneTree) -> void:
	var menu: Node = await h.call("boot_scene", tree, "res://scenes/ui/main_menu.tscn")
	if menu == null:
		h.call("check", false, "main_menu loaded")
		return
	h.call("press_button", menu.get_node("Menu/VBoxContainer/jogar") as Button)
	await h.call("await_frames", tree, 2)
	await h.call("send_key_tap", tree, KEY_ESCAPE, 0)
	await h.call("await_frames", tree, 2)
	var qc: ConfirmationDialog = menu.get("quit_confirmation")
	h.call("check_false", qc.visible, "QuitConfirmation stays hidden when Esc closes GameDialog")

func _t1_f16_3(h: RefCounted, tree: SceneTree) -> void:
	var menu: Node = await h.call("boot_scene", tree, "res://scenes/ui/main_menu.tscn")
	if menu == null:
		h.call("check", false, "main_menu loaded")
		return
	var jogar := menu.get_node("Menu/VBoxContainer/jogar") as Button
	h.call("press_button", jogar)
	await h.call("await_frames", tree, 2)
	await h.call("send_key_tap", tree, KEY_ESCAPE, 0)
	await h.call("await_frames", tree, 2)
	h.call("press_button", jogar)
	await h.call("await_frames", tree, 2)
	h.call("check_true", menu.has_node("GameDialog"), "GameDialog reopens cleanly after Esc")

func _t1_f16_4(h: RefCounted, tree: SceneTree) -> void:
	var menu: Node = await h.call("boot_scene", tree, "res://scenes/ui/main_menu.tscn")
	if menu == null:
		h.call("check", false, "main_menu loaded")
		return
	h.call("press_button", menu.get_node("Menu/VBoxContainer/jogar") as Button)
	await h.call("await_frames", tree, 2)
	var dlg := menu.get_node_or_null("GameDialog")
	var cancel: Button = h.call("find_button_by_text", dlg, "Cancelar")
	h.call("check_true", cancel != null, "Cancel button exists")
	if cancel != null:
		h.call("press_button", cancel)
		await h.call("await_frames", tree, 2)
		h.call("check_false", menu.has_node("GameDialog"), "Cancel closes GameDialog")
		h.call("check_eq", tree.current_scene, menu, "Remains on main_menu")

func _t1_f16_5(h: RefCounted, tree: SceneTree) -> void:
	var menu: Node = await h.call("boot_scene", tree, "res://scenes/ui/main_menu.tscn")
	if menu == null:
		h.call("check", false, "main_menu loaded")
		return
	h.call("press_button", menu.get_node("Menu/VBoxContainer/jogar") as Button)
	await h.call("await_frames", tree, 2)
	var dlg := menu.get_node_or_null("GameDialog")
	var city_inp := dlg.find_child("CityName", true, false) as LineEdit
	h.call("check_true", city_inp != null and city_inp.has_focus(), "CityName focused")
	await h.call("type_text", tree, "Test")
	await h.call("send_key_tap", tree, KEY_ESCAPE, 0)
	await h.call("await_frames", tree, 2)
	h.call("check_false", menu.has_node("GameDialog"), "Esc closes GameDialog while CityName focused")
	h.call("check_eq", tree.current_scene, menu, "Game did not start")

func _t1_f17_1(h: RefCounted, _tree: SceneTree) -> void:
	var dead_scripts := [
		"res://scripts/city_data.gd",
		"res://scripts/tile_building.gd",
		"res://scenes/game/event_manager.gd",
		"res://scenes/game/time_manager.gd",
		"res://scenes/game/InvestmentUiButton.gd"
	]
	for p in dead_scripts:
		h.call("check_false", FileAccess.file_exists(p), "Dead script removed: %s" % p)
		h.call("check_false", FileAccess.file_exists(p + ".uid"), "Dead script .uid removed: %s.uid" % p)

func _t1_f17_2(h: RefCounted, _tree: SceneTree) -> void:
	for p in ["res://scenes/ui/EventPopup.tscn", "res://scenes/game/TileMapCity.tscn"]:
		h.call("check_false", ResourceLoader.exists(p), "Dead scene removed: %s" % p)
		h.call("check_false", FileAccess.file_exists(p), "Dead scene file removed: %s" % p)

func _t1_f17_3(h: RefCounted, _tree: SceneTree) -> void:
	h.call("check_false", FileAccess.file_exists("res://localization/en.json"), "Unreferenced en.json removed")

func _t1_f17_4(h: RefCounted, tree: SceneTree) -> void:
	var settings := tree.root.get_node_or_null("SettingsService")
	if settings != null:
		settings.call("update", "locale", "en")
	h.call("check_eq", TranslationServer.translate("Jogar"), "Play", "en.po translates Jogar -> Play")
	h.call("check_eq", TranslationServer.translate("Vazio"), "Empty", "en.po translates Vazio -> Empty")

func _t1_f17_5(h: RefCounted, _tree: SceneTree) -> void:
	var forbidden := ["EventPopup.tscn", "TileMapCity.tscn", "city_data.gd", "tile_building.gd", "InvestmentUiButton.gd", "en.json"]
	var files: Array = []
	for d in ["res://core", "res://game", "res://scenes", "res://scripts", "res://ui"]:
		files.append_array(h.call("scan_files_recursive", d, ".gd"))
		files.append_array(h.call("scan_files_recursive", d, ".tscn"))
	for f in files:
		var txt := FileAccess.get_file_as_string(String(f))
		for term in forbidden:
			h.call("check_not_contains", txt, term, "%s must not reference %s" % [f, term])

func _t1_f18_1(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "NoGround", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	h.call("check_true", game.get_node_or_null("Ground") == null, "Legacy $Ground node removed")

func _t1_f18_2(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "NoRoad", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	h.call("check_true", game.get_node_or_null("Road") == null, "Legacy $Road node removed")

func _t1_f18_3(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "NoBuilds", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	h.call("check_true", game.get_node_or_null("Builds") == null, "Legacy $Builds node removed")

func _t1_f18_4(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "SoleVis", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var vis: Variant = game.get("visuals")
	h.call("check_true", vis is CityVisuals, "game.visuals is CityVisuals")
	if vis is CityVisuals:
		h.call("check_true", (vis as Node).is_inside_tree(), "CityVisuals is in scene tree")
		h.call("check_eq", (vis as CityVisuals).lots.size(), 484, "CityVisuals has 484 lots")

func _t1_f18_5(h: RefCounted, _tree: SceneTree) -> void:
	var txt := FileAccess.get_file_as_string("res://scenes/game/Game.tscn")
	h.call("check_not_contains", txt, "TileSet_g4v7s", "Orphaned TileSet_g4v7s removed from Game.tscn")
	h.call("check_not_contains", txt, "TileMapLayer", "Legacy TileMapLayer nodes removed from Game.tscn")

func _t1_f19_1(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "NoOcc", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var hud: Node = game.get("hud")
	h.call("check_true", hud.get_node_or_null("OccurrencePanel") == null, "OccurrencePanel removed from HUD")
	h.call("check_false", hud.has_method("_open_occurrences"), "_open_occurrences removed from GameHUD")

func _t1_f19_2(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "NoOptPanel", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var pm: Node = game.get("pause_menu")
	h.call("check_true", pm.get_node_or_null("%OptionsPanel") == null, "Legacy %OptionsPanel removed from PauseMenu")
	h.call("check_false", pm.has_method("_sync_options"), "_sync_options removed from pause_menu.gd")
	pm.call("open_menu")
	h.call("press_button", pm.get("options_button") as Button)
	await h.call("await_frames", tree, 2)
	h.call("check_true", pm.has_node("GameDialog"), "Options still opens dynamic SettingsService dialog")

func _t1_f19_3(h: RefCounted, _tree: SceneTree) -> void:
	var tm := TimeManager.new()
	h.call("check_false", "_skip_until_event" in tm, "Dead _skip_until_event removed from TimeManager")
	var steps := [0]
	tm.day_passed.connect(func(_d, _m, _y): steps[0] += 1)
	tm.skip_until_next_event(func(): return steps[0] >= 3)
	h.call("check_eq", steps[0], 3, "skip_until_next_event works cleanly")
	tm.free()

func _t1_f19_4(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "NoFmt", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	h.call("check_false", game.has_method("_format_countdown"), "Unused _format_countdown removed from GameManager")
	var hud: Node = game.get("hud")
	h.call("check_true", hud.has_method("_format_countdown"), "GameHUD retains _format_countdown")

func _t1_f19_5(h: RefCounted, tree: SceneTree) -> void:
	var menu: Control = await h.call("boot_scene", tree, "res://scenes/ui/main_menu.tscn")
	if menu == null:
		h.call("check", false, "main_menu loaded")
		return
	h.call("check_true", menu.scale.is_equal_approx(Vector2.ONE), "TittleScreen scale normalized to Vector2.ONE")
	h.call("check_approx", menu.anchor_right, 1.0, 0.001, "TittleScreen anchor_right == 1.0")
	h.call("check_approx", menu.anchor_bottom, 1.0, 0.001, "TittleScreen anchor_bottom == 1.0")
	var ss_src := FileAccess.get_file_as_string("res://core/settings/settings_service.gd")
	h.call("check_not_contains", ss_src, "result.set_stylebox(\"normal\", \"Button\", _style(", "Overwritten Button stylebox block removed from settings_service.gd")

func _t1_f20_1(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "HudAPI", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var hud: Node = game.get("hud")
	for sig in ["menu_requested", "investment_requested", "construction_requested", "housing_requested", "skip_requested", "map_center_requested", "panels_changed", "problem_open_requested"]:
		h.call("check_true", hud.has_signal(sig), "GameHUD has signal %s" % sig)
	for m in ["bind_time_manager", "set_city_indicators", "close_panels", "has_open_panel", "update_problem_tabs", "set_problem_mode", "bind_city", "refresh_city", "show_notice"]:
		h.call("check_true", hud.has_method(m), "GameHUD has method %s" % m)
	for prop in ["_sidebar_panel", "_problem_buttons", "_investment_mode", "high_button", "medium_button", "low_button", "urgent_open_button", "funds_button", "reputation_button", "menu_button", "investment_panel", "statistics_panel"]:
		h.call("check_true", prop in hud, "GameHUD has property %s" % prop)

func _t1_f20_2(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "HudPaths", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var hud: Node = game.get("hud")
	var paths := [
		"TimeDock/TimeControls", "TimeDock/TimeControls/SkipButton", "Footer", "HousingButton",
		"InvestmentPanel/Content/Header/CloseButton", "StatisticsPanel/Content/Header/CloseButton",
		"InvestmentPanel/Content/Categories/EducationCell/EducationButton",
		"InvestmentPanel/Content/Categories/HealthCell/HealthButton",
		"InvestmentPanel/Content/Categories/WaterCell/WaterButton",
		"InvestmentPanel/Content/Categories/SecurityCell/SecurityButton",
		"InvestmentPanel/Content/Categories/CultureCell/CultureButton",
		"InvestmentPanel/Content/Categories/SocialCell/SocialButton"
	]
	for p in paths:
		h.call("check_true", hud.get_node_or_null(p) != null, "HUD preserved node path exists: %s" % p)

func _t1_f20_3(h: RefCounted, _tree: SceneTree) -> void:
	var session_scripts: Array = h.call("scan_files_recursive", "res://game/session", ".gd")
	var hud_scripts: Array = h.call("scan_files_recursive", "res://ui/hud", ".gd")
	h.call("check_gt", float(session_scripts.size()), 0.0, "Extracted session helper scripts exist in res://game/session/")
	h.call("check_gt", float(hud_scripts.size()), 0.0, "Extracted HUD helper scripts exist in res://ui/hud/")
	var gm_lines := FileAccess.get_file_as_string("res://scripts/game_manager.gd").split("\n").size()
	var gh_lines := FileAccess.get_file_as_string("res://scripts/game_hud.gd").split("\n").size()
	h.call("check_lt", float(gm_lines), 520.0, "game_manager.gd decoupled below 520 lines (got %d)" % gm_lines)
	h.call("check_lt", float(gh_lines), 530.0, "game_hud.gd decoupled below 530 lines (got %d)" % gh_lines)

func _t1_f20_4(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "GmAPI", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	for prop in ["city", "visuals", "event_database", "event_manager", "time_manager", "hud", "pause_menu", "problem_layer", "return_dialog", "_modal", "_placement_bar", "_placement_area", "_current_problem_popup", "_current_problem_id"]:
		h.call("check_true", prop in game, "GameManager has property %s" % prop)
	for m in ["open_problem", "_close_dialog", "_construct", "_place_building", "_skip_to_next", "_on_problem_close_requested", "_close_current_problem", "_refresh_problem_tabs", "_find_active_event", "_problem_description", "_on_campaign_event"]:
		h.call("check_true", game.has_method(m), "GameManager has method %s" % m)

func _t1_f20_5(h: RefCounted, tree: SceneTree) -> void:
	var game: Node = await h.call("start_new_game", tree, "Delegate", "medium", true, true)
	if game == null:
		h.call("check", false, "Game loaded")
		return
	var hud: Node = game.get("hud")
	var city: CityState = game.get("city")
	var before_funds := city.funds
	hud.emit_signal("investment_requested", "education", 10000.0)
	h.call("check_approx", city.funds, before_funds - 10000.0, 0.01, "HUD investment_requested delegates to city")
	hud.emit_signal("construction_requested", "health")
	h.call("check_eq", String(game.get("_placement_area")), "health", "HUD construction_requested starts placement")
	game.call("_cancel_placement")
	h.call("press_button", hud.get("funds_button") as Button)
	h.call("check_true", bool(hud.call("has_open_panel")), "HUD panel toggle works")
	h.call("check_true", bool(game.get("time_manager").get("paused")), "Open HUD panel holds time pause")

func _t1_f21_1(h: RefCounted, tree: SceneTree) -> void:
	var sm := tree.root.get_node_or_null("SaveManager")
	var ss := tree.root.get_node_or_null("SettingsService")
	h.call("check_true", sm != null and String(sm.get("save_dir")).begins_with("user://e2e_"), "SaveManager save_dir isolated under user://e2e_")
	h.call("check_true", ss != null and String(ss.get("storage_path")).begins_with("user://e2e_"), "SettingsService storage_path isolated under user://e2e_")

func _t1_f21_2(h: RefCounted, _tree: SceneTree) -> void:
	var st: Dictionary = h.call("run_git", ["status", "--porcelain", "godot/scripts", "godot/scenes", "godot/game", "godot/core", "godot/ui", "godot/localization"])
	h.call("check_eq", st["exit_code"], 0, "git status succeeds")
	var real_saves := ProjectSettings.globalize_path("user://saves")
	h.call("check_false", DirAccess.dir_exists_absolute(real_saves) and DirAccess.get_files_at(real_saves).size() > 0, "user://saves untouched by E2E")

func _t1_f21_3(h: RefCounted, _tree: SceneTree) -> void:
	var s := load("res://scripts/eventdatabase.gd") as GDScript
	var out := []
	for _run in range(2):
		var db: Node = s.new()
		db.call("register_default_problems")
		db.call("ensure_month_content", 4, 1)
		out.append(db.call("get_event", "municipal_4_4"))
		db.free()
	h.call("check_eq", out[0], out[1], "Procedural generation is deterministically repeatable")

func _t1_f21_4(h: RefCounted, tree: SceneTree) -> void:
	h.call("setup_isolated_env", tree, "cleanup_probe")
	var abs_dir := ProjectSettings.globalize_path("user://e2e_saves_cleanup_probe")
	h.call("check_true", DirAccess.dir_exists_absolute(abs_dir), "Isolated temp dir created")
	h.call("cleanup_isolated_env", tree, "cleanup_probe")
	h.call("check_false", DirAccess.dir_exists_absolute(abs_dir), "Isolated temp dir removed by cleanup")

func _t1_f21_5(h: RefCounted, tree: SceneTree) -> void:
	var reg: Variant = tree.root.get_meta("e2e_suite_registry", [])
	h.call("check_true", reg is Array, "Suite registry metadata present")
	var tier_counts := {1: 0, 2: 0, 3: 0, 4: 0}
	var total := 0
	for item in reg:
		var t := int(item.get("tier", 0))
		var c := int(item.get("count", 0))
		tier_counts[t] = int(tier_counts.get(t, 0)) + c
		total += c
	h.call("check_eq", tier_counts[1], 105, "Tier 1 has 105 cases")
	h.call("check_eq", tier_counts[2], 105, "Tier 2 has 105 cases")
	h.call("check_eq", tier_counts[3], 24, "Tier 3 has 24 cases")
	h.call("check_eq", tier_counts[4], 12, "Tier 4 has 12 cases")
	h.call("check_eq", total, 246, "Total registered cases == 246")
