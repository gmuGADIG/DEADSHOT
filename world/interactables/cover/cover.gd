extends Node3D

func _on_killed() -> void:
	queue_free()
