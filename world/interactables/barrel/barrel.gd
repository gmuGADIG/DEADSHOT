extends CharacterBody3D

@export var speed := 10.
var was_hit := false
@onready var _animated_sprite := $AnimatedSprite3D 
@onready var enemy_hurter: Area3D = %EnemyHurter


func _physics_process(_delta: float) -> void:
	if move_and_slide():
		for i in range(get_slide_collision_count()):
			var collision := get_slide_collision(i)
			#print(collision.dget_collision_count())
			for j in range(collision.get_collision_count()):
				if not collision.get_normal(j).is_equal_approx(Vector3.UP):
					queue_free()


func hit(bullet: Bullet) -> void:
	if was_hit: return
	was_hit = true
	enemy_hurter.monitoring = true
	enemy_hurter.monitorable = true
	set_collision_layer_value(1, false)
	
	# quantize bullet velocity to nearest vector
	var directions: Array[Vector3] = [
		Vector3.LEFT, Vector3.RIGHT, 
		Vector3.FORWARD, Vector3.BACK
	]
	var dot_result := -INF
	var v := Vector3()
	for dir in directions:
		var d := bullet.velocity.dot(dir)
		if d > dot_result:
			dot_result = d
			v = dir
	
	# play animation (based on direction)
	match v:
		Vector3.RIGHT: _animated_sprite.play("rolling_right")
		Vector3.LEFT: _animated_sprite.play_backwards("rolling_right")
		Vector3.FORWARD: _animated_sprite.play("rolling_up")
		Vector3.BACK: _animated_sprite.play_backwards("rolling_up")
	
	velocity = v * speed
	bullet.queue_free()
