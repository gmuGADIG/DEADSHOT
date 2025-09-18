extends Node3D



func _on_area_3d_body_entered(body: Node3D) -> void:
	print("Currecny Collected")
	Global.currency += 1
	print(Global.currency)
	queue_free()
