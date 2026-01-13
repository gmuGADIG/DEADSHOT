extends Control

@export_custom(PROPERTY_HINT_NONE, "suffix:px/s") var scroll_speed := 50.0

func _process(delta: float) -> void:
	position.y -= scroll_speed * delta
