extends CharacterBody3D

@export var speed := 10.
var was_hit := false
@onready var _animated_sprite := $AnimatedSprite3D 
@onready var enemy_hurter: Area3D = %EnemyHurter


func _physics_process(_delta: float) -> void:
	if move_and_slide(): queue_free()


func hit(bullet: Bullet) -> void:
	if was_hit: return
	was_hit = true
	enemy_hurter.monitoring = true
	set_collision_layer_value(1, false)
	
	_animated_sprite.play("rolling")
	
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
	
	velocity = v * speed
	bullet.queue_free()
