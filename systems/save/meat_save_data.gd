class_name MeatSaveData extends Resource

@export_storage var meat : int

func _init() -> void:
	if Global == null:
		return
	Global.meat_currency = 1000

func save() -> void:
	meat = Global.meat_currency
	
func load() -> void:
	Global.meat_currency = meat
