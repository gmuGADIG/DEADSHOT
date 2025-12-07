@abstract
class_name Gun
extends Node3D

signal fired

@export var damage : float = 1.
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

var salvage_count: int = 0:
	set(v):
		if SkillSet.has_skill(SkillSet.SkillUID.PISTOL_SALVAGE):
			salvage_count = v
			if v >= 10: # assume v is never >= 20
				salvage_count -= 10
				reserve_ammo += 4
				%SalvageProc.play()

var is_reloading := false

@onready var player: Player = Player.instance
@export var fire_cooldown: float = 0.2
var fire_timer: float = 0.0

func _ready() -> void:
	chamber_ammo = get_max_chamber()
	reserve_ammo = max_reserve

	Global.skill_tree_changed.connect(func(skill: SkillSet.SkillUID) -> void:
		if skill == SkillSet.SkillUID.RIFLE_MAG or skill == SkillSet.SkillUID.RESPEC:
			chamber_ammo = get_max_chamber()
	)

func update_hud() -> void:
	Global.player_ammo_changed.emit(chamber_ammo)
	Global.player_ammo_reserve_changed.emit(reserve_ammo)

func _process(delta: float) -> void:
	fire_timer += delta
	
	if not player.can_shoot(): return
 
	# No shooting if you're rolling or the cooldown hasn't ended!
	if Input.is_action_just_pressed("fire") and fire_timer >= get_fire_cooldown():
		fire_timer = 0.0
	
		## if the player cannot shoot / is reloading, do not fire
		if not Player.instance.can_shoot() or is_reloading == true:
			return
		
		## Reloads gun with left click if no bullets in chamber (keep or remove?)
		if (chamber_ammo == 0):
			reload()
			return
	 
		fire(true, 1)
		fired.emit()

		if SkillSet.has_skill(SkillSet.SkillUID.PISTOL_DOUBLE_SHOT):
			get_tree().create_timer(.08).timeout.connect(func() -> void:
				fire(true, .5)
				fired.emit()
			)
	
	# Reloads the gun as well (if you can shoot, you can reload).
	if Input.is_action_just_pressed("reload") and is_reloading == false:
		reload()
	
	set_gun_rotation()

@abstract
func fire(consumes_ammo: bool, damage_mul: float) -> void
	

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
		0., 1., reload_time,
	).finished
	
	if (reserve_ammo >= chamber_diff):
		reserve_ammo -= chamber_diff
		chamber_ammo += chamber_diff
	else:
		chamber_ammo += reserve_ammo
		reserve_ammo = 0
	
	is_reloading = false
	
	print("reloaded")

## Rotate gun towards aim direction. Affects visuals and (for certain guns) ensures they fire in the desired direction.
func set_gun_rotation() -> void:
	self.look_at(player.global_position+player.aim_dir())
	rotation.x=0.0
	rotation.z=0.0
	
	if rotation.y > 0:
		scale.x = -1 * abs(scale.x)
	else:
		scale.x = abs(scale.x)

func get_bullet_scene() -> PackedScene:
	if SkillSet.has_skill(SkillSet.SkillUID.SHOTGUN_FIRE):
		return preload("res://world/player/weapon/bullet/fire_bullet.tscn")
	else:
		return preload("res://world/player/weapon/bullet/player_bullet.tscn")

func get_damage() -> float:
	var modifier := 1.
	
	if SkillSet.has_skill(SkillSet.SkillUID.BASE_DAMAGE): modifier += 1.
	if SkillSet.has_skill(SkillSet.SkillUID.RIFLE_DAMAGE_1): modifier += 1.
	if SkillSet.has_skill(SkillSet.SkillUID.RIFLE_DAMAGE_2): modifier += 1.
	if SkillSet.has_skill(SkillSet.SkillUID.PISTOL_DAMAGE): modifier += 1.
	
	return damage * modifier

func get_fire_cooldown() -> float:
	var modifier := 1.
	
	if SkillSet.has_skill(SkillSet.SkillUID.SHOTGUN_FIRE_RATE): modifier *= .5
	if SkillSet.has_skill(SkillSet.SkillUID.PISTOL_FIRE_RATE): modifier *= .75
	if SkillSet.has_skill(SkillSet.SkillUID.RIFLE_FIRE_RATE): modifier *= .75
	
	return fire_cooldown * modifier

func get_max_chamber() -> int:
	var ret := max_chamber

	if SkillSet.has_skill(SkillSet.SkillUID.RIFLE_MAG): ret += 2

	return ret
