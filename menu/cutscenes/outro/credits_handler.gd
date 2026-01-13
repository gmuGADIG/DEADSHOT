extends Node

# i measured this when the scroller speed was at 30 px/s
const CREDITS_DURATION := 158.

func start() -> void:
	%Scroller.start()

	await get_tree().create_timer(CREDITS_DURATION, false).timeout
	SceneManager.change_scene_to_file("res://menu/main_menu/main_menu.tscn")

