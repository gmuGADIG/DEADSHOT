extends Control

func _ready() -> void:
	Global.meat_changed.connect(_on_meat_changed)
	display_meat()

func _on_meat_changed() -> void:
	display_meat()

func display_meat() -> void:
	%MeatLabel.text = str(Global.meat_currency)
