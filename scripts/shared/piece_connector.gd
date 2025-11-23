extends Area2D

class_name PieceConnector

var parent_piece: WavePiece
var connector_id: int = 0
var target_connector_id: int = 0
var snap_position: Vector2

@onready var connector_point := $Connector

func _ready() -> void:
	snap_position = connector_point.global_position
