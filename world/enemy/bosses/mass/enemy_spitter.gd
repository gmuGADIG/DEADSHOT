extends Node3D

class LaunchedEnemy:
	var enemy : EnemyBase
	var target : Vector3
	var age : float
	func _init(enemy : EnemyBase, target : Vector3) -> void:
		self.enemy = enemy
		self.target = target
		self.age = 0

@onready var the_mass : TheMass = get_parent()
@export var enemy_scenes : Array[PackedScene]
@export var launch_curve : Curve

var launched_enemies : Array[LaunchedEnemy]



func spit_enemy(target : Vector3) -> void:
	var new_enemy : EnemyBase = enemy_scenes.pick_random().instantiate()
	add_child(new_enemy)
	new_enemy.global_position = global_position
	new_enemy.process_mode = Node.PROCESS_MODE_DISABLED
	launched_enemies.append(LaunchedEnemy.new(new_enemy,target))

func _physics_process(delta: float) -> void:
	for launched_enemy in launched_enemies:
		launched_enemy.age += delta
		if launched_enemy.age >= launch_curve.max_domain:
			launched_enemy.enemy.global_position = global_position+launched_enemy.target
			launched_enemy.enemy.process_mode = Node.PROCESS_MODE_INHERIT
			remove_child(launched_enemy.enemy)
			the_mass.add_sibling(launched_enemy.enemy)
			launched_enemies.erase(launched_enemy)
		else:
			var lerp_x : float = lerpf(global_position.x,launched_enemy.target.x,launched_enemy.age/launch_curve.max_domain)
			var y_height : float = launch_curve.sample(launched_enemy.age)
			var lerp_z : float = lerpf(global_position.z,launched_enemy.target.z,launched_enemy.age/launch_curve.max_domain)
			launched_enemy.enemy.global_position = Vector3(lerp_x,y_height,lerp_z)
