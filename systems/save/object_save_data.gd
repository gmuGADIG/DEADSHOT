class_name ObjectSaveData extends Resource

@export_storage var lit_campfires: Array[NodePath]

func has_campfire(campfire: Campfire) -> bool:
	return lit_campfires.has(campfire.get_path())

func add_campfire(campfire: Campfire) -> void:
	lit_campfires.append(campfire.get_path())

func save() -> void:
	pass

func load() -> void:
	pass
