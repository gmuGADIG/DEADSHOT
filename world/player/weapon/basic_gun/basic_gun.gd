extends Gun

func fire(consumes_ammo: bool, damage_mul: float) -> void:
	var bullet : Bullet = get_bullet()
	get_tree().current_scene.add_child(bullet)
	bullet.fire(self, Player.instance.aim_dir())
	bullet.atk_damage = get_damage() * damage_mul
	bullet.explosive = SkillSet.has_skill(SkillSet.SkillUID.RIFLE_EXPLOSIVE_SHOT)
	
	%ShootSound.play()
	
	if consumes_ammo: chamber_ammo -= 1
