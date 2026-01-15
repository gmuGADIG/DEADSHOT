class_name Sheriff
extends Wilder

#enum SelectedAttack{
	#WHIP,
	#STAR
#}

@export var barrage_time : float
@export var star : PackedScene
@export var slash : PackedScene

#var selected_attack : SelectedAttack = SelectedAttack.STAR

func _ready() -> void:
	super._ready()
	$FiringTimerREAL.timeout.connect(func() -> void:
		if aggro != AggroState.ATTACKING:
			barrage()
	)
	$FiringTimerREAL.start(barrage_time)
	
#func pick_target(flee : bool) -> void:
	#if not flee:
		#barrage()
	#super.pick_target(flee)
	
func shoot(shoot_dir : Vector3) -> void:
	var newBullet: Bullet = bullet.instantiate()
	newBullet.atk_source = DamageInfo.Source.ENEMY
	add_sibling(newBullet)
	newBullet.fire(self, shoot_dir)
	$SheriffShootSound.play()
	
func _on_killed() -> void:
	var die_sound:AudioStreamPlayer3D = $BossDeathSound
	die_sound.reparent(get_tree().current_scene)
	die_sound.play()

func fire() -> void:
	$SheriffShootSound.play()
	shoot_star()
	switch_state(AggroState.BENIGN)
	
func shoot_star() -> void:
	var new_star : = star.instantiate()
	new_star.atk_source = DamageInfo.Source.ENEMY
	add_sibling(new_star)
	new_star.fire(self, getPlayerDirection())

func do_slash() -> void:
	var new_slash : = slash.instantiate()
	new_slash.atk_source = DamageInfo.Source.ENEMY
	add_sibling(new_slash)
	new_slash.fire(self, getPlayerDirection())
	pass
