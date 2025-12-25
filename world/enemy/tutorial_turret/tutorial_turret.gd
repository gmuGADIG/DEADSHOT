extends StaticBody3D

@export var bullet : PackedScene

func shoot() -> void:
	var new_bullet : Bullet = bullet.instantiate()
	add_sibling(new_bullet)
	new_bullet.global_position = $ShootOrigin.global_position
	new_bullet.velocity = Vector3.LEFT * new_bullet.speed


func _on_killed() -> void:
	queue_free()
