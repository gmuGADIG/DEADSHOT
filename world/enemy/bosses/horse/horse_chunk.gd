extends Area3D

var stopPoint: Vector3

@export var speed: float = 1.0

var velocity: Vector3

signal reached_point

func _process(delta: float) -> void:
	global_position += velocity * delta
	if global_position.distance_to(stopPoint) < 0.1:
		reached_point.emit()
		var splat_sfx := $MassSplatSound
		if splat_sfx:
			splat_sfx.reparent(get_tree().current_scene)
			splat_sfx.play()
		queue_free()

func set_target(target: Vector3) -> void:
	stopPoint = target
	var dir := target - position
	dir.y = 0
	velocity = dir.normalized() * speed
