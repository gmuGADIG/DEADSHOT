class_name SpriteShaker
extends Node

@export var shake_intensity := .25
@export var shake_speed := 300.

@export var shaking := false
@export var sprite: SpriteBase3D
@export var noise: FastNoiseLite

@onready var initial_sprite_transform := sprite.transform

var clock := 0.0
func _process(delta: float) -> void:
	sprite.transform = initial_sprite_transform
	
	if shaking:
		clock += delta * shake_speed
		
		var x := noise.get_noise_1d(clock) * shake_intensity
		var y := noise.get_noise_1d(-clock) * shake_intensity
		
		sprite.position += sprite.basis.x * x
		sprite.position += sprite.basis.y * y
	else:
		clock = 0.
