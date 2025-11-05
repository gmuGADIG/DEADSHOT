class_name Save extends Resource

const SAVE_FILE := "user://save.tres" ## Filepath where the save file is loaded

static var save_data : Save ## The resource that gets saved to file
@export var object_save_data : ObjectSaveData ## Saves objects in the world, e.g. campfires used, enemies killed
@export var location_save_data : LocationSaveData ## Saves information regarding the player's location
@export var health_save_data : HealthSaveData ## Saves info regarding the player's max health

static func _static_init() -> void:
	Save.create()

static func create() -> void: ## Creates an empty save file if one does not exist
	save_data = Save.new()
	save_data.object_save_data = ObjectSaveData.new()
	save_data.location_save_data = LocationSaveData.new()
	save_data.health_save_data = HealthSaveData.new()

static func save_game() -> void: ## Saves the game
	save_data.object_save_data.save()
	save_data.location_save_data.save()
	save_data.health_save_data.save()
	
	ResourceSaver.save(save_data, SAVE_FILE)

static func load_game() -> void: ## Loads the game
	if not ResourceLoader.exists(SAVE_FILE):
		printerr("Save file not found")
	
	save_data = ResourceLoader.load(SAVE_FILE)
	
	save_data.object_save_data.load()
	save_data.location_save_data.load()
	save_data.health_save_data.load()

static func save_file_exists() -> void:
	ResourceLoader.exists(SAVE_FILE)
