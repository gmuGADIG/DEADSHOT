extends Area3D

class_name Interactor

var controller: Node3D

func interact(interactable: Interactable) -> void:
	interactble.interacted.emit(self)

func focus(interactable: Interactable) -> void:
	interactble.focused.emit(self)

func unfocus(interactable: Interactable) -> void:
	interactble.unfocused.emit(self)
	
func get_closest_interactable() -> Interactable:
	var list: Array[Area3D] = get_overlapping_areas()
	var distance: float
	var closest_distance: float = INF
	var closest: Interactable = null
		
	for interactable in list:
		distance = Interactable.global_position.distance_to(global_position)
		
		if distance < closest_distance:
			closest = interactable as Interactable
			closest_distance = distance
			
	return closest
			
			
