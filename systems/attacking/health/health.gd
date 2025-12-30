class_name Health extends Node

signal hp_changed(value: float)
signal max_hp_changed(value: float)
signal killed
signal damaged

@export var max_health : float
@export var vulnerable:bool = true

var health : float: 
	set(v):
		health = v
		hp_changed.emit(health)

## If this callback is not null, then it will be called when the
## health component should die instead of the health component
## dying. 
## 
## It is then the job of the death callback to kill the health
## component when appropriate.
##
## The death callback is called with [code]death_callback(self)[/code].
var death_callback: Callable

## kills the health component :(
func kill() -> void:
	killed.emit()

func _ready() -> void:
	health = max_health

func hurt(amount : float) -> void:
	if !vulnerable: return
	
	if health <= 0: return # already dead
	
	health = clampf(health - amount, 0, health)
	damaged.emit()
	
	print(get_parent().name,": ",health," hp")
	if health <= 0:
		if death_callback.is_valid():
			death_callback.call(self)
		else:
			kill()

func heal(amount : float) -> void:
	health = clamp(health + amount, 0, max_health)

func modify_max_health(amount : float) -> void:
	max_health += amount
	max_hp_changed.emit(max_health)
	print("max health now ",max_health)
	
	if amount > 0:
		heal(amount)
	elif health > max_health:
		health = max_health
