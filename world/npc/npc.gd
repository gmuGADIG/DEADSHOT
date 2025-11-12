extends Interactable

@export var timelime: DialogTimeline

func interact() -> void:
	if Dialog.play(timelime):
		await Dialog.timeline_ended
