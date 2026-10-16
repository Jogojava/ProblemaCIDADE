extends SceneTree

var checks := 0
var failures := 0
var output: String
var game: Node

func _initialize() -> void:
	output = ProjectSettings.globalize_path("user://verification_screenshots")
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--capture-dir="):
			output = argument.trim_prefix("--capture-dir=")
	DirAccess.make_dir_recursive_absolute(output)
	call_deferred("_run")

func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		print("FAIL: ", message)

func _run() -> void:
	var save := root.get_node("SaveManager")
	save.save_dir = "user://verification_saves_visual_20261016"
	for slot in range(1, 4):
		save.delete_slot(slot)
	root.size = Vector2i(1280, 720)
	change_scene_to_file("res://scenes/ui/main_menu.tscn")
	await _frames()
	var design_settings := root.get_node("SettingsService")
	var menu_play: Button = current_scene.get_node("Menu/VBoxContainer/jogar")
	check(menu_play.get_theme_stylebox("normal").texture.resource_path.ends_with("debora/play.png"), "Menu usa a arte Jogar da Debora.")
	var sound: Button = current_scene.get_node("SoundButton")
	var was_muted: bool = design_settings.values.muted
	await _click(sound)
	check(bool(design_settings.values.muted) != was_muted, "Botao desenhado alterna o som.")
	check(sound.get_theme_stylebox("normal").texture.resource_path.ends_with("sound_off.png" if not was_muted else "sound_on.png"), "Arte do som acompanha o estado.")
	check(current_scene.get_global_rect().encloses(sound.get_global_rect()), "Botao de som fica inteiro na tela.")
	await _click(sound)
	design_settings.update("locale", "en")
	check(menu_play.get_theme_color("font_color").a > 0.9, "Menu ingles exibe o texto traduzido.")
	check(menu_play.get_theme_stylebox("normal").texture.resource_path.ends_with("button_blue.png"), "Menu ingles usa moldura sem texto portugues.")
	design_settings.update("locale", "pt_BR")
	await _frames()
	check(menu_play.get_theme_color("font_color").a == 0.0, "Texto nativo nao duplica a legenda da arte portuguesa.")
	await _capture("01-menu.png")
	await _click(current_scene.get_node("Menu/VBoxContainer/jogar"))
	check(current_scene.has_node("GameDialog"), "Jogar abre configuração de partida.")
	await _capture("02-nova-gestao.png")
	var start := _find_button(current_scene.get_node("GameDialog"), "Começar")
	check(start != null, "Começar disponível.")
	if start != null:
		await _click(start)
	await _frames()
	game = current_scene
	if game.scene_file_path != "res://scenes/game/Game.tscn":
		check(false, "Clique abre a partida.")
		quit(1)
		return
	check(game._modal != null, "Orientação inicial visível.")
	await _capture("03-instrucoes.png")
	await _click(_find_button(game._modal, "Iniciar mandato"))
	await _frames()
	game.time_manager.pause_game()
	for pair in [[game.hud.high_button, "important"], [game.hud.medium_button, "common"], [game.hud.low_button, "optional"], [game.hud.urgent_open_button, "urgent"]]:
		check(pair[0].icon.resource_path.ends_with("debora/" + pair[1] + ".png"), "Ocorrencia usa arte da categoria " + pair[1])
	await _capture("04-cidade.png")
	var controls: HBoxContainer = game.hud.get_node("TimeDock/TimeControls")
	var skip := controls.get_node("SkipButton") as Button
	check(controls.get_child_count() == 5, "Avanço é o quinto controle da mesma linha.")
	check(skip.text.is_empty() and skip.icon != null, "Avanço usa apenas ícone.")
	check(skip.tooltip_text.contains("próxima ocorrência"), "Descrição do avanço está no tooltip.")
	check(game.hud.get_node("Footer").size.y <= 160.1, "Barra inferior mantém altura compacta.")
	for button in controls.get_children():
		check(is_equal_approx(button.position.y, skip.position.y), "Controles de tempo compartilham a linha.")
	await _hover(skip)
	await create_timer(0.65).timeout
	await _capture("19-avanco-tooltip.png")
	# Reproduce the screenshot with populated categories.
	for category in ["optional", "common", "important"]:
		var definitions: Array[Dictionary] = game.event_database.get_events_by_category(category)
		for i in range(mini(definitions.size(), 2)):
			var item: Dictionary = definitions[i]
			game.event_manager.active_events.append(game.event_database.build_runtime_event(item.id, 1, 1, 1))
	game._refresh_problem_tabs()
	await _frames()
	await _hover(game.hud.low_button)
	await create_timer(0.65).timeout
	check(game.hud._sidebar_panel.visible, "Categoria abre lista.")
	var visible_buttons: Array[Button] = []
	for button in game.hud._problem_buttons.values():
		if button.visible:
			visible_buttons.append(button)
	check(visible_buttons.size() == 2, "Lista mostra apenas a categoria escolhida.")
	for button in visible_buttons:
		check(button.get_parent() is VBoxContainer, "Lista usa ordenação por contêiner.")
	check(game.hud.theme.get_color("font_color", "TooltipLabel").get_luminance() > 0.8, "Tooltip tem texto claro.")
	await _capture("05-ocorrencias-tooltip.png")
	if not visible_buttons.is_empty():
		await _click(visible_buttons[0])
	check(game._current_problem_popup != null, "Clique na lista abre problema.")
	await _capture("06-problema.png")
	await _verify_problem_controls("1280")
	if game._current_problem_popup != null:
		var definition: Dictionary = game.event_database.get_event(game._current_problem_id)
		var correct := String(definition.get("correct_answer", ""))
		var options: Array = definition.payload.get("options", [])
		for i in range(options.size()):
			if String(options[i].id) == correct:
				await _click(game._current_problem_popup._get_option_buttons()[i])
				break
	check(game._modal != null, "Clique em resposta exibe explicação.")
	await _capture("07-consequencias.png")
	if game._modal != null:
		await _click(_find_button(game._modal, "Continuar gestão"))
	await _click(game.hud.funds_button)
	check(game.hud.investment_panel.visible, "Botão de dinheiro abre investimentos.")
	await _capture("08-investimentos.png")
	var before: float = game.city.funds
	await _click(game.hud.get_node("InvestmentPanel/Content/Categories/HealthCell/HealthButton"))
	check(game.city.funds < before, "Clique no investimento aplica custo real.")
	game.hud._investment_mode.select(1)
	await _click(game.hud.get_node("InvestmentPanel/Content/Categories/EducationCell/EducationButton"))
	check(game.city.projects.size() == 1, "Clique inicia construção.")
	await _click(game.hud.get_node("InvestmentPanel/Content/Header/CloseButton"))
	for _month in range(12):
		game.city.advance_month()
	await _click(game.hud.reputation_button)
	check(game.hud.statistics_panel.visible, "Botão de reputação abre histórico e projeções.")
	await _capture("09-projecoes.png")
	await _click(game.hud.get_node("StatisticsPanel/Content/Header/CloseButton"))
	await _click(game.hud.menu_button)
	check(game.pause_menu.visible, "Menu de pausa abre por clique.")
	await _capture("10-pausa.png")
	await _click(game.pause_menu.saves_button)
	check(game._modal != null, "Saves abre seleção explícita de slots.")
	await _capture("11-slots.png")
	await _click(_find_button(game._modal, "Slot 1 · Vazio"))
	check(not save.read_slot(1).is_empty(), "Clique grava o slot escolhido.")
	await _click(_find_button(game._modal, "Voltar"))
	await _click(game.pause_menu.options_button)
	await _capture("12-opcoes.png")
	game.pause_menu.back_or_resume()
	await _click(game.pause_menu.resume_button)
	root.size = Vector2i(1024, 768)
	await _frames()
	await _capture("13-cidade-1024.png")
	await _click(game.hud.funds_button)
	await _capture("14-investimentos-1024.png")
	await _click(game.hud.get_node("InvestmentPanel/Content/Header/CloseButton"))
	game.city.completed_months = 96
	game.city.outcome = "completed"
	game.city.term = 2
	game._on_campaign_event("completed")
	await _capture("15-final-1024.png")
	var settings := root.get_node("SettingsService")
	settings.update("locale", "en")
	root.get_node("SaveManager").start_new("English check", "easy")
	change_scene_to_file("res://scenes/game/Game.tscn")
	await _frames()
	game = current_scene
	await _capture("16-english-briefing.png")
	game._close_dialog()
	await _frames()
	game.event_manager.active_events.append(game.event_database.build_runtime_event("municipal_1_4", 1, 1, 1))
	game.open_problem("municipal_1_4")
	await _frames()
	check(game._current_problem_popup.description_label.text.contains("shortest route"), "Enunciado em inglês.")
	check(game._current_problem_popup.illustration_panel.get_child_count() > 1, "Minigame de rotas inclui grafo.")
	await _capture("17-english-graph.png")
	await _verify_problem_controls("1024")
	settings.update("locale", "pt_BR")
	var old_values: Dictionary = settings.values.duplicate(true)
	settings.test_mode = false
	settings.values.mode = 0
	settings.values.resolution = 0
	settings.values.quality = 0
	settings.values.master = 25.0
	settings.values.muted = true
	settings.apply_settings()
	await _frames()
	check(DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED, "Modo janela aplicado.")
	check(DisplayServer.window_get_size() == Vector2i(1280, 720), "Resolução aplicada.")
	check(root.canvas_item_default_texture_filter == Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST, "Qualidade baixa aplicada.")
	check(AudioServer.is_bus_mute(AudioServer.get_bus_index("Master")), "Silenciamento aplicado.")
	check(is_equal_approx(db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))), 0.25), "Volume aplicado ao barramento real.")
	settings.values.mode = 2
	settings.values.quality = 1
	settings.apply_settings()
	await _frames()
	check(DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_BORDERLESS), "Janela sem borda aplicada.")
	check(root.canvas_item_default_texture_filter == Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_LINEAR, "Qualidade alta aplicada.")
	settings.values.mode = 1
	settings.apply_settings()
	await _frames()
	check(DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN, "Tela cheia aplicada.")
	settings.play_feedback(true)
	await create_timer(0.4).timeout
	settings.values = old_values
	settings.values.mode = 0
	settings.apply_settings()
	var old_path := String(settings.storage_path)
	settings.storage_path = "user://verification_settings_20261016.cfg"
	settings.update("music", 37.0)
	var stored := ConfigFile.new()
	check(stored.load(settings.storage_path) == OK and float(stored.get_value("settings", "music", 0)) == 37.0, "Preferências persistem no arquivo de configurações.")
	DirAccess.remove_absolute(settings.storage_path)
	settings.storage_path = old_path
	settings.values = old_values
	settings.test_mode = true
	settings.apply_settings()
	change_scene_to_file("res://scenes/ui/main_menu.tscn")
	await _frames()
	await _click(current_scene.get_node("Menu/VBoxContainer/continuar"))
	check(current_scene.scene_file_path == "res://scenes/ui/carregar.tscn", "Menu abre tela de partidas salvas.")
	await _capture("18-carregar.png")
	var row := current_scene.get_node("Center/Panel/Margin/Content/Slots/Slot1")
	check(not row.get_node("LoadButton").disabled, "Slot salvo pode ser carregado.")
	await _click(row.get_node("LoadButton"))
	check(current_scene.scene_file_path == "res://scenes/game/Game.tscn", "Clique no slot carrega a partida.")
	game = current_scene
	check(game.city.projects.size() == 1, "Carregamento pela interface preserva a obra.")
	for slot in range(1, 4):
		save.delete_slot(slot)
	print("Renderização: %d verificações, %d falhas. END" % [checks, failures])
	quit(0 if failures == 0 else 1)

