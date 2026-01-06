extends CanvasLayer

@onready var template: QTETarget2D = %Template

var sprites: Dictionary[NodePath, QTETarget2D] = {}
var sprite_ready: Dictionary[NodePath, bool] = {}
var clicked_this_frame := false


func start() -> void:
	var i := 0
	for path in sprites:
		var sprite := sprites[path]
		if get_node(path).visible:
			var tween := sprite.create_tween()
			
			sprite.scale = Vector2.ZERO
			sprite.rotation = -TAU * 1
			
			tween.set_ignore_time_scale(true)
			tween.tween_interval(i * 0.2)
			tween.tween_property(sprite, "scale", sprite.preferred_scale, .45)
			tween.parallel().tween_property(sprite, "rotation", 0, .45)
			
			i += 1
			
			tween.finished.connect(func() -> void: sprite_ready[path] = true)


func new_target(new_name: String) -> QTETarget2D:
	var ret: QTETarget2D = (load("res://qte_vfx/qte_target_2d.tscn") as PackedScene).instantiate()
	ret.name = new_name
	add_child(ret)
	ret.scale = Vector2.ZERO
	ret.show()
	
	return ret


func _on_tree_node_added(new_node: Node) -> void:
	if new_node.is_in_group("qte_target"):
		var sprite := new_target(str(hash(new_node.get_path())))
		sprites[new_node.get_path()] = sprite
		sprite_ready[new_node.get_path()] = false
		sprite.preferred_scale = Vector2.ONE * new_node.scale.x
		sprite.clicked.connect(func() -> void: 
			if sprite_ready[new_node.get_path()] and not clicked_this_frame:
				new_node.queue_free()
				%BulletFlash.flash()
				clicked_this_frame = true
		)


func _ready() -> void:
	get_tree().node_added.connect(_on_tree_node_added)
	for target in get_tree().get_nodes_in_group("qte_target"):
		_on_tree_node_added(target)
	
	get_tree().node_removed.connect(func(doomed_node: Node) -> void:
		if doomed_node.is_in_group("qte_target"):
			sprites[doomed_node.get_path()].queue_free()
			sprites.erase(doomed_node.get_path())
	)


func _process_targets_visibility() -> void:
	for target: Node3D in get_tree().get_nodes_in_group("qte_target"):
		var sprite := sprites[target.get_path()]
		sprite.visible = target.visible


func _process_targets_positions() -> void:
	if not MainCam.instance: return
	
	for target: Node3D in get_tree().get_nodes_in_group("qte_target"):
		var sprite := sprites[target.get_path()]
		sprite.position = MainCam.instance.unproject_position(target.global_position)


func _process(_delta: float) -> void:
	clicked_this_frame = false
	_process_targets_visibility()
	_process_targets_positions()
