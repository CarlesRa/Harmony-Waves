extends CanvasLayer

@onready var color_rect = %TransitionColorRect

func fade_in(duration: float = 1) -> void:

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(color_rect, "modulate:a", 0.0, duration)

	if AudioManager.is_playing:
		tween.tween_method(
			func(value): 
			AudioServer.set_bus_volume_db(
				AudioServer.get_bus_index("Master"), value
			),
			-80.0,
			0.0,
			duration
		)

	await tween.finished

func fade_out(duration: float = 5) -> void:	
	var tween = create_tween()

	tween.set_parallel(true)
	tween.tween_property(color_rect, "modulate:a", 1.0, duration)

	if AudioManager.is_playing:
		tween.tween_method(
			func(value): 
			AudioServer.set_bus_volume_db(
				AudioServer.get_bus_index("Master"), value
			),
			0.0,
			-80.0,
			duration
		)

	await tween.finished
