class_name ArenaArea extends CollisionShape3D

#var cube_area : BoxShape3D
var arena_threshold : Vector3 

func _ready() -> void:
	assert(shape is BoxShape3D, "Arena area is not a box shape")
	arena_threshold = shape.size/2
	
func is_point_in_arena(point : Vector3) -> bool:
	var rel_point : Vector3 = (point-global_position).abs()
	return rel_point.x <= arena_threshold.x and rel_point.z <= arena_threshold.z
