extends Gun
func fire() -> void:
	for i in 5 :
		var bullet : Bullet
		bullet = preload("res://world/player/weapon/bullet/player_bullet.tscn").instantiate()
		get_tree().current_scene.add_child(bullet)
		bullet.fire(self, Player.instance.aim_dir().rotated(Vector3.UP, i * 0.2))
	
	chamber_ammo -= 1
