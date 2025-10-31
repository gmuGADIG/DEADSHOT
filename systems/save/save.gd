class_name Save extends Resource

const SAVE_FILE := "user://save.tres" ## Filepath where the save file is loaded

static var save_data : Save ## The resource that gets saved to file
@export var location_save_data : LocationSaveData ## Saves information regarding the player's location
@export var health_save_data : HealthSaveData ## Saves info regarding the player's max health
@export var skill_save_data : SkillSaveData ## Saves the player's selected skills

static func create() -> void: ## Creates an empty save file if one does not exist
	save_data = Save.new()
	save_data.location_save_data = LocationSaveData.new()
	save_data.health_save_data = HealthSaveData.new()
	save_data.skill_save_data = SkillSaveData.new()

static func save_game() -> void: ## Saves the game
	if save_data == null:
		Save.create()
	
	save_data.location_save_data.save()
	save_data.health_save_data.save()
	save_data.skill_save_data.save()
	
	ResourceSaver.save(save_data, SAVE_FILE)

static func load_game() -> void: ## Loads the game
	if not ResourceLoader.exists(SAVE_FILE):
		printerr("Save file not found")
	
	save_data = ResourceLoader.load(SAVE_FILE)
	
	save_data.location_save_data.load()
	save_data.health_save_data.load()
	save_data.skill_save_data.load()

static func save_file_exists() -> void:
	ResourceLoader.exists(SAVE_FILE)

		
