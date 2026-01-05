extends Node3D

func _on_killed() -> void:
	%Anim.play("break")
	await %Anim.animation_finished
	queue_free()
