extends EnemyBase

@export var bullet: PackedScene
@export var slash: PackedScene
@export var shootInt: int
@export var maxSpeed: float

#switch_state(AggroState.ATTACKING) <- USE THIS WHEN ADDING OTHER ATTACKS :P
#region Behavoiur Functions
var walkTime: int = 0
var walkInt: int = randi_range(30, 90)
var shootTime: int = 0
var swapTime: int = 0
var swapInt: int = randi_range(300,420)
var xSpeed: float = randf_range(-maxSpeed,maxSpeed)
var zSpeed: float = randf_range(-maxSpeed,maxSpeed)
var specialAttack: int = randi_range(0,1)
func _ready() -> void:
	super._ready()
	switch_state(AggroState.HOSTILE)
	
func hostile() -> void: 
	position.x += xSpeed
	position.z += zSpeed
	walkTime += 1
	shootTime += 1
	swapTime += 1
	if(swapTime >= swapInt):
		swapTime = 0
		print("I am attak")
		switch_state(AggroState.ATTACKING)
	if walkTime >= walkInt:
		walkTime = 0
		walkInt = randi_range(120, 240)
		xSpeed = randf_range(-maxSpeed,maxSpeed)
		zSpeed = randf_range(-maxSpeed,maxSpeed)
	if shootTime >= shootInt:
		shootTime = 0
		var b: Bullet = bullet.instantiate()
		b.atk_source = DamageInfo.Source.ENEMY
		add_sibling(b)
		b.fire(self, global_position.direction_to(player.global_position) + Vector3(randf_range(-0.2,0.2),0,0))
	
func attack() -> void:
	swapTime += 1
	if(specialAttack == 0): #tendrill sweep
		if(swapTime == 120):
			var s: Slash = slash.instantiate()
			s.scale.x *= 2
			s.scale.z *= 2
			s.atk_source = DamageInfo.Source.ENEMY
			add_sibling(s)
			s.fire(self, global_position.direction_to(player.global_position))
		if(swapTime == 180):
			swapTime = 0
			swapInt = randi_range(300,420)
			specialAttack = randi_range(0,1)
			switch_state(AggroState.HOSTILE)
	if(specialAttack == 1): #big sherrif star
		if(swapTime == 120):
			var b: Bullet = bullet.instantiate()
			b.scale *= 8
			b.atk_source = DamageInfo.Source.ENEMY
			add_sibling(b)
			b.fire(self, global_position.direction_to(player.global_position) + Vector3(randf_range(-0.2,0.2),0,0))
		if(swapTime == 180):
			swapTime = 0
			swapInt = randi_range(300,420)
			specialAttack = randi_range(0,1)
			switch_state(AggroState.HOSTILE)
		
#endregion
