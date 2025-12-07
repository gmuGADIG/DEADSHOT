class_name HealthSaveData extends Resource

@export_storage var max_health : float

func save() -> void:
	max_health = Player.instance.health_component.max_health
	
func load() -> void:
	Player.instance.health_component.max_health = max_health
