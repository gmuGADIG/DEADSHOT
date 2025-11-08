extends Node

var dead_list := {}

func mark_dead(id: String) -> void:
	dead_list[id] = true
	
func is_dead(id: String) -> bool:
	return dead_list.get(id, false)
