extends Control
@onready var tap_button : TextureButton = $TextureButton
@onready var animator : AnimationPlayer = $AnimationPlayer
@onready var text : Node2D = $Text

@export var timelines: Array[DialogTimeline]
@export var next_scene: PackedScene

func play_timeline(timeline_idx: int) -> void:
	print("[Cutscene] play_timeline called, pausing at %.2f" % animator.current_animation_position)
	animator.pause()
	Dialog.play(timelines[timeline_idx])
	await text_finished()
	print("[Cutscene] Dialog done, resuming animation")
	animator.play()

func goto_music_section(section_name: String, transition_time: float = 0.5) -> void:
	print("[Cutscene] goto_music_section('%s', %.2f)" % [section_name, transition_time])
	MainMusicPlayer.goto_section(section_name, transition_time)

func set_music_volume(level: float, duration: float = 0.0) -> void:
	print("[Cutscene] set_music_volume(%.2f, %.2f)" % [level, duration])
	MainMusicPlayer.set_volume(level, duration)

func _ready()->void:
	tap_button.hide()
	
	animator.play("cutscene")
	await animator.animation_finished
	await show_advance_prompt()
	get_tree().change_scene_to_packed(next_scene)
	
	#animator.play("before_dialogue")
	#await animator.animation_finished
#
	#Dialog.play(timeline)
	#await text_finished()
	#
	#animator.play("after_dialogue")
	#await animator.animation_finished

func text_finished() -> void:
	while Dialog.panel.visible:
		await get_tree().process_frame

func show_advance_prompt() -> void:
	tap_button.show()
	while not Input.is_action_just_pressed("interact"):
		await get_tree().process_frame
