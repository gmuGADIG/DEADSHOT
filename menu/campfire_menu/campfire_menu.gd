class_name CampfireMenu
extends Control

static var instance: CampfireMenu

func _init() -> void:
	instance = self

func _on_skill_tree_pressed() -> void:
	var skill_tree := preload("res://menu/skill_tree/skill_tree.tscn").instantiate()
	add_sibling(skill_tree)
	close()
	await skill_tree.tree_exited
	queue_free()

func _on_cancel_pressed() -> void:
	await close()
	queue_free()

## Visually closes the scene.
## Note that it still needs to be freed.
## That way, the campfire knows to give control back to the player.
func close() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE # prevent clicking again while closing
	%Anim.play_backwards("start")
	await %Anim.animation_finished
