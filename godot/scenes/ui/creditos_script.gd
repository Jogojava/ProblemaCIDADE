extends Control

signal close_requested()

var popup_mode := false

func _ready() -> void:
	theme = SettingsService.game_theme
	$Background.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if popup_mode:
		_make_popup()

func _make_popup() -> void:
	$Background.hide()
	$Shade.hide()
	var content := $Content as VBoxContainer
	remove_child(content)

	var shade := ColorRect.new()
	shade.name = "PopupBackdrop"
	shade.color = Color(0.025, 0.055, 0.075, 0.78)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)
	move_child(shade, 0)

	var center := CenterContainer.new()
	center.name = "PopupCenter"
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var viewport_size := get_viewport_rect().size
	var popup_size := Vector2(minf(1240.0, viewport_size.x - 48.0), minf(680.0, viewport_size.y - 48.0))
	var panel := PanelContainer.new()
	panel.custom_minimum_size = popup_size
	center.add_child(panel)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color("10272f")
	panel_style.border_color = Color("3fb8d5")
	panel_style.set_border_width_all(3)
	panel_style.set_corner_radius_all(16)
	panel.add_theme_stylebox_override("panel", panel_style)

	var margin := MarginContainer.new()
	for side in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 14)
	panel.add_child(margin)
	var scroll := ScrollContainer.new()
	scroll.name = "CreditsScroll"
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(scroll)
	content.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	content.offset_left = 0.0
	content.offset_top = 0.0
	content.offset_right = 0.0
	content.offset_bottom = 0.0
	content.size_flags_horizontal = Control.SIZE_FILL
	content.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	var content_minimum := content.get_combined_minimum_size()
	content.custom_minimum_size = Vector2(maxf(content_minimum.x, popup_size.x - 32.0), content_minimum.y)
	scroll.add_child(content)

func voltar_on_pressed() -> void:
	if popup_mode:
		close_requested.emit()
	else:
		get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
