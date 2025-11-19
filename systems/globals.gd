extends Node

signal meat_changed

signal encounter_object_killed(obj: EncounterObject)

signal player_hp_changed(value: int)
signal player_max_hp_changed(value: int)

signal player_ammo_changed(value: int)
signal player_ammo_reserve_changed(value: int)
signal player_reload_progress_changed(value: float)

signal player_stamina_changed(value: float)

var meat_currency:int = 1000:
	set(new_val):
		meat_currency = new_val
		meat_changed.emit()
