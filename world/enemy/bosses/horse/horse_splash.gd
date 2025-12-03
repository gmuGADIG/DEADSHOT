extends Node3D

@export var delay : float = 0.75 ##Time to wait before sending up the spike
@export var splash_curve : Curve ##How the spike moves over time
@onready var timer : Timer = $Timer
@onready var y_pos : float = $Splash.position.y

var age : float = -1

func prime() -> void:
	age = 0

func _ready() -> void:
	# Connect the timeout signal to a function in this script
	timer.wait_time = delay # Set wait time
	timer.one_shot = true # Make it run only once

func _process(delta: float) -> void:
	if not timer.is_stopped():
		if age >= 0:
			age += delta
		
		$Splash.position.y = y_pos + 3 * splash_curve.sample(1-(timer.time_left / delay))

func _on_damage_area_area_entered(area: Area3D) -> void:
	if area is Hurtbox:
		area.hit(DamageInfo.new(1,DamageInfo.Source.ENEMY))
		print("DAMAGED")

func Area_entered(_area: Area3D) -> void:
	timer.start() # Start the timer
	print("Chunk collision")
	#_area.queue_free()
	pass # Replace with function body.

func timer_timeout() -> void:
	queue_free()
	pass # Replace with function body.
