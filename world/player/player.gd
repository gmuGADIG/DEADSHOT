class_name Player extends CharacterBody3D

signal player_state_changed

class PlayerPersistingData:
	var max_health : int
	var health : int
	var curr_chamber : int
	var curr_reserve : int

## Tracks name of current gun node. CHANGE THIS VARIABLE WHEN GUNS ARE CHANGED.
static var gun_name := "Dualies"
#static var gun_name := "BasicGun"

## These are the states that the player can be in. States control what the player can do.
enum PlayerState {
	WALKING, ## Default state. Player can walk and shoot.
	ROLLING, ## Dodging / rolling.
	INTERACTING, ## Interacting with an NPC. Most actions are disabled during this.
}

#region Variables
static var persisting_data : PlayerPersistingData
static var instance : Player

var speed_multiplier: float = 1.0

## EXPORT VARIABLES
@export_category("Movement")
@export var walk_speed: float = 8.0
@export var roll_curve : Curve
@export var roll_influence_strength: float = 3 ## Controls how much player input affects steering when mid-roll.

@export_category("Dependencies")
@export var health_component : Health
@export var whip : Whip
@onready var interactor : Interactor = %InteractionArea

## Is the player currently in combat? If so, HUD will be shown and dashing will cost stamina.
var is_in_combat: bool = true

var previous_input_direction: Vector3 = Vector3.RIGHT ## Roll this way if you roll while not holding any directions. Updated every time the player makes a movement input.
var roll_time : float = 0

## Stamina. Consumed by rolling. Up to 3. We use a float so we can smoothly recharge it partially over time.
var stamina: float = 3.0:
	set(value):
		if value == stamina: return # no change
		stamina = value
		Global.player_stamina_changed.emit(stamina)

## How much stamina recharges every second
const STAMINA_RECHARGE_RATE: float = 0.666667

var current_state: PlayerState = PlayerState.WALKING:
	set(new_val):
		current_state = new_val
		player_state_changed.emit()
#endregion

@onready var starting_y_pos : float = position.y
#endregion

#region Builtin Functions
func _ready() -> void:
	var gun := instance.get_node(gun_name)
	
	instance = self
	if persisting_data != null:
		health_component.max_health = persisting_data.max_health
		health_component.health = persisting_data.health
		gun.chamber_ammo = persisting_data.curr_chamber
		gun.reserve_ammo = persisting_data.curr_reserve
	
	interactor.interaction_started.connect(_on_interaction_started)
	interactor.interaction_ended.connect(_on_interaction_ended)
	
	health_component.hp_changed.connect(Global.player_hp_changed.emit)
	health_component.max_hp_changed.connect(Global.player_max_hp_changed.emit)

func _init() -> void:
	instance = self

func _physics_process(delta: float) -> void:
	#if health drops below zero, wait for a bit (if there is a death animation), then go to death screen
	if(instance.health_component.health <= 0):
		await get_tree().create_timer(0.2, true,true).timeout
		get_tree().change_scene_to_file("res://menu/death_menu/death_menu.tscn")
		
	if Input.is_action_just_pressed("roll") and whip.whip_state == Whip.WhipState.OFF:
		begin_roll()
	
	if current_state == PlayerState.WALKING:
		var input_dir : Vector3 = input_direction()
		velocity = input_dir * walk_speed * speed_multiplier
		if input_dir != Vector3.ZERO:
			previous_input_direction = input_dir
	elif current_state == PlayerState.ROLLING:
		## We move the velocity vector towards the direction of the movement. 
		## This means that velocity doesn't immediately become where we're pointing, but changes over time.
		## We normalize the shit out of everything so we can multiply it by a consistent speed.
		## This way there's no weird acceleration or slowdown.
		roll(delta)
	elif current_state == PlayerState.INTERACTING:
		velocity = Vector3.ZERO
	
	move_and_slide()
	position.y = starting_y_pos # ensures that player does not move above starting plane

## We use the proper process function to update stamina, since it appears on the HUD and that could be drawn faster than the physics tickrate.
func _process(delta: float) -> void:
	update_stamina(delta)
#endregion

#region Custom Functions
static func update_persisting_data() -> void:	
	if persisting_data == null:
		persisting_data = PlayerPersistingData.new()
		
	persisting_data.max_health = instance.health_component.max_health
	persisting_data.health = instance.health_component.health
	persisting_data.curr_chamber = instance.get_gun().chamber_ammo
	persisting_data.curr_reserve = instance.get_gun().reserve_ammo

func get_gun() -> Gun:
	return get_node(gun_name)

## Returns the inputted walking direction on the XZ plane (Y = 0)
func input_direction() -> Vector3:
	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	return Vector3(input.x,0,input.y)

## Returns the direction from the player to the reticle (Y = 0)
func aim_dir() -> Vector3:
	var dir: Vector3 = %Reticle.global_position - self.global_position
	dir.y = 0
	return dir.normalized()

## Checks if the player is able to shoot or not.
func can_shoot() -> bool:
	# The player should only be able to shoot from the walking state.
	if current_state != PlayerState.WALKING:
		return false
	# The player can't shoot if they are using the whip either.
	if whip.whip_state != Whip.WhipState.OFF:
		return false
	
	return true

## Begins the roll by changing the state and decreasing stamina.
func begin_roll() -> void:
	# This function only runs when the roll starts.
	# Get out of here if you're already rolling!
	if current_state == PlayerState.ROLLING: return
	
	# Factor in stamina
	if stamina < 1.0: return
	stamina -= 1.0
	
	%RollSound.play()
	current_state = PlayerState.ROLLING
	health_component.vulnerable = false
	roll_time = 0

## Roll the player in the current direction.
func roll(delta : float) -> void:
	var roll_dir : Vector3 = previous_input_direction
	var roll_speed : float = roll_curve.sample(roll_time)
	
	##Influence the dash direction
	var roll_influence : Vector3 = input_direction()
	var angle_difference : float = previous_input_direction.signed_angle_to(roll_influence,Vector3.UP)
	
	if abs(angle_difference) <= deg_to_rad(135): ##Turn
		previous_input_direction = previous_input_direction.rotated(Vector3.UP,clampf(angle_difference,-roll_influence_strength*delta,roll_influence_strength*delta))
	else: ##Slowdown
		roll_speed *= 0.5
	
	##Apply velocity
	velocity = roll_dir * roll_speed
	roll_time += delta
	
	if roll_time >= roll_curve.max_domain:
		health_component.vulnerable = true
		current_state = PlayerState.WALKING

## Called every frame if the player is in combat.
func update_stamina(delta: float) -> void:
	if Encounter.is_encounter_active():
		stamina += STAMINA_RECHARGE_RATE * delta
		stamina = clampf(stamina, 0.0, 3.0)
	else:
		stamina = 3.0

## Function bound to the signal for beginning an interaction.
## Changes the state to Interacting.
func _on_interaction_started() -> void:
	current_state = PlayerState.INTERACTING

## Connects to the was_hit signal on the player's Hurtbox to play a sound.
func _on_hurtbox_component_was_hit(_dmg: DamageInfo) -> void:
	%HurtSound.play()

## Function bound to the signal for ending an interaction
## Changes state to Walking by default.
func _on_interaction_ended() -> void:
	current_state = PlayerState.WALKING

#endregion
