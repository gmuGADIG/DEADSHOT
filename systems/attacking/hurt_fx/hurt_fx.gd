extends Node3D

@onready var sprite: SpriteBase3D = get_parent()
@onready var sprite_pos := sprite.position

@export var health: Health
@export var bleed := true

func _ready() -> void:
	health.damaged.connect(_on_hurt)

func _on_hurt() -> void:
	_shake()
	if bleed:
		_flash_modulate()
		_blood_particles()

func _shake() -> void:
	const DURATION := 0.1
	# This code runs every frame while the effect is active
	create_tween().tween_method(
		func(t: float) -> void:
			sprite.position = sprite_pos
			if t == 0.0: return # set to normal position at the end
			
			var rand := Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1))
			sprite.position += rand * 0.2,
		0.0, 1.0, DURATION
	)

func _flash_modulate() -> void:
	sprite.modulate = Color("bd0000")
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color.WHITE

func _blood_particles() -> void:
	var blood := preload("res://systems/attacking/hurt_fx/blood_splatter.tscn").instantiate()
	get_tree().current_scene.add_child(blood)
	blood.global_position = global_position
	blood.global_position.y = 0
