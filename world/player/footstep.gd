extends Sprite3D

@export var alpha_curve : Curve

var age : float
func _ready() -> void:
	modulate.a = alpha_curve.sample(alpha_curve.min_domain)
	age = alpha_curve.min_domain

func sand_kick() -> void:
	$CPUParticles3D.emitting = true

func _physics_process(delta: float) -> void:
	modulate.a = alpha_curve.sample(age)
	
	age += delta
	if age > alpha_curve.max_domain:
		queue_free()
