extends Bullet

@export var sprite_spin_speed : float = 360

@export var movement_curve : Curve
@export var skip_slowdown_time : float
@export var apex_time : float
var age : float

var reached_apex : bool = false

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	global_position += velocity * delta * movement_curve.sample(age)
	global_position.y = 1.0
	age += delta
	
	$Sprite3D.rotate(Vector3.UP,sprite_spin_speed * delta)
		 
	if not reached_apex and age >= apex_time:
		
		set_target(Player.instance.global_position)
		reached_apex = true
	if age > movement_curve.max_domain:
		queue_free()
