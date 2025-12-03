extends Gun

func fire() -> void:
	var bullet : Bullet = get_bullet_scene().instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.fire(self, Player.instance.aim_dir())
	
	%ShootSound.play()
	
	chamber_ammo -= 1
