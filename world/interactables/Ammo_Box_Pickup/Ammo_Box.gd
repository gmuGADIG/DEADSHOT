extends Area3D

@export var ammo: int
func _on_body_entered(body: Node3D) -> void:
	# player will pick up ammo when it collides
	if body is Player:
		
		print("ammo Box picked up")
		
