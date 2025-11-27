extends Node2D

@export var level_bpm: float = 90.0
@export var level_loop_beats_duration: float = 16.0

func _ready() -> void:
	AudioManager.setup_level(level_bpm, level_loop_beats_duration)
	GameManager.snaps_to_win = 6
	GameManager.current_snaps = 1
