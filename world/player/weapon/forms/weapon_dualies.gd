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
@export var fire_cooldown: float = 0.2
var fire_timer: float = 0.0

func _process(delta: float) -> void:
	fire_timer+=delta
	# No shooting if you're rolling or the cooldown hasn't ended!
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

## Rotate Dualies to aim direction to keep bullet spawn points correct
func setGunRotation() -> void:
	self.look_at(player.global_position+player.aim_dir())
	rotation.x=0.0
	rotation.z=0.0

func fire() -> void:
	setGunRotation()
	add_bullet($Right)
	add_bullet($Left)
	%ShootSound.play()

func add_bullet(gun: Node3D) -> void:
	var bullet : Bullet
	if bullets_of_fire_unlocked:
		bullet = preload("res://world/player/weapon/bullet/fire_bullet.tscn").instantiate()
	else:
		bullet = preload("res://world/player/weapon/bullet/player_bullet.tscn").instantiate()
	get_tree().current_scene.add_child(bullet)
	#TODO: Damage uses integers right now. It should either use floats or much bigger integers.
	# The standard pistol bullet does 2 damage. Each dualie bullet needs to do somewhere between 50-100% of that.
	# We override the bullet's damage here in code. This could be set up later as an export variable, or as a 
	# unique bullet scene, but I didn't see the point.
	bullet.atk_damage = 7
	bullet.fire(gun, player.aim_dir())
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
