extends Area3D


func _on_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	print("collision") # Replace with function body.
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact") and has_overlapping_bodies():
		print("interact")
