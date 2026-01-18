extends Node

# i measured this when the scroller speed was at 30 px/s
const CREDITS_DURATION := 218.
var started := false

@export var songs: Array[Song]

func start() -> void:
	started = true
	%Scroller.start()

	# await get_tree().create_timer(CREDITS_DURATION, false).timeout

	var t := CREDITS_DURATION / songs.size()
	for song in songs:
		MainMusicPlayer.play_song(song)
		await get_tree().create_timer(t, false).timeout

	SceneManager.change_scene_to_file("res://menu/main_menu/main_menu.tscn")

func _process(_delta: float) -> void:
	if Input.is_action_pressed("speed_up_credits") and started:
		Engine.time_scale = 5.
	else:
		Engine.time_scale = 1.

func _exit_tree() -> void:
	Engine.time_scale = 1.
