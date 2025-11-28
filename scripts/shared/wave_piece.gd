extends Area2D
class_name WavePiece

@export var is_piece_connected: bool = false
@export var music_stream: AudioStream = null
@export var original_position: Vector2 = Vector2.ZERO
@export var error_sound: AudioStream
@export var success_sound: AudioStream
@export var drag_sound: AudioStream
@export var piece_id: int;

@export_group("Connector 1")
@export var C1_connector_id: int = 1
@export var C1_target_id: int = 0

@export_group("Connector 2")
@export var C2_connector_id: int = 2
@export var C2_target_id: int = 0

@onready var connector_1: PieceConnector = $%PieceConnector1
@onready var connector_1_point: Node2D = $PieceConnector1/Connector
@onready var connector_2: PieceConnector = $%PieceConnector2
@onready var connector_2_point: Node2D = $PieceConnector2/Connector
@onready var audio_player: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var piece_sprite: Sprite2D = $Piece

const SNAP_DISTANCE: float = 300.0

var is_dragging: bool = false
var colliding_targets := []
var dragging_connector_ids := []
var drag_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	_set_connectors()
	_setup_audio()
	_setup_shader()
	GameManager.level_completed.connect(_on_level_completed)

func _process(_delta: float) -> void:
	if is_dragging:
		global_position = get_global_mouse_position() - drag_offset

func _set_connectors() -> void:
	connector_1.parent_piece = self
	connector_1.connector_id = C1_connector_id
	connector_1.target_connector_id = C1_target_id
	connector_1.initialize_connector()
	connector_2.parent_piece = self
	connector_2.connector_id = C2_connector_id
	connector_2.target_connector_id = C2_target_id
	connector_2.initialize_connector()

func _setup_audio() -> void:
	add_child(audio_player)
	if music_stream:
		audio_player.stream = music_stream
		if is_piece_connected:
			audio_player.volume_db = 0
		else:
			audio_player.volume_db = -80

		audio_player.bus = "Pieces"
		audio_player.finished.connect(_on_audio_finished)
		AudioManager.add_piece_audio_player(piece_id, audio_player)

func _setup_shader() -> void:
	if not piece_sprite:
		return
	if not piece_sprite.material:
		var shader_material = ShaderMaterial.new()
		var shader = load("res://assets/shaders/waves.gdshader")
		shader_material.shader = shader
		piece_sprite.material = shader_material

	piece_sprite.material.set_shader_parameter("is_playing", is_piece_connected)

func _on_audio_finished() -> void:
	if music_stream:
		audio_player.play()

func stop_audio() -> void:
	audio_player.stop()

func _on_wave_piece_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not is_piece_connected and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				_start_drag()
			if event.is_released():
				_end_drag()

func _start_drag() -> void:
	original_position = global_position
	drag_offset = get_global_mouse_position() - global_position
	z_index = 1
	if drag_sound:
		AudioManager.play_sfx(drag_sound)
	is_dragging = true

func _end_drag() -> void:	
	if not is_dragging: return
	z_index = 0
	_try_snap_on_release()
	if drag_sound:
		AudioManager.stop_sfx(drag_sound)
	is_dragging = false

func _try_snap_on_release() -> bool:
	if colliding_targets.is_empty():
		return_to_original_position()
		return false
		
	var valid_connections = []
	
	for info in colliding_targets:
		var target_id = info["id"]
		var current_drag_point: Node2D = info["dragged_connector_point"]

		if target_id == current_drag_point.get_parent().connector_id:
			valid_connections.append(info)

	if valid_connections.is_empty():
		return_to_original_position()
		return false

	var first_connection = valid_connections[0]
	var target_pos = first_connection["target_pos"]
	var drag_point: Node2D = first_connection["dragged_connector_point"]
	var dragged_pos = drag_point.global_position
	var offset = target_pos - dragged_pos
	global_position += offset
	
	for connection in valid_connections:
		var dragged_connector: PieceConnector = connection["dragged_connector_point"].get_parent()
		var target_connector: PieceConnector = connection["target_connector"]
		dragged_connector.is_active = true
		target_connector.is_active = true

	is_piece_connected = true
	connector_1.is_active = true
	connector_2.is_active = true

	if success_sound:
		AudioManager.play_sfx(success_sound)

	AudioManager.play_piece_audio_player(piece_id)
	piece_sprite.material.set_shader_parameter("is_playing", true)
	#start_audio_synced()
	colliding_targets.clear()
	GameManager.current_snaps += 1
	return true

func return_to_original_position() -> void:
	if error_sound:
		AudioManager.play_sfx(error_sound)

	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "global_position", original_position, 0.3)

# Connector 1
func _on_piece_connector_1_area_entered(area: Area2D) -> void:	
	if area is PieceConnector and area.get_parent() != self:
		if !area.is_active:
			return
		var static_connector_point = area.get_node("Connector")
		var target_pos = static_connector_point.global_position
		var info = {
			"id": area.target_connector_id,
			"target_pos": target_pos,
			"dragged_connector_point": connector_1_point,
			"target_connector": area 
		}
		colliding_targets.append(info)

func _on_piece_connector_1_area_exited(area: Area2D) -> void:
	if area is PieceConnector and area.get_parent() != self:
		colliding_targets = colliding_targets.filter(
			func(e): return e["id"] != area.target_connector_id
		)


# Connector 2
func _on_piece_connector_2_area_entered(area: Area2D) -> void:
	if area is PieceConnector and area.get_parent() != self:
		if !area.is_active:
			return
		var static_connector_point = area.get_node("Connector")
		var target_pos = static_connector_point.global_position
		var info = {
			"id": area.target_connector_id,
			"target_pos": target_pos,
			"dragged_connector_point": connector_2_point,
			"target_connector": area 
		}
		colliding_targets.append(info)

func _on_piece_connector_2_area_exited(area: Area2D) -> void:
	if area is PieceConnector and area.get_parent() != self:
		colliding_targets = colliding_targets.filter(
			func(e): return e["id"] != area.target_connector_id
		)

func _on_level_completed():
	if not is_piece_connected:
		_fade_and_destroy()

func _fade_and_destroy():
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 1)
	tween.tween_property(self, "scale", Vector2(0.8, 0.8), 1)
	await tween.finished
	queue_free()

func destroy():
	stop_audio()
	if audio_player:
		audio_player.stop()
		audio_player.queue_free()
	queue_free()
