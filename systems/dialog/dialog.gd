
extends Node

@onready var text_box:=$RichTextLabel

#func _ready() -> void:
	#if not is_inside_tree():
		#get_tree().root.add_child(self)

func play(timeline:DialogTimeline) -> void:
	text_box.text=timeline.dialog
	print(timeline.dialog)
	
