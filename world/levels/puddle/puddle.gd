extends Area3D

#variables
@onready var damage_timer: Timer = %DamageTimer
@export var puddle_multipler: float = 0.25
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	print(Player.instance.speed_multiplier)
	print(damage_timer.time_left)

#lower player's movement multiplier 
#starts the damage timer
#TODO damage the player once health is added
func _on_body_entered(body: Node3D) -> void:
	Player.instance.speed_multiplier = puddle_multipler
	damage_timer.start()

#reset damage timer
#return player movement multiplier back to normal (1)
func _on_body_exited(body: Node3D) -> void:
	Player.instance.speed_multiplier = 1.0
	damage_timer.stop()
	
