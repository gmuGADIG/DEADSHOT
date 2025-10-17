class_name Whip extends Node3D

@onready var player : Player = get_parent()


@export_category("Whip Settings")
@export var windup_time : float ##Time in seconds after the whip swing to deal damage
@export var cooldown_time : float ##Time in seconds after dealing damage for the whip to be put away

@export var time_per_charge : float ##Time it takes to increase the charge value by one

@export var charge_levels : Array[WhipAttackData] ##The values of different charge levels for the whip

var charge_time : float = 0:
	set(new_val):
		var old_charge : int = int(charge_time/time_per_charge)
		var new_charge : int = int(new_val/time_per_charge)
		if old_charge != new_charge:
			update_charge_visuals(new_charge)
		charge_time = new_val

enum WhipState { OFF, CHARGING, ATTACKING }

var whip_state : WhipState = WhipState.OFF:
	set(new_val):
		whip_state = new_val
		match new_val:
			WhipState.OFF:
				$Attack/ChargeUpSprite3D.hide()
				$Attack/SwingSprite3D.hide()
			WhipState.CHARGING:
				$Attack/ChargeUpSprite3D.show()
				$Attack/SwingSprite3D.hide()
			WhipState.ATTACKING:
				$Attack/ChargeUpSprite3D.hide()
				$Attack/SwingSprite3D.show()
		

func update_charge_visuals(charge_index : float) -> void:
	if charge_index >= charge_levels.size():
		return
	print("charg")
	var whip_charge_info : WhipAttackData = charge_levels[charge_index]
	$Attack/ChargeUpSprite3D/ChargeUpOutline.modulate.a = whip_charge_info.sprite_glow_brightness


func _ready() -> void:
	$WindupTimer.timeout.connect(attack)
	$CooldownTimer.timeout.connect(func() -> void:
		whip_state = WhipState.OFF
	)

func _process(delta: float) -> void:
	if Input.is_action_pressed("whip") && whip_state == WhipState.OFF:
		charge_time = 0
		whip_state = WhipState.CHARGING
	
	if whip_state == WhipState.CHARGING:
		rotation.y = Vector3.RIGHT.signed_angle_to(player.aim_dir(),Vector3.UP)
		charge_time += delta
		if not Input.is_action_pressed("whip"):
			whip_state = WhipState.ATTACKING
			$WindupTimer.start(windup_time)


func attack() -> void:
	var charge_index : int = clampi(int(charge_time/time_per_charge),0,charge_levels.size()-1)
	var whip_attack_data : WhipAttackData = charge_levels[charge_index]
	var damage : int= whip_attack_data.damage
	var kb := whip_attack_data.knockback
	var kb_dir := Vector3.RIGHT.rotated(Vector3.UP,self.rotation.y)
	for area : Area3D in $Attack/Area3D.get_overlapping_areas():
		print(area)
		if area is Hurtbox:
			area.hit(DamageInfo.new(damage,DamageInfo.Source.PLAYER,kb,kb_dir))
	$CooldownTimer.start(cooldown_time)
