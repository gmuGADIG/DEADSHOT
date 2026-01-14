extends Node

signal meat_changed

signal encounter_object_killed(obj: EncounterObject)

signal player_hp_changed(value: float)
signal player_max_hp_changed(value: float)

signal player_ammo_changed(value: int)
signal player_ammo_reserve_changed(value: int)
signal player_reload_progress_changed(value: float)

signal player_stamina_changed(value: float)

signal skill_tree_changed(skill: SkillSet.SkillUID)
signal skill_removed(skill: SkillSet.SkillUID)

signal boss_spawned(boss: BossEnemy)
signal entered_boss_encounter

var meat_currency:int = 999:
	set(new_val):
		meat_currency = new_val
		meat_changed.emit()
