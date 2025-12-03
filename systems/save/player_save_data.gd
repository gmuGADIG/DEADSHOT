class_name PlayerPersistingData extends Resource

@export_storage var max_health : int
@export_storage var health : int
@export_storage var curr_chamber : int
@export_storage var curr_reserve : int

func save() -> void:
	Player.update_persisting_data()
	max_health = Player.persisting_data.max_health
	health = Player.persisting_data.health
	curr_chamber = Player.persisting_data.curr_chamber
	curr_reserve = Player.persisting_data.curr_reserve
	
func load() -> void:
	Player.persisting_data = PlayerPersistingData.new()
	Player.persisting_data.max_health = max_health
	Player.persisting_data.health = health
	Player.persisting_data.curr_chamber = curr_chamber
	Player.persisting_data.curr_reserve = curr_reserve
