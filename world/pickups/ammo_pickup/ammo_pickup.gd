extends Area3D

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		grab_ammo()

func grab_ammo() -> void:
	var gun: Gun = Player.instance.get_gun()
	var ammo_added := gun.add_ammo()
	
	var sfx := $AmmoPickupSound
	sfx.reparent(get_tree().current_scene)
	sfx.play()
	
	var flavor_text := preload("res://world/pickups/ammo_pickup/pickup_text/pickup_text.tscn").instantiate()
	flavor_text.set_ammo(ammo_added)
	flavor_text.position = self.position
	add_sibling(flavor_text)
	
	queue_free()
	
