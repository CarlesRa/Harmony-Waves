extends Node2D

@onready var level_container = $LevelContainer
@onready var camera = $Camera2D

func _ready() -> void:
	GameManager.connect("level_completed", _go_to_level_complete_scene)
	GameManager.set_level_container(level_container)
	GameManager.load_level(1)
	#GameManager.load_level("res://scenes/levels/level_02.tscn", "Level 2")

func _go_to_level_complete_scene():
	GameManager.load_level_overlapping("res://scenes/shared/level_completed.tscn")
	
