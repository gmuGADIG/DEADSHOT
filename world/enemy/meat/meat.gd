extends Node3D

func _on_area_3d_body_entered(body: Node3D) -> void:
	if not body is Player:
		return
	
	print("Currecny Colletced")
	Global.meat_currency += 1
	print(Global.meat_currency)
	queue_free()
