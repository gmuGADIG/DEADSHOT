extends Node3D

@export var encounter: Encounter
@export var anim: AnimationPlayer
@export var pre_timeline: DialogTimeline
@export var post_timeline: DialogTimeline

func _ready() -> void:
	Save.save_game()
	encounter.start_encounter()
	anim.play("start")
	await anim.animation_finished
	
	Dialog.play(pre_timeline)
	await Dialog.timeline_ended
	
	anim.play("fight")
	await Global.player_max_hp_changed # hacky way to wait for the corrupt heart to break
	await get_tree().create_timer(1.0, false).timeout # bit of extra wait
	
	Dialog.play(post_timeline)
	await Dialog.timeline_ended
