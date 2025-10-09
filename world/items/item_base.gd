## Base class for any item pickup.
class_name Item extends Area3D

func _ready() -> void:
	body_entered.connect(on_pickup)

## Behaviour for when the item is collected.
func on_pickup(_body: Node3D) -> void:
	pass;
