extends AnimatedSprite3D
# This script controls the player's sprite animation based on the player movement state and shooting.


## Player reference to check states
@export var player: Player
## Gun reference to check when fired
var gun: Gun

func _ready() -> void:
	#TODO: When the player changes their gun, this script will need to be told to get_gun() again! So will the player.
	gun = player.get_gun()
	gun.fired.connect(_on_gun_fired)
	player.player_state_changed.connect(_on_player_state_change)
	animation_finished.connect(_on_animation_finished)

func _process(_delta: float) -> void:
	updateMovementAnimation(player.current_state)
	if player.velocity == Vector3.ZERO: updateSpriteAnimation("idle")
	checkSpriteDirection()
	print(scale)


func _on_player_state_change() -> void:
	updateMovementAnimation(player.current_state)
	

## Update if the player is walking or rolling
func updateMovementAnimation(state: Player.PlayerState) -> void:
	match state:
		player.PlayerState.WALKING:
			updateSpriteAnimation("walking")
			#TODO: Flip sprite direction based on player direction
		player.PlayerState.ROLLING:
			updateSpriteAnimation("rolling")
			#TODO: Flip sprite direction based on player direction

func updateSpriteAnimation(animationName: String) -> void:
	match animationName:
		"idle":
			# If the system tries to set the animation to idle, it won't be allowed to if
			# the player is in the middle of firing or rolling. That's information they need first.
			if animation=="rolling"||animation=="shooting":
				return
		"walking":
			# Similarly, if the system tries to play the walking animation, it'll be stopped if
			# the player is in the middle of shooting.
			if animation=="shooting":
				return
	play(animationName)


func _on_animation_finished() -> void:
	# if we just finished finished animations that aren't allowed to be cancelled,
	# we'll set them to something else so the anti-cancel checks don't get confused. 
	if animation=="shooting"||animation=="rolling": 
		animation="idle"
	updateMovementAnimation(player.current_state)

func _on_gun_fired() -> void:
	#if/else statement to update the sprite's direction according to direction shot towards. skips if player is aiming perfectly upwards
	if player.aim_dir().x != 0: 
		scale.x = 0.39 * player.aim_dir().x/abs(player.aim_dir().x)
	else:
		return
	updateSpriteAnimation("shooting")


func checkSpriteDirection() -> void:
	var playerDirection: Vector2 = Vector2(player.velocity.x, player.velocity.z).normalized()
	var directionDifference: float = Vector2.RIGHT.dot(playerDirection)
	#updates the sprite's direction if the player isn't standing still nor shooting
	#TODO: fix lighting issue when the sprite is scaled negatively
	if (directionDifference != 0) && (animation != "shooting"):
		scale.x = 0.39 * directionDifference/abs(directionDifference)
	else:
		return
