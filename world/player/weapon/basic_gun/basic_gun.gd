extends Gun

func fire() -> void:
	var bullet : Bullet
	if bullets_of_fire_unlocked:
		bullet = preload("res://world/player/weapon/bullet/fire_bullet.tscn").instantiate()
	else:
		bullet = preload("res://world/player/weapon/bullet/player_bullet.tscn").instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.fire(self, Player.instance.aim_dir())
	
	%ShootSound.play()
	
	chamber_ammo -= 1
