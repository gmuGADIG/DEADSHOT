extends Interactable

@export var timelime: DialogTimeline

func interact() -> void:
	Dialog.play(timelime)
