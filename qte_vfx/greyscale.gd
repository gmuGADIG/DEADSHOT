extends CanvasLayer

@onready var template: QTETarget2D = %Template

var sprites: Dictionary[NodePath, QTETarget2D] = {}


func new_target(new_name: String) -> QTETarget2D:
	var ret: QTETarget2D = template.duplicate()
	ret.name = new_name
	add_child(ret)
	ret.show()
	
	return ret


func _ready() -> void:
	get_tree().node_added.connect(func(new_node: Node) -> void:
		if new_node.is_in_group("qte_target"):
			var sprite := new_target(str(hash(new_node.get_path())))
			sprites[new_node.get_path()] = sprite
			sprite.clicked.connect(func() -> void: new_node.queue_free())
	)

	get_tree().node_removed.connect(func(doomed_node: Node) -> void:
		if doomed_node.is_in_group("qte_target"):
			sprites[doomed_node.get_path()].queue_free()
			sprites.erase(doomed_node.get_path())
	)


func _process_targets_visibility() -> void:
	for target: Node3D in get_tree().get_nodes_in_group("qte_target"):
		var sprite := sprites[target.get_path()]
		if sprite == null:
			print("huh")
			continue
		sprite.visible = target.visible


func _process_targets_positions() -> void:
	if not MainCam.instance: return
	
	for target: Node3D in get_tree().get_nodes_in_group("qte_target"):
		var sprite := sprites[target.get_path()]
		if sprite == null:
			continue
		sprite.position = MainCam.instance.unproject_position(target.global_position)


func _process(_delta: float) -> void:
	_process_targets_visibility()
	_process_targets_positions()
