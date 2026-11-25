extends Node

signal changed()

const PATH := "user://settings.cfg"
const PLAYER_ICON_PATH := "user://player_icon.png"
const DEFAULT_PLAYER_ICON_PATH := "res://assets/ui/hud/player icn.png"
const TRACK_MAIN_MENU := "res://assets/soundtrack/src_aud_lobby-classic-game.mp3"
const TRACK_CITY_1 := "res://assets/soundtrack/city_1_st.mp3"
const TRACK_CITY_2 := "res://assets/soundtrack/city_2_st.mp3"
const TRACK_PROBLEM_OPTIONAL := "res://assets/soundtrack/optionalproblem_st.mp3"
const TRACK_PROBLEM_COMMON := "res://assets/soundtrack/commonproblem_st.mp3"
const TRACK_PROBLEM_PRIORITY := "res://assets/soundtrack/priorityproblem_st.mp3"
const TRACK_PROBLEM_URGENT := "res://assets/soundtrack/urgentproblem_st.mp3"
const SPECIAL_KAHOOT_PROBLEM_ID := "aura_travessia"
const MUSIC_TRANSITION_SECONDS := 0.85
const SILENT_DB := -80.0
const SFX_BIG_CLICK := "res://assets/sound_effects/bigclick_SE.wav"
const SFX_LITTLE_CLICK := "res://assets/sound_effects/littleclick_SE.wav"
const SFX_SPEED_NORMAL := "res://assets/sound_effects/spaced_double_click_SE.wav"
const SFX_SPEED_FAST := "res://assets/sound_effects/normal_double_click_SE.wav"
const SFX_SPEED_VERY_FAST := "res://assets/sound_effects/fast_double_click_SE.wav"
const SFX_BUILDING := "res://assets/sound_effects/building_SE.wav"
const SFX_SUCCESS := "res://assets/sound_effects/Success_SE.wav"
const SFX_FAIL := "res://assets/sound_effects/Fail_SE.wav"
const SFX_URGENT := "res://assets/sound_effects/urgent_SE.wav"
const SFX_WIND := "res://assets/sound_effects/wind_SE.wav"
const WIND_NORMAL_DB := -15.0
const WIND_DUCKED_DB := -24.0

var storage_path := PATH
var values := {"master": 80.0, "music": 65.0, "effects": 80.0, "muted": false, "mode": 0, "resolution": 0, "quality": 1, "locale": "pt_BR", "pause_unfocused": true, "dark_mode": false}
var game_theme: Theme
var test_mode := false
var _music: AudioStreamPlayer
var _music_standby: AudioStreamPlayer
var _music_tween: Tween
var _music_cache: Dictionary = {}
var _sfx_cache: Dictionary = {}
var _wind_player: AudioStreamPlayer
var _wind_tween: Tween
var _wind_active := false
var _current_track_path := ""
var _music_mode := "menu"
var _city_track_index := 0
var _city_playback_position := 0.0
var _player_icon_texture: Texture2D = null
var _player_icon_loaded := false
var _default_player_icon_texture: Texture2D = null

func _ready() -> void:
	test_mode = OS.get_cmdline_user_args().has("--test")
	var config := ConfigFile.new()
	if not test_mode and config.load(storage_path) == OK:
		if not config.has_section("settings"):
			values.master = config.get_value("audio", "volume", values.master)
			values.mode = 1 if bool(config.get_value("display", "fullscreen", false)) else 0
		for key in values:
			values[key] = config.get_value("settings", key, values[key])
	game_theme = make_theme()
	_load_translations()
	_ensure_bus("Music")
	_ensure_bus("Effects")
	apply_settings()
	get_tree().node_added.connect(_on_node_added)
	if not test_mode:
		_music = _create_music_player()
		_music_standby = _create_music_player()
		call_deferred("attach_button_sfx", get_tree().root)
	play_main_menu_music(true)

func _exit_tree() -> void:
	if _music_tween != null and is_instance_valid(_music_tween):
		_music_tween.kill()
		_music_tween = null
	if _wind_tween != null and is_instance_valid(_wind_tween):
		_wind_tween.kill()
		_wind_tween = null
	_music_cache.clear()
	_sfx_cache.clear()


