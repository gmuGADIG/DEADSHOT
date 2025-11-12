class_name BirdSwarm
extends EnemyBase

var timer : float = 0.0;
@export var MELEE_RANGE: float = 0.3
@export var MELEE_DAMAGE: int = 2
@export var homing_bird_fire_speed: float = 0.5


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
		if(timer >= homing_bird_fire_speed):
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

func _on_damagebox_area_entered(area: Area3D) -> void:
	if area is Hurtbox:
		var hurtbox : Hurtbox = area
		var dmg := DamageInfo.new(damage, DamageInfo.Source.ENEMY, 0, velocity.normalized())
		hurtbox.hit(dmg)
		 # Replace with function body.
