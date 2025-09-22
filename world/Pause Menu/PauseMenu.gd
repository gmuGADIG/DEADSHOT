extends Control
var is_paused: bool = false

var resume_button: Button
var options_button: Button
var quit_to_menu_button: Button
var close_game_button: Button

func _ready() ->void:
	resume_button = $Panel/VBoxContainer/ResumeButton
	options_button = $Panel/VBoxContainer/OptionsButton
	quit_to_menu_button = $Panel/VBoxContainer/QuitToMenuButton
	close_game_button = $Panel/VBoxContainer/CloseGameButton
	
	hide()

func _process(delta: float) ->void:
	#Makes ESC key pull up pause menu and close it again
	if(Input.is_action_just_pressed("ui_cancel")):
		if (is_paused == true):
			is_paused = false
			get_tree().paused = false
			hide()
		else:
			is_paused = true
			show()
	if(resume_button.button_pressed):
		get_tree().paused = false
		hide()
	if(options_button.button_pressed):
		print("Options menu goes here")
	if(quit_to_menu_button.button_pressed):
		#Add "game won't save" popup here
		print("Returning to Main Menu...")
		#Send back to main menu
		get_tree().quit()
	if(close_game_button.button_pressed):
		#Add "game won't save" popup here
		get_tree().quit()