func _create_music_player() -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.bus = "Music"
	add_child(player)
	player.finished.connect(_on_music_player_finished.bind(player))
	return player

func _get_music_stream(track_path: String) -> AudioStream:
	if _music_cache.has(track_path):
		return _music_cache[track_path]
	var loaded := load(track_path)
	if loaded is AudioStream:
		_music_cache[track_path] = loaded
		return loaded
	push_warning("Trilha sonora não encontrada ou inválida: %s" % track_path)
	return null

func get_current_track_path() -> String:
	return _current_track_path

func get_problem_track_path(event_id: String, category: String) -> String:
	if event_id == SPECIAL_KAHOOT_PROBLEM_ID:
		return TRACK_MAIN_MENU
	match category:
		"optional":
			return TRACK_PROBLEM_OPTIONAL
		"common":
			return TRACK_PROBLEM_COMMON
		"important":
			return TRACK_PROBLEM_PRIORITY
		"urgent":
			return TRACK_PROBLEM_URGENT
		_:
			return TRACK_PROBLEM_COMMON

func play_main_menu_music(immediate: bool = false) -> void:
	_music_mode = "menu"
	_city_track_index = 0
	_city_playback_position = 0.0
	_transition_to_track(TRACK_MAIN_MENU, 0.0, immediate)

func play_city_music(reset_playlist: bool = false) -> void:
	if reset_playlist:
		_city_track_index = 0
		_city_playback_position = 0.0
	_music_mode = "city"
	var track_path := _get_city_track_path(_city_track_index)
	_transition_to_track(track_path, _city_playback_position, false)

func play_problem_music(event_id: String, category: String) -> void:
	if _music_mode == "city" and _music != null and _music.playing:
		_city_playback_position = _music.get_playback_position()
	_music_mode = "problem"
	var track_path := get_problem_track_path(event_id, category)
	_transition_to_track(track_path, 0.0, false)

func _get_city_track_path(index: int) -> String:
	return TRACK_CITY_1 if (index % 2) == 0 else TRACK_CITY_2

func _transition_to_track(track_path: String, start_position: float = 0.0, immediate: bool = false) -> void:
	if track_path.is_empty():
		return
	if _current_track_path == track_path and (test_mode or (_music != null and _music.playing)):
		return
	_current_track_path = track_path
	if test_mode or _music == null or _music_standby == null:
		return
	var stream := _get_music_stream(track_path)
	if stream == null:
		return
	var safe_start := maxf(0.0, start_position)
	var stream_length := stream.get_length()
	if stream_length > 0.0 and safe_start >= stream_length - 0.1:
		safe_start = 0.0
	if _music_tween != null and is_instance_valid(_music_tween):
		_music_tween.kill()
	if immediate or not _music.playing:
		_music_standby.stop()
		_music.stream = stream
		_music.volume_db = 0.0
		_music.play(safe_start)
		return

	var outgoing := _music
	var incoming := _music_standby
	_music = incoming
	_music_standby = outgoing

	var outgoing_start_linear := db_to_linear(outgoing.volume_db) if outgoing.playing else 0.0
	incoming.stop()
	incoming.stream = stream
	incoming.volume_db = SILENT_DB
	incoming.play(safe_start)

	_music_tween = create_tween()
	_music_tween.set_trans(Tween.TRANS_LINEAR)
	_music_tween.tween_method(func(progress: float) -> void:
		var clamped := clampf(progress, 0.0, 1.0)
		var eased := clamped * clamped * (3.0 - 2.0 * clamped)
		var in_linear := sin(eased * PI * 0.5)
		var out_linear := outgoing_start_linear * cos(eased * PI * 0.5)
		incoming.volume_db = SILENT_DB if in_linear <= 0.0001 else linear_to_db(in_linear)
		if outgoing.playing:
			outgoing.volume_db = SILENT_DB if out_linear <= 0.0001 else linear_to_db(out_linear)
	, 0.0, 1.0, MUSIC_TRANSITION_SECONDS)
	_music_tween.tween_callback(func() -> void:
		outgoing.stop()
		outgoing.volume_db = 0.0
		incoming.volume_db = 0.0
	)

