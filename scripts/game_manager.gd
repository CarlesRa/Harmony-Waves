extends Node

signal level_changed(new_level_loaded)
signal snaps_to_win_sign(new_snaps_to_win)
signal current_snaps_sign(new_current_snap)
signal level_completed(level_completed)

const BASE_LEVEL_PATH = "res://scenes/levels/level_%02d.tscn"
const BASE_LEVEL_LABEL = "Level %d"
const MAX_LEVELS = 6

var current_level: Node = null
var current_level_number: int = 1
var level_container: Node = null
var _snaps_to_win: int = 4
var _current_snaps: int = 1


var snaps_to_win:
	get:
		return _snaps_to_win
	set(value):
		_snaps_to_win = value
		emit_signal('snaps_to_win_sign', value)

var current_snaps:
	get:
		return _current_snaps
	set(value):
		_current_snaps = value
		if (_current_snaps >= _snaps_to_win):
			emit_signal("level_completed")
		emit_signal('current_snaps_sign', value)

func set_level_container(container: Node) -> void:
	level_container = container
	
func load_next_level() -> void:
	if current_level_number >= MAX_LEVELS:
		pass # TODO: GAME COMPLETED!
		return

	await TransitionManager.fade_out()
	AudioManager.reset()
	unload_level()
	await get_tree().process_frame
	load_level(current_level_number + 1)
	await TransitionManager.fade_in()

func load_level(level_number: int) -> void:
	var level_label = BASE_LEVEL_LABEL % level_number
	var level_path = BASE_LEVEL_PATH % level_number
	var level_scene = load(level_path)

	if !level_scene:
		push_error("Error loading level: " + level_path)

	current_level_number = level_number
	current_level = level_scene.instantiate()
	level_container.add_child(current_level)
	emit_signal('level_changed', level_label)

func load_level_overlapping(level_path: String) -> void:
	var level_scene = load(level_path)
	if not level_scene:
		push_error("Error loading level: " + level_path)
		return

	level_container.add_child(level_scene.instantiate())
	

func unload_level() -> void:
	if level_container:
		for child in level_container.get_children():
			_recursive_stop_and_destroy(child)

func _recursive_stop_and_destroy(node: Node) -> void:
	for child in node.get_children():
		_recursive_stop_and_destroy(child)
		
	if node is WavePiece:
		node.destroy()
		
	node.queue_free()
		
