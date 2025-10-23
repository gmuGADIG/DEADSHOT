class_name Bullet
extends Area3D

## How much damage the bullet will do.
@export var atk_damage: int = 0
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
	await get_tree().create_timer(despawn_after_seconds).timeout
	queue_free()


func fire(gun: Node3D, direction: Vector3) -> void:
	global_position = gun.global_position
	velocity = direction * speed

func _process(delta: float) -> void:
	global_position += velocity * delta

func _on_area_entered(area: Area3D) -> void:
	if area is Hurtbox:
		var hurtbox : Hurtbox = area
		var dmg := DamageInfo.new(atk_damage, atk_source, atk_knockback, velocity.normalized())
		var did_damage := hurtbox.hit(dmg)
		
		if did_damage:
			queue_free()
