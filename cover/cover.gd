#Kernighan Mitchell

extends Node3D

@export var health: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func hit(body: Node3D) -> void: 
	print("cover hit")
	body.queue_free()
	health -= 1
	print(health)
	if(health <= 0):
		self.queue_free()
