@abstract
class_name Gun
extends Node3D

signal fired

@export var reload_time : float = 1.25 ## Time in seconds to reload
@export var max_chamber : int = 6 ## Max number of bullets in chamber (a single clip)
@export var max_reserve : int = 60 ## Max number of bullets in the reserve
@export var ammo_per_pickup : int = 30 ## How much ammo is added when the player gets an ammo pickup

## Gets set to the max_wep_ammo and max_reserve_ammo from player.
var chamber_ammo : int:
	set(value):
		if value == chamber_ammo: return # no change
		chamber_ammo = value
		Global.player_ammo_changed.emit(chamber_ammo)
		
var reserve_ammo : int:
	set(value):
		if value == reserve_ammo: return # no change
		reserve_ammo = value
		Global.player_ammo_reserve_changed.emit(reserve_ammo)

var is_reloading := false
var bullets_of_fire_unlocked: bool

@onready var player: Player = Player.instance
@export var fire_cooldown: float = 0.2
var fire_timer: float = 0.0

func _ready() -> void:
	Global.player_ammo_changed.emit(chamber_ammo)
	Global.player_ammo_reserve_changed.emit(reserve_ammo)
	
	chamber_ammo = max_chamber
	reserve_ammo = max_reserve

func _process(delta: float) -> void:
	fire_timer += delta
	
	if not player.can_shoot(): return
 
	# No shooting if you're rolling or the cooldown hasn't ended!
	if Input.is_action_just_pressed("fire") and fire_timer>=fire_cooldown:
		fire_timer = 0.0
	
		## if the player cannot shoot / is reloading, do not fire
		if not Player.instance.can_shoot() or is_reloading == true:
			return
		
		## Reloads gun with left click if no bullets in chamber (keep or remove?)
		if (chamber_ammo == 0):
			reload()
			return
	 
		fire()
		fired.emit()
	
	# Reloads the gun as well (if you can shoot, you can reload).
	if Input.is_action_just_pressed("reload") and is_reloading == false:
		reload()

@abstract
func fire() -> void
	

## Called when an ammo pickup is grabbed.
## Adds to the gun's reserve.
## Returns the amount added, since different guns can have different amounts.
func add_ammo() -> int:
	reserve_ammo += ammo_per_pickup
	return ammo_per_pickup

## Reloads the gun if there are less than the max number of bullets in the chamber and if there are any bullets in the reserve available.
func reload() -> void:
	var chamber_diff := max_chamber - chamber_ammo
	if chamber_diff == 0 or reserve_ammo == 0:
		return
		
	print("reloading...")

	is_reloading = true
	
	# wait `reload_time` seconds, while emitting player_reload_progress_changed every frame
	await create_tween().tween_method(
		Global.player_reload_progress_changed.emit,
		0., 1., reload_time
	).finished
	
	if (reserve_ammo >= chamber_diff):
		reserve_ammo -= chamber_diff
		chamber_ammo += chamber_diff
	else:
		chamber_ammo += reserve_ammo
		reserve_ammo = 0
	
	is_reloading = false
	
	print("reloaded")

func get_bullet_scene() -> PackedScene:
	if bullets_of_fire_unlocked:
		return preload("res://world/player/weapon/bullet/fire_bullet.tscn")
	else:
		return preload("res://world/player/weapon/bullet/player_bullet.tscn")
