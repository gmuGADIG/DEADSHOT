extends AnimatedSprite3D

@onready var enemy: CharacterBody3D = $".."

func _process(_delta: float) -> void:
	var v := enemy.velocity
	if v.z != 0.0:
		play("up" if v.z > 0 else "down")
	
	if v.x != 0.0:
		flip_h = v.x < 0
