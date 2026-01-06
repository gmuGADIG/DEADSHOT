extends Node


func start() -> void:
	%AnimationPlayer.play("woosh_in")


func end() -> void:
	%AnimationPlayer.play("woosh_out")
