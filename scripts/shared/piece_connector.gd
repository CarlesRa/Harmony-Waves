extends Area2D

class_name PieceConnector

@onready var connector := $Connector

var parent_piece: WavePiece
var original_material: ShaderMaterial
var connector_id: int = 0
var target_connector_id: int = 0
var snap_position: Vector2
var _is_active: bool
var is_active:
	get:
		return _is_active
	set(value):
		_set_is_active(value)

func _set_is_active(value) -> void:	
	if !value:
		connector.material = null
		return
	connector.material = original_material

@onready var connector_point := $Connector

func _ready() -> void:	
	snap_position = connector_point.global_position
	original_material = connector.material

func initialize_connector() -> void:
	is_active = parent_piece.is_piece_connected
