extends Node2D

func _ready() -> void:
	GameManager.snaps_to_win = 10
	GameManager.current_snaps = 1
	await get_tree().process_frame
	AudioManager._start_all_piece_players()
