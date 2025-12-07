extends Gun

func fire(consumes_ammo: bool, damage_mul: float) -> void:
	# set_gun_rotation() # already covered by _process 
	add_bullet($Right, consumes_ammo, damage_mul)
	add_bullet($Left, consumes_ammo, damage_mul)
	%ShootSound.play()

func add_bullet(gun: Node3D, consumes_ammo: bool, damage_mul: float) -> void:
	var bullet : Bullet = get_bullet_scene().instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.atk_damage = get_damage() * damage_mul
	bullet.fire(gun, player.aim_dir())

	if consumes_ammo: chamber_ammo -= 1
