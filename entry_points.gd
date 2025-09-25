class_name EntryPoints extends Node3D

static var current_entry_point:String = ""
static func set_entry_point(entry_point_name: String) -> void:
	current_entry_point = entry_point_name
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var entry_node: Node3D = get_node_or_null(current_entry_point)
	if entry_node == null:
		print("null")
	else:
		print(entry_node.position)
		Player.instance.position = entry_node.global_position
	current_entry_point = ""


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
