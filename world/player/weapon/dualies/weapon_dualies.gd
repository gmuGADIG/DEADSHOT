extends Gun

func fire() -> void:
	# set_gun_rotation() # already covered by _process 
	add_bullet($Right)
	add_bullet($Left)
	%ShootSound.play()

func add_bullet(gun: Node3D) -> void:
	var bullet : Bullet = get_bullet_scene().instantiate()
	get_tree().current_scene.add_child(bullet)
	# The standard pistol bullet does 2 damage. Each dualie bullet needs to do somewhere between 50-100% of that.
	# We override the bullet's damage here in code. This could be set up later as an export variable, or as a 
	# unique bullet scene, but I didn't see the point.
	bullet.atk_damage = .75
	bullet.fire(gun, player.aim_dir())
	chamber_ammo -= 1
