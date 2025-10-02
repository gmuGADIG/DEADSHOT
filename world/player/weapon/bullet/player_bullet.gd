class_name Bullet
extends Area3D

@export var damage_component : DamageComponent

const SPEED := 40.0

var velocity: Vector3

func fire(gun: Node3D, direction: Vector3) -> void:
	global_position = gun.global_position
	velocity = direction * SPEED

func _process(delta: float) -> void:
	global_position += velocity * delta

func _on_body_entered(body: Node3D) -> void:
	print("Bullet hit `%s`" % body.name)


func _on_area_entered(area: Area3D) -> void:
	if area is HurtboxComponent:
		var hurtbox : HurtboxComponent = area
		hurtbox.hit(damage_component)
