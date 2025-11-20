extends EnemyBase

func hostile() -> void:
	set_movement_target(player.global_position);
	should_move = not is_close_to_destination();
	
func attack() -> void:
	pass
