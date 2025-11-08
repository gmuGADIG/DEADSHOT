extends Node2D
@onready var tap_button : TextureButton = $TextureButton
@onready var animator : AnimationPlayer = $AnimationPlayer
@onready var text : Node2D = $Text
@export var timeline:DialogTimeline

func _ready()->void:
	tap_button.hide()
	
	animator.play("before_dialogue")
	await animator.animation_finished

	Dialog.play(timeline)
	await text_finished()
	
	animator.play("after_dialogue")
	await animator.animation_finished

	await show_advance_prompt()
	get_tree().change_scene_to_file("res://world/levels/desert_intro/level_desert_intro.tscn")

func text_finished() -> void:
	while Dialog.panel.visible:
		await get_tree().process_frame

func show_advance_prompt() -> void:
	tap_button.show()
	while not Input.is_action_just_pressed("interact"):
		await get_tree().process_frame
