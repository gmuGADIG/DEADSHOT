extends EnemyBase

@export var bullet: PackedScene

#region Behavoiur Functions
var swapTime: int = 0
var swapInt: int = randi_range(120, 240)
var shootTime: int = 0
var shootInt: int = 10
var maxSpeed: float = 0.05
var xSpeed: float = randf_range(-maxSpeed,maxSpeed)
var zSpeed: float = randf_range(-maxSpeed,maxSpeed)
func _ready() -> void:
	super._ready()
	switch_state(AggroState.HOSTILE)
	
func hostile() -> void: 
	position.x += xSpeed
	position.z += zSpeed
	swapTime += 1
	shootTime += 1
	if swapTime >= swapInt:
		swapTime = 0
		swapInt = randi_range(120, 240)
		xSpeed = randf_range(-maxSpeed,maxSpeed)
		zSpeed = randf_range(-maxSpeed,maxSpeed)
		switch_state(AggroState.ATTACKING)
	if shootTime >= shootInt:
		shootTime = 0
		var b: Bullet = bullet.instantiate()
		b.atk_source = DamageInfo.Source.ENEMY
		add_sibling(b)
		b.fire(self, global_position.direction_to(player.global_position) + Vector3(randf_range(-0.2,0.2),0,0))
	
func attack() -> void:
	print("I am attak")
#endregion
