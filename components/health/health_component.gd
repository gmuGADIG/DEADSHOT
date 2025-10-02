class_name HealthComponent extends Node

signal killed

@export var max_health : int

var health : int

func _ready() -> void:
	health = max_health

func hurt(amount : int) -> void:
	health-=amount
	print(get_parent().name,": ",health," hp")
	if health <= 0:
		killed.emit()

func heal(amount : int) -> void:
	health = clampi(health+amount,0,max_health)
