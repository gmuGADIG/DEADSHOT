extends Node3D

var bullets_of_fire_unlocked: bool

@onready var player: Player = get_parent()

func _process(_delta: float) -> void:
	# No shooting if you're rolling!
	if Input.is_action_just_pressed("fire"):
		if not player.can_shoot():
			return
		fire()

func fire() -> void:
	var bullet : Bullet
	if bullets_of_fire_unlocked:
		bullet = preload("res://world/player/weapon/bullet/fire_bullet.tscn").instantiate()
	else:
		bullet = preload("res://world/player/weapon/bullet/player_bullet.tscn").instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.fire(self, player.aim_dir())
	
	%ShootSound.play()
