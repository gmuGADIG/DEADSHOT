extends Node

signal meat_changed

@warning_ignore("unused_signal")
signal encounter_object_killed(obj: EncounterObject)

var meat_currency:int = 1000:
	set(new_val):
		meat_currency = new_val
		meat_changed.emit()
