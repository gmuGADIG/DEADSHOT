extends Area3D
@export_file("*.tscn") var target_scene:String 
@export var target_entry_point:String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		EntryPoints.set_entry_point(target_entry_point)
		get_tree().change_scene_to_file(target_scene)
	pass # Replace with function body.
