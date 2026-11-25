extends Control

const SAVES_SCENE := preload("res://scenes/ui/carregar.tscn")
const OPTIONS_SCENE := preload("res://scenes/ui/opcoes.tscn")
const CREDITS_SCENE := preload("res://scenes/ui/creditos.tscn")

@onready var quit_confirmation: ConfirmationDialog = $QuitConfirmation
var _active_popup: Control

func _ready() -> void:
	theme = SettingsService.game_theme
	SettingsService.stop_city_ambience()
	SettingsService.play_main_menu_music()
	$SoundButton.set_meta("sfx", "none")
	$SoundButton.pressed.connect(_on_sound_pressed)
	$ExitButton.set_meta("sfx", "little")
	$ExitButton.pressed.connect(_on_exit_pressed)
	quit_confirmation.confirmed.connect(func() -> void: get_tree().quit())
	quit_confirmation.ok_button_text = "Sair"
	quit_confirmation.cancel_button_text = "Continuar jogando"
	_sync_sound_button()
	$Menu/VBoxContainer/jogar.set_meta("sfx", "big")
	$Menu/VBoxContainer/continuar.set_meta("sfx", "big")
	$Menu/VBoxContainer/opcoes.set_meta("sfx", "big")
	$Menu/VBoxContainer/creditos.set_meta("sfx", "big")
	$Menu/VBoxContainer/jogar.pressed.connect(_on_btjogar_pressed)
	$Menu/VBoxContainer/continuar.pressed.connect(_on_btcontinuar_pressed)
	$Menu/VBoxContainer/opcoes.pressed.connect(_on_btopcoes_pressed)
	$Menu/VBoxContainer/creditos.pressed.connect(_on_btcreditos_pressed)
	$Menu/VBoxContainer/continuar.disabled = false
	$Menu/VBoxContainer/continuar.text = "Partidas salvas"
	$Menu/VBoxContainer/continuar.tooltip_text = "Abrir slots de salvamento."
	SettingsService.attach_button_sfx(self)
	SettingsService.changed.connect(_apply_design)
	_apply_design()

func _input(event: InputEvent) -> void:
	if has_node("GameDialog") and not quit_confirmation.visible:
		if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
			_close_game_dialog()
			get_viewport().set_input_as_handled()

func _unhandled_input(event: InputEvent) -> void:
	if _active_popup != null and is_instance_valid(_active_popup):
		if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
			_close_active_popup()
			get_viewport().set_input_as_handled()

func _on_exit_pressed() -> void:
	quit_confirmation.popup_centered()

func _on_btjogar_pressed() -> void:
	if has_node("GameDialog"):
		return
	var dialog := UIFactory.dialog(self, tr("Nova gestão"), 820)
	var column: VBoxContainer = dialog.content
	column.add_child(UIFactory.label(tr("Nome da cidade")))
	var city_name := LineEdit.new()
	city_name.name = "CityName"
	city_name.text = tr("Vila Esperança")
	city_name.max_length = 36
	city_name.custom_minimum_size.y = 54
	column.add_child(city_name)
	column.add_child(UIFactory.label(tr("Dificuldade")))
	var difficulty := OptionButton.new()
	difficulty.name = "Difficulty"
	for item in ["Fácil", "Médio", "Difícil"]:
		difficulty.add_item(tr(item))
	difficulty.selected = 1
	column.add_child(difficulty)
	column.add_child(UIFactory.label(tr("Fácil: 60% de reputação inicial (mais orçamento, sem problemas comuns). Médio: 52% (equilibrado). Difícil: 42% (menor orçamento e penalidades maiores)."), 23))
	column.add_child(UIFactory.label(tr("Objetivo: reeleição com pelo menos 50% de reputação após quatro anos; depois, concluir o segundo mandato."), 23))
	column.add_child(UIFactory.button(tr("Começar"), func():
		SaveManager.start_new(city_name.text, ["easy", "medium", "hard"][difficulty.selected])
		get_tree().change_scene_to_file("res://scenes/game/Game.tscn")))
	column.add_child(UIFactory.button(tr("Cancelar"), _close_game_dialog))
	city_name.grab_focus()

func _close_game_dialog() -> void:
	var dialog := get_node_or_null("GameDialog") as Control
	if dialog == null or not is_instance_valid(dialog):
		return
	dialog.hide()
	remove_child(dialog)
	dialog.queue_free()
	$Menu/VBoxContainer/jogar.grab_focus()

