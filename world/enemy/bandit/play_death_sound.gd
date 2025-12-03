extends Node3D

@onready var deathSound:AudioStreamPlayer3D = %BanditDies

func _on_health_killed() -> void:
	# lets reparent since we're about to queue_free
	var gp := deathSound.global_position
	deathSound.reparent(get_tree().current_scene)
	deathSound.global_position = gp
	deathSound.play()
