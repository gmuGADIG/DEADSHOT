class_name EncounterObject
extends Node

## If false, the object will start hidden until an encounter starts.
## If true, the object will be active and visible from the start.
## Useful if an enemy is spawned in the middle of an encounter.
@export var start_active := false

## If true, this object will immediately activate when an encounter starts.
## Otherwise, there will be an animated delay.
@export var start_instant := false

## True if the object should hide itself after the encounter finishes.
@export var hide_on_finish := false

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

## Called when the game starts. Hides the object until the encounter starts.
func hide() -> void:
	var p: Node3D = get_parent()
	p.visible = false
	p.process_mode = PROCESS_MODE_DISABLED

## Called on all objects immediately when the encounter starts.
## Different from `start`, which is called after some animated delay.
func prepare() -> void:
	if start_instant: start()

## Called when the encounter starts. Makes the object appear, with a little animation.
## Note that each object's start method is called one after another, with a delay between each one.
func start() -> void:
	if _started: return
	
	_started = true
	
	var p: Node3D = get_parent()
	p.visible = true
	p.process_mode = Node.PROCESS_MODE_INHERIT
	
	# Animation
	var y := p.position.y
	p.position.y = -5.0
	var tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(p, "position:y", y, 0.01 if start_instant else 0.3)
	await tween.finished
	

## Called when the encounter finishes.
func finish() -> void:
	if not hide_on_finish: return
	
	var p: Node3D = get_parent()
	
	var tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(p, "position:y", -5, 0.3)
	await tween.finished
	
	p.visible = false
	p.process_mode = Node.PROCESS_MODE_DISABLED

func is_active() -> bool:
	return _started

func is_enemy() -> bool:
	return get_parent() is EnemyBase
