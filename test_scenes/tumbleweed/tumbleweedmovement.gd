extends Sprite3D

var bounce := 0.0 #controls bouncing movement
var amplitude := 0.5 #height of the bounce
var frequency := 4 #bounce speed
var velocity := Vector3(randf_range(-maxVelChange,maxVelChange),0,randf_range(-maxVelChange,maxVelChange)) #velocity for x and z
var hit := false #if tumbleweed was hit by bullet
@export var maxVelChange := 0.025 #max vel change that can occur through randomization
@export var knockbackResistance := 200 #how resistant tumbleweed is to getting shot (higher number = less movement)
@export var rotateSpeed := 3 #rotation speed
@export var maxVelocity := 0.05 #max velocity for x and z directions
func _physics_process(delta: float) -> void:
	#rotate on y-plane
	rotate_z(deg_to_rad(rotateSpeed))
	rotate_y(deg_to_rad(rotateSpeed))
	#bounce updates, then calcuate position y using some trig
	bounce += delta * frequency
	position.y = amplitude * sin(bounce)
	#if tumbleweed hits the ground, do stuff
	if(position.y < -0.499):
		#if it has been hit, restore velocity and reset hit
		if(hit):
			velocity /= (knockbackResistance * 2)
			hit = false
		#add new force to velocity, clamp it to max velocity
		velocity += Vector3(randf_range(-maxVelChange,maxVelChange), 0, randf_range(-maxVelChange,maxVelChange))
		clampf(velocity.x, -maxVelocity, maxVelocity)
		clampf(velocity.z, -maxVelocity, maxVelocity)
	#move the tumbleweed using velocity
	position += velocity


func _on_area_3d_area_entered(area: Area3D) -> void:
	#when hit, print message, add bullet vel / knockback resistance to vel, and set hit to true
	print("Tumbleweed has been shot...")
	velocity += area.velocity / knockbackResistance
	hit = true
