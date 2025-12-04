extends Node3D

@export var max_vel_change := 0.025 # max vel change that can occur through randomization
@export var knockback_multiplier := 2.0
@export var rotate_speed := 3 # rotation speed in degrees per physics frame
@export var max_velocity := 0.05 # max velocity for x and z directions

var bounce := 0.0 # controls bouncing movement
var amplitude := 0.3 # height of the bounce
var frequency := 6 # bounce speed
var velocity := Vector3(randf_range(-max_vel_change,max_vel_change),0,randf_range(-max_vel_change,max_vel_change)) # velocity for x and z
var hit := false # if tumbleweed was hit by bullet

func _physics_process(delta: float) -> void:
	#rotate on y-plane
	var speed_factor := clampf(velocity.length() * .2, 0, 1)
	%Sprite.rotate_z(deg_to_rad(rotate_speed * speed_factor))
	#%SpriteHolder.rotate_y(deg_to_rad(rotate_speed))
	
	#bounce updates, then calcuate position y using some trig
	bounce += delta * frequency
	position.y = amplitude * sin(bounce * speed_factor)
	
	#if tumbleweed hits the ground, do stuff
	if(position.y < -0.499):
		#if it has been hit, restore velocity and reset hit
		if(hit):
			velocity /= 400.0
			hit = false
		
		#add new force to velocity, clamp it to max velocity
		velocity += Vector3(randf_range(-max_vel_change,max_vel_change), 0, randf_range(-max_vel_change,max_vel_change))
		clampf(velocity.x, -max_velocity, max_velocity)
		clampf(velocity.z, -max_velocity, max_velocity)

	#move the tumbleweed using velocity
	position += velocity * delta
	
	#velocity = velocity.lerp(Vector3.ZERO, 1.0 - exp(-.5 * delta))

func _on_hurtbox_was_hit(dmg: DamageInfo) -> void:
	velocity += dmg.get_knockback() * knockback_multiplier
	hit = true
