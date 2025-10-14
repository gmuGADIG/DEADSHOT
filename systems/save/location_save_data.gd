class_name LocationSaveData extends Resource

const DEFAULT_SCENE : String = "res://test_scenes/example_scene.tscn"

@export_storage var scene_file_path : String
@export_storage var position : Vector3


func save() -> void:
	position = Player.instance.position
	scene_file_path = Player.instance.get_tree().current_scene.scene_file_path

func load() -> void:
	var tree : SceneTree = Engine.get_main_loop() as SceneTree
	if ResourceLoader.exists(scene_file_path):
		tree.change_scene_to_file(scene_file_path)
		await tree.scene_changed
		Player.instance.position = position
	else:
		tree.change_scene_to_file(DEFAULT_SCENE)
