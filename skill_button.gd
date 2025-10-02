extends TextureButton

@export var skillName:String
@export var meatCost:int

func _ready() -> void:
	$Label.text = skillName
