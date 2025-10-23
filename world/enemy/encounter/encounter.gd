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
	for obj in get_encounter_objects():
		obj.start()
		await get_tree().create_timer(0.1, false).timeout

func end_encounter() -> void:
	print("Encounter END")
	progress = EncounterProgress.DONE
	active_encounter = null

func _is_encounter_done() -> bool:
	for o: EncounterObject in get_tree().get_nodes_in_group("encounter_object"):
		if o.is_enemy() and o.is_active(): return false
	
	return true

func _on_object_killed(obj: EncounterObject) -> void:
	if progress != EncounterProgress.IN_PROGRESS: return # this is another encounter's problem
	
	print("Object killed: `%s`" % obj.get_parent().name)
	await get_tree().process_frame
	if _is_encounter_done():
		end_encounter()

func _on_body_entered(body: Node3D) -> void:
	if progress != EncounterProgress.WAITING: return # encounter has already been started
	
	if body is Player:
		start_encounter()

static func is_encounter_active() -> bool:
	return active_encounter != null
