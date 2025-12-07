extends Gun

func fire() -> void:
	var bullet : Bullet = get_bullet_scene().instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.fire(self, Player.instance.aim_dir())
	bullet.atk_damage = get_damage()
	bullet.explosive = SkillSet.has_skill(SkillSet.SkillUID.RIFLE_EXPLOSIVE_SHOT)
	
	%ShootSound.play()
	
	chamber_ammo -= 1
