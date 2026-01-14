extends EnemyBase

# Called when the node enters the scene tree for the first time.
func hostile() -> void:
	set_movement_target(player.global_position);
	should_move = not is_close_to_destination();


# Called every frame. 'delta' is the elapsed time since the previous frame.
func attack() -> void:
	pass

func shoot_bullet() -> void:
	super.shoot_bullet()
	$Sounds/SplitterRattleSound.play()
	
func death() -> void:
	# save that this enemy died
	
	if spawn_on_killed != null:
		var split_sound := $Sounds/SplitterSplitSound
		split_sound.reparent(get_tree().current_scene)
		split_sound.play()
		var spawn := spawn_on_killed.instantiate()
		add_sibling(spawn)
		spawn.global_position = global_position + Vector3(-2,0,0)
		var spawn_2 := spawn_on_killed.instantiate()
		add_sibling(spawn_2)
		spawn_2.global_position = global_position + Vector3(2,0,0)
	else:
		var death_sound := $Sounds/SplitterDeathSound
		death_sound.reparent(get_tree().current_scene)
		death_sound.play()
	
	# free
	queue_free()
