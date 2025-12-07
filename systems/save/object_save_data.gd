class_name ObjectSaveData extends Resource

@export_storage var lit_campfires: Array[NodePath]
@export_storage var dead_enemies: Array[NodePath]

#- Campfires -#
func has_campfire(campfire: Campfire) -> bool:
	return lit_campfires.has(campfire.get_path())

func add_campfire(campfire: Campfire) -> void:
	lit_campfires.append(campfire.get_path())

#- Encounters -#
func mark_dead(enemy: Encounter) -> void:
	dead_enemies.append(enemy.get_path())
	
func is_dead(enemy: Encounter) -> bool:
	return dead_enemies.has(enemy.get_path())

#- Save / Load -#
func save() -> void:
	pass

func load() -> void:
	pass
