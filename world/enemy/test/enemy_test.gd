extends CharacterBody3D

func _on_damage_area_body_entered(body: Node3D) -> void:
	if body is Player:
		body.hurt(1)
	print("GET REKT")
