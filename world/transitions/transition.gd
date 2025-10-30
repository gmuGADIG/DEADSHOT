extends Area3D
@export_file("*.tscn") var target_scene:String 
@export var target_entry_point:String

func _on_body_entered(body: Node3D) -> void:
	if body is not Player: return
	
	var player: Player = body
	if player.is_in_combat:
		print("is in combat")
		return
	
	Player.update_persisting_data()
	
	EntryPoints.set_entry_point(target_entry_point)
	get_tree().change_scene_to_file(target_scene)
	
	
