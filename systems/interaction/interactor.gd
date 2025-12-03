extends Area3D
class_name Interactor

var controller: Node3D
var interactable : Interactable = null

var is_interacting := false:
	set(value):
		if value == is_interacting: return
		is_interacting = value
		
		if is_interacting: interaction_started.emit()
		else: interaction_ended.emit()

signal interaction_started
signal interaction_ended

func get_closest_interactable() -> Interactable:
	var list: Array[Area3D] = get_overlapping_areas()	
	var distance: float
	var closest_distance: float = INF
	var closest: Interactable = null
	for item in list:
		print("iterating on: ", item)
		distance = item.global_position.distance_to(global_position)

		if distance < closest_distance:
			closest = item as Interactable
			closest_distance = distance

	return closest

func _process(_delta: float) -> void:	
	if is_interacting: return
	
	if Input.is_action_just_pressed("interact"):
		interactable = get_closest_interactable()
		if interactable != null:
			is_interacting = true
			
			@warning_ignore("redundant_await")
			await interactable.interact()
			
			is_interacting = false
		print("Trying to interact with '%s'" % interactable)
