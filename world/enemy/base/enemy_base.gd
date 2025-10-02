class_name EnemyBase extends CharacterBody3D

@export var health : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func hit(damage: int, knockback : Vector3) -> void:
	health -= damage
	pass

func stun(time: float) -> void:
	pass
