extends Area2D



func _on_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	print('Tucant lareaaa!!!')
	if area is WavePiece:
		var piece: WavePiece = area
		if piece.is_dragging:
			piece.is_dragging = false
