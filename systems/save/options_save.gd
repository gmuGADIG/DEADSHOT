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
	
	Options.sfx_value = options_save_data.sfx_value
	Options.music_value = options_save_data.music_value
	
static func save_options() -> void:
	print()
	options_save_data.sfx_value = Options.sfx_value
	options_save_data.music_value = Options.music_value
	ResourceSaver.save(options_save_data, OPTIONS_SAVE)
	
