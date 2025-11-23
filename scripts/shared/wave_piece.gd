extends Area2D
class_name WavePiece

@export var is_piece_connected: bool = false
@export var music_stream: AudioStream = null
@export var original_position: Vector2 = Vector2.ZERO

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

const SNAP_DISTANCE: float = 300.0

var is_dragging: bool = false
var colliding_targets := []
var dragging_connector_ids := []
var drag_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	_set_connectors()
	

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

func _on_wave_piece_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not is_piece_connected and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				_start_drag()
			if event.is_released():
				_end_drag()

func _start_drag() -> void:
	GameManager.current_dragged_piece = self
	original_position = global_position
	drag_offset = get_global_mouse_position() - global_position
	z_index = 1
	is_dragging = true

func _end_drag() -> void:
	if not is_dragging: return
	z_index = 0
	if GameManager.current_dragged_piece == self:
		GameManager.current_dragged_piece = null
	_try_snap_on_release()
	is_dragging = false

func _try_snap_on_release() -> void:
	if colliding_targets.is_empty():
		return
	for info in colliding_targets:
		var target_id = info["id"]
		var target_pos = info["target_pos"]
		var drag_point: Node2D = info["dragged_connector_point"]
		var dragged_pos = drag_point.get_global_transform_with_canvas().origin
		if target_id == drag_point.get_parent().connector_id:
			var offset = target_pos - dragged_pos
			global_position += offset
			is_piece_connected = true
			drag_point.get_parent().is_active = true
			colliding_targets.clear()
			return


# Connector 1
func _on_piece_connector_1_area_entered(area: Area2D) -> void:	
	if area is PieceConnector and area.get_parent() != self:
		if !area.is_active:
			return
		var static_connector_point = area.get_node("Connector")
		var target_pos = static_connector_point.get_global_transform_with_canvas().origin
		var info = {
			"id": area.target_connector_id,
			"target_pos": target_pos,
			"dragged_connector_point": connector_1_point
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
		var static_connector_point = area.get_node("Connector")
		var target_pos = static_connector_point.get_global_transform_with_canvas().origin
		print(target_pos)
		var info = {
			"id": area.target_connector_id,
			"target_pos": target_pos,
			"dragged_connector_point": connector_2_point
		}
		colliding_targets.append(info)

func _on_piece_connector_2_area_exited(area: Area2D) -> void:
	if area is PieceConnector and area.get_parent() != self:
		colliding_targets = colliding_targets.filter(
			func(e): return e["id"] != area.target_connector_id
		)
