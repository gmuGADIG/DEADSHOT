extends Node3D

func _ready() -> void:
	await %Anim.animation_finished
	queue_free()

func set_ammo(amount: int) -> void:
	%Label.text %= amount
