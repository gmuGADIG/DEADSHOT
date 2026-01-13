extends Area3D

@export_file("*.tscn") var target_scene:String 
@export var target_entry_point:String

@onready var fade_panel : ColorRect = $Fade

var player : Player

func _on_body_entered(body: Node3D) -> void:
	if body is not Player: return
	player = body as Player
	
	Player.update_persisting_data()
	EntryPoints.set_entry_point(target_entry_point)
	
	player.current_state = Player.PlayerState.TRANSITIONING
	fade_panel.show()
	fade_panel.color = Color(0,0,0,0)
	var fade_tween : Tween = create_tween()
	fade_tween.tween_property(fade_panel, "color", Color.BLACK, 1)
	await fade_tween.finished
	player.current_state = Player.PlayerState.WALKING
	get_tree().change_scene_to_file(target_scene)
