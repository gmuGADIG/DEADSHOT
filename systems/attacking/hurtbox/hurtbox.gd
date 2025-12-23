class_name Hurtbox extends Area3D

@export var health_component : Health
@export var allowed_damage_sources : Array[DamageInfo.Source]

signal was_hit(dmg: DamageInfo)

## Takes damage. Returns false if the damage source was ignored.
func hit(dmg: DamageInfo) -> bool:
	if dmg.source not in allowed_damage_sources: return false
	if health_component.vulnerable == false: return false
	
	if health_component != null:
		health_component.hurt(dmg.damage)
	
	was_hit.emit(dmg)
	
	return true
