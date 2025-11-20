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
	var time := 0.0
	while time < 0.1:
		sprite.position = sprite_pos + Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)) * .2
		
		await get_tree().process_frame
		time += get_process_delta_time()
	sprite.position = sprite_pos

func _flash_modulate() -> void:
	sprite.modulate = Color("bd0000")
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color.WHITE

func _blood_particles() -> void:
	var blood := preload("res://systems/attacking/hurt_fx/blood_splatter.tscn").instantiate()
	get_tree().current_scene.add_child(blood)
	blood.global_position = global_position
	blood.global_position.y = 0
