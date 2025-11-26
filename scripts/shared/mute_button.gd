extends Button

var is_muted: bool = false

func _ready() -> void:
	_setup_theme()
	pressed.connect(_on_pressed)
	_update_button()

func _setup_theme() -> void:
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = Color(0, 0, 0, 0)
	style_normal.border_width_left = 0
	style_normal.border_width_top = 0
	style_normal.border_width_right = 0
	style_normal.border_width_bottom = 0
	
	add_theme_stylebox_override("normal", style_normal)
	add_theme_stylebox_override("hover", style_normal)
	add_theme_stylebox_override("pressed", style_normal)
	add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	
	mouse_default_cursor_shape = Control.CURSOR_ARROW

func _on_pressed() -> void:
	is_muted = !is_muted
	AudioServer.set_bus_mute(0, is_muted)
	_update_button()

func _update_button() -> void:
	var color: Color
	
	if is_muted:
		text = "♪ MUTE"
		color = Color("#FF0066")
	else:
		text = "♪ MUTE"
		color = Color("#00FF88")

	add_theme_color_override("font_color", color)
	add_theme_color_override("font_hover_color", color)
	add_theme_color_override("font_pressed_color", color)
	add_theme_color_override("font_focus_color", color)
	add_theme_color_override("font_disabled_color", color)
	add_theme_color_override("font_outline_color", Color.TRANSPARENT)
