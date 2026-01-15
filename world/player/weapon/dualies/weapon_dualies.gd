extends Gun

func fire(consumes_ammo: bool, damage_mul: float) -> void:
	var double_shot := SkillSet.has_skill(SkillSet.SkillUID.PISTOL_DOUBLE_SHOT)

	# set_gun_rotation() # already covered by _process 
	add_bullet($Right, consumes_ammo, damage_mul)
	%ShootSound.play()

	await get_tree().create_timer(0.08, false).timeout

	add_bullet($Left, consumes_ammo, damage_mul)
	%ShootSound.play()

	if double_shot:
		await get_tree().create_timer(0.08, false).timeout
		add_bullet($Right, false, damage_mul)
		%ShootSound.play()
		
		await get_tree().create_timer(0.08, false).timeout
		add_bullet($Left, false, damage_mul)
		%ShootSound.play()

func add_bullet(gun: Node3D, consumes_ammo: bool, damage_mul: float) -> void:
	var bullet : Bullet = get_bullet()
	get_tree().current_scene.add_child(bullet)
	bullet.atk_damage = get_damage() * damage_mul
	bullet.fire(gun, player.aim_dir())

	if consumes_ammo: chamber_ammo -= 1
