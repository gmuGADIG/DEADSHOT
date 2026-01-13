extends AnimatedSprite3D

@export var walk_left: EnemyFrames
@export var walk_right: EnemyFrames

@export var attack_enabled := true
@export var attack_left: EnemyFrames
@export var attack_right: EnemyFrames

@onready var enemy: EnemyBase = get_parent()

var dir := 1 ## 1 for right; -1 for left
var attacking := false

func _ready() -> void:
	if OS.has_feature("debug"):
		if walk_left == null or walk_right == null:
			push_error("Missing walking frames!")
			set_process(false)
		
		if attack_enabled and attack_left == null or attack_right == null:
			push_error("Missing attacking frames!")
			set_process(false)

func _process(_delta: float) -> void:
	if enemy.velocity.x < 0:
		dir = -1
	else:
		dir = +1
	
	if not attacking:
		_set_frames(attack_left if dir < 0 else attack_right)

func _set_frames(frames: EnemyFrames) -> void:
	animation = frames.clip
	flip_h = frames.flipped

func attack() -> void:
	if not attack_enabled: return
	
	attacking = true
	_set_frames(attack_left if dir < 0 else attack_right)
	await animation_finished
	attacking = false
	
