extends BossEnemy

@export var num_shots_in_spread: int = 5
@export var spread_angle: float = 45.0
@export var rock_speed: float = 2
const rock_obj := preload("res://world/enemy/bosses/horse/rock.tscn")
func pick_action() -> void:
	if len(phase_1_action_names) == 0: return
	action_player.play(phase_1_action_names.pick_random())

func idle() -> void: pass

func stomp_fire_attack() -> void:
	print("stomp fire")
	for i in range(num_shots_in_spread):
		var bullet_reference: Node3D = rock_obj.instantiate()
		add_sibling(bullet_reference)
		bullet_reference.global_position = global_position
		bullet_reference.set_speed(rock_speed)

		var target_position: Vector3 = player.global_position if player else (global_position + Vector3(0, 0, 1))
		var direction: Vector3 = (target_position - global_position).normalized()
		var base_angle: float = direction.angle_to(Vector3.FORWARD)
		var angle_offset: float = spread_angle * ((float(i) / (num_shots_in_spread - 1)) - 0.5)
		var final_angle: float = base_angle + deg_to_rad(angle_offset)
		var final_direction: Vector3 = -Vector3(sin(final_angle), 0, cos(final_angle)).normalized()
		bullet_reference.set_target(global_position + final_direction * 10)

		print("Fired rock at angle offset: %f" % angle_offset)
