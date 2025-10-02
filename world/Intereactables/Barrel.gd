extends CharacterBody3D

func _physics_process(delta: float) -> void:
	move_and_slide()

func hit(bullet: Bullet) -> void:
	if bullet.velocity.angle_to(Vector3.FORWARD) > 3 :
		velocity.z = 1
	else:
		velocity.z = -1
	#if bullet.velocity.angle_to(Vector3.LEFT) > 3:
		#velocity.x = -1
	#else:
		#velocity.x = 1
	
	print(bullet.velocity.angle_to(Vector3.FORWARD))
	print(bullet.velocity.angle_to(Vector3.LEFT))
	
	#print(velocity.x)
	#print(velocity.z)
	#velocity = bullet.velocity
	bullet.queue_free()
