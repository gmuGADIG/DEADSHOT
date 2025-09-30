class_name Bullet
extends Area3D

const SPEED := 40.0

var velocity: Vector3

func fire(gun: Node3D, direction: Vector3) -> void:
	global_position = gun.global_position
	velocity = direction * SPEED

func _process(delta: float) -> void:
	global_position += velocity * delta

func _on_body_entered(body: Node3D) -> void:
	print("Shot `%s`" % body.name)
