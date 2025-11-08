extends Node3D

## Time in seconds to reload
@export var reload_time : float = 2.5
## Max number of bullets in chamber and reserve
@export var max_chamber : int = 12
@export var max_reserve : int = 72

## Gets set to the max_wep_ammo and max_reserve_ammo from player.
var chamber_ammo : int = max_chamber
var reserve_ammo : int = max_reserve

var is_reloading := false
var bullets_of_fire_unlocked: bool

@onready var player: Player = get_parent()
@export var fire_cooldown: float = 0.1
var fire_timer: float = 0.0

func _process(_delta: float) -> void:
	# No shooting if you're rolling!
	fire_timer+=_delta
  
	if Input.is_action_just_pressed("fire") && player.current_state != player.PlayerState.ROLLING && fire_timer>=fire_cooldown:
		fire_timer = 0.0
	
		## if the player cannot shoot / is reloading, do not fire
		if not Player.instance.can_shoot() or is_reloading == true:
			return
		
		## Reloads gun with left click if no bullets in chamber (keep or remove?)
		if (chamber_ammo == 0):
			reload()
			return
	 
		fire()
		
	
	# Reloads the gun as well (if you can shoot, you can reload).
	if Input.is_action_just_pressed("reload") and Player.instance.can_shoot() and is_reloading == false:
		reload()

func fire() -> void:
	var bullet : PackedScene
	if bullets_of_fire_unlocked:
		bullet = preload("res://world/player/weapon/bullet/fire_bullet.tscn")
	else:
		bullet = preload("res://world/player/weapon/bullet/player_bullet.tscn")
	
	var bullet1: Bullet = bullet.instantiate()
	get_tree().current_scene.add_child(bullet1)
	bullet1.fire(self, Player.instance.aim_dir(), Vector3(0.5, 0, 0))
	%ShootSound.play()

	await get_tree().create_timer(0.2).timeout
	
	var bullet2: Bullet = bullet.instantiate()
	get_tree().current_scene.add_child(bullet2)
	bullet2.fire(self, Player.instance.aim_dir(), Vector3(-0.5, 0, 0))
	%ShootSound.play()
	
	chamber_ammo -= 2
	
## Reloads the gun if there are less than the max number of bullets in the chamber and if there are any bullets in the reserve available.
func reload() -> void:
	var chamber_diff := max_chamber - chamber_ammo
	if chamber_diff == 0 or reserve_ammo == 0:
		return
		
	print("reloading...")

	is_reloading = true
	await get_tree().create_timer(reload_time).timeout
	
	if (reserve_ammo >= chamber_diff):
		reserve_ammo -= chamber_diff
		chamber_ammo += chamber_diff
	else:
		chamber_ammo += reserve_ammo
		reserve_ammo = 0
	
	is_reloading = false
	
	print("reloaded")