func _on_music_player_finished(player: AudioStreamPlayer) -> void:
	if player != _music:
		return
	if _music_mode == "city":
		_city_track_index = (_city_track_index + 1) % 2
		_city_playback_position = 0.0
		var next_track := _get_city_track_path(_city_track_index)
		_current_track_path = ""
		_transition_to_track(next_track, 0.0, false)
	else:
		player.play()


func _ensure_bus(bus_name: String) -> void:
	if AudioServer.get_bus_index(bus_name) == -1:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count - 1, bus_name)
		AudioServer.set_bus_send(AudioServer.bus_count - 1, "Master")

func _on_node_added(node: Node) -> void:
	if node is Control and (node.get_parent() is CanvasLayer or not node.get_parent() is Control):
		node.theme = game_theme
	if node is AudioStreamPlayer:
		if node.bus == "Master":
			node.bus = "Music"
	if node is BaseButton and not test_mode:
		_connect_button_sfx(node as BaseButton)
	elif node is AcceptDialog and not test_mode:
		_connect_dialog_buttons(node as AcceptDialog)

func attach_button_sfx(root_node: Node) -> void:
	if test_mode or root_node == null or not is_instance_valid(root_node):
		return
	if root_node is BaseButton:
		_connect_button_sfx(root_node as BaseButton)
	elif root_node is AcceptDialog:
		_connect_dialog_buttons(root_node as AcceptDialog)
	for child in root_node.get_children():
		attach_button_sfx(child)

func _connect_button_sfx(button: BaseButton) -> void:
	if not button.pressed.is_connected(_on_ui_button_pressed):
		button.pressed.connect(_on_ui_button_pressed.bind(button))

func _connect_dialog_buttons(dialog: AcceptDialog) -> void:
	var ok_btn := dialog.get_ok_button()
	if ok_btn != null:
		_connect_button_sfx(ok_btn)
	if dialog is ConfirmationDialog:
		var cancel_btn := (dialog as ConfirmationDialog).get_cancel_button()
		if cancel_btn != null:
			_connect_button_sfx(cancel_btn)

func _get_sfx_stream(sfx_path: String) -> AudioStream:
	if _sfx_cache.has(sfx_path):
		return _sfx_cache[sfx_path]
	var loaded := load(sfx_path)
	if loaded is AudioStream:
		_sfx_cache[sfx_path] = loaded
		return loaded
	push_warning("Efeito sonoro não encontrado ou inválido: %s" % sfx_path)
	return null

func play_sfx(sfx_path: String, volume_db: float = 0.0, pitch_scale: float = 1.0) -> void:
	if test_mode or sfx_path.is_empty():
		return
	var stream := _get_sfx_stream(sfx_path)
	if stream == null:
		return
	var player := AudioStreamPlayer.new()
	player.bus = "Effects"
	player.stream = stream
	player.volume_db = volume_db
	player.pitch_scale = clampf(pitch_scale, 0.5, 2.0)
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()

func play_big_click() -> void:
	play_sfx(SFX_BIG_CLICK, -2.0, randf_range(0.98, 1.02))

func play_little_click(pitch_scale: float = -1.0) -> void:
	var pitch := pitch_scale if pitch_scale > 0.0 else randf_range(0.97, 1.03)
	play_sfx(SFX_LITTLE_CLICK, -3.0, pitch)

func play_speed_sfx(speed: int) -> void:
	match speed:
		TimeManager.Speed.FAST:
			play_sfx(SFX_SPEED_FAST, -2.0, 1.0)
		TimeManager.Speed.VERY_FAST:
			play_sfx(SFX_SPEED_VERY_FAST, -2.0, 1.0)
		_:
			play_sfx(SFX_SPEED_NORMAL, -2.0, 1.0)

func play_building_sfx() -> void:
	play_sfx(SFX_BUILDING, -2.0, randf_range(0.96, 1.04))

func play_urgent_alert_sfx() -> void:
	if test_mode:
		return
	play_sfx(SFX_URGENT, -1.0, 1.0)

