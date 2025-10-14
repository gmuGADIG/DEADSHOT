extends Sprite3D

@export var max_vel_change := 0.025 # max vel change that can occur through randomization
@export var knockback_resistance := 200 # how resistant tumbleweed is to getting shot (higher number = less movement)
@export var rotate_speed := 3 # rotation speed in degrees per physics frame
@export var max_velocity := 0.05 # max velocity for x and z directions

var bounce := 0.0 # controls bouncing movement
var amplitude := 0.5 # height of the bounce
var frequency := 4 # bounce speed
var velocity := Vector3(randf_range(-max_vel_change,max_vel_change),0,randf_range(-max_vel_change,max_vel_change)) # velocity for x and z
var hit := false # if tumbleweed was hit by bullet

func _physics_process(delta: float) -> void:
	#rotate on y-plane
	rotate_z(deg_to_rad(rotate_speed))
	rotate_y(deg_to_rad(rotate_speed))
	
	#bounce updates, then calcuate position y using some trig
	bounce += delta * frequency
	position.y = amplitude * sin(bounce)
	
	#if tumbleweed hits the ground, do stuff
	if(position.y < -0.499):
		#if it has been hit, restore velocity and reset hit
		if(hit):
			velocity /= (knockback_resistance * 2)
			hit = false
		
		#add new force to velocity, clamp it to max velocity
		velocity += Vector3(randf_range(-max_vel_change,max_vel_change), 0, randf_range(-max_vel_change,max_vel_change))
		clampf(velocity.x, -max_velocity, max_velocity)
		clampf(velocity.z, -max_velocity, max_velocity)

	#move the tumbleweed using velocity
	position += velocity

func _on_area_3d_area_entered(area: Area3D) -> void:
	#when hit, print message, add bullet vel / knockback resistance to vel, and set hit to true
	print("Tumbleweed has been shot...")
	velocity += area.velocity / knockback_resistance
	hit = true
