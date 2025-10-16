extends CharacterBody3D

func _physics_process(delta: float) -> void:
	move_and_slide()


func hit(bullet: Bullet) -> void:
	if bullet.velocity.angle_to(Vector3.FORWARD) > 2 :
		velocity.z = 3
	if bullet.velocity.angle_to(Vector3.BACK) > 2 :
		velocity.z = -3
	if bullet.velocity.angle_to(Vector3.LEFT) > 2 :
		velocity.x = 3
	if bullet.velocity.angle_to(Vector3.RIGHT) > 2 :
		velocity.x = -3
	bullet.queue_free()
	
