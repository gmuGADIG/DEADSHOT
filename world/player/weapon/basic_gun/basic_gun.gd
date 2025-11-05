extends Node3D

@onready var player: Player = get_parent()

func _process(_delta: float) -> void:
	# No shooting if you're rolling!
	if Input.is_action_just_pressed("fire") && player.current_state != player.PlayerState.ROLLING:
		fire()

func fire() -> void:
	var bullet: Bullet = preload("res://world/player/weapon/bullet/player_bullet.tscn").instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.fire(self, player.aim_dir())
	
	%ShootSound.play()
