extends Area3D
class_name Interactor

var controller: Node3D
var interactable : Interactable = null

func _ready() -> void:
	Dialog.finish_interaction.connect(change_player_state)

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
	if Input.is_action_just_pressed("interact"):
		interactable = get_closest_interactable()
		if interactable != null:
			interactable.interact()
		print("Trying to interact with '%s'" % interactable)
		change_player_state()

func change_player_state() -> void:
	if (Dialog.is_text_being_rendered()):
		get_parent().emit_signal("begin_interacting")
	else:
		get_parent().emit_signal("end_interacting")
