@tool
extends Encounter

@export var anim: AnimationPlayer
@export var pre_timeline: DialogTimeline
@export var mass: TheMass

func start_encounter() -> void:
	Player.instance._on_interaction_started()
	anim.play("start")
	await anim.animation_finished
	MainCam.instance.process_mode = Node.PROCESS_MODE_DISABLED
	
	Dialog.play(pre_timeline)
	await Dialog.timeline_ended
	
	MainCam.instance.process_mode = Node.PROCESS_MODE_INHERIT
	super.start_encounter()
	Global.boss_spawned.emit(mass)
	Player.instance._on_interaction_ended()
