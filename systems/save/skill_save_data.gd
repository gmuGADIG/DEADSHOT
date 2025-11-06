class_name SkillSaveData extends Resource

@export_storage var skill_bitfield : int

func save() -> void:
	skill_bitfield = SkillSet.skill_bitfield
	
func load() -> void:
	SkillSet.skill_bitfield = skill_bitfield
