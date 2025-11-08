## Base class for any item pickup.
class_name Item extends Area3D

@export var bobFrequency: float = 1.7
@export var bobAmplitude: float = 0.004
var time: float = 0.0

func _ready() -> void:
	connect("body_entered", Callable(self, "on_pickup"))

## Makes the item bob up and down.
func _process(delta: float) -> void:
	time+=delta
	$Sprite3D.position.y += sin(time * bobFrequency)*bobAmplitude
	

## Behaviour for when the item is collected.
func on_pickup(_body: Node3D) -> void:
	pass
