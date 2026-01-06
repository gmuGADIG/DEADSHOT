extends Node3D

var health: Health
func _ready() -> void:
	await get_tree().process_frame

	if get_child_count() == 0:
		queue_free()
		return
	
	var parent := get_parent() as EnemyBase
	if parent == null:
		queue_free()
		return
	
	health = parent.health
	health.death_callback = death_callback

	for child in get_children():
		assert(child is QTETarget)
		child.hide()
	
	child_exiting_tree.connect(func() -> void:
		print("huh: ", get_child_count())
	)

func _process(_delta: float) -> void:
	# TODO: use exiting_tree family of signals instead?
	if get_child_count() == 0:
		health.kill()
		QTEVFX.end()

func death_callback(_health: Health) -> void:
	for child in get_children():
		assert(child is QTETarget)
		child.show()
	QTEVFX.start()
