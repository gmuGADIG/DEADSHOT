extends Interactable

var menuOpen: bool = false
func interact()->void:
	menuOpen = !menuOpen
	if(menuOpen):
		$campfireSprite.texture = load("res://temp_art/gartic/shopping_cart_of_water.png")
		
	else:
		$campfireSprite.texture = load("res://temp_art/gartic/lorax_kirby.png")
	
		
