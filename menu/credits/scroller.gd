extends Node2D

@export_custom(PROPERTY_HINT_NONE, "suffix:px/s") var scroll_speed := 50.0

var real_speed := 0.

func start() -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_LINEAR) 
	tween.tween_property(self, "real_speed", scroll_speed, 2.) 

func _process(delta: float) -> void:
	position.y -= real_speed * delta
