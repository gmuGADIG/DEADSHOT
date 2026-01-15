extends Sprite3D

func _process(_delta: float) -> void:
	var cam := MainCam.instance
	
	position = cam.global_position
	position += -cam.basis.z * 50.0
	position += cam.basis.y * 10.0
	position.x *= 0.8
	position.z *= 0.7
