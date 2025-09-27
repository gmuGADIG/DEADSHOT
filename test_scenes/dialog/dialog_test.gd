extends Node2D
@export var timeline:DialogTimeline

func _ready() -> void:
	Dialog.play(timeline)
	