func _on_btcontinuar_pressed() -> void:
	_open_popup(SAVES_SCENE)
	
func _on_btopcoes_pressed() -> void:
	_open_popup(OPTIONS_SCENE)
	
func _on_btcreditos_pressed() -> void:
	_open_popup(CREDITS_SCENE)

func _open_popup(scene: PackedScene) -> void:
	if _active_popup != null and is_instance_valid(_active_popup):
		return
	var popup := scene.instantiate() as Control
	popup.set("popup_mode", true)
	popup.theme = theme
	popup.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	popup.z_index = 100
	popup.connect("close_requested", _close_active_popup)
	_active_popup = popup
	add_child(popup)

func _close_active_popup() -> void:
	if _active_popup == null or not is_instance_valid(_active_popup):
		_active_popup = null
		return
	_active_popup.hide()
	_active_popup.queue_free()
	_active_popup = null

func _on_sound_pressed() -> void:
	SettingsService.update("muted", not bool(SettingsService.values.muted))
	_sync_sound_button()
	SettingsService.play_little_click()

func _sync_sound_button() -> void:
	var master := AudioServer.get_bus_index("Master")
	var muted := master >= 0 and AudioServer.is_bus_mute(master)
	$SoundButton.text = "Som: desligado" if muted else "Som: ligado"
	$SoundButton.tooltip_text = tr($SoundButton.text)
	$SoundButton.text = ""
	$SoundButton.custom_minimum_size = Vector2(100, 83)
	$SoundButton.offset_top = -111
	$SoundButton.offset_right = 128
	DeboraDesign.button($SoundButton, "sound_off" if muted else "sound_on", true)

func _apply_design() -> void:
	$Background.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	$Background.modulate = Color.WHITE
	if has_node("TitleGroup/LogoTexture"):
		var logo_rect: TextureRect = $TitleGroup/LogoTexture
		logo_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		if logo_rect.texture != null and not (logo_rect.texture is AtlasTexture):
			var img := logo_rect.texture.get_image()
			if img != null:
				var used := img.get_used_rect()
				if used.size.x > 0 and used.size.y > 0:
					var atlas := AtlasTexture.new()
					atlas.atlas = logo_rect.texture
					atlas.region = Rect2(used.position, used.size)
					logo_rect.texture = atlas
	var portuguese := not String(SettingsService.values.locale).begins_with("en")
	var names := ["jogar", "continuar", "opcoes", "creditos"]
	var art := ["play", "continue", "options", "credits"]
	var blanks := ["blue", "gray", "green", "yellow"]
	for index in range(names.size()):
		var control: Button = $Menu/VBoxContainer.get_node(names[index])
		control.custom_minimum_size = Vector2(440, 104)
		DeboraDesign.button(control, art[index] if portuguese else "button_" + blanks[index], portuguese)
	$Menu/VBoxContainer/continuar.text = "Continuar"
	$Menu/VBoxContainer.add_theme_constant_override("separation", 8)
	_sync_sound_button()
	_sync_exit_button()

func _sync_exit_button() -> void:
	$ExitButton.tooltip_text = tr("Sair")
	$ExitButton.text = ""
	$ExitButton.custom_minimum_size = Vector2(100, 83)
	$ExitButton.offset_left = -128
	$ExitButton.offset_top = -111
	$ExitButton.offset_right = -28
	$ExitButton.offset_bottom = -28
	$ExitButton.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var raw := load("res://assets/ui/hud/sair.png") as Texture2D
	if raw == null:
		return
	var tex: Texture2D = raw
	var img := raw.get_image()
	if img != null:
		var used := img.get_used_rect()
		if used.size.x > 0 and used.size.y > 0:
			var atlas := AtlasTexture.new()
			atlas.atlas = raw
			atlas.region = Rect2(used.position, used.size)
			tex = atlas
	for state in ["normal", "hover", "pressed", "disabled"]:
		var style := StyleBoxTexture.new()
		style.texture = tex
		var tint := Color.WHITE
		if state == "hover": tint = Color(1.15, 1.15, 1.15)
		if state == "pressed": tint = Color(0.75, 0.75, 0.75)
		if state == "disabled": tint = Color(0.55, 0.55, 0.55, 0.7)
		style.modulate_color = tint
		$ExitButton.add_theme_stylebox_override(state, style)
	for state in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_disabled_color"]:
		$ExitButton.add_theme_color_override(state, Color.TRANSPARENT)
	$ExitButton.add_theme_constant_override("outline_size", 0)
