extends Node2D

@onready var level_container = $LevelContainer
@onready var camera = $Camera2D

func _ready() -> void:
	GameManager.set_level_container(level_container)
	GameManager.load_level("res://scenes/levels/level_01.tscn")
	
	await get_tree().process_frame
	_adjust_camera_to_fit_level()

func _adjust_camera_to_fit_level() -> void:
	if level_container.get_child_count() == 0:
		return
	
	var level = level_container.get_child(0)
	var pieces = []
	
	# Recopilar todas las piezas
	for child in level.get_children():
		if child is WavePiece:
			pieces.append(child)
	
	if pieces.is_empty():
		return
	
	# Calcular bounds (límites) de todas las piezas
	var min_pos = pieces[0].global_position
	var max_pos = pieces[0].global_position
	
	for piece in pieces:
		min_pos.x = min(min_pos.x, piece.global_position.x)
		min_pos.y = min(min_pos.y, piece.global_position.y)
		max_pos.x = max(max_pos.x, piece.global_position.x)
		max_pos.y = max(max_pos.y, piece.global_position.y)
	
	# Centrar cámara
	var center = (min_pos + max_pos) / 2
	camera.position = center
	
	# Ajustar zoom para que quepan todas las piezas
	var viewport_size = get_viewport_rect().size
	var level_size = max_pos - min_pos
	var zoom_x = viewport_size.x / (level_size.x + 200)  # +200 de margen
	var zoom_y = viewport_size.y / (level_size.y + 200)
	camera.zoom = Vector2.ONE * min(zoom_x, zoom_y)
