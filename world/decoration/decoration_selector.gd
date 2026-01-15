@tool
extends Node3D

## If true, `type` will be randomized on startup
@export var randomize_type := true

## Cycles between possible decoration sprites. [br]
## -1 = random [br]
## 0 and up for a specific sprite
@export var type := 0:
	set(value):
		type = value
		update_sprite()

@export var sprites: Array[Texture2D]

func _ready() -> void:
	if randomize_type: type = _random_index()
	update_sprite()
	
	if not Engine.is_editor_hint():
		if randf() < 0.5: scale.x *= -1

func update_sprite() -> void:
	if sprites.size() == 0: return
	%Sprite.texture = sprites[type % sprites.size()]

func _random_index() -> int:
	var rng := RandomNumberGenerator.new()
	rng.seed = get_path().hash()
	return rng.randi() % sprites.size()
