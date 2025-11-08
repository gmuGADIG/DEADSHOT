extends EnemyBase

## THE WILDER
## The wilder's a terrifying tanky lunatic with a grenade launcher. They zip around spamming grenade projectiles.



#region Variables

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
## How long to wait between firing a bullet
@export var timeBetweenShots: float = 0.2
## Select what node this fires as a bullet. It has to be of the Bullet class!
@export var bullet: PackedScene
## The most distance the enemy will travel in a single movement cycle
@export var maxTravelDistance: float = 5.0 
## Timer used to periodically check if the enemy is moving closer to its destination
@export var StuckTimer: Timer
## Stores a past position an arbitrary amount of time in the past to check if the enemy is moving closer to its destination
var pastPosition: Vector3
#endregion

#region Behaviour Functions

func _ready() -> void:
	super._ready()
	attack()
	stuckCheckLoop()


## FIND A NICE POSITION TO RUN TO
func enter_hostile() -> void:
	# Get a random point on the navigation mesh and go there.
	# NOTE: This only works if the current navigation map is FULLY CONTINUOUS and connected.
	# If there are separate mesh islands, the Wilder will try to go there and never stop.
	# This is a problem in test scenes, but the actual levels are fine. 
	var targetPoint: Vector3 = NavigationServer3D.map_get_random_point(get_world_3d().get_navigation_map(), 1, false)
	var targetIterations: int = 0
	
	# In this while loop, we test if the target point is too far away and re-roll until it's at a good distance.  
	# We want to do this because the enemy is meant to move erratically and randomly, and that illusion breaks
	# if the enemy is running 50 meters out in a straight line before it's able to roll for a new random point.
	# That's still technically moving between random positions, but it's not visibly chaotic enough.
	while true:
		targetIterations+=1
		if targetPoint.distance_to(self.global_position) > maxTravelDistance:
			targetPoint = NavigationServer3D.map_get_random_point(get_world_3d().get_navigation_map(), 1, false)
		else:
			print(targetIterations)
			break
		
	set_movement_target(targetPoint)

## RUN AROUND
func hostile() -> void:
	#set_movement_target(player.global_position);
	should_move = not is_close_to_destination();
	if is_close_to_destination(): switch_state(AggroState.HOSTILE)

## SHOOT AROUND
# While attack() is in the state machine and is called every frame while the state is HOSTILE,
# we aren't doing that here. This thing is constantly firing shots while moving around, not
# transitioning between a "hostile" and "attack" state. NEVER set the Wilder's state to ATTACKING!
func attack() -> void:
	while true:
		await get_tree().create_timer(timeBetweenShots, false).timeout
		if process_mode == ProcessMode.PROCESS_MODE_DISABLED: continue
		shootBullet()


## Create a bullet aimed at the player.
func shootBullet() -> void:
	var newBullet: Bullet = bullet.instantiate()
	newBullet.atk_source = DamageInfo.Source.ENEMY
	add_sibling(newBullet)
	newBullet.fire(self, getPlayerDirection())

func getPlayerDirection() -> Vector3:
	# We add 1 to the Y value of this vector to keep it aimed at the player's center of mass, not their origin.
	#var rawDirection: Vector3 = player.global_position-self.global_position + Vector3(0,1,0)
	var rawDirection: Vector3 = self.global_position.direction_to(player.global_position + Vector3(0,1,0))
	return rawDirection.normalized()

## The enemy checks that its position at the moment isn't the same as it was a short time prior. If they're too close, it must be stuck. Re-roll for a new position.
func stuckCheckLoop() -> void:
	while true:
		pastPosition = self.global_position
		await StuckTimer.timeout
		if self.global_position.distance_to(pastPosition) < 0.5:
			switch_state(AggroState.HOSTILE)

#endregion
