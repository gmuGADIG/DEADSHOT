extends Interactable
var menuOpen: bool
func _ready() -> void:
	$CampfireMenu.hide()
	menuOpen = false
func interact()->void:
	menuOpen = !menuOpen
	if(menuOpen):
		$campfireSprite.texture = load("res://temp_art/gartic/shopping_cart_of_water.png")
		$CampfireMenu.show()
		
	else:
		$campfireSprite.texture = load("res://temp_art/gartic/lorax_kirby.png")
		$CampfireMenu.hide()
	Save.save_game()
