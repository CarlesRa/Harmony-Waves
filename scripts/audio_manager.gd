extends Node

var bpm: float = 120.0
var beat_duration: float
var loop_duration: float = 4.0
var total_loop_time: float = 0.0
var master_clock: AudioStreamPlayer
var music_start_time: float = 0.0
var is_playing: bool = false
var sfx_players: Array[AudioStreamPlayer] = []
const MAX_SFX_PLAYERS: int = 4

var output_latency: float = 0.0

func _ready() -> void:
	_setup_master_clock()
	_setup_sfx()

	output_latency = AudioServer.get_output_latency()
	print("Audio output latency: %.3f seconds" % output_latency)

func _setup_master_clock() -> void:
	master_clock = AudioStreamPlayer.new()
	add_child(master_clock)
	master_clock.bus = "Master"
	master_clock.volume_db = -80

func _setup_sfx() -> void:
	for i in range(MAX_SFX_PLAYERS):
		var player = AudioStreamPlayer.new()
		add_child(player)
		player.bus = "Master"
		sfx_players.append(player)

func setup_level(level_bpm: float, level_loop_duration: float) -> void:
	bpm = level_bpm
	loop_duration = level_loop_duration
	_calculate_beat_duration()
	total_loop_time = loop_duration * beat_duration
	print("Loop configured: %d BPM, %d beats = %.2f seconds" % [bpm, loop_duration, total_loop_time])	

func _calculate_beat_duration() -> void:
	beat_duration = 60.0 / bpm

func get_loop_position() -> float:
	if not is_playing:
		return 0.0
	
	var current_time = master_clock.get_playback_position()

	current_time += AudioServer.get_time_since_last_mix()
	current_time -= output_latency
	

	if current_time < 0:
		current_time = 0
	
	return fmod(current_time, total_loop_time)

func get_time_to_next_loop() -> float:
	var current_pos = get_loop_position()
	return total_loop_time - current_pos

func start_music() -> void:
	if is_playing:
		return
	
	is_playing = true
	music_start_time = Time.get_ticks_msec() / 1000.0
	
	if master_clock.stream == null:
		var silence = AudioStreamGenerator.new()
		silence.mix_rate = 44100
		master_clock.stream = silence
	
	master_clock.play()
	print("Music started at %.3f seconds" % music_start_time)

func reset() -> void:
	is_playing = false
	music_start_time = 0.0
	if master_clock:
		master_clock.stop()

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
