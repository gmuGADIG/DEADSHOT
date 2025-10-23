extends CharacterBody3D

@onready var _animated_sprite := $AnimatedSprite3D 


func _physics_process(delta: float) -> void:
	move_and_slide()


func hit(bullet: Bullet) -> void:
	_animated_sprite.set_frame_and_progress(1,0.0)
	if bullet.velocity.angle_to(Vector3.FORWARD) > 2 :
		velocity.z = 3
	if bullet.velocity.angle_to(Vector3.BACK) > 2 :
		velocity.z = -3
	if bullet.velocity.angle_to(Vector3.LEFT) > 2 :
		velocity.x = 3
	if bullet.velocity.angle_to(Vector3.RIGHT) > 2 :
		velocity.x = -3
	bullet.queue_free()
	await get_tree().create_timer(5.0).timeout
	_animated_sprite.set_frame_and_progress(2,0.0)
