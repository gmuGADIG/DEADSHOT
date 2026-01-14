extends Control
@onready var tap_button : TextureButton = $TextureButton
@onready var animator : AnimationPlayer = $AnimationPlayer
@onready var text : Node2D = $Text

@export var timelines: Array[DialogTimeline]
@export var next_scene: PackedScene

@export var auto_advance := false

func play_timeline(timeline_idx: int) -> void:
	animator.pause()
	Dialog.play(timelines[timeline_idx])
	await text_finished()
	animator.play()

func goto_music_section(section_name: String, transition_time: float = 0.5) -> void:
	MainMusicPlayer.goto_section(section_name, transition_time)

func set_music_volume(level: float, duration: float = 0.0) -> void:
	MainMusicPlayer.set_volume(level, duration)

func _ready()->void:
	tap_button.hide()
	
	animator.play("cutscene")

	# animator.seek(50.) # TODO: remove this line
	# MainMusicPlayer.seek(50.) # TODO: remove this line

	await animator.animation_finished
	if not auto_advance:
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
	while Dialog.visible:
		await get_tree().process_frame

func show_advance_prompt() -> void:
	tap_button.show()
	while not Input.is_action_just_pressed("interact"):
		await get_tree().process_frame
