extends Node2D
@onready var tap_button : TextureButton = $TextureButton
@onready var animator : AnimationPlayer = $AnimationPlayer
@onready var black_screen : ColorRect = $AnimationPlayer/BlackTransitionScreen

func _ready()->void:
	tap_button.hide()
	black_screen.hide()
	animator.play("new_animation")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	animator.play("black_transition")
	await animator.animation_finished
	await show_advance_prompt()
	get_tree().change_scene_to_file("res://test_scenes/example_scene.tscn")
	
	print("the animation \"" + anim_name + "\" finished playing.")

func show_advance_prompt() -> void:
	tap_button.show()
	
	while not Input.is_action_just_pressed("interact"):
		await get_tree().process_frame
	#print("test1")
	#await tap_button.pressed
	#print("test2")
