extends Node3D

func _on_area_3d_body_entered(body: Node3D) -> void:
	if not body is Player:
		return
	
	print("Currecny Colletced")
	Global.meat_currency += 1
	print(Global.meat_currency)
	
	# Play the meat pickup sound
	var pickup_sound := preload("res://audio/streams/meat_pickup_sound.tscn").instantiate()
	add_sibling(pickup_sound)
	queue_free()
