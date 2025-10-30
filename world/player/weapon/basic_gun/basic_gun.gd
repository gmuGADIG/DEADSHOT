extends Node3D

@onready var player: Player = get_parent()
@export var fire_cooldown: float = 0.2
var fire_timer: float = 0.0

func _process(_delta: float) -> void:
	# No shooting if you're rolling!
	fire_timer+=_delta
	if Input.is_action_just_pressed("fire") && player.current_state != player.PlayerState.ROLLING && fire_timer>=fire_cooldown:
		fire_timer = 0.0
		fire()

func fire() -> void:
	var bullet: Area3D = preload("res://world/player/weapon/bullet/player_bullet.tscn").instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.fire(self, player.aim_dir())
	
	%ShootSound.play()
