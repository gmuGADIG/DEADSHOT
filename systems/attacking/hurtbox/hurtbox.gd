class_name Hurtbox extends Area3D

@export var health_component : Health
@export var allowed_damage_sources : Array[DamageInfo.Source]

func _ready() -> void:
	assert(health_component != null, "No health component added")

## Takes damage. Returns false if the damage source was ignored.
func hit(dmg: DamageInfo) -> bool:
	if dmg.source not in allowed_damage_sources: return false
	
	print(get_parent())
	health_component.hurt(dmg.damage)
	return true
