extends Node3D

const DMG_PER_HIT := 0.25

@onready var hurtbox: Hurtbox = get_parent()
@onready var dot_timer: Timer = %DOTTimer
var on_fire := false
var stacks := 0

## Starts damaging this enemy over time.
## Does nothing if the enemy is already on fire.
func set_on_fire() -> void:
	stacks += 1
	if on_fire: return
	on_fire = true
	
	dot_timer.start()
	# %FireStartSound.play()
	%FireParticles.emitting = true
	%FireLight.show()

func _on_dot_timer_timeout() -> void:
	# %FireHitSound.play()
	hurtbox.hit(DamageInfo.new(
		DMG_PER_HIT * stacks,
		DamageInfo.Source.PLAYER,
		DamageInfo.KnockbackStrength.NONE,
		Vector3.ZERO
	))
