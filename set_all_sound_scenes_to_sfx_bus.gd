@tool
extends EditorScript

const TARGET_FOLDER := "res://audio/streams" # <-- change this
const FROM_BUS := "Master"
const TO_BUS := "SFX"

func _run() -> void:
	var dir := DirAccess.open(TARGET_FOLDER)
	if dir == null:
		push_error("Failed to open folder: " + TARGET_FOLDER)
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()
	var changed_scenes := 0

	while file_name != "":
		if file_name.ends_with(".tscn"):
			var scene_path := TARGET_FOLDER + "/" + file_name
			if _process_scene(scene_path):
				changed_scenes += 1
		file_name = dir.get_next()

	dir.list_dir_end()
	print("Done. Modified %d scenes." % changed_scenes)


func _process_scene(scene_path: String) -> bool:
	print(scene_path)
	var scene := load(scene_path) as PackedScene
	var stream := scene.instantiate()
	if stream.get("bus") != null:
		stream.bus = &"SFX"
		scene.pack(stream)
		ResourceSaver.save(scene, scene_path)
		return true
	return false
