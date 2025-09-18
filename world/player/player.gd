extends CharacterBody3D

## EXPORT VARIABLES
# Movement
@export var walkSpeed: float = 8.0
@export var rollSpeed: float = 18.0
## Controls how much player input affects steering when mid-roll. 
@export var rollInfluence: float = 8

## This timer node controls the amount of time rolling takes.
@export var rollDurationTimer: Timer

## These are the states that the player can be in. States control what the player can do.
## So far, they're just pertaining to movement. They might not always be, so I'm not calling it movementStates.
enum playerStates{
	WALKING,
	ROLLING
}
## This variable holds the current state. By default, the player will be walking
var currentState: playerStates = playerStates.WALKING


func _physics_process(_delta: float) -> void:
	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var movement := Vector3(input.x, 0, input.y)
	
	if Input.is_action_just_pressed("roll"):
		beginRoll()
	
	match currentState:
		playerStates.WALKING:
			velocity = movement * walkSpeed
		playerStates.ROLLING:
			## We move the velocity vector towards the direction of the movement. 
			## This means that velocity doesn't immediately become where we're pointing, but changes over time.
			## We normalize the shit out of everything so we can multiply it by a consistent speed.
			## This way there's no weird acceleration or slowdown.
			velocity = velocity.move_toward(movement.normalized(), rollInfluence).normalized() * rollSpeed
			# TODO: Rolling while not holding any other inputs effectively freezes you.
			# The previous facing direction should be considered. 
			
	move_and_slide()

func beginRoll() -> void:
	#TODO: Play animation, do iframes.
	currentState = playerStates.ROLLING
	rollDurationTimer.start()
	await rollDurationTimer.timeout
	currentState = playerStates.WALKING
	
	
