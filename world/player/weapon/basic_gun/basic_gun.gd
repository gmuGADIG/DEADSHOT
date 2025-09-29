extends Node3D

@onready var player: Player = get_parent()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("fire"):
		fire()

func fire() -> void:
	var bullet: Bullet = preload("res://world/player/weapon/bullet/player_bullet.tscn").instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.fire(self, player.aim_dir())
