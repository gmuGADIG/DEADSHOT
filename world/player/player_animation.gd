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
	player.whip.whipped.connect(_on_whipped)


func _process(_delta: float) -> void:
	if player.current_state != Player.PlayerState.DEAD:
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
		player.PlayerState.DEAD:
			_on_player_death()

func updateSpriteAnimation(animationName: String) -> void:
	match animationName:
		"idle":
			# If the system tries to set the animation to idle, it won't be allowed to if
			# the player is in the middle of firing or rolling. That's information they need first.
			if animation in ["rolling", "shooting", "whipping"]:
				return
		"walking":
			# Similarly, if the system tries to play the walking animation, it'll be stopped if
			# the player is in the middle of shooting. Shooting takes priority.
			if animation in ["shooting", "whipping"] || player.velocity == Vector3.ZERO:
				return
		"shooting":
			# We stop the sprite before playing the "shooting" animation. This means that if the player needs
			# to shoot before the animation is finished, the sprite will actually shoot again instead of continuing.
			stop()
		"whipping":
			stop()
	play(animationName)

func _on_player_death() -> void:
	play_backwards("rolling")

func _on_animation_finished() -> void:
	# if we just finished finished animations that aren't allowed to be cancelled,
	# we'll set them to something else so the anti-cancel checks don't get confused. 
	if animation in ["shooting", "rolling", "whipping"]:
		animation="idle"
	elif player.current_state == Player.PlayerState.DEAD:
		play("dead")
		speed_scale = 0
		return
	updateMovementAnimation(player.current_state)

func _on_whipped() -> void:
	updateSpriteAnimation("whipping")

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
	
	# Flip sprite based on player velocity.
	if player.velocity.x < 0:
		flip_h = true
	elif player.velocity.x > 0:
		flip_h = false
