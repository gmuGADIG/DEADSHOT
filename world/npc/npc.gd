extends Interactable

@export var timeline: DialogTimeline

func _ready() -> void:
	if timeline == null:
		push_error("Timeline wasn't set for `%s`! Using placeholder." % get_path())
		timeline = load("res://world/npc/test/placeholder_timeline.tres")

func interact() -> void:
	if Dialog.play(timeline):
		await Dialog.timeline_ended