func play_problem_notice_sfx(category: String) -> void:
	if test_mode:
		return
	match category:
		"urgent":
			play_urgent_alert_sfx()
		"important":
			play_sfx(SFX_LITTLE_CLICK, -3.5, 1.18)
		"optional":
			play_sfx(SFX_LITTLE_CLICK, -5.5, 1.04)

func play_feedback(correct: bool) -> void:
	if test_mode:
		return
	play_sfx(SFX_SUCCESS if correct else SFX_FAIL, -1.0, 1.0)

func start_city_ambience() -> void:
	if test_mode:
		return
	var stream := _get_sfx_stream(SFX_WIND)
	if stream == null:
		return
	if _wind_player == null or not is_instance_valid(_wind_player):
		_wind_player = AudioStreamPlayer.new()
		_wind_player.bus = "Effects"
		_wind_player.stream = stream
		_wind_player.volume_db = SILENT_DB
		add_child(_wind_player)
		_wind_player.finished.connect(func() -> void:
			if _wind_active and is_instance_valid(_wind_player):
				_wind_player.play())
	_wind_active = true
	if not _wind_player.playing:
		_wind_player.volume_db = SILENT_DB
		_wind_player.play()
	_tween_wind_volume(WIND_NORMAL_DB, 0.9)

func set_city_ambience_ducked(ducked: bool) -> void:
	if test_mode or not _wind_active or _wind_player == null or not is_instance_valid(_wind_player):
		return
	_tween_wind_volume(WIND_DUCKED_DB if ducked else WIND_NORMAL_DB, 0.45)

func stop_city_ambience() -> void:
	_wind_active = false
	if _wind_player == null or not is_instance_valid(_wind_player):
		return
	if _wind_tween != null and is_instance_valid(_wind_tween):
		_wind_tween.kill()
	_wind_tween = create_tween()
	_wind_tween.tween_property(_wind_player, "volume_db", SILENT_DB, 0.5)
	_wind_tween.tween_callback(func() -> void:
		if not _wind_active and is_instance_valid(_wind_player):
			_wind_player.stop())

func _tween_wind_volume(target_db: float, duration: float) -> void:
	if _wind_player == null or not is_instance_valid(_wind_player):
		return
	if _wind_tween != null and is_instance_valid(_wind_tween):
		_wind_tween.kill()
	_wind_tween = create_tween()
	_wind_tween.tween_property(_wind_player, "volume_db", target_db, duration)

func _on_ui_button_pressed(button: BaseButton) -> void:
	if not is_instance_valid(button):
		return
	if button.has_meta("sfx"):
		var tag := String(button.get_meta("sfx"))
		match tag:
			"none":
				return
			"big":
				play_big_click()
				return
			"little":
				play_little_click()
				return
	if button is CheckBox or button is CheckButton or button is OptionButton:
		play_little_click()
		return
	var btn_name := button.name.to_lower()
	if btn_name.contains("close") or btn_name.contains("clear") or btn_name.contains("cancel") or btn_name.contains("back") or btn_name.contains("center") or btn_name.contains("sound"):
		play_little_click()
		return
	if button.size.x > 0.0 and button.size.x <= 120.0 and button.size.y <= 90.0:
		play_little_click()
		return
	play_big_click()

func update(key: String, value: Variant) -> void:
	if not values.has(key):
		return
	values[key] = value
	apply_settings()
	if not test_mode:
		var config := ConfigFile.new()
		for item in values:
			config.set_value("settings", item, values[item])
		config.save(storage_path)
	changed.emit()

func is_dark_mode() -> bool:
	return bool(values.get("dark_mode", false))

