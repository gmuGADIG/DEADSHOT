extends BossEnemy

@export var num_shots_in_spread: int = 5
@export var spread_angle: float = 45.0
@export var rock_speed: float = 2
const rock_obj := preload("res://world/enemy/bosses/horse/horse_rock.tscn")

#region Longhorn_Variables
@export var charge_time:float
@export var cooldown_time:float
@export var atk_source: DamageInfo.Source
@export var atk_knockback: DamageInfo.KnockbackStrength

var is_charging:bool = false
var target:Vector3

@onready var timer: Timer = %ChargeTimer

@onready var shaker: SpriteShaker = %SpriteShaker

@export var floor_area: Path3D

var current_action: StringName = ""
#endregion

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
		bullet_reference.set_speed(rock_speed)

		var target_position: Vector3 = player.global_position
		var direction: Vector3 = (target_position - global_position).normalized()
		var base_angle: float = get_2d_angle(Vector3.FORWARD, direction)
		var angle_offset: float = spread_angle * ((float(i) / (num_shots_in_spread - 1)) - 0.5)
		var final_angle: float = base_angle + deg_to_rad(angle_offset)
		var final_direction: Vector3 = -Vector3(sin(final_angle), 0, cos(final_angle)).normalized()
		bullet_reference.set_target(global_position + final_direction * 10)

		print("Fired rock at angle offset: %f" % rad_to_deg(final_angle))

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

func get_bounds() -> AABB:
	var minPoint: Vector3 = floor_area.curve.get_point_position(0)
	var maxPoint: Vector3 = floor_area.curve.get_point_position(0)
	for i in range(floor_area.curve.get_point_count()):
		var point: Vector3 = floor_area.curve.get_point_position(i)
		minPoint.x = min(minPoint.x, point.x)
		minPoint.y = min(minPoint.y, point.y)
		minPoint.z = min(minPoint.z, point.z)
		maxPoint.x = max(maxPoint.x, point.x)
		maxPoint.y = max(maxPoint.y, point.y)
		maxPoint.z = max(maxPoint.z, point.z)
	return AABB(minPoint, maxPoint - minPoint)

func roam() -> void:
	var bounds: AABB = get_bounds()
	var random_x: float = randf_range(bounds.position.x, bounds.position.x + bounds.size.x)
	var random_z: float = randf_range(bounds.position.z, bounds.position.z + bounds.size.z)
	var target_pos: Vector3 = Vector3(random_x, global_position.y, random_z)
	set_movement_target(target_pos)
	should_move = true
	aggro = AggroState.HOSTILE
	if not navigation_agent.is_target_reachable():
		roam() #try again
	

func hostile() -> void:
	if navigation_agent.is_navigation_finished():
		pick_action()
	
#endregion
