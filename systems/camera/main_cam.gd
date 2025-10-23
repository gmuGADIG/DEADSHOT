extends Camera3D

@export var offset: Vector3

func _process(_delta: float) -> void:
	var target := average_position()
	target += offset
	
	global_position = target

func average_position() -> Vector3:
	# Do a weighted average on all "camera_tracked" nodes
	var result := Vector3.ZERO
	var weight_sum := 0.0
	for obj: CameraTracked in get_tree().get_nodes_in_group("camera_tracked"):
		var pos := obj.global_position
		pos.y = 0.0
		result += pos * obj.weight
		weight_sum += obj.weight
	result /= weight_sum
	return result
