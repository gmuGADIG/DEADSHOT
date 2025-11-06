extends BossEnemy

@export var num_shots_in_spread: int = 5
@export var spread_angle: float = 45.0
@export var rock_speed: float = 2
const rock_obj := preload("res://world/enemy/bosses/horse/rock.tscn")

#region Longhorn_Variables
@export var charge_time:float
@export var cooldown_time:float
@export var atk_source: DamageInfo.Source
@export var atk_knockback: DamageInfo.KnockbackStrength

var is_charging:bool = false
var target:Vector3

@onready var timer: Timer = %ChargeTimer

@onready var shaker: SpriteShaker = %SpriteShaker

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

func stomp_fire_attack() -> void:
	print("stomp fire")
	for i in range(num_shots_in_spread):
		var bullet_reference: Node3D = rock_obj.instantiate()
		add_sibling(bullet_reference)
		bullet_reference.global_position = global_position
		bullet_reference.set_speed(rock_speed)

		var target_position: Vector3 = player.global_position
		var direction: Vector3 = (target_position - global_position).normalized()
		var base_angle: float = direction.angle_to(Vector3.FORWARD)
		var angle_offset: float = spread_angle * ((float(i) / (num_shots_in_spread - 1)) - 0.5)
		var final_angle: float = base_angle + deg_to_rad(angle_offset)
		var final_direction: Vector3 = -Vector3(sin(final_angle), 0, cos(final_angle)).normalized()
		bullet_reference.set_target(global_position + final_direction * 10)

		print("Fired rock at angle offset: %f" % angle_offset)

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
#endregion
