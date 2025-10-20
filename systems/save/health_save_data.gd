class_name HealthSaveData extends Resource

@export_storage var max_health : int
@export_storage var current_health : int

func save() -> void:
	max_health = Player.instance.health_component.max_health
	current_health = Player.instance.health_component.health
	
func load() -> void:
	Player.instance.health_component.max_health = max_health
	Player.instance.health_component.health = current_health
