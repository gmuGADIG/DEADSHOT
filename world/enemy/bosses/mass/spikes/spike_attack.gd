class_name Spike extends Node3D

@export var predict : bool = false
@export_subgroup("Timing")
@export var delay : float = 0.75 ##Time to wait before sending up the spike
@export var spike_curve : Curve ##How the spike moves over time
@export_subgroup("Stationary")
@export var stationary_random_spread_distance : float ## The variance in how far away the spike spawns from the player when they are standing still
@export_subgroup("Predict")
@export var moving_random_spread_distance : float ## The variance in how far away the spike spawns from the player when they are moving
@export var random_spread_degrees : float ## The angle range where spikes can spawn, centered in the direction of the player's velocity




var age : float = 0

func _ready() -> void:
	var player_velocity : Vector3 = Player.instance.velocity.normalized()
	var spike_origin : Vector3 = Player.instance.global_position
	
	var angle : float = 0
	var spike_offset : Vector3
	var distance_multiplier : float
	if !predict or player_velocity == Vector3.ZERO:
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
	
	attack(delta)

func attack(delta : float) -> void:
	if age >= delay: ##Do attack
		$Spike.position.y = spike_curve.sample(age-delay)
		
	age += delta
	if age-delay >= spike_curve.max_domain:
		queue_free()

func _on_damage_area_area_entered(area: Area3D) -> void:
	if area is Hurtbox:
		area.hit(DamageInfo.new(1,DamageInfo.Source.ENEMY))
