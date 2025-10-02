extends Node3D

@onready var player: Player = get_parent()

@export var base_damage : int = 1
@export var bonus_knock
@export var cooldown_time : float
@export var min_charge_time : float
@export var time_per_charge : float

var remaining_cooldown : float
var charging : bool = false
var charge_time : float = 0

func _input(event: InputEvent) -> void:
	pass
		
		
func _process(delta: float) -> void:
	if Input.is_action_pressed("whip") && !charging && remaining_cooldown <= 0:
		
		charge_time = 0
		charging = true
		
	if charging:
		charge_time += delta
		
	if !Input.is_action_pressed("whip") && charging && charge_time > min_charge_time:
		remaining_cooldown = cooldown_time
		swing()
		charging = false
	
	if remaining_cooldown >= 0:
		remaining_cooldown -= delta
	else:
		$Attack.visible = false

func swing() -> void:
	##Rotate towards aim
	##make visible
	##Play animation
	##Wait for it to end
	##Hide
	
	
	rotation.y = Vector3.RIGHT.signed_angle_to(player.aim_dir(),Vector3.UP)
	$Attack.visible = true
	
	#get_tree().current_scene.add_child(bullet)
	#bullet.fire(self, player.aim_dir())
	#
	#%ShootSound.play()
	pass


func _on_area_3d_body_entered(body: Node3D) -> void:
	var charge_bonus : int = clampi(charge_time - min_charge_time, 0, 2)
	if not body is EnemyBase:
		return
	var enemy : EnemyBase = body
	enemy.hurt(base_damage+charge_bonus)
	
	pass # Replace with function body.
