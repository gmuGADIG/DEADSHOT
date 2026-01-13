extends EnemyBase

# Called when the node enters the scene tree for the first time.
func hostile() -> void:
	set_movement_target(player.global_position);
	should_move = not is_close_to_destination();


# Called every frame. 'delta' is the elapsed time since the previous frame.
func attack() -> void:
	pass
	
func death() -> void:
	# save that this enemy died
	
	if spawn_on_killed != null:
		var spawn := spawn_on_killed.instantiate()
		add_sibling(spawn)
		spawn.global_position = global_position + Vector3(-2,0,0)
		var spawn_2 := spawn_on_killed.instantiate()
		add_sibling(spawn_2)
		spawn_2.global_position = global_position + Vector3(2,0,0)
	
	# free
	queue_free()
