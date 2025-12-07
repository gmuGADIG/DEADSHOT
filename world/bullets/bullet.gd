class_name Bullet
extends Area3D

## How much damage the bullet will do.
@export var atk_damage: float = 0
## The bullet's allegiance. The bullet won't hurt anyone in this group.
@export var atk_source: DamageInfo.Source
## The knockback added to anyone hurt by the bullet.
@export var atk_knockback: DamageInfo.KnockbackStrength
## How long the bullet is allowed to live before despawning
@export var despawn_after_seconds : float = 5.0
## How fast the bullet travels.
@export var speed: float = 40.0

var velocity: Vector3

func _ready() -> void:
	# Immediately set the despawn timer and wait
	await get_tree().create_timer(despawn_after_seconds).timeout
	queue_free()

## Creates the bullet.
func fire(gun: Node3D, direction: Vector3) -> void:
	global_position = gun.global_position
	velocity = direction * speed

## Optionally aims the bullet towards a given point.
func set_target(target: Vector3) -> void:
	var dir := target - position
	dir.y = 0
	velocity = dir.normalized() * speed
	
## Optionally overrides the bullet speed with code.
func set_speed(newspeed: float) ->void:
	speed = newspeed
	velocity = velocity.normalized()*speed

func _process(delta: float) -> void:
	global_position += velocity * delta
	global_position.y = 1.0

func _on_area_entered(area: Area3D) -> void:
	if area is Hurtbox:
		var hurtbox : Hurtbox = area
		var dmg := DamageInfo.new(atk_damage, atk_source, atk_knockback, velocity.normalized())
		var did_damage := hurtbox.hit(dmg)
		
		if did_damage:
			queue_free()

func _on_body_entered(body: Node3D) -> void:
	if body.has_method("hit"):
		body.hit(self)
