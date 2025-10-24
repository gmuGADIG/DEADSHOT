class_name Player extends CharacterBody3D

class PlayerPersistingData:
	var max_health : int
	var health : int
	
static var persisting_data : PlayerPersistingData

static var instance:Player
var speed_multiplier: float = 1.0;
## EXPORT VARIABLES
@export_category("Movement")
@export var walk_speed: float = 8.0
@export var roll_speed: float = 18.0
@export var roll_duration: float = 0.4
@export var roll_influence: float = 8 ## Controls how much player input affects steering when mid-roll.
@export_category("Dependencies")
@export var health_component : Health
@export var whip : Whip

var previous_facing_direction: Vector2 = Vector2.RIGHT ## Roll this way if you roll while not holding any directions. Updated every time the player makes a movement input.

## Is the player currently in combat? If so, HUD will be shown and dashing will cost stamina.
var is_in_combat: bool = false

## Stamina. Consumed by rolling. Up to 3. We use a float so we can smoothly recharge it partially over time.
var stamina: float = 3.0
## How much stamina recharges every second. It should take 1.5 seconds for 1 bar to recover.
const STAMINA_RECHARGE_RATE: float = 0.666667

## These are the states that the player can be in. States control what the player can do.
enum PlayerState {
	WALKING,
	ROLLING
}

var current_state: PlayerState = PlayerState.WALKING

static func update_persisting_data() -> void:
	if persisting_data == null:
		persisting_data = PlayerPersistingData.new()
	
	persisting_data.max_health = Player.instance.health_component.max_health
	persisting_data.health = Player.instance.health_component.health

## Returns the inputted walking direction on the XZ plane (Y = 0)
func walking_dir() -> Vector3:
	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	# We always save the last real direction (non-zero vector) the player gave as a failsafe for rolling. 
	if input!=Vector2.ZERO: previous_facing_direction = input
	# If the player is rolling but didn't hit a direction, let's make sure they go somewhere. Without this and the previous check, rolling without input would freeze you.
	if input == Vector2.ZERO && current_state == PlayerState.ROLLING: input = previous_facing_direction
	return Vector3(input.x, 0, input.y)

func _ready() -> void:
	instance = self
	if persisting_data != null:
		health_component.max_health = persisting_data.max_health
		health_component.health = persisting_data.health

func _init() -> void:
	instance = self

## Returns the direction from the player to the reticle (Y = 0)
func aim_dir() -> Vector3:
	var dir: Vector3 = %Reticle.global_position - self.global_position
	dir.y = 0
	return dir.normalized()


func _physics_process(_delta: float) -> void:
	
	if Input.is_action_just_pressed("roll") and whip.whip_state == Whip.WhipState.OFF:
		begin_roll()
	
	if current_state == PlayerState.WALKING:
		velocity = walking_dir() * walk_speed * speed_multiplier
	elif current_state == PlayerState.ROLLING && whip.whip_state == Whip.WhipState.OFF:
		## We move the velocity vector towards the direction of the movement. 
		## This means that velocity doesn't immediately become where we're pointing, but changes over time.
		## We normalize the shit out of everything so we can multiply it by a consistent speed.
		## This way there's no weird acceleration or slowdown.
		velocity = velocity.move_toward(walking_dir().normalized(), roll_influence).normalized() * roll_speed
			
	move_and_slide()
		
## We use the proper process function to update stamina, since it appears on the HUD and that could be drawn faster than the physics tickrate.
func _process(delta: float) -> void:
	if is_in_combat: update_stamina(delta)
	
	# TEST COMBAT ENCOUNTER MODE FOR STAMINA
	if Input.is_action_just_pressed("ui_focus_next"):
		if is_in_combat:
			exit_combat()
		else:
			enter_combat()

func can_shoot() -> bool:
	if current_state == PlayerState.ROLLING:
		return false
	
	if whip.whip_state != Whip.WhipState.OFF:
		return false
	
	return true

func begin_roll() -> void:
	# This function only runs when the roll starts. Get out of here if you're already rolling!
	if current_state == PlayerState.ROLLING: return
	
	# Factor in stamina
	if stamina < 1.0: return
	stamina -= 1.0
	
	#TODO: Play animation, do iframes.
	current_state = PlayerState.ROLLING
	%RollDurationTimer.start()
	await %RollDurationTimer.timeout
	current_state = PlayerState.WALKING

## Called every frame if the player is in combat.
func update_stamina(delta: float) -> void:
	if is_in_combat:
		stamina += STAMINA_RECHARGE_RATE * delta
		stamina = clampf(stamina, 0.0, 3.0)
		$Hud.update_stamina_bar(stamina)
	else:
		stamina = 3.0


# COMBAT ENCOUNTERS
# According to the GDD, the player will enter Combat Encounters. These involve:
# - The camera locking
# - Enemies spawning in a group
# - Rolling becomes stamina-dependent
# To handle all of this, some other object should just tell the player about combat encounters with signals.
# These next two functions are provided to hook your signals into.
## Call this to tell the player that a combat encounter is beginning.
func enter_combat() -> void:
	if is_in_combat: return
	is_in_combat = true
	$Hud.fade_stamina_in()
## Call this to tell the player that a combat encounter is done.
func exit_combat() -> void:
	if !is_in_combat: return
	is_in_combat = false
	stamina = 3.0
	$Hud.fade_stamina_out()
