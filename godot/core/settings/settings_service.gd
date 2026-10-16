extends Node

signal changed()

const PATH := "user://settings.cfg"
var storage_path := PATH
var values := {"master": 80.0, "music": 65.0, "effects": 80.0, "muted": false, "mode": 0, "resolution": 0, "quality": 1, "locale": "pt_BR", "pause_unfocused": true}
var game_theme: Theme
var test_mode := false
var _music: AudioStreamPlayer

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
		_music = AudioStreamPlayer.new()
		_music.bus = "Music"
		_music.stream = load("res://assets/soundtrack/src_aud_lobby-classic-game.mp3")
		add_child(_music)
		_music.finished.connect(_music.play)
		_music.play()

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

func play_feedback(correct: bool) -> void:
	if test_mode:
		return
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = 22050
	var samples := PackedByteArray()
	samples.resize(6615 * 2)
	for i in range(6615):
		var envelope := pow(1.0 - i / 6615.0, 2)
		var frequency := 660.0 if correct else 220.0
		var value := sin(TAU * frequency * i / 22050.0) * envelope * 5000.0
		samples.encode_s16(i * 2, int(value))
	stream.data = samples
	var player := AudioStreamPlayer.new()
	player.bus = "Effects"
	player.stream = stream
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()

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

func apply_settings() -> void:
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
	result.default_font_size = 25
	var ink := Color("20383f")
	var teal := Color("17687b")
	var cream := Color("f3f7f5")
	for type in ["Label", "Button", "CheckBox", "OptionButton", "LineEdit"]:
		result.set_color("font_color", type, ink)
	result.set_color("font_hover_color", "Button", ink)
	result.set_color("font_focus_color", "Button", ink)
	result.set_color("font_pressed_color", "Button", Color.WHITE)
	result.set_color("icon_pressed_color", "Button", Color.WHITE)
	result.set_color("font_disabled_color", "Button", Color("7a8b91"))
	result.set_color("font_color", "TooltipLabel", Color.WHITE)
	result.set_font_size("font_size", "TooltipLabel", 22)
	result.set_color("font_color", "LineEdit", ink)
	result.set_color("caret_color", "LineEdit", ink)
	result.set_color("font_placeholder_color", "LineEdit", Color("647a82"))
	result.set_stylebox("panel", "PanelContainer", _style(cream, Color("c0d2d6"), 18, 2, 20))
	result.set_stylebox("panel", "AcceptDialog", _style(cream, teal, 18, 2, 20))
	result.set_stylebox("panel", "TooltipPanel", _style(Color("163b48"), Color("51b7cf"), 10, 1, 14))
	result.set_stylebox("normal", "LineEdit", _style(Color.WHITE, Color("a8bec4"), 10, 2, 12))
	result.set_stylebox("focus", "LineEdit", _style(Color.WHITE, teal, 10, 3, 12))
	result.set_stylebox("normal", "Button", _style(Color("e7f1f2"), Color("94bbc3"), 12, 1, 12))
	result.set_stylebox("hover", "Button", _style(Color("cfeaf0"), teal, 12, 2, 12))
	result.set_stylebox("pressed", "Button", _style(teal, teal, 12, 2, 12))
	result.set_stylebox("disabled", "Button", _style(Color("e2e7e5"), Color("c3cecb"), 12, 1, 12))
	var focus := _style(Color.TRANSPARENT, Color("20a7cb"), 12, 3, 0)
	result.set_stylebox("focus", "Button", focus)
	result.set_stylebox("focus", "OptionButton", focus)
	result.set_stylebox("background", "ProgressBar", _style(Color("d3e1df"), Color("d3e1df"), 6, 0, 0))
	result.set_stylebox("fill", "ProgressBar", _style(Color("28a3bb"), Color("28a3bb"), 6, 0, 0))
	return result

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
