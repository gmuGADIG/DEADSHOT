extends Node3D

@onready var player: Player = get_parent()

## Gets set to the max_wep_ammo and max_reserve_ammo from player.
var chamber_ammo : int
var reserve_ammo : int

func _ready() -> void:
	chamber_ammo = player.max_wep_ammo
	reserve_ammo = player.max_reserve_ammo

func _process(_delta: float) -> void:
	# No shooting if you're rolling!
	if Input.is_action_just_pressed("fire"):
		print(chamber_ammo)
		## Reloads gun with left click if no bullets in chamber
		if (chamber_ammo == 0):
			reload()
			return
			
		if not player.can_shoot():
			return
		fire()

func fire() -> void:
	var bullet: Bullet = preload("res://world/player/weapon/bullet/player_bullet.tscn").instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.fire(self, player.aim_dir())
	
	%ShootSound.play()
	
	chamber_ammo -= 1
	
## Definitely want this to have a delay. Will implement
func reload() -> void:
	var chamber_diff := player.max_wep_ammo - chamber_ammo
	print(reserve_ammo)
	
	if (reserve_ammo >= chamber_diff):
		reserve_ammo -= chamber_diff
		chamber_ammo += chamber_diff
	else:
		chamber_ammo += reserve_ammo
		reserve_ammo = 0
	
	print(reserve_ammo)
