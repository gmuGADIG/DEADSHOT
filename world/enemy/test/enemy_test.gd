extends EnemyBase

#region Variables

#endregion

#region Behaviour Functions

func hostile() -> void:
	set_movement_target(player.global_position);
	should_move = not is_close_to_destination();

func attack() -> void:
	pass
#endregion
