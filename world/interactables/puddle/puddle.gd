extends Area3D

@export var player_speed_mult: float = 0.5
@export var atk_damage: int

@onready var damage_timer: Timer = %DamageTimer

func _on_body_entered(body: Node3D) -> void:
	# lower player's movement multiplier. starts the damage timer
	if body is Player:
		body.speed_multiplier = player_speed_mult
		damage_timer.start()

func _on_body_exited(body: Node3D) -> void:
	# reset damage timer. return player movement multiplier back to normal (1)
	if body is Player:
		body.speed_multiplier = 1.0
		damage_timer.stop()

func _on_damage_timer_timeout() -> void:
	var overlaps := get_overlapping_areas()
	print("Puddle damaging (overlaps = %s)" % str(overlaps))
	for obj in overlaps:
		if obj is Hurtbox:
			obj.hit(DamageInfo.new(
				atk_damage,
				DamageInfo.Source.HAZARD,
				DamageInfo.KnockbackStrength.NONE,
				Vector3.ZERO
			))
