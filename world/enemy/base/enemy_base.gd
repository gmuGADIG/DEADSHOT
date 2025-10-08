extends CharacterBody3D

@export var fire_rate: float
@export var bullet_speed: float
@onready var timer: Timer = $Timer
var shooting := false
var can_shoot := true

func _ready() -> void:
	timer.wait_time = fire_rate
	shoot_bullet()

func shoot_bullet() -> void:
	if !can_shoot:
		return
	timer.start()
	if (!shooting):
		var bullet_reference: Node3D = load("res://world/enemy/Enemy Bullets/enemy_bullet.tscn").instantiate()
		bullet_reference.set_speed(fire_rate);
		bullet_reference.set_target(Vector3(-1, 0, 1))
		add_sibling(bullet_reference)
		bullet_reference.global_position = global_position + Vector3(0, 1, 0)
		shooting = true

func _on_timer_timeout() -> void:
	shooting = false
	shoot_bullet()

func stop_shooting() -> void:
	can_shoot = false
