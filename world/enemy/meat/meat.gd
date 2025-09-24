extends Node3D

func _on_area_3d_body_entered(body: Node3D) -> void:
	print("Currecny Colletced")
	Global.meat_currency += 1
	print(Global.meat_currency)
	queue_free()
