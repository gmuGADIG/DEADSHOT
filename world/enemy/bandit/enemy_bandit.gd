extends EnemyBase


# Called when the node enters the scene tree for the first time.
func hostile() -> void:
	set_movement_target(player.global_position);
	should_move = not is_close_to_destination();


# Called every frame. 'delta' is the elapsed time since the previous frame.
func attack() -> void:
	pass
