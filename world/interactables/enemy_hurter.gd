extends Hurtbox

@export var damage: float = 3 

func hit(dmg: DamageInfo) -> bool:
	print("hit barrel")
	return true ##Gaslights bullets into killing themselves

func _on_area_entered(area: Area3D) -> void:
	if area is Hurtbox:
		area.hit(DamageInfo.new(
			damage, 
			DamageInfo.Source.PLAYER, 
			DamageInfo.KnockbackStrength.NORMAL,
			global_position.direction_to(area.global_position)
		))
	elif area is Bullet:
		area.queue_free()
