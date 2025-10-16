class_name BirdSwarm
extends EnemyBase

var timer : float = 0.0;

func fireHomingBird() -> void:
	var homingBird: HomingBird = preload("res://world/enemy/bird_swarm/homing_bird.tscn").instantiate()
	get_tree().current_scene.add_child(homingBird)
	homingBird.fire(self,player.global_position - self.global_position)

func hostile() -> void:
	#spawn projectiles when closing in on player
	timer += get_process_delta_time();
	
	if(timer >= 0.9):
		fireHomingBird()
		timer = 0;
	set_movement_target(player.global_position);
	should_move = not is_close_to_destination();

func attack() -> void:
	#damage player when close
	pass
