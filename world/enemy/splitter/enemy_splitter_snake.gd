extends EnemyBase

#region Variables

#endregion

#region Behaviour Functions

func hostile() -> void:
	set_movement_target(player.global_position);
	should_move = not is_close_to_destination();

func attack() -> void:
	pass

func shoot_bullet() -> void:
	super.shoot_bullet()
	$Sounds/SplitterSmallRattleSound.play()

func death() -> void:
	# save that this enemy died
	
	var death_sound := $Sounds/SplitterDeathSound
	death_sound.reparent(get_tree().current_scene)
	death_sound.play()
	
	# drop stuff
	drop_tonic()
	if spawn_on_killed != null:
		var spawn := spawn_on_killed.instantiate()
		add_sibling(spawn)
		spawn.global_position = global_position
	
	# free
	queue_free()
#endregion
