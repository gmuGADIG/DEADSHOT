extends Node
class_name MusicScanner

var root_path: String = "res://audio/music/"
var sound_files: Array[Resource] = []
var song_dict: Dictionary = {}

func _ready() -> void:
	index_all_sound_files_in_root_directory()

# Recursively scan `root_path` and fill both sound_files and song_dict
func index_all_sound_files_in_root_directory() -> void:
	sound_files.clear()
	song_dict.clear()
	_scan_folder(root_path)

func _scan_folder(path: String) -> void:
	var dir: DirAccess = DirAccess.open(path)
	if dir == null:
		push_error("MusicScanner: failed to open directory '%s'" % path)
		return

	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		file_name = file_name.trim_suffix(".remap")
		var full_path: String = path.path_join(file_name)
		if dir.current_is_dir():
			_scan_folder(full_path + "/")
		else:
			if _is_sound_file(file_name):
				var res: Resource = ResourceLoader.load(full_path)
				if res:
					sound_files.append(res)
					# if it's a .tres and actually a Song, add to our song_dict
					if file_name.get_extension().to_lower() == "tres" and res is Song:
						song_dict[file_name] = res
				else:
					push_warning("MusicScanner: could not load '%s'" % full_path)
		file_name = dir.get_next()
	dir.list_dir_end()

# Helper to filter by extension
func _is_sound_file(file_name: String) -> bool:
	var ext: String = file_name.get_extension().to_lower()
	return ext in ["wav", "ogg", "mp3", "tres"]

# Public method to retrieve a Song by its filename (e.g. "example_song.tres")
func get_song_by_filename(filename: String) -> Song:
	return song_dict.get(filename, null) as Song
