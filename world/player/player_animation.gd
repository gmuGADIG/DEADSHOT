extends AnimatedSprite3D
# This script controls the player's sprite animation and facing direction based on the player movement state and shooting.


## Player reference to check states
@export var player: Player
## Gun reference to check when fired
var gun: Gun

func _ready() -> void:
	#TODO: When the player changes their gun, this script will need to be told to get_gun() again and reconnect the signal! So will the player.
	gun = player.get_gun()
	gun.fired.connect(_on_gun_fired)
	player.player_state_changed.connect(_on_player_state_change)
	animation_finished.connect(_on_animation_finished)


func _process(_delta: float) -> void:
	updateMovementAnimation(player.current_state)
	if player.velocity == Vector3.ZERO: updateSpriteAnimation("idle")
	checkSpriteDirection()


func _on_player_state_change() -> void:
	updateMovementAnimation(player.current_state)
	
## Update if the player is walking or rolling
func updateMovementAnimation(state: Player.PlayerState) -> void:
	match state:
		player.PlayerState.WALKING:
			updateSpriteAnimation("walking")
		player.PlayerState.ROLLING:
			updateSpriteAnimation("rolling")

func updateSpriteAnimation(animationName: String) -> void:
	match animationName:
		"idle":
			# If the system tries to set the animation to idle, it won't be allowed to if
			# the player is in the middle of firing or rolling. That's information they need first.
			if animation=="rolling"||animation=="shooting":
				return
		"walking":
			# Similarly, if the system tries to play the walking animation, it'll be stopped if
			# the player is in the middle of shooting. Shooting takes priority.
			if animation=="shooting" || player.velocity == Vector3.ZERO:
				return
		"shooting":
			# We stop the sprite before playing the "shooting" animation. This means that if the player needs
			# to shoot before the animation is finished, the sprite will actually shoot again instead of continuing.
			stop()
	play(animationName)


func _on_animation_finished() -> void:
	# if we just finished finished animations that aren't allowed to be cancelled,
	# we'll set them to something else so the anti-cancel checks don't get confused. 
	if animation=="shooting"||animation=="rolling": 
		animation="idle"
	updateMovementAnimation(player.current_state)


func _on_gun_fired() -> void:
	# The player needs that feedback to see the direction they're shooting in. No matter how they're walking,
	# we flip the sprite to face towards their line of fire.
	if player.aim_dir().x >= 0: 
		flip_h=false
	else:
		flip_h=true
	updateSpriteAnimation("shooting")

## Flips sprite based on movement direction
func checkSpriteDirection() -> void:
	# We skip updating the direction if the player is shooting. We want the player to face their line of fire
	# more than we want them to face their movement direction.
	if animation=="shooting": return
	
	# Dot product of two normal vectors! 
	# The player sprite art is RIGHT FACING, i.e. always Vector2.RIGHT.
	# We're checking if the player's movement is in the same direction as that or not. If not, we flip it.
	var playerDirection: Vector2 = Vector2(player.velocity.x, player.velocity.z).normalized()
	var directionDifference: int = int(roundf(Vector2.RIGHT.dot(playerDirection)))
	match directionDifference:
		-1:
			flip_h=true
		0:
			flip_h=false
		1:
			flip_h=false
		_:
			printerr("player_animation.gd directionDifference is out of bounds!")
