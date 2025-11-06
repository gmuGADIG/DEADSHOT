extends EnemyBase

#region Variables
@export var charge_time:float
@export var cooldown_time:float
@export var atk_source: DamageInfo.Source
@export var atk_knockback: DamageInfo.KnockbackStrength

var target:Vector3

@onready var timer: Timer = %ChargeTimer
@onready var health: Health = %Health
@onready var shaker: SpriteShaker = %SpriteShaker
#endregion

#region Behaviour Functions
func hostile() -> void:
	if timer.is_stopped():
		print("Charging")
		health.vulnerable = false
		shaker.shaking = true
		timer.start(charge_time)


func attack() -> void:
	if timer.is_stopped():
		set_movement_target(target);
		$Sounds/DashSound.play()
		
		should_move = not is_close_to_destination();
	
		if !should_move:
			if timer.is_stopped():
				timer.start(cooldown_time)
				print("I'm vulny")
				health.vulnerable = true
				shaker.shaking = false
				#hurtbox.allowed_damage_sources.insert(0, player_damage_source)
#endregion


func _on_charge_timer_timeout() -> void:
	timer.stop()
	shaker.shaking = false
	if aggro == AggroState.HOSTILE:
		target = player.global_position
		aggro = AggroState.ATTACKING
	elif aggro == AggroState.ATTACKING:
		aggro = AggroState.HOSTILE


func _on_hurter_box_area_entered(area: Area3D) -> void:
	if area is Hurtbox:
		var hurtbox : Hurtbox = area
		var dmg := DamageInfo.new(damage, atk_source, atk_knockback, velocity.normalized())
		var did_damage := hurtbox.hit(dmg)
		print(hurtbox.get_parent())
		if did_damage:
			print("owie")



func _on_killed() -> void:
	var die_sound:AudioStreamPlayer3D = $Sounds/DieSound
	die_sound.reparent(get_tree().current_scene)
	die_sound.play()
	print("idied")
	
