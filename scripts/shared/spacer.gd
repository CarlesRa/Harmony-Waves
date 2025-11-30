# TitleScreen.gd
extends Control

@onready var title_label = $VBoxContainer/TitleLabel
@onready var subtitle_label = $VBoxContainer/SubtitleLabel
@onready var menu_container = $VBoxContainer/MenuContainer
@onready var play_button = $VBoxContainer/MenuContainer/PlayButton
@onready var quit_button = $VBoxContainer/MenuContainer/QuitButton
@onready var background = $Background

var time_passed = 0.0

func _ready():
	play_button.pressed.connect(_on_play_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	title_label.modulate.a = 0
	subtitle_label.modulate.a = 0
	menu_container.modulate.a = 0
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(title_label, "modulate:a", 1.0, 1.5).set_ease(Tween.EASE_OUT)
	tween.tween_property(subtitle_label, "modulate:a", 1.0, 1.5).set_delay(0.5)
	tween.tween_property(menu_container, "modulate:a", 1.0, 1.0).set_delay(1.0)

func _process(delta):
	time_passed += delta
	
	var pulse = sin(time_passed * 2.0) * 0.5 + 0.5
	title_label.scale = Vector2.ONE * (1.0 + pulse * 0.05)
	
	var glow = sin(time_passed * 1.5) * 0.5 + 0.5
	subtitle_label.modulate = Color(0.0, 1.0 + glow * 0.3, 1.0 + glow * 0.3, 1.0)

func _on_play_pressed():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	GameManager.load_next_level()

func _on_quit_pressed():
	get_tree().quit()
