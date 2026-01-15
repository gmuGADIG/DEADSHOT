@tool
extends Node3D

func update_aniamation() -> void:
	if damage_states:
		damage_states.animation = "sand" if is_sand_rock else "default"

@export var is_sand_rock := false:
	set(v):
		is_sand_rock = v
		update_aniamation()

@export var damage_states: AnimatedSprite3D

func _ready() -> void:
	update_aniamation()

func _on_killed() -> void:
	%Anim.play("break")
	await %Anim.animation_finished
	queue_free()


func _on_health_component_damaged() -> void:
	if damage_states:
		damage_states.frame += 1
