extends Item

func on_pickup(body: Node3D) -> void:
	var player: Player = body as Player;
	if player:
		print("res://world/player/weapon/" + name + "/" + name + ".tscn")
		var gun_scene: PackedScene = load("res://world/player/weapon/" + name + "/" + name + ".tscn")
		if gun_scene:
			swap_gun(player, gun_scene)

	
func swap_gun(player: Player, new_gun_scene: PackedScene) -> void:
	if player.has_node(player.gun_name):
		player.get_node(player.gun_name).queue_free()
	
	var new_gun: Node = new_gun_scene.instantiate()
	player.add_child(new_gun)
	new_gun.owner = player
	
	player.gun_name = new_gun.name
	
	# Can be reformatted when guns have more consistent naming
	if name == "dual_pistols":
		player.get_node("Sprite3D").texture = load("res://temp_art/player_dual_pistols_temp.png")
	else:
		player.get_node("Sprite3D").texture = load("res://temp_art/gartic/harry_potter_with_gun.png")
