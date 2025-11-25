extends Node

const AUDIO_LATENCY_COMPENSATION: float = 0.05

var bpm: float = 120.0
var beat_duration: float
var loop_duration: float = 4.0  # Beats en el loop

var master_clock: AudioStreamPlayer
var reference_start_time: float = 0.0
var is_playing: bool = false

var sfx_players: Array[AudioStreamPlayer] = []
const MAX_SFX_PLAYERS: int = 4

func _ready() -> void:
	#_calculate_beat_duration()
	_setup_master_clock()
	_setup_sfx()

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

func _calculate_beat_duration() -> void:
	beat_duration = 60.0 / bpm

func get_loop_position() -> float:
	if not is_playing or not master_clock.playing:
		return 0.0

	var playback_pos = master_clock.get_playback_position()
	var total_time = playback_pos + AudioServer.get_time_since_last_mix()
	# Compensate Audio latency
	total_time -= AudioServer.get_output_latency()
	
	var total_loop_time = loop_duration * beat_duration
	return fmod(total_time, total_loop_time)

func get_precise_loop_position() -> float:
	"""Versión más precisa usando el bus de audio"""
	if not is_playing:
		return 0.0
	
	var time = AudioServer.get_time_to_next_mix() + AudioServer.get_time_since_last_mix()
	var elapsed = reference_start_time + time
	var total_loop_time = loop_duration * beat_duration
	
	return fmod(elapsed, total_loop_time)

func get_time_to_next_loop() -> float:
	var loop_time = loop_duration * beat_duration
	var current_pos = get_loop_position()
	return loop_time - current_pos

func start_music() -> void:
	is_playing = true
	reference_start_time = 0.0

	if master_clock.stream == null:
		var silence = AudioStreamGenerator.new()
		silence.mix_rate = 44100
		master_clock.stream = silence
	
	master_clock.play()

func reset() -> void:
	is_playing = false
	reference_start_time = 0.0
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
