extends AnimatedSprite3D

var Barrel = AnimatedSprite3D.new()

func hit(bullet: Bullet) -> void:
	Barrel.play("new_animation")
	
func _process(delta):
	pass
