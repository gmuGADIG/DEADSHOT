extends Bullet

## Overrides the damage doing 
func _on_area_entered(area: Area3D) -> void:
	if area.get_parent() is EnemyBase:
		var enemy := area.get_parent() as EnemyBase
		enemy.set_on_fire()
	elif area is Hurtbox:
		var hurtbox : Hurtbox = area
		var dmg := DamageInfo.new(atk_damage, atk_source, atk_knockback, velocity.normalized())
		hurtbox.hit(dmg)
