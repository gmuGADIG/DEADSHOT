class_name OptionsSave extends Resource

const OPTIONS_SAVE := "user://options.tres"

static var options_save_data : OptionsSave
static var sfx_bus := AudioServer.get_bus_index("SFX")

@export_storage var sfx_value := 100.0
@export_storage var music_value := 100.0

static func _static_init() -> void:
	load_options()

static func load_options() -> void:
	if ResourceLoader.exists(OPTIONS_SAVE):
		options_save_data = ResourceLoader.load(OPTIONS_SAVE)
	else:
		options_save_data = OptionsSave.new()
		
	MainMusicPlayer.set_master_loudness(clampf(options_save_data.music_value / 100.0, 0.0, 1.0))
	AudioServer.set_bus_volume_linear(sfx_bus, options_save_data.sfx_value / 100.0)
	
static func save_options() -> void:
	options_save_data.sfx_value = db_to_linear(AudioServer.get_bus_volume_db(sfx_bus)) * 100
	options_save_data.music_value = MainMusicPlayer.get_master_loudness() * 100.0
	ResourceSaver.save(options_save_data, OPTIONS_SAVE)
	
