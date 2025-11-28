extends Node

const MAX_SFX_PLAYERS: int = 4
var is_playing: bool = false
var piece_players: Dictionary[int, AudioStreamPlayer] = {}
var sfx_players: Array[AudioStreamPlayer] = []

func _ready() -> void:
	_setup_sfx()

func _setup_sfx() -> void:
	for i in range(MAX_SFX_PLAYERS):
		var player = AudioStreamPlayer.new()
		add_child(player)
		player.bus = "SFX"
		sfx_players.append(player)

func add_piece_audio_player(id: int, player: AudioStreamPlayer) -> void:
	piece_players.set(id, player)

func _start_all_piece_players() -> void:
	for player: AudioStreamPlayer in piece_players.values():
		player.play()
	is_playing = true

func play_piece_audio_player(key: int) -> void:
	var player = piece_players.get(key)
	if (player):
		fade_in(player)

func fade_in(player: AudioStreamPlayer):
	var tween = create_tween()
	tween.tween_property(player, "volume_db", 0, 0.3)

func fade_out(player: AudioStreamPlayer):
	var tween = create_tween()
	tween.tween_property(player, "volume_db", -80, 0.3)
	
func reset_pieces_audio() -> void:
	piece_players.clear()

func play_sfx(sound: AudioStream) -> void:
	if not sound:
		return
	for player in sfx_players:
		if not player.playing:
			player.stream = sound
			player.play()
			return
	
	sfx_players[0].stream = sound
	sfx_players[0].play()

func stop_sfx(sound: AudioStream) -> void:
	if not sound:
		return
	for player in sfx_players:
		if player.playing and player.stream == sound:
			player.stop()

func stop_all_sfx() -> void:
	for player in sfx_players:
		player.stop()
