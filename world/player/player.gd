class_name Player extends CharacterBody3D

signal player_state_changed
signal whipped

## Tracks name of current gun node. CHANGE THIS VARIABLE WHEN GUNS ARE CHANGED.
#static var gun_name := "Shotgun"
#static var gun_name := "Dualies"
#static var gun_name := "BasicGun"
enum FootstepState{
	FIRST = 0,
	LEFT = -1,
	RIGHT = 1
}
var footstep_state : FootstepState = FootstepState.FIRST

## These are the states that the player can be in. States control what the player can do.
enum PlayerState {
	WALKING, ## Default state. Player can walk and shoot.
	ROLLING, ## Dodging / rolling.
	INTERACTING, ## Interacting with an NPC. Most actions are disabled during this.
	DEAD, ## State of no health. All actions are disabled in this state.
	TRANSITIONING,  ## Moving between scenes and not accepting input
}


#region Variables
static var persisting_data : PlayerPersistingData
static var instance : Player

@onready var desert_particles : CPUParticles3D = $DesertAmbientParticles
@onready var cave_particles : CPUParticles3D = $CaveAmbientParticles


signal player_ready

var speed_multiplier: float = 1.0

## EXPORT VARIABLES
@export_category("Movement")
@export var walk_speed: float = 8.0
@export var roll_curve : Curve
@export var roll_influence_strength: float = 3 ## Controls how much player input affects steering when mid-roll.
@export var footstep : PackedScene

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

enum FloorType{ ## Where the player is walking
	WOOD,
	SAND,
	STONE,
	STONE_SOFT,
}
@export var floor_type: FloorType

@onready var starting_y_pos : float = position.y

var walk_sfx: AudioStreamPlayer3D
var walk_sfx_timer: Timer
#endregion

func setup_gun() -> void:
	for child in $Weapons.get_children():
		if child is Gun:
			child.process_mode = Node.PROCESS_MODE_DISABLED
			child.hide()
	var gun := get_gun()
	gun.process_mode = Node.PROCESS_MODE_INHERIT
	gun.show()
	gun.update_hud()

#region Builtin Functions
func _ready() -> void:
	
	walk_sfx = generate_walking_sounds() # Sets the player's walking sound.
	walk_sfx_timer = Timer.new()
	
	var frame_time := 1. / 8.
	walk_sfx_timer.wait_time = frame_time * 2 # the run sprite is 8 FPS and a basic 4 frame run cycle
	walk_sfx_timer.timeout.connect(play_walking_sfx)
	add_child(walk_sfx_timer)

	setup_gun()
	Global.skill_tree_changed.connect(func(_skill: SkillSet.SkillUID) -> void:
		if not get_gun().visible:
			setup_gun()
	)
	
	instance = self
	if persisting_data != null:
		health_component.max_health = persisting_data.max_health
		health_component.health = persisting_data.health
		get_gun().chamber_ammo = persisting_data.curr_chamber
		get_gun().reserve_ammo = persisting_data.curr_reserve
	
	interactor.interaction_started.connect(_on_interaction_started)
	interactor.interaction_ended.connect(_on_interaction_ended)
	
	health_component.hp_changed.connect(Global.player_hp_changed.emit)
	health_component.max_hp_changed.connect(Global.player_max_hp_changed.emit)
	
	health_component.killed.connect(_on_killed)

	var hp_skills := [
		SkillSet.SkillUID.SHOTGUN_HP_1,
		SkillSet.SkillUID.SHOTGUN_HP_2,
	]
	Global.skill_tree_changed.connect(func(skill: SkillSet.SkillUID) -> void:
		if skill in hp_skills:
			health_component.modify_max_health(2)
		if skill == SkillSet.SkillUID.PISTOL_ROLL_COOLDOWN:
			health_component.modify_max_health(-2)
		if skill == SkillSet.SkillUID.RIFLE_DAMAGE_2:
			health_component.modify_max_health(-2)
	)
	Global.skill_removed.connect(func(skill: SkillSet.SkillUID) -> void:
		if skill in hp_skills:
			health_component.modify_max_health(-2)
		if skill == SkillSet.SkillUID.PISTOL_ROLL_COOLDOWN:
			health_component.modify_max_health(2)
		if skill == SkillSet.SkillUID.RIFLE_DAMAGE_2:
			health_component.modify_max_health(2)
	)
	
	player_ready.emit()

func _init() -> void:
	instance = self

func _physics_process(delta: float) -> void:		
	walk_sfx_timer.paused = current_state != PlayerState.WALKING
	
	if current_state == PlayerState.WALKING:		
		var input_dir : Vector3 = input_direction()

		velocity = input_dir * walk_speed * speed_multiplier * skill_speed_mul()
		if input_dir != Vector3.ZERO:
			previous_input_direction = input_dir
			if walk_sfx_timer.is_stopped():
				walk_sfx_timer.start()
				play_walking_sfx()
		else:
			walk_sfx_timer.stop()
			footstep_state = FootstepState.FIRST
			
		if Input.is_action_just_pressed("roll") and whip.whip_state == Whip.WhipState.OFF:
			begin_roll()
		
	elif current_state == PlayerState.ROLLING:
		## We move the velocity vector towards the direction of the movement. 
		## This means that velocity doesn't immediately become where we're pointing, but changes over time.
		## We normalize the shit out of everything so we can multiply it by a consistent speed.
		## This way there's no weird acceleration or slowdown.
		roll(delta)
	elif current_state == PlayerState.INTERACTING:
		velocity = Vector3.ZERO
	elif current_state == PlayerState.TRANSITIONING:
		velocity = previous_input_direction * walk_speed * 0.5
	
	if current_state != PlayerState.DEAD:
		move_and_slide()

	position.y = starting_y_pos # ensures that player does not move above starting plane
	
	var is_whipping := whip.whip_state != Whip.WhipState.OFF
	%Weapons.visible = not is_whipping

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
	

