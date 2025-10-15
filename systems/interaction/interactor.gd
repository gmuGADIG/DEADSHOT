extends Area3D
class_name Interactor

var controller: Node3D

func get_closest_interactable() -> Interactable:
	var list: Array[Area3D] = get_overlapping_areas()	
	var distance: float
	var closest_distance: float = INF
	var closest: Interactable = null
	for interactable in list:
		print("iterating on: ", interactable)
		distance = interactable.global_position.distance_to(global_position)

		if distance < closest_distance:
			closest = interactable as Interactable
			closest_distance = distance
			
	return closest

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		var closest := get_closest_interactable()
		if closest != null:
			closest.interact()
		print("Trying to interact with '%s'" % closest)
			
