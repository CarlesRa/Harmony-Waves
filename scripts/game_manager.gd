extends Node

signal level_changed(new_level_loaded)
signal snaps_to_win_sign(new_snaps_to_win)
signal current_snaps_sign(new_current_snap)

var current_level: Node = null
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
		emit_signal('current_snaps_sign', value)

func set_level_container(container: Node) -> void:
	level_container = container

func load_level(level_path: String, level_label: String) -> void:	
	if current_level:
		current_level.queue_free()
		await get_tree().process_frame
		
	var level_scene = load(level_path)
	if not level_scene:
		push_error("Error loading level: " + level_path)
		return
	
	current_level = level_scene.instantiate()
	level_container.add_child(current_level)
	emit_signal('level_changed', level_label)

func unload_level() -> void:
	if current_level:
		current_level.queue_free()
		current_level = null