func apply_settings() -> void:
	if game_theme != null:
		_populate_theme(game_theme)
	for pair in [["Master", "master"], ["Music", "music"], ["Effects", "effects"]]:
		var bus := AudioServer.get_bus_index(pair[0])
		AudioServer.set_bus_volume_db(bus, linear_to_db(maxf(0.0001, float(values[pair[1]]) / 100.0)))
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), bool(values.muted))
	TranslationServer.set_locale(String(values.locale))
	if test_mode or DisplayServer.get_name() == "headless":
		return
	var modes := [DisplayServer.WINDOW_MODE_WINDOWED, DisplayServer.WINDOW_MODE_FULLSCREEN, DisplayServer.WINDOW_MODE_WINDOWED]
	DisplayServer.window_set_mode(modes[clampi(int(values.mode), 0, 2)])
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, int(values.mode) == 2)
	var resolutions := [Vector2i(1280, 720), Vector2i(1600, 900), Vector2i(1920, 1080)]
	if int(values.mode) != 1:
		DisplayServer.window_set_size(resolutions[clampi(int(values.resolution), 0, 2)])
	# Compatibility does not implement 2D MSAA. Use supported texture filtering.
	get_viewport().canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST if int(values.quality) == 0 else Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_LINEAR

func build_options(column: VBoxContainer) -> void:
	for pair in [["Volume geral", "master"], ["Música", "music"], ["Efeitos sonoros", "effects"]]:
		var heading := UIFactory.label(tr(pair[0]) + " · %d%%" % int(values[pair[1]]), 23)
		column.add_child(heading)
		var slider := HSlider.new()
		slider.custom_minimum_size.y = 32
		slider.max_value = 100
		slider.value = float(values[pair[1]])
		slider.tooltip_text = tr(pair[0])
		column.add_child(slider)
		slider.value_changed.connect(func(value: float):
			heading.text = tr(pair[0]) + " · %d%%" % int(value)
			update(pair[1], value))
	var mute := CheckBox.new()
	mute.text = tr("Silenciar áudio")
	mute.button_pressed = bool(values.muted)
	mute.toggled.connect(func(value: bool): update("muted", value))
	column.add_child(mute)
	_option(column, "Modo de exibição", "mode", ["Janela", "Tela cheia", "Janela sem borda"])
	_option(column, "Resolução", "resolution", ["1280 × 720", "1600 × 900", "1920 × 1080"])
	_option(column, "Qualidade gráfica", "quality", ["Baixa", "Alta"])
	var language := OptionButton.new()
	language.add_item("Português (Brasil)")
	language.add_item("English (International)")
	language.selected = 1 if String(values.locale).begins_with("en") else 0
	language.tooltip_text = tr("Idioma")
	language.item_selected.connect(func(index: int): update("locale", "pt_BR" if index == 0 else "en"))
	column.add_child(language)
	var inactivity := CheckBox.new()
	inactivity.text = tr("Pausar quando a janela estiver inativa")
	inactivity.button_pressed = bool(values.pause_unfocused)
	inactivity.toggled.connect(func(value: bool): update("pause_unfocused", value))
	column.add_child(inactivity)
	var dark_toggle := CheckBox.new()
	dark_toggle.name = "DarkModeCheckBox"
	dark_toggle.text = tr("Modo noturno (tema escuro)")
	dark_toggle.button_pressed = is_dark_mode()
	dark_toggle.toggled.connect(func(value: bool): update("dark_mode", value))
	column.add_child(dark_toggle)
	_build_player_icon_option(column)

func get_default_player_icon_texture() -> Texture2D:
	if _default_player_icon_texture != null:
		return _default_player_icon_texture
	var raw := load(DEFAULT_PLAYER_ICON_PATH) as Texture2D
	if raw == null:
		return null
	var img := raw.get_image()
	if img != null:
		var used := img.get_used_rect()
		if used.size.x > 0 and used.size.y > 0:
			var atlas := AtlasTexture.new()
			atlas.atlas = raw
			atlas.region = Rect2(used.position, used.size)
			_default_player_icon_texture = atlas
			return _default_player_icon_texture
	_default_player_icon_texture = raw
	return _default_player_icon_texture

func get_player_icon_texture() -> Texture2D:
	if _player_icon_loaded:
		return _player_icon_texture
	_player_icon_loaded = true
	if not test_mode and FileAccess.file_exists(PLAYER_ICON_PATH):
		var img := Image.new()
		if img.load(PLAYER_ICON_PATH) == OK and not img.is_empty():
			_player_icon_texture = ImageTexture.create_from_image(img)
	return _player_icon_texture

