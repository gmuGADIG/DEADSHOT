extends Area3D

@export_file("*.tscn") var target_scene:String 
@export var target_entry_point:String

@onready var fade_panel : ColorRect = $Fade

func _on_body_entered(body: Node3D) -> void:
	if body is not Player: return
	
	Player.update_persisting_data()
	EntryPoints.set_entry_point(target_entry_point)
	
	fade_panel.show()
	fade_panel.color = Color(0,0,0,0)
	var fade_tween : Tween = create_tween()
	fade_tween.tween_property(fade_panel, "color", Color.BLACK, 3)
	await fade_tween.finished
	get_tree().change_scene_to_file(target_scene)
