class_name MeatSaveData extends Resource

@export_storage var meat : int

func save() -> void:
	meat = Global.meat_currency
	
func load() -> void:
	Global.meat_currency = meat
