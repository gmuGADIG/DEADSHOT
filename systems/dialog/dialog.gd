
extends Node

@onready var text_box:=$RichTextLabel
var dialog_lines: Array[String]=[]
@onready var timer:=$LineTimer

func _input(event: InputEvent) -> void:
	
	if (event.is_action_pressed("interact") or event.is_action_pressed("fire")) and (text_box.visible): 
		if (is_text_being_rendered()):
			timer.stop()
			text_box.visible_ratio = 1
			
		else:
			if dialog_lines.is_empty():
				text_box.visible = false
				return
			text_box.visible_ratio = 0
			text_box.text = dialog_lines.pop_front()
			timer.start()
		
func is_text_being_rendered() -> bool:
	return text_box.visible_ratio != 1
	
	

	

#func _ready() -> void:
	#if not is_inside_tree():
		#get_tree().root.add_child(self)

func play(timeline:DialogTimeline) -> void:
	text_box.visible = true
	timer.start()
	text_box.visible_characters = 0
	text_box.visible_ratio = 0
	text_box.text = timeline.dialog
	dialog_lines.assign(timeline.dialog.split("\n"))
	text_box.text = dialog_lines.pop_front()
	
	#show_character()
	
	
	print(timeline.dialog)

func show_character() -> void:
	if (text_box.visible_ratio == 1):
		timer.stop()
		#print("Test")
		return
	text_box.visible_characters += 1
	
	