func _on_killed() -> void:
	# Get rid of greyscale
	if QTEVFX.active:
		QTEVFX.end()

	current_state = PlayerState.DEAD
	var death_scene := preload("res://menu/death_menu/death_menu.tscn")
	$"../UI".add_child(death_scene.instantiate())

func get_gun() -> Gun:
	var gun_name := ""

	if SkillSet.has_skill(SkillSet.SkillUID.BOLT_ACTION_RIFLE):
		gun_name = "Rifle"
	elif SkillSet.has_skill(SkillSet.SkillUID.SHOTGUN):
		gun_name = "Shotgun"
	elif SkillSet.has_skill(SkillSet.SkillUID.DUAL_PISTOL):
		gun_name = "Dualies"
	else:
		gun_name = "BasicGun"

	return get_node("Weapons/" + gun_name)

func set_ambience(ambience_type : Level.AmbienceType) -> void:
	match ambience_type:
		Level.AmbienceType.DESERT:
			desert_particles.emitting = true
			cave_particles.emitting = false
		Level.AmbienceType.CAVE:
			desert_particles.emitting = false
			cave_particles.emitting = true
	pass

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
	#REDUNDANT
	# This function only runs when the roll starts.
	# Get out of here if you're already rolling!
	#if current_state == PlayerState.ROLLING: return
	
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
	var roll_speed : float = roll_curve.sample(roll_time) * skill_speed_mul()
	
	##Influence the dash direction
	var roll_influence : Vector3 = input_direction()
	var angle_difference : float = previous_input_direction.signed_angle_to(roll_influence,Vector3.UP)
	
	if abs(angle_difference) <= deg_to_rad(135): ##Turn
		previous_input_direction = previous_input_direction.rotated(Vector3.UP,clampf(angle_difference,-roll_influence_strength*delta,roll_influence_strength*delta))
	else: ##Slowdown
		roll_speed *= 0.5
	
	##Apply velocity
	velocity = roll_dir * roll_speed
	var mul := 1. if not SkillSet.has_skill(SkillSet.SkillUID.PISTOL_DAMAGE) else 2.
	roll_time += delta * mul
	
	if roll_time >= roll_curve.max_domain:
		health_component.vulnerable = true
		current_state = PlayerState.WALKING

## Called every frame if the player is in combat.
func update_stamina(delta: float) -> void:
	if Encounter.is_encounter_active():
		var roll_bonus := 1.5 if SkillSet.has_skill(SkillSet.SkillUID.PISTOL_ROLL_COOLDOWN) else 1.0
		stamina += STAMINA_RECHARGE_RATE * roll_bonus * delta
		stamina = clampf(stamina, 0.0, 3.0)
	else:
		stamina = 3.0

# Determines what sound the player should make when walking, and generates
# the audio stream player that plays that sound
func generate_walking_sounds() -> AudioStreamPlayer3D: 
	var soundEffect : PackedScene
	
	match floor_type:
		FloorType.WOOD:
			soundEffect = load("res://audio/streams/WalkSFX/walk_wood.tscn")
		FloorType.SAND:
			soundEffect = load("res://audio/streams/WalkSFX/walk_sand.tscn")
		FloorType.STONE:
			soundEffect = load("res://audio/streams/WalkSFX/walk_stone.tscn")
		FloorType.STONE_SOFT:
			soundEffect = load("res://audio/streams/WalkSFX/walk_soft_stone.tscn")
	
	var ret := soundEffect.instantiate()
	add_child(ret)
	return ret
	

## Function bound to the signal for beginning an interaction.
## Changes the state to Interacting.
func _on_interaction_started() -> void:
	current_state = PlayerState.INTERACTING

## Connects to the hurt signal on the player's Health
func _on_hurt() -> void:
	%HurtSound.play()
	%HealthComponent.vulnerable = false
	%IFrameAnim.play("flash")
	await %IFrameAnim.animation_finished
	%HealthComponent.vulnerable = true

## Function bound to the signal for ending an interaction
## Changes state to Walking by default.
func _on_interaction_ended() -> void:
	current_state = PlayerState.WALKING

func play_walking_sfx() -> void:
	if current_state == PlayerState.ROLLING:
		return
	if footstep_state == FootstepState.FIRST:
		footstep_state = FootstepState.RIGHT
	else:
		var new_footstep := footstep.instantiate()
		add_sibling(new_footstep)
		new_footstep.global_position = $FootstepEmitter.global_position
		if footstep_state == FootstepState.RIGHT:
			new_footstep.global_position += velocity.normalized().rotated(Vector3.UP,-PI/2)*0.2
			footstep_state = FootstepState.LEFT
		else:
			new_footstep.global_position += velocity.normalized().rotated(Vector3.UP,PI/2)*0.2
			footstep_state = FootstepState.RIGHT
		if desert_particles.emitting:
			new_footstep.sand_kick()
	
	print("STEP")
	if(speed_multiplier == 0.5): #Check if player is in puddle
		%WalkPuddle.play() #Need to update to play puddle noise
	else:
		walk_sfx.play() #Play normal walking noise

func skill_speed_mul() -> float:
	var ret := 1.
	if SkillSet.has_skill(SkillSet.SkillUID.SHOTGUN_MOVEMENT_SPEED): ret *= 1.3
	if SkillSet.has_skill(SkillSet.SkillUID.PISTOL_MOVEMENT_SPEED): ret *= 1.3

	if SkillSet.has_skill(SkillSet.SkillUID.RIFLE_MAG): ret *= .8

	return ret

#endregion
