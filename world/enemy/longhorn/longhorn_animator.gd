extends AnimatedSprite3D

@onready var enemy: CharacterBody3D = $".."

func _process(_delta: float) -> void:
	var v := enemy.velocity
	if v.x != 0.0:
		flip_h = v.x < 0.0
	else:
		var aim_dir := enemy.global_position.direction_to(Player.instance.global_position)
		flip_h = aim_dir.x < 0.0
