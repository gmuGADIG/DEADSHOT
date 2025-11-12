extends HBoxContainer

func _ready() -> void:
	set_stamina(Player.instance.stamina)
	Global.player_stamina_changed.connect(set_stamina)

func set_stamina(stamina: float) -> void:
	visible = stamina < 3.0
	
	for blip: ProgressBar in get_children():
		blip.value = clamp(stamina, 0, 1)
		stamina -= 1.0
