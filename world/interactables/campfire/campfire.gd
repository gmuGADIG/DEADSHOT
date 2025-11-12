class_name Campfire
extends Interactable

var extinguish: bool = false ## Boolean if campfire is interacted with

func _ready() -> void:
	if Save.save_data.object_save_data.has_campfire(self):
		extinguish = true # Extinguishes campfire
		%Sprite.play('extinguished')
		%Light.visible = false
	else:
		%Sprite.play('lit')

func interact()->void:
	if CampfireMenu.instance != null:
		return # menu's already open; ignore
	
	if not extinguish:
		# save game and heal player to max hp
		Save.save_game()
		Player.instance.health_component.heal(Player.instance.health_component.max_health)

		# extinguish campfire
		extinguish = true
		
		Save.save_data.object_save_data.add_campfire(self)
		%Sprite.play('extinguished')
		%Light.visible = false
	
	# open campfire menu
	var menu := preload("res://menu/campfire_menu/campfire_menu.tscn").instantiate()
	add_child(menu)
	await menu.tree_exited
