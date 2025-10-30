extends Node3D

@onready var player: Player = get_parent()
	
func _process(_delta: float) -> void:
	# No shooting if you're rolling!
	if Input.is_action_just_pressed("fire"):
		if not player.can_shoot():
			return
		fire()

func fire() -> void:
	add_bullet($Right)
	add_bullet($Left)
	%ShootSound.play()

func add_bullet(gun: Node3D) -> void:
	var bullet: Bullet = preload("res://world/player/weapon/bullet/player_bullet.tscn").instantiate()
	get_tree().current_scene.add_child(bullet)
	#TODO: Damage uses integers right now. It should either use floats or much bigger integers.
	# The standard pistol bullet does 2 damage. Each dualie bullet needs to do somewhere between 50-100% of that.
	# We override the bullet's damage here in code. This could be set up later as an export variable, or as a 
	# unique bullet scene, but I didn't see the point.
	bullet.atk_damage = 1
	bullet.fire(gun, player.aim_dir())
	
