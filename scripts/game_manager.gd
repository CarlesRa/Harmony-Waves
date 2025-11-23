extends Node

var current_dragged_piece = null
var current_level: Node = null
var level_container: Node = null

func set_level_container(container: Node) -> void:
	level_container = container

func load_level(level_path: String) -> void:	
	if current_level:
		current_level.queue_free()
		await get_tree().process_frame
		
	var level_scene = load(level_path)
	if not level_scene:
		push_error("Error loading level: " + level_path)
		return
	
	current_level = level_scene.instantiate()
	level_container.add_child(current_level)	

func unload_level() -> void:
	if current_level:
		current_level.queue_free()
		current_level = null
