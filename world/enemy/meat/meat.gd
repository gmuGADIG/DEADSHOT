extends Node3D

func _on_area_3d_body_entered(body: Node3D) -> void:
	if not body is Player:
		return
	
	print("Currecny Colletced")
	Global.meat_currency += 3
	print(Global.meat_currency)
	
	var flavor_text: PickupText = preload("res://world/pickups/ammo_pickup/pickup_text/pickup_text.tscn").instantiate()
	flavor_text.set_meat(3)
	flavor_text.position = self.position
	add_sibling(flavor_text)
		
	# Play the meat pickup sound
	var sfx := $MeatPickupSound
	sfx.reparent(get_tree().current_scene)
	sfx.play()
	
	queue_free()
