extends Node3D

@export var despawn_after_seconds := 5.0
@onready var area_3d: Area3D = $Area3D
@onready var timer: Timer = $Timer
var bullet_speed := 10.0
var direction: Vector3

func _ready() -> void:
	timer.wait_time = despawn_after_seconds

func _process(delta: float) -> void:
	position += direction * bullet_speed * delta

# if hits player or terrain, despawn
func _on_area_3d_body_entered(body: Node3D) -> void:
	pass

func _on_timer_timeout() -> void:
	queue_free()

func set_speed(speed: float) -> void:
	bullet_speed = speed

func set_target(target: Vector3) -> void:
	direction = (target - position).normalized()
