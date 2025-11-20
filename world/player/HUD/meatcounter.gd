extends Control

var meat_currency:int = 1000:
	set(new_val):
		meat_currency = new_val
	
func _ready() -> void:
	set_meat(Global.meat_currency)
	Global.meat_changed.connect(_on_meat_changed)

func _on_meat_changed() -> void:
	set_meat(Global.meat_currency)

func set_meat(meat: int) -> void:
	$MeatLabel.text = str(meat)
	
	
	
	
	
