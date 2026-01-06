extends Node


@export var engine_timescale := 1.:
	set(v):
		Engine.time_scale = v
	get:
		return Engine.time_scale


var active := false


func _process(_delta: float) -> void:
	%AnimationPlayer.speed_scale = 1. / Engine.time_scale
	pass


func start() -> void:
	%AnimationPlayer.play("woosh_in")
	%Greyscale.start()
	active = true


func end() -> void:
	%AnimationPlayer.play("woosh_out")
	active = false
