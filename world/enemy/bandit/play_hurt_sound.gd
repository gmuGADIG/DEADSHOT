extends Node3D

@onready var hurtSound:AudioStreamPlayer3D = $"../../Sounds/BanditHurt"

func _on_hurtbox_was_hit(dmg: DamageInfo) -> void:
	hurtSound.play();
