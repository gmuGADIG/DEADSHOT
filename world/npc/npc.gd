class_name NPC
extends Interactable

@export var timeline: DialogTimeline
@export var duo: Array[NPC] ## Interacting with this NPC will de-exclaim anyone in this array

func _ready() -> void:
	if timeline == null:
		push_error("Timeline wasn't set for `%s`! Using placeholder." % get_path())
		timeline = load("res://world/npc/test/placeholder_timeline.tres")

func interact() -> void:
	%Exclaim.hide()
	if Dialog.play(timeline):
		if $PaperPickupSound:
			$PaperPickupSound.play()
		await Dialog.timeline_ended

func show_exclamation() -> void:
	%Exclaim.show()
