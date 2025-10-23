class_name Health extends Node

signal killed

@export var max_health : int

var health : int

func _ready() -> void:
	health = max_health

func hurt(amount : int) -> void:
	if health <= 0: return # already dead
	
	health -= amount
	
	print(get_parent().name,": ",health," hp")
	if health <= 0:
		killed.emit()

func heal(amount : int) -> void:
	health = clampi(health + amount, 0, max_health)

func modify_max_health(amount : int) -> void:
	
	max_health += amount
	print("max health now ",max_health)
	
	if amount > 0:
		heal(amount)
	elif health > max_health:
		health = max_health
