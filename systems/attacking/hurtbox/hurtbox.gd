class_name Hurtbox extends Area3D

@export var health_component : Health
@export var allowed_damage_sources : Array[DamageInfo.Source]
@onready var dot_timer : Timer = $DOTTimer

signal was_hit(dmg: DamageInfo)

## Takes damage. Returns false if the damage source was ignored.
func hit(dmg: DamageInfo) -> bool:
	if dmg.source not in allowed_damage_sources: return false
	
	if health_component != null:
		health_component.hurt(dmg.damage)
	
	was_hit.emit(dmg)
	
	return true

## Starts damaging this enemy over time.
## DOT is currently the number of total enemies on fire in the scene.
func damage_over_time() -> void:
	if dot_timer: dot_timer.start()

func _on_dot_timer_timeout() -> void:
	hit(DamageInfo.new(
		EnemyBase.on_fire_count,
		DamageInfo.Source.HAZARD,
		DamageInfo.KnockbackStrength.NONE,
		Vector3.ZERO
	))
	dot_timer.start()
