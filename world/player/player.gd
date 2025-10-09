extends CharacterBody3D

## EXPORT VARIABLES
@export var walk_speed: float = 8.0

@export var roll_speed: float = 18.0
@export var roll_duration: float = 0.4
@export var roll_influence: float = 8 ## Controls how much player input affects steering when mid-roll. 

## These are the states that the player can be in. States control what the player can do.
enum PlayerState {
	WALKING,
	ROLLING
}

var current_state: PlayerState = PlayerState.WALKING

## Returns the inputted walking direction on the XZ plane (Y = 0)
func walking_dir() -> Vector3:
	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	return Vector3(input.x, 0, input.y)

func _physics_process(_delta: float) -> void:
	check_interactions()
	
	if Input.is_action_just_pressed("roll"):
		begin_roll()
	
	match current_state:
		PlayerState.WALKING:
			velocity = walking_dir() * walk_speed
		PlayerState.ROLLING:
			## We move the velocity vector towards the direction of the movement. 
			## This means that velocity doesn't immediately become where we're pointing, but changes over time.
			## We normalize the shit out of everything so we can multiply it by a consistent speed.
			## This way there's no weird acceleration or slowdown.
			velocity = velocity.move_toward(walking_dir().normalized(), roll_influence).normalized() * roll_speed
			# TODO: Rolling while not holding any other inputs effectively freezes you.
			# The previous facing direction should be considered. 
			
	move_and_slide()

func check_interactions() -> void:
	var area: Area3D = %InteractionArea
	#print(overlaps.size())
	var closest : Interactable
	if Input.is_action_just_pressed("interact"):
		closest = %InteractionArea.get_closest_interactable()
		if closest != null:
			%InteractionArea.interact(closest);
		
		

func begin_roll() -> void:
	#TODO: Play animation, do iframes.
	current_state = PlayerState.ROLLING
	%RollDurationTimer.start()
	await %RollDurationTimer.timeout
	current_state = PlayerState.WALKING
	
	
