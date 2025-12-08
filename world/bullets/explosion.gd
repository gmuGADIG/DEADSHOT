class_name Explosion
extends Area3D

@export var atk_source: DamageInfo.Source

func _on_area_entered(area: Area3D) -> void:
	print("explosion.gd: area = ", area.get_path())
	if area is Hurtbox:
		var hurtbox : Hurtbox = area
		var dmg := DamageInfo.new(5, atk_source, DamageInfo.KnockbackStrength.STRONG, global_position.direction_to(area.global_position))
		hurtbox.hit(dmg)

func _on_lifetime_timeout() -> void:
	queue_free()

