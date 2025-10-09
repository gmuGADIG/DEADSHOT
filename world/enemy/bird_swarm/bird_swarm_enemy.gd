extends EnemyBase

var timer : float = 0.0;

func hostile() -> void:
	#spawn projectiles when closing in on player
	timer += get_process_delta_time();
	
	if(timer >= 0.5):
		var bullet: Bullet = preload("res://world/enemy/bird_swarm/homing_bird.tscn").instantiate();
		get_tree().current_scene.add_child(bullet);
		var dir: Vector3 = player.global_position - self.global_position;
		dir.y = 0;
		dir = dir.normalized();
		bullet.fire(self, dir);
		timer = 0;
	set_movement_target(player.global_position);
	should_move = not is_close_to_destination();

func attack() -> void:
	#damage player when close
	pass
