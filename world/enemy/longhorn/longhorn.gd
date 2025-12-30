extends EnemyBase

#region Variables
@export var charge_time:float
@export var cooldown_time:float
@export var stuck_time:float
@export var atk_source: DamageInfo.Source
@export var atk_knockback: DamageInfo.KnockbackStrength

var target:Vector3
var is_stuck:bool = false

@onready var timer: Timer = %ChargeTimer
@onready var stuck_timer: Timer = $StuckTimer
@onready var shaker: SpriteShaker = %SpriteShaker
#endregion

#region Behaviour Functions
func hostile() -> void:
	if timer.is_stopped():
		print("Charging")
		shaker.shaking = true
		timer.start(charge_time)


func attack() -> void:
	if timer.is_stopped():
		set_movement_target(target);
		
		if stuck_timer.is_stopped():
			print("starting stuck timer!")
			stuck_timer.start(stuck_time)
		
		should_move = not is_close_to_destination()
		
		if !should_move || is_stuck:
			if timer.is_stopped():
				timer.start(cooldown_time)
				is_stuck = false
				stuck_timer.stop()
				shaker.shaking = false
				#hurtbox.allowed_damage_sources.insert(0, player_damage_source)
#endregion


func _on_charge_timer_timeout() -> void:
	timer.stop()
	shaker.shaking = false
	velocity = Vector3.ZERO
	if aggro == AggroState.HOSTILE:
		target = player.global_position
		$Sounds/LonghornDashSound.play()
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
	var die_sound:AudioStreamPlayer3D = $Sounds/LonghornDieSound
	die_sound.reparent(get_tree().current_scene)
	die_sound.play()
	print("idied")
	


func _on_stuck_timer_timeout() -> void:
	print("Stuck :(")
	is_stuck = true
