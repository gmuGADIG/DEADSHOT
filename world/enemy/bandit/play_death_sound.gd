extends Node3D

@onready var deathSound:AudioStreamPlayer3D = $"../../Sounds/BanditDies"

func _on_health_killed() -> void:
	deathSound.play()