func has_custom_player_icon() -> bool:
	return get_player_icon_texture() != null

func import_player_icon(source_path: String) -> String:
	var clean_path := source_path.strip_edges()
	if clean_path.is_empty():
		return "Nenhum arquivo selecionado."
	if not clean_path.to_lower().ends_with(".png"):
		return "Selecione um arquivo no formato PNG."
	var img := Image.new()
	if img.load(clean_path) != OK or img.is_empty():
		return "Não foi possível carregar a imagem PNG selecionada."
	var side := mini(img.get_width(), img.get_height())
	if img.get_width() != img.get_height():
		var crop_x := int((img.get_width() - side) / 2)
		var crop_y := int((img.get_height() - side) / 2)
		img = img.get_region(Rect2i(crop_x, crop_y, side, side))
	if side > 256:
		img.resize(256, 256, Image.INTERPOLATE_LANCZOS)
	if not test_mode:
		var save_err := img.save_png(PLAYER_ICON_PATH)
		if save_err != OK:
			return "Não foi possível salvar o ícone do jogador."
	_player_icon_texture = ImageTexture.create_from_image(img)
	_player_icon_loaded = true
	changed.emit()
	return ""

func clear_player_icon() -> void:
	_player_icon_texture = null
	_player_icon_loaded = true
	if not test_mode and FileAccess.file_exists(PLAYER_ICON_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(PLAYER_ICON_PATH))
	changed.emit()

func open_player_icon_picker(host: Node = null, on_result: Callable = Callable()) -> void:
	var dialog := FileDialog.new()
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.use_native_dialog = true
	dialog.title = tr("Escolher ícone do jogador (PNG)")
	dialog.filters = PackedStringArray(["*.png ; " + tr("Imagens PNG")])
	dialog.file_selected.connect(func(path: String) -> void:
		var error := import_player_icon(path)
		if on_result.is_valid():
			on_result.call(error)
		dialog.queue_free())
	dialog.canceled.connect(func() -> void: dialog.queue_free())
	var parent_node: Node = host if (host != null and is_instance_valid(host)) else self
	parent_node.add_child(dialog)
	dialog.popup_centered_ratio(0.65)

func _build_player_icon_option(column: VBoxContainer) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	row.add_child(UIFactory.label(tr("Ícone do jogador"), 23))
	var preview := TextureRect.new()
	preview.custom_minimum_size = Vector2(44, 44)
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	row.add_child(preview)
	var status := UIFactory.label("", 18)
	status.visible = false
	var import_btn := UIFactory.button(tr("Importar PNG"), func() -> void:
		open_player_icon_picker(column, func(error: String) -> void:
			if is_instance_valid(status):
				status.visible = not error.is_empty()
				status.text = tr(error)))
	import_btn.custom_minimum_size = Vector2(180, 44)
	row.add_child(import_btn)
	var reset_btn := UIFactory.button(tr("Padrão"), func() -> void:
		clear_player_icon()
		if is_instance_valid(status):
			status.visible = false)
	reset_btn.custom_minimum_size = Vector2(130, 44)
	row.add_child(reset_btn)
	column.add_child(row)
	column.add_child(status)
	var default_tex := get_default_player_icon_texture()
	var refresh_preview := func() -> void:
		if not is_instance_valid(preview) or not is_instance_valid(reset_btn):
			return
		var custom := get_player_icon_texture()
		preview.texture = custom if custom != null else default_tex
		preview.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR if custom != null else CanvasItem.TEXTURE_FILTER_NEAREST
		reset_btn.disabled = custom == null
	refresh_preview.call()
	changed.connect(refresh_preview)
	row.tree_exiting.connect(func() -> void:
		if changed.is_connected(refresh_preview):
			changed.disconnect(refresh_preview))

func _option(column: VBoxContainer, heading: String, key: String, options: Array) -> void:
	var row := HBoxContainer.new()
	row.add_child(UIFactory.label(tr(heading), 23))
	var selector := OptionButton.new()
	selector.custom_minimum_size = Vector2(280, 44)
	for option in options:
		selector.add_item(tr(option))
	selector.selected = clampi(int(values[key]), 0, options.size() - 1)
	selector.item_selected.connect(func(index: int): update(key, index))
	row.add_child(selector)
	column.add_child(row)

