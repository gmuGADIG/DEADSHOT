extends Control

var tween: Tween

var meat_currency: int = 0:
	set(new_val):
		meat_currency = new_val
	
func _ready() -> void:
	set_meat(Global.meat_currency)
	Global.meat_changed.connect(_on_meat_changed)

func _on_meat_changed() -> void:
	if tween and tween.is_valid():
		tween.kill()
	
	tween = create_tween()
	
	tween.tween_property(self, "scale", Vector2(1.1,1.1), 0.25).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1,1), 0.25).set_ease(Tween.EASE_IN)
	set_meat(Global.meat_currency)

func set_meat(meat: int) -> void:
	$MeatLabel.text = str(meat)
	
	
	
	
	
