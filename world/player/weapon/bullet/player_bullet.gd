class_name Bullet
extends Area3D

@export var atk_damage: int = 0
@export var atk_source: DamageInfo.Source
@export var atk_knockback: DamageInfo.KnockbackStrength

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
		hurtbox.hit(DamageInfo.new(atk_damage, atk_source, atk_knockback, velocity.normalized()))
