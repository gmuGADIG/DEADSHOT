class_name Spike extends Node3D

@export var moving_random_spread_distance : float
@export var stationary_random_spread_distance : float
@export var random_spread_degrees : float
@export var delay : float ##Time to wait before sending up the spike
@export var spike_curve : Curve ##How the spike moves over time
var age : float = 0

func _ready() -> void:
	var player_velocity : Vector3 = Player.instance.velocity.normalized()
	var spike_origin : Vector3 = Player.instance.global_position
	
	var angle : float = 0
	var spike_offset : Vector3
	var distance_multiplier : float
	if player_velocity == Vector3.ZERO:
		angle = randf_range(0,360)
		spike_offset = Vector3.RIGHT
		distance_multiplier = stationary_random_spread_distance*randf()
	else:
		angle = randf_range(-random_spread_degrees,random_spread_degrees)
		spike_offset = player_velocity
		distance_multiplier = moving_random_spread_distance*randf()
	
	spike_offset = spike_offset.rotated(Vector3.UP,deg_to_rad(angle))
	global_position = spike_origin + spike_offset*distance_multiplier

func _process(delta: float) -> void:
	#$WarningTarget.rotate(Vector3.UP,warning_spin_speed*delta)
	
	if age >= delay: ##Do attack
		$Spike.position.y = spike_curve.sample(age-delay)
		
	age += delta
	if age-delay >= spike_curve.max_domain:
		queue_free()

func _on_damage_area_area_entered(area: Area3D) -> void:
	if area is Hurtbox:
		area.hit(DamageInfo.new(1,DamageInfo.Source.ENEMY))