func _find_button(node: Node, text_value: String) -> Button:
	if node == null:
		return null
	if node is Button and node.text == text_value:
		return node
	for child in node.get_children():
		var found := _find_button(child, text_value)
		if found != null:
			return found
	return null

func _verify_problem_controls(suffix: String) -> void:
	var popup: ProblemTemplate = game._current_problem_popup
	if popup == null:
		check(false, "Problema aberto para verificar rascunho e X.")
		return
	var id := String(game._current_problem_id)
	var before_count: int = game.city.solved_count
	var before_funds: float = game.city.funds
	var before_reputation: float = game.city.reputation
	var manually_paused: bool = game.time_manager.get_save_data().paused
	popup.answer_input.text = "123,5"
	await _click(popup.get_node("Center/Panel/Margin/Content/Body/BoardButton"))
	check(popup.board_overlay.visible, "Botão abre rascunho.")
	var area := popup.drawing_area
	check(area.get_global_rect().is_equal_approx(popup.get_global_rect()), "Rascunho cobre toda a tela, além da janela do problema.")
	for corner in [Vector2(0.025, 0.035), Vector2(0.93, 0.035), Vector2(0.025, 0.91), Vector2(0.93, 0.91)]:
		await _draw_stroke(area, area.size * corner, area.size * corner + Vector2(42, 28))
	check(area.strokes.size() == 4, "Desenho funciona nos quatro cantos.")
	check(game.city.solved_count == before_count, "Desenhar sobre o problema não aciona respostas.")
	await _capture("20-rascunho-" + suffix + ".png")
	await _click(popup.get_node("BoardOverlay/Toolbar/Content/CloseButton"))
	check(not popup.board_overlay.visible, "Voltar ao problema fecha apenas o rascunho.")
	await _click(popup.get_node("Center/Panel/Margin/Content/Header/CloseButton"))
	check(game._current_problem_popup == null, "X fecha a janela do problema.")
	check(not game._find_active_event(id).is_empty(), "X mantém o problema pendente.")
	check(game.city.solved_count == before_count and game.city.funds == before_funds and game.city.reputation == before_reputation, "X não altera pontuação, saldo ou reputação.")
	check(game.time_manager.paused == manually_paused, "X preserva a pausa manual anterior.")
	var category: String = game._find_active_event(id).category
	var category_button: Button = {"optional": game.hud.low_button, "common": game.hud.medium_button, "important": game.hud.high_button}.get(category, game.hud.low_button)
	await _hover(category_button)
	await _click(game.hud._problem_buttons[id])
	popup = game._current_problem_popup
	check(popup != null, "Problema pode ser reaberto pela barra lateral.")
	if popup == null:
		return
	check(popup.drawing_area.strokes.size() == 4 and popup.answer_input.text == "123,5", "Reabrir restaura rascunho e texto digitado.")
	await _click(popup.get_node("Center/Panel/Margin/Content/Body/BoardButton"))
	await _click(popup.get_node("BoardOverlay/Toolbar/Content/ClearButton"))
	check(popup.drawing_area.strokes.is_empty(), "Limpar remove os traços.")
	await _click(popup.get_node("BoardOverlay/Toolbar/Content/CloseButton"))

