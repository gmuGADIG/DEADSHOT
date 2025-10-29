extends Sprite3D

func _process(_delta: float) -> void:
	var cam := MainCam.instance
	
	position = cam.global_position
	position += -cam.basis.z * 50.0
	position.x *= 0.9