func make_theme() -> Theme:
	var result := Theme.new()
	_populate_theme(result)
	return result

func _populate_theme(result: Theme) -> void:
	result.default_font_size = 25
	var dark := is_dark_mode()
	var ink := Color("e6f0f4") if dark else Color("20383f")
	var teal := Color("3bb9eb") if dark else Color("17687b")
	var surface := Color("16222c") if dark else Color("f3f7f5")
	var panel_border := Color("2e4a59") if dark else Color("c0d2d6")
	var input_bg := Color("0f1820") if dark else Color.WHITE
	var input_border := Color("365566") if dark else Color("a8bec4")
	var placeholder := Color("7d98a6") if dark else Color("647a82")
	var prog_bg := Color("223542") if dark else Color("d3e1df")
	var prog_fill := Color("3bb9eb") if dark else Color("28a3bb")
	for type in ["Label", "CheckBox", "OptionButton", "LineEdit"]:
		result.set_color("font_color", type, ink)
	result.set_color("font_hover_color", "CheckBox", ink)
	result.set_color("font_pressed_color", "CheckBox", ink)
	result.set_color("font_focus_color", "CheckBox", ink)
	result.set_color("icon_pressed_color", "Button", Color.WHITE)
	result.set_color("font_disabled_color", "Button", Color("6c7f8a") if dark else Color("7a8b91"))
	result.set_color("font_color", "TooltipLabel", Color.WHITE)
	result.set_font_size("font_size", "TooltipLabel", 22)
	result.set_color("font_color", "LineEdit", ink)
	result.set_color("caret_color", "LineEdit", ink)
	result.set_color("font_placeholder_color", "LineEdit", placeholder)
	result.set_stylebox("panel", "PanelContainer", _style(surface, panel_border, 18, 2, 20))
	result.set_stylebox("panel", "AcceptDialog", _style(surface, teal, 18, 2, 20))
	result.set_stylebox("panel", "TooltipPanel", _style(Color("0e2430") if dark else Color("163b48"), Color("51b7cf"), 10, 1, 14))
	result.set_stylebox("normal", "LineEdit", _style(input_bg, input_border, 10, 2, 12))
	result.set_stylebox("focus", "LineEdit", _style(input_bg, teal, 10, 3, 12))
	var focus := _style(Color.TRANSPARENT, Color("3bb9eb") if dark else Color("20a7cb"), 12, 3, 0)
	result.set_stylebox("focus", "Button", focus)
	result.set_stylebox("focus", "OptionButton", focus)
	result.set_stylebox("background", "ProgressBar", _style(prog_bg, prog_bg, 6, 0, 0))
	result.set_stylebox("fill", "ProgressBar", _style(prog_fill, prog_fill, 6, 0, 0))
	# Reuse Debora's pixel border and palette for functional controls.
	for state in ["normal", "hover", "pressed", "disabled"]:
		var tint := Color(0.84, 0.90, 0.98) if dark else Color.WHITE
		if state == "hover": tint = Color(1.0, 1.08, 1.15) if dark else Color(1.15, 1.15, 1.15)
		if state == "pressed": tint = Color(0.65, 0.72, 0.80) if dark else Color(0.75, 0.75, 0.75)
		result.set_stylebox(state, "Button", DeboraDesign.skin("button_gray" if state == "disabled" else "button_blue", tint, true))
	for state in ["font_color", "font_hover_color", "font_focus_color", "font_pressed_color"]:
		result.set_color(state, "Button", Color.WHITE)

func _style(background: Color, border: Color, radius: int, border_width: int, margin: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_corner_radius_all(radius)
	style.set_border_width_all(border_width)
	style.content_margin_left = margin
	style.content_margin_right = margin
	style.content_margin_top = margin
	style.content_margin_bottom = margin
	return style

func _load_translations() -> void:
	var translation := load("res://localization/en.po") as Translation
	if translation != null:
		TranslationServer.add_translation(translation)