func _draw_stroke(area: Control, from: Vector2, to: Vector2) -> void:
	var transform := root.get_screen_transform() * area.get_global_transform_with_canvas()
	var start := transform * from
	var end := transform * to
	var motion := InputEventMouseMotion.new()
	motion.position = start
	motion.global_position = start
	root.push_input(motion, false)
	await process_frame
	var press := InputEventMouseButton.new()
	press.position = start
	press.global_position = start
	press.button_index = MOUSE_BUTTON_LEFT
	press.button_mask = MOUSE_BUTTON_MASK_LEFT
	press.pressed = true
	root.push_input(press, false)
	await process_frame
	var drawing := InputEventMouseMotion.new()
	drawing.position = end
	drawing.global_position = end
	drawing.relative = end - start
	drawing.button_mask = MOUSE_BUTTON_MASK_LEFT
	root.push_input(drawing, false)
	await process_frame
	var release := InputEventMouseButton.new()
	release.position = end
	release.global_position = end
	release.button_index = MOUSE_BUTTON_LEFT
	release.pressed = false
	root.push_input(release, false)
	await _frames()

func _frames() -> void:
	await create_timer(0.05).timeout
	for _i in range(4):
		await process_frame

func _hover(control: Control) -> void:
	var point := root.get_screen_transform() * control.get_global_transform_with_canvas() * (control.size / 2)
	var motion := InputEventMouseMotion.new()
	motion.position = point
	motion.global_position = point
	root.push_input(motion, false)
	await _frames()

func _click(control: Control) -> void:
	if control == null:
		check(false, "Controle de clique não encontrado.")
		return
	await _hover(control)
	var point := root.get_screen_transform() * control.get_global_transform_with_canvas() * (control.size / 2)
	for pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.position = point
		event.global_position = point
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		event.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
		root.push_input(event, false)
		await process_frame
	await _frames()

func _capture(filename: String) -> void:
	await _frames()
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	check(image != null and not image.is_empty(), "Captura renderizada: " + filename)
	if image != null:
		check(image.save_png(output.path_join(filename)) == OK, "Captura gravada: " + filename)
