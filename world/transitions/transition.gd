extends Area3D

@export_file("*.tscn") var target_scene : String 
@export var target_entry_point:String

@onready var fade_panel : ColorRect = $Fade

var player : Player

func _on_body_entered(body: Node3D) -> void:
	if body is not Player: return
	player = body as Player
	
	Player.update_persisting_data()
	EntryPoints.set_entry_point(target_entry_point)
	
	player.current_state = Player.PlayerState.TRANSITIONING
	player.collision_mask = 0
	fade_panel.color = Color(0,0,0,0)
	fade_panel.show()
	var fade_tween : Tween = create_tween()
	fade_tween.tween_property(fade_panel, "color", Color.BLACK,
		EntryPoints.transition_duration)
	await fade_tween.finished
	change_scene_smooth(target_scene)

func change_scene_smooth(scene_path : String) -> void:
	var tree := get_tree()
	var prev_scene : Node = tree.current_scene
	var next_scene : Node = load(scene_path).instantiate()
	tree.get_root().add_child(next_scene)
	prev_scene.hide()
	prev_scene.queue_free()
	tree.get_root().remove_child(prev_scene)
	tree.set_current_scene(next_scene)
