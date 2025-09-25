extends Area3D

@export var newScene:PackedScene
# Called when the node enters the scene tree for the first time.


func _on_body_entered(body: Node3D) -> void:
	if (body.is_in_group("Player")):
		print("Teleporting!")
		get_tree().change_scene_to_packed(newScene) # Replace with function body.
