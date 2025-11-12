extends Interactable

@export var timeline: DialogTimeline

func interact() -> void:
	if timeline == null:
		push_error("Timeline wasn't set for `%s`" % get_path())
		return
	
	if Dialog.play(timeline):
		await Dialog.timeline_ended
