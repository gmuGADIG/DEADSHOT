extends Node3D

var health: Health
func _ready() -> void:
	await get_tree().process_frame

	if get_child_count() == 0:
		queue_free()
		return
	
	var parent := get_parent() as EnemyBase
	if parent == null:
		queue_free()
		return
	
	health = parent.health
	health.death_callback = death_callback

func death_callback(_health: Health) -> void:
	health.kill()
