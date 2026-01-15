@tool
extends Encounter

@export var horse: Horse
@export var pre_timeline: DialogTimeline
@export var post_timeline: DialogTimeline

func start_encounter() -> void:
	Player.instance._on_interaction_started()
	Dialog.play(pre_timeline)
	await Dialog.timeline_ended
	Player.instance._on_interaction_ended()
	
	Global.boss_spawned.emit(horse)
	super.start_encounter()
	
	horse.process_mode = Node.PROCESS_MODE_INHERIT
	await Global.player_max_hp_changed # hacky way to wait for corrupt heart to be destroyed
	await get_tree().create_timer(0.5, false).timeout
	
	Player.instance._on_interaction_started()
	Dialog.play(post_timeline)
	await Dialog.timeline_ended
	
	Player.instance._on_interaction_ended()
