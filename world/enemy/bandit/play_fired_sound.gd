extends Node3D

@onready var fireSound:AudioStreamPlayer3D = $"../Sounds/BanditFire"

func _on_enemy_bandit_enemy_fired() -> void:
	fireSound.play()
