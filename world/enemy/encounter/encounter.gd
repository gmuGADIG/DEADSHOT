@tool
class_name Encounter
extends Area3D

## If an encounter is active, this references it.
## Otherwise, null.
static var active_encounter: Encounter = null

enum EncounterProgress {
	WAITING,
	IN_PROGRESS,
	DONE,
}

## Camera will zoom out this much when the encounter is active.
@export var camera_zoom := 1.2

## When the encounter starts, objects appear one after another, with this many seconds between each object.
@export var appear_delay := 0.1

## Optional. If set, finishing the encounter will change to this scene.
@export var ending_scene: PackedScene = null

var progress := EncounterProgress.WAITING

func _ready() -> void:
	if Engine.is_editor_hint():
		add_collision_shape.call_deferred()
		return
	
	Global.encounter_object_killed.connect(_on_object_killed)
	prepare_encounter()

## If no collision shape is present, adds it automiatically.
## This is called as soon as the object is created, for easier design usage.
func add_collision_shape() -> void:
	#- Check if a collision shape is present -#
	for child in get_children():
		if child is CollisionShape3D:
			return
	
	#- If not, create a new shape -#
	var col := CollisionShape3D.new()
	col.shape = BoxShape3D.new()
	col.shape.size = Vector3(10, 3, 10)
	col.name = "EncounterShape"
	add_child(col, true)
	col.owner = self.owner

func get_encounter_objects() -> Array[EncounterObject]:
	print("Finding encounters.")
	var result: Array[EncounterObject] = []
	for node in get_children():
		if not node.has_meta("encounter_object"): continue
		result.append(node.get_meta("encounter_object"))
	return result

func prepare_encounter() -> void:
	print("Encounter prepared...")
	progress = EncounterProgress.WAITING
	for obj in get_encounter_objects():
		obj.hide()

func start_encounter() -> void:
	print("Encounter START")
	progress = EncounterProgress.IN_PROGRESS
	active_encounter = self
	%CameraTracked.enabled = true
	
	var objects := get_encounter_objects()
	for obj in objects:
		obj.prepare()
	
	for obj in objects:
		obj.start()
		await get_tree().create_timer(appear_delay, false).timeout

func end_encounter() -> void:
	print("Encounter END")
	progress = EncounterProgress.DONE
	%CameraTracked.enabled = false
	active_encounter = null
	
	for obj in get_encounter_objects():
		obj.finish()
	
	if ending_scene != null:
		get_tree().change_scene_to_packed(ending_scene)

func _is_encounter_done() -> bool:
	for o: EncounterObject in get_encounter_objects():
		if o.is_enemy(): return false
	
	return true

func _on_object_killed(obj: EncounterObject) -> void:
	if progress != EncounterProgress.IN_PROGRESS: return # this is another encounter's problem
	
	print("Object killed: `%s`" % obj.get_parent().name)
	await get_tree().process_frame
	if _is_encounter_done():
		end_encounter()

func _on_body_entered(body: Node3D) -> void:
	if progress != EncounterProgress.WAITING: return # encounter has already been started
	
	if body is Player && _is_encounter_done() == false:## Added a check to see if encounter is "done" before starting. Because enemies do not respawn, the get encounter will be zero hence encounter will be done.
		start_encounter()

static func is_encounter_active() -> bool:
	return active_encounter != null
