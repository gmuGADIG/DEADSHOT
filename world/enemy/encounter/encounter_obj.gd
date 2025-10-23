class_name EncounterObject
extends Node

## If false, the object will start hidden until an encounter starts.
## If true, the object will be active and visible from the start.
## Useful if an enemy is spawned in the middle of an encounter.
@export var start_active := false

var _started := false

func _ready() -> void:
	# Set parent metadata and group
	print("Added metadata to '%s'" % get_parent().name)
	get_parent().set_meta("encounter_object", self)
	self.add_to_group("encounter_object")
	
	# If there's a health component, attach to its signals
	var health := _find_health_node()
	if health != null:
		health.killed.connect(Global.encounter_object_killed.emit.bind(self))

func _find_health_node() -> Health:
	for sibling in get_parent().get_children():
		if sibling is Health: return sibling
		if sibling is Hurtbox: return sibling.health_component
	return null

func hide() -> void:
	var p: Node3D = get_parent()
	p.visible = false
	p.process_mode = PROCESS_MODE_DISABLED

func start() -> void:
	_started = true
	
	var p: Node3D = get_parent()
	p.visible = true
	p.process_mode = Node.PROCESS_MODE_INHERIT
	
	# Animation
	var y := p.position.y
	p.position.y = -5.0
	var tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(p, "position:y", y, 0.3)
	await tween.finished

func is_active() -> bool:
	return _started

func is_enemy() -> bool:
	return get_parent() is EnemyBase
