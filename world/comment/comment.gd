@tool
extends Node3D

const BASE_SIZE := 0.01

@export_multiline var text: String:
	set(value):
		text = value
		update_text()

@export_range(0, 2) var size: float:
	set(value):
		size = value
		update_text()

func _ready() -> void:
	update_text()

func update_text() -> void:
	if not is_node_ready(): return
	%Label.text = text
	%Label.pixel_size = size * BASE_SIZE
