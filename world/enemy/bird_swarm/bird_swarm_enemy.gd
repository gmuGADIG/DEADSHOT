class_name BirdSwarm
extends EnemyBase

var timer : float = 0.0;
const MELEE_RANGE: float = 2.0
const MELEE_DAMAGE: int = 10


func fireHomingBird() -> void:
	var homingBird: HomingBird = preload("res://world/enemy/bird_swarm/homing_bird.tscn").instantiate()
	get_tree().current_scene.add_child(homingBird)
	
	homingBird.atk_damage = 1
	
	homingBird.fire(self,player.global_position - self.global_position)

func hostile() -> void:
	#spawn projectiles when closing in on player
	timer += get_process_delta_time();
	
	var distance_to_player: float = global_position.distance_to(player.global_position)
	
	if distance_to_player > MELEE_RANGE:
		if(timer >= 0.9):
			fireHomingBird()
			timer = 0;
	else:
		attack()
		timer = 0
	
	
	set_movement_target(player.global_position);
	should_move = not is_close_to_destination();



func attack() -> void:
	#damage player when close
	if not player:
		return
		
	var distance_to_player: float = global_position.distance_to(player.global_position)
	
	if distance_to_player <= MELEE_RANGE:
		print("BirdSwarm launches melee attack!") 
		
		if player.has_method("take_damage"):
			player.take_damage(10)
			print("Melee attack! Deal 10 damage")
		elif player.has_method("damage"):
			player.damage(10)
			print("Melee attack! Deal 10 damage")	
		elif player.has_method("hurt"):
			player.hurt(10)
			print("Melee attack! Deal 10 damage")
		else:
			push_warning("BirdSwarm: Player has no damage method")
