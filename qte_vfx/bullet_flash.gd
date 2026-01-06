extends CanvasLayer

@export var noise_texture: NoiseTexture2D

@onready var canvas_modulate: CanvasModulate = %BFCanvasModulate
@onready var sprite: Sprite2D = %BFSprite

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("fire") and Player.instance:
		canvas_modulate.color.a = 1.
		sprite.position = get_viewport().get_mouse_position()

		show()
		await create_tween().tween_property(canvas_modulate, "color:a", 0, 0.15).finished
		hide()
		noise_texture.noise.seed += 1
