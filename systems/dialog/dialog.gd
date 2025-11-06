extends Node

const DEBOUNCE_DURATION := .1

@onready var text_box:=$Panel/VBoxContainer/Speech
@onready var panel:=$Panel
@onready var timer:=$LineTimer
@onready var speaker_box:=$Panel/VBoxContainer/Speaker
@onready var base_speed :float= 1/$LineTimer.wait_time
@onready var sound_effect:=$AudioStreamPlayer 

var dialog_lines: Array[String]=[]
var last_dialog_timestamp := 0.

@export var sfx : Voicebank
@export var skip_n_characters : int = 0

func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("interact") or event.is_action_pressed("fire")) and panel.visible: 
		if (is_text_being_rendered()):
			timer.stop()
			text_box.visible_ratio = 1
		else:
			if dialog_lines.is_empty():
				panel.visible = false
				last_dialog_timestamp = Time.get_ticks_msec()
				return
			show_line()

func debounce() -> bool:
	return last_dialog_timestamp + (DEBOUNCE_DURATION * 1000) > Time.get_ticks_msec()

func is_text_being_rendered() -> bool:
	return text_box.visible_ratio != 1

func play(timeline:DialogTimeline) -> void:
	if panel.visible or debounce(): 
		push_warning("Dialog.play called when a timeline is already playing. Ignoring...")
		return
	panel.visible = true
	dialog_lines.assign(timeline.dialog.split("\n"))
	speaker_box.text = ""
	
	show_line()

var countPlayedCharacters := 0
const punctuationCharacters := [".", ",", "!", "?", ";", ":"]
func play_char(character: String) -> void:
	if not sfx: return
	for sound in sfx.charToSteam:
		if character in punctuationCharacters and sound.resource_path.ends_with("Punc.wav"):
			sound_effect.stream = sound
			sound_effect.play() # force play punctuation sound
			return
		if sound.resource_path.ends_with(character.to_upper() + ".wav"):
			if countPlayedCharacters >= skip_n_characters:
				countPlayedCharacters = 0
			else:
				countPlayedCharacters += 1
				return
			sound_effect.stream = sound
			sound_effect.play()

func show_character() -> void:
	if not is_text_being_rendered():
		timer.stop()
		return
	check_speed_change()
	play_char(text_box.text[text_box.visible_characters])
	
	text_box.visible_characters += 1

func check_speed_change() -> void:
	if not is_text_being_rendered():
		return
	if text_box.text[text_box.visible_characters] != '{':
		return

	var non_visible_text:String = text_box.text.substr(text_box.visible_characters)
	var visible_text:String = text_box.text.substr(0, text_box.visible_characters)
	
	var regex:RegEx = RegEx.new()
	regex.compile(r"^\{speed=(?<speed>\d?\.?\d+)\}(?<rest>.*)$")
	var match:RegExMatch = regex.search(non_visible_text)
	if match:
		var speed:float = match.get_string("speed").to_float()
		timer.wait_time = 1/(base_speed * speed)
		text_box.text = visible_text + match.get_string("rest")
		timer.start()

func show_line() -> void:
	timer.wait_time = 1/base_speed
	timer.start()

	var line:String = parse_dialog_line(dialog_lines.pop_front())
	
	text_box.visible_ratio = 0
	text_box.text = line
	
	
func parse_dialog_line(line:String) -> String:
	var regex:RegEx = RegEx.new()
	regex.compile(r"^(?:\[(?<speaker>[^\[\]]+)\]:?)?(.*)$")
	var match:RegExMatch = regex.search(line)
	if match:
		var speaker:String = match.get_string("speaker")
		if speaker != "":
			speaker_box.text = speaker
		return match.get_string(2).strip_edges()
	return line.strip_edges()
