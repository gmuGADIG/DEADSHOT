class_name EnemySaveData extends Resource

@export_storage var dead_list : Dictionary = {}

func mark_dead(id: String) -> void:
	dead_list[id] = true
	
func is_dead(id: String) -> bool:
	return dead_list.get(id, false)
