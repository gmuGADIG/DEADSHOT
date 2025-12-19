class_name MainCam
extends Camera3D

static var instance: MainCam

@export var offset: Vector3
@export var encounter_zoom: float = 1.0
@export var smoothing: float

func _init() -> void:
	instance = self

func _ready() -> void:
	global_position = average_position()

func _process(delta: float) -> void:
	var target := average_position()
	if Encounter.is_encounter_active():
		target += offset * Encounter.active_encounter.camera_zoom
	else:
		target += offset
	
	global_position = lerp(global_position, target, 1.0 - exp(-smoothing * delta))

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
