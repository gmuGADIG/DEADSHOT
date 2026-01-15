@abstract
class_name Gun
extends Node3D

signal fired

@export_exp_easing var shake_easing : float = 0.
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
var charge_timer: float = 0.

const CHARGE_TIME := 2.
const CHARGE_DMG_MIN := 0.5
const CHARGE_DMG_MAX := 4.0
const SHAKE_INTENSITY := 0.5

func _ready() -> void:
	chamber_ammo = get_max_chamber()
	reserve_ammo = max_reserve

	Global.skill_tree_changed.connect(func(skill: SkillSet.SkillUID) -> void:
		if skill in [
			SkillSet.SkillUID.RIFLE_MAG,
			SkillSet.SkillUID.RESPEC,
			SkillSet.SkillUID.PISTOL_FIRE_RATE,
			SkillSet.SkillUID.SHOTGUN_HP_2,
		]:
			chamber_ammo = get_max_chamber()
		# if skill == SkillSet.SkillUID.RIFLE_MAG or skill == SkillSet.SkillUID.RESPEC:
	)

func update_hud() -> void:
	Global.player_ammo_changed.emit(chamber_ammo)
	Global.player_ammo_reserve_changed.emit(reserve_ammo)

func _process_fire_charge_shot(delta: float) -> bool:
	if Input.is_action_pressed("fire"):
		charge_timer = min(CHARGE_TIME, charge_timer + (delta / get_fire_cooldown_mul()))

		return false

	if Input.is_action_just_released("fire"):
		fire_timer = 0.

		fire(true, remap(charge_timer, 0., CHARGE_TIME, CHARGE_DMG_MIN, CHARGE_DMG_MAX))
		charge_timer = 0.
		fired.emit()

		return true

	return false

func _process_fire_no_charge_shot() -> bool:
	if not Input.is_action_just_pressed("fire"):
		return false

	fire_timer = 0.0
	fire(true, 1)
	fired.emit()
	return true

func _process(delta: float) -> void:
	fire_timer += delta

	var shaker: SpriteShaker = get_node_or_null("%SpriteShaker")
	if shaker: 
		var t := inverse_lerp(0., CHARGE_TIME, charge_timer)
		shaker.shake_intensity = lerp(
			0.,
			SHAKE_INTENSITY,
			ease(t, shake_easing)
		)

	if player.can_shoot() and not is_reloading: set_gun_rotation()

	if not player.can_shoot(): return
	if QTEVFX.active: return

	# reload if the player tries to shoot with no ammo
	if Input.is_action_pressed("fire") and chamber_ammo <= 0 and not is_reloading:
		reload()
		return
	
	# can't shoot if cooldown isn't done
	if fire_timer <= get_fire_cooldown(): return
	# can't shoot if reloading
	if is_reloading: return

	var shot := false
	if SkillSet.has_skill(SkillSet.SkillUID.RIFLE_CHARGE_SHOT):
		shot = _process_fire_charge_shot(delta)
	else:
		shot = _process_fire_no_charge_shot()

	if shot and chamber_ammo <= 0:
		reload()
 
	# Reloads the gun as well (if you can shoot, you can reload).
	if Input.is_action_just_pressed("reload") and is_reloading == false:
		reload()

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

func get_bullet() -> Bullet:
	var scene: PackedScene
	if SkillSet.has_skill(SkillSet.SkillUID.SHOTGUN_FIRE):
		scene =preload("res://world/player/weapon/bullet/fire_bullet.tscn")
	else:
		scene = preload("res://world/player/weapon/bullet/player_bullet.tscn")
	
	var ret := scene.instantiate() as Bullet
	ret.atk_knockback = DamageInfo.KnockbackStrength.STRONG if SkillSet.has_skill(SkillSet.SkillUID.SHOTGUN_KNOCKBACK) else DamageInfo.KnockbackStrength.NORMAL
	return ret

func get_damage() -> float:
	var modifier := 1.0
	
	if SkillSet.has_skill(SkillSet.SkillUID.BASE_DAMAGE): modifier += 0.3
	if SkillSet.has_skill(SkillSet.SkillUID.RIFLE_DAMAGE_1): modifier += 0.3
	if SkillSet.has_skill(SkillSet.SkillUID.RIFLE_DAMAGE_2): modifier += 0.3
	if SkillSet.has_skill(SkillSet.SkillUID.PISTOL_DAMAGE): modifier += 0.15

	if SkillSet.has_skill(SkillSet.SkillUID.RIFLE_FIRE_RATE): modifier -= .3
	
	return damage * modifier

func get_fire_cooldown_mul() -> float:
	var modifier := 1.
	
	if SkillSet.has_skill(SkillSet.SkillUID.SHOTGUN_FIRE_RATE): modifier *= .75
	if SkillSet.has_skill(SkillSet.SkillUID.PISTOL_FIRE_RATE): modifier *= .90
	if SkillSet.has_skill(SkillSet.SkillUID.RIFLE_FIRE_RATE): modifier *= .75

	if SkillSet.has_skill(SkillSet.SkillUID.SHOTGUN_HP_1): modifier *= 1.4
	if SkillSet.has_skill(SkillSet.SkillUID.RIFLE_DAMAGE_1): modifier *= 1.4
	if SkillSet.has_skill(SkillSet.SkillUID.SHOTGUN_FIRE_RATE): modifier *= 1.3
	if SkillSet.has_skill(SkillSet.SkillUID.PISTOL_MOVEMENT_SPEED): modifier *= 1.3

	return modifier


func get_fire_cooldown() -> float:
	return fire_cooldown * get_fire_cooldown_mul()

func get_max_chamber() -> int:
	var ret := max_chamber

	if SkillSet.has_skill(SkillSet.SkillUID.RIFLE_MAG): ret += 2
	if SkillSet.has_skill(SkillSet.SkillUID.PISTOL_FIRE_RATE): ret -= 4
	if SkillSet.has_skill(SkillSet.SkillUID.SHOTGUN_HP_2): ret -= 1

	return ret
