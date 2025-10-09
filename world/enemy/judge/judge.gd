extends EnemyBase

#region Variables
#endregion

#region Behaviour Functions

func _init()->void:
	max_hp = 100 #Obviously these are subject to change
	damage = 5  #Don't know how much HP the player has rn so consider these placeholders


func hostile()->void:
	set_movement_target(player.global_position);
	should_move = not is_close_to_destination();
	#Took this from enemy_test.gd, I figure that an aggressive enemy
	#would pursue you in order to shoot you with a shotgun, a short-range weapon

func attack()->void:
	pass
#endregion
