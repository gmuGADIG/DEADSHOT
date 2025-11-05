extends Node3D

## Time in seconds to reload
@export var reload_time : float = 1.25
## Max number of bullets in chamber and reserve
@export var max_chamber : int = 6
@export var max_reserve : int = 60

## Gets set to the max_wep_ammo and max_reserve_ammo from player.
var chamber_ammo : int = max_chamber
var reserve_ammo : int = max_reserve

var is_reloading := false
var bullets_of_fire_unlocked: bool

@onready var player: Player = get_parent()

func _process(_delta: float) -> void:
	# No shooting if you're rolling!
	if Input.is_action_just_pressed("fire"):
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
	var bullet : Bullet
	if bullets_of_fire_unlocked:
		bullet = preload("res://world/player/weapon/bullet/fire_bullet.tscn").instantiate()
	else:
		bullet = preload("res://world/player/weapon/bullet/player_bullet.tscn").instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.fire(self, Player.instance.aim_dir())
	
	%ShootSound.play()
	
	chamber_ammo -= 1
	
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
