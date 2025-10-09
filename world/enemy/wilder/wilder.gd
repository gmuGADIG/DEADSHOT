extends EnemyBase

## THE WILDER
## The wilder's a terrifying tanky lunatic with a grenade launcher. They zip around spamming grenade projectiles.



#region Variables

#endregion

#region Behaviour Functions

## FIND A NICE POSITION TO RUN TO
func enter_hostile() -> void:
	set_movement_target(NavigationServer3D.map_get_random_point(get_world_3d().get_navigation_map(), 1, false))
## RUN AROUND
func hostile() -> void:
	#set_movement_target(player.global_position);
	should_move = not is_close_to_destination();
	if is_close_to_destination(): switch_state(AggroState.HOSTILE)
## SHOOT AROUND
func attack() -> void:
	pass
#endregion
