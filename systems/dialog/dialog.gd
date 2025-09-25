
extends Node

@onready var text_box:=$RichTextLabel
var dialog_lines: Array[String]=[]

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"): #add fire button input
		if dialog_lines.is_empty():
			text_box.visible = false
			return
		text_box.text = dialog_lines.pop_front()

#func _ready() -> void:
	#if not is_inside_tree():
		#get_tree().root.add_child(self)

func play(timeline:DialogTimeline) -> void:
	text_box.visible = true
	text_box.text = timeline.dialog
	dialog_lines.assign(timeline.dialog.split("\n"))
	text_box.text = dialog_lines.pop_front()
	
	
	
	print(timeline.dialog)
