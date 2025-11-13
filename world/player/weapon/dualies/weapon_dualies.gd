extends Gun

func fire() -> void:
	set_gun_rotation()
	add_bullet($Right)
	add_bullet($Left)
	%ShootSound.play()

## Rotate Dualies to aim direction to keep bullet spawn points correct
func set_gun_rotation() -> void:
	self.look_at(player.global_position+player.aim_dir())
	rotation.x=0.0
	rotation.z=0.0

func add_bullet(gun: Node3D) -> void:
	var bullet : Bullet
	if bullets_of_fire_unlocked:
		bullet = preload("res://world/player/weapon/bullet/fire_bullet.tscn").instantiate()
	else:
		bullet = preload("res://world/player/weapon/bullet/player_bullet.tscn").instantiate()
	get_tree().current_scene.add_child(bullet)
	#TODO: Damage uses integers right now. It should either use floats or much bigger integers.
	# The standard pistol bullet does 2 damage. Each dualie bullet needs to do somewhere between 50-100% of that.
	# We override the bullet's damage here in code. This could be set up later as an export variable, or as a 
	# unique bullet scene, but I didn't see the point.
	bullet.atk_damage = 7
	bullet.fire(gun, player.aim_dir())
	chamber_ammo -= 1
