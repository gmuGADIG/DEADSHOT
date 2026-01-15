class_name Spike extends Node3D

@export var delay : float = 0.75 ##Time to wait before sending up the spike
@export var spike_curve : Curve ##How the spike moves over time

var debounce: bool = false

var age : float = -1

func prime() -> void:
	age = 0

func _process(delta: float) -> void:
	if age >= delay: ##Do attack
		$Spike.position.y = spike_curve.sample(age-delay)
		
		if $SpikePierceSound and not debounce:
			debounce = true
			$SpikePierceSound.play()
	
	if age >= 0:
		age += delta
	
	if age-delay >= spike_curve.max_domain:
		queue_free()

func _on_damage_area_area_entered(area: Area3D) -> void:
	if area is Hurtbox:
		area.hit(DamageInfo.new(1,DamageInfo.Source.ENEMY))
