extends EnemyBase

#region Variables
@export var timer:Timer
@export var charge_time:float
@export var cooldown_time:float
@export var hurtbox:Hurtbox
@export var health:Health
var player_damage_source:DamageInfo.Source = DamageInfo.Source.PLAYER
var target:Vector3

#endregion

#region Behaviour Functions

func hostile() -> void:
	if timer.is_stopped():
		print("Charging")
		health.vulnerable = false
		#hurtbox.allowed_damage_sources.pop_front()
		timer.start(charge_time)
		

func attack() -> void:
	if timer.is_stopped():
		set_movement_target(target);
		
		should_move = not is_close_to_destination();
	
		if !should_move:
			if timer.is_stopped():
				timer.start(cooldown_time)
				print("I'm vulny")
				health.vulnerable = true
				#hurtbox.allowed_damage_sources.insert(0, player_damage_source)
		
#endregion

func _on_charge_timer_timeout() -> void:
	timer.stop()
	if aggro == AggroState.HOSTILE:
		target = player.global_position
		aggro = AggroState.ATTACKING
	elif aggro == AggroState.ATTACKING:
		aggro = AggroState.HOSTILE
