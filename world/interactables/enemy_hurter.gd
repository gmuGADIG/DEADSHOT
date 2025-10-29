extends Area3D

@export var damage: int = 1

func _on_area_entered(area: Area3D) -> void:
	if area is Hurtbox:
		area.hit(DamageInfo.new(
			damage, 
			DamageInfo.Source.PLAYER, 
			DamageInfo.KnockbackStrength.NORMAL,
			global_position.direction_to(area.global_position)
		))
