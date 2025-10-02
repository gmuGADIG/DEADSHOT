extends Sprite3D
var bounce := 0.0
var amplitude := 0.5
var frequency := 4
var velocity := Vector3(randf_range(-maxChange,maxChange),0,randf_range(-maxChange,maxChange))
var maxChange := 0.025
func _physics_process(delta: float) -> void:
	rotate_z(deg_to_rad(3))
	rotate_y(deg_to_rad(3))
	bounce += delta * frequency
	position.y = amplitude * sin(bounce)
	#print(position.y)
	if(position.y < -0.499):
		#print("woah")
		velocity += Vector3(randf_range(-maxChange,maxChange), 0, randf_range(-maxChange,maxChange))
		clampf(velocity.x, -0.05, 0.05)
		clampf(velocity.z, -0.05, 0.05)
	position += velocity

	
