extends Node

var save_file_path := "user://save/"
var save_file_name := "PlayerSave.tres"

var playerData := PlayerData.new()

@onready var player := $"../Player"

@onready var button1 := $Button
@onready var button2 := $Button2

func _ready() -> void:
	verify_save_directory(save_file_path)

func verify_save_directory(path : String) -> void:
	DirAccess.make_dir_absolute(path)

func save_player_data_to_resource() -> void:
	playerData.set_position(player.position)
	playerData.set_scene(player.scene_file_path)

func load_player_data_from_resource() -> void:
	player.position = Vector3(playerData.posX,0,playerData.posY)
	
func load_game() -> void:
	playerData = ResourceLoader.load(save_file_path + save_file_name).duplicate(true)
	load_player_data_from_resource()
func save_game() -> void:
	save_player_data_to_resource()
	ResourceSaver.save(playerData, save_file_path + save_file_name)
		


func _process(_delta: float) -> void:
	if(Input.is_key_pressed(KEY_ESCAPE)):
		button1.visible = !button1.visible
		button2.visible = !button2.visible

	

func _on_button_pressed() -> void:
	save_game()

func _on_button_2_pressed() -> void:
	load_game()
