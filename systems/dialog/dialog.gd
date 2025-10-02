
extends Node

@onready var text_box:=$Panel/VBoxContainer/Speech
@onready var panel:=$Panel
var dialog_lines: Array[String]=[]
@onready var timer:=$LineTimer
@onready var speaker_box:=$Panel/VBoxContainer/Speaker

func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("interact") or event.is_action_pressed("fire")) and (text_box.visible): 
		if (is_text_being_rendered()):
			timer.stop()
			text_box.visible_ratio = 1
			
		else:
			if dialog_lines.is_empty():
				panel.visible = false
				return
			show_line()
			
		
func is_text_being_rendered() -> bool:
	return text_box.visible_ratio != 1





#func _ready() -> void:
	#if not is_inside_tree():
		#get_tree().root.add_child(self)

func play(timeline:DialogTimeline) -> void:
	panel.visible = true
	dialog_lines.assign(timeline.dialog.split("\n"))
	speaker_box.text = ""
	
	show_line()

	print(timeline.dialog)

func show_character() -> void:
	if (text_box.visible_ratio == 1):
		timer.stop()
		#print("Test")
		return
	text_box.visible_characters += 1

func show_line() -> void:
	#var chunks: PackedStringArray = dialog_lines.pop_front().split(":")
	#if chunks.size() == 1:
		#text_box.text = chunks[0]
	timer.start()
	text_box.visible_ratio = 0
	text_box.text = dialog_lines.pop_front()
	
