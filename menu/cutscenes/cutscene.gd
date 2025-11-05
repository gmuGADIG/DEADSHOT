extends Node2D
@onready var tap_button : TextureButton = $TextureButton
@onready var animator : AnimationPlayer = $AnimationPlayer
@onready var black_screen : ColorRect = $AnimationPlayer/BlackTransitionScreen

func _ready()->void:
	tap_button.hide()
	black_screen.hide()
	animator.play("new_animation")
	await animator.animation_finished
	animator.play("black_transition")
	await animator.animation_finished
	await show_advance_prompt()
	get_tree().change_scene_to_file("res://world/levels/desert_intro/level_desert_intro.tscn")
	
func show_advance_prompt() -> void:
	tap_button.show()
	
	while not Input.is_action_just_pressed("interact"):
		await get_tree().process_frame
	#print("test1")
	#await tap_button.pressed
	#print("test2")
