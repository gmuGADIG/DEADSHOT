class_name Spike extends Node3D

@export var warning_spin_speed : float
@export var spike_curve : Curve
@export var damage : DamageInfo

var age : float = 0


func _process(delta: float) -> void:
	$WarningTarget.rotate(Vector3.UP,warning_spin_speed*delta)
	$Spike.position.y = spike_curve.sample(age)
	age+= delta
	if age >= spike_curve.max_domain:
		queue_free()
	
