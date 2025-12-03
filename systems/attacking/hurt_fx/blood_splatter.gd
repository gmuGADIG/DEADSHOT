extends Node3D

func _ready() -> void:
	await get_tree().process_frame
	%Stain.emitting = true
	%Particles.emitting = true
