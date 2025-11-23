extends Area2D



func _on_area_shape_entered(_area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	if area is WavePiece:
		var piece: WavePiece = area
		if piece.is_dragging:
			piece.is_dragging = false
