extends Node

const AUDIO_LATENCY_COMPENSATION: float = 0.072
var bpm: float = 120.0
var beat_duration: float
var loop_duration: float = 4.0  # Beats
var current_time: float = 0.0
var is_playing: bool = false

func _ready() -> void:
	_calculate_beat_duration()

func _process(delta: float) -> void:
	if is_playing:
		current_time += delta

func setup_level(level_bpm: float, level_loop_duration: float) -> void:
	bpm = level_bpm
	loop_duration = level_loop_duration
	_calculate_beat_duration()

func _calculate_beat_duration() -> void:
	beat_duration = 60.0 / bpm

func get_loop_position() -> float:
	var total_loop_time = loop_duration * beat_duration
	return fmod(current_time, total_loop_time)

func get_time_to_next_loop() -> float:
	var loop_time = loop_duration * beat_duration
	var current_pos = get_loop_position()
	return loop_time - current_pos

func start_music() -> void:
	is_playing = true
	current_time = 0.0

func reset() -> void:
	is_playing = false
	current_time = 0.0
