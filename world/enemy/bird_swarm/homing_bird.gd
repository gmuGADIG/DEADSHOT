class_name HomingBird
extends Bullet

func _ready() -> void:
	super._ready()

func fire(gun: Node3D, direction: Vector3) -> void:
	super.fire(gun, direction)
	if direction.x < 0: scale.x *= -1

#
#func _process(delta: float) -> void:
	#home_direction = Player.instance.global_position - self.global_position;
	#velocity = home_direction * homingBirdSpeed
	#global_position.x += velocity.x * delta
	#global_position.z += velocity.z * delta
#
#func _on_area_entered(area: Area3D) -> void:
	#if area is Hurtbox:
		#var hurtbox : Hurtbox = area
		#var dmg := DamageInfo.new(atk_damage, atk_source, atk_knockback, velocity.normalized())
		#var did_damage := hurtbox.hit(dmg)
		#
		#if did_damage:
			#queue_free()
