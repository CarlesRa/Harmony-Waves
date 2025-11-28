extends Node2D

@export var level_bpm: float = 100.0
@export var level_loop_beats_duration: float = 16.0

func _ready() -> void:
	GameManager.snaps_to_win = 7
	GameManager.current_snaps = 1
	await get_tree().process_frame
	AudioManager._start_all_piece_players()
