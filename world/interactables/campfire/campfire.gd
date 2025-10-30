extends Interactable

@export var health_component : Health #Might be irrelevant?
@onready var max_health: int = Player.instance.health_component.max_health #Gets the max health index from player
static var usedList: Array = [] #Global array of all lit campfires
var extinguish: bool = false #Boolean if campfire is interacted with
func _ready() -> void:
	$CampfireMenu.hide()#Hides menu, control node
	
	if(usedList.has(get_path())): #Checks if campfire is in global array
		extinguish = true; #Extinguishes campfire
		
	if(extinguish): #Checks if campfire is extinguished, see above
		$campfireSprite.play('extinguished')
	else:
		$campfireSprite.play('lit')
	
func interact()->void:
	
	extinguish = true #Campfire has been interacted with
	if not usedList: #If this is a new campifre will add to array
		usedList.append(get_path())
	$CampfireMenu.visible = not $CampfireMenu.visible
	if(extinguish):
		$campfireSprite.play('extinguished')
	else:
		$campfireSprite.play('lit')
	
	
	
	Save.save_game()#Self Explanatory
	Player.instance.health_component.heal(max_health)#Calls the player's health component and heals
	
	
