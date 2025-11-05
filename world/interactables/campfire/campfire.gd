extends Interactable

static var used_list: Array = [] ## Global array of all lit campfires
var extinguish: bool = false ## Boolean if campfire is interacted with

func _ready() -> void:
	if(used_list.has(get_path())): # Checks if campfire is in global array
		extinguish = true # Extinguishes campfire
		
	if(extinguish): # Checks if campfire is extinguished, see above
		%Sprite.play('extinguished')
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
		used_list.append(get_path())
		%Sprite.play('extinguished')
		%Light.visible = false
	
	# open campfire menu
	var menu := preload("res://menu/campfire_menu/campfire_menu.tscn").instantiate()
	add_child(menu)
