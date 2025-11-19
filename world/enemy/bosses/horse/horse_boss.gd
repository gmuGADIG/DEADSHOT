extends BossEnemy

const rock_obj := preload("res://world/enemy/bosses/horse/horse_rock.tscn")
const splash_obj := preload("res://world/enemy/bosses/horse/horse_splash.tscn")
const chunk_obj := preload("res://world/enemy/bosses/horse/horse_chunk.tscn")

@export var roam_points: Array[Node3D]
@export var num_shots_in_spread: int = 5
@export var spread_angle: float = 45.0
@export var rock_speed: float = 0.25
@export var charge_time:float
@export var cooldown_time:float
@export var atk_source: DamageInfo.Source
@export var atk_knockback: DamageInfo.KnockbackStrength

@export var mass_chunk_amount: int = 3
@export var player_still_spread_distance : float = 15 ## Used by spike field, and rapid spike when the player is not moving


var is_charging:bool = false
var target:Vector3

@onready var timer: Timer = %ChargeTimer

@onready var shaker: SpriteShaker = %SpriteShaker

@export var floor_area: Path3D

var current_action: StringName = ""

func pick_action() -> void:
	
	if len(phase_1_action_names) == 0: return
	if current_action != "": 
		print("Action in progress, not picking new action")
		return
	var action_name: StringName = phase_1_action_names.pick_random()
	action_player.play(action_name)
	current_action = action_name
	print("picking action ", action_name)
func _ready() -> void:
	super._ready()
	timer.connect("timeout", _on_charge_timer_timeout)

func idle() -> void: pass

#region Stomp_funcs
func get_2d_angle(from: Vector3, to: Vector3) -> float:
	var cross := from.cross(to)
	var dot := from.dot(to)
	var angle := atan2(cross.y, dot)
	return angle
func stomp_fire_attack() -> void:
	print("stomp fire")
	aggro = AggroState.ATTACKING
	should_move = false
	for i in range(num_shots_in_spread):
		var bullet_reference: Node3D = rock_obj.instantiate()
		add_sibling(bullet_reference)
		bullet_reference.global_position = global_position

		var target_position: Vector3 = player.global_position
		var direction: Vector3 = (target_position - global_position).normalized()
		var base_angle: float = get_2d_angle(Vector3.FORWARD, direction)
		var angle_offset: float = spread_angle * ((float(i) / (num_shots_in_spread - 1)) - 0.5)
		var final_angle: float = base_angle + deg_to_rad(angle_offset)
		var final_direction: Vector3 = -Vector3(sin(final_angle), 0, cos(final_angle)).normalized()
		bullet_reference.set_target(global_position + final_direction * 10)

		print("Fired rock at angle offset: %f" % rad_to_deg(final_angle))
#endregion

#region Longhorn_funcs
func longhorn_charge_ready() -> void:
	
	
	print("Charging")
	
	shaker.shaking = true



func longhorn_charge_attack() -> void:
	is_charging = true
	aggro = AggroState.ATTACKING
	%Health.vulnerable = false
	target = player.global_position
	print("attacking")
	
	
func _on_charge_timer_timeout() -> void:
	if not is_charging: 
		current_action = ""
		roam()
		pick_action()
		
	
func _on_hurter_box_area_entered(area: Area3D) -> void:
	if area is Hurtbox:
		var hurtbox : Hurtbox = area
		@warning_ignore("narrowing_conversion")
		var dmg := DamageInfo.new(damage, atk_source, atk_knockback, velocity.normalized())
		var did_damage := hurtbox.hit(dmg)
		print(hurtbox.get_parent())
		if did_damage:
			print("owie")

func action_finished(anim_name: StringName) -> void:
	if current_action == &"charge":
		print("charge anim finished, waiting for stop")
	else:
		current_action = ""
		super.action_finished(anim_name)
		roam()
		
func longhorn_process() -> void:
	
	set_movement_target(target);
	should_move = not is_close_to_destination();
	if !should_move:
		print("I'm vulny")
		%Health.vulnerable = true
		shaker.shaking = false
		is_charging = false
		timer.start(cooldown_time)	
func attack() -> void:
	if (is_charging):
		longhorn_process()

func roam() -> void:
	var target_pos: Vector3 = roam_points.pick_random().global_position
	set_movement_target(target_pos)
	should_move = true
	aggro = AggroState.HOSTILE
	if not navigation_agent.is_target_reachable():
		roam() #try again
	

func hostile() -> void:
	if navigation_agent.is_navigation_finished():
		pick_action()
	
#endregion

#region MassChunks_funcs
@export var mass_targets: Array[Node3D]
@export var arena_area : ArenaArea

func mass_chunks_charge() -> void:
	mass_targets.clear()
	print("Charging chunks")
	shaker.shaking = true
	var player_position : Vector3 = Player.instance.global_position
	for i in range(mass_chunk_amount):
		var chunk_position : Vector3 = player_position + neutral_spread(0,player_still_spread_distance)
		var bullet_reference: Node3D = splash_obj.instantiate()
		add_sibling(bullet_reference)
		bullet_reference.global_position = chunk_position
		mass_targets.append(bullet_reference)

func mass_chunks_attack() -> void:
	print("mass chunks fire")
	aggro = AggroState.ATTACKING
	should_move = false
	shaker.shaking = false
	
	for i in range(num_shots_in_spread):
		var target_position: Vector3 = mass_targets[i].global_position
		
		#if not arena_area.is_point_in_arena(target_position): #is_point_in_arena caused crash
			#return
		
		var bullet_reference: Node3D = chunk_obj.instantiate()
		add_sibling(bullet_reference)
		bullet_reference.global_position = global_position
		bullet_reference.speed = 40
		
		
		bullet_reference.set_target(target_position)
		
		
	

func neutral_spread(min_dist : float, max_dist : float) -> Vector3:
	var result : Vector3 = Vector3.RIGHT
	var angle : float = randf_range(0,360)
	var distance_multiplier : float = randf_range(min_dist,max_dist)
	
	return result.rotated(Vector3.UP,deg_to_rad(angle))*distance_multiplier


#endregion
