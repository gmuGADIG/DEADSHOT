extends CanvasLayer

@export var noise_texture: NoiseTexture2D

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("fire") and Player.instance:
		%CanvasModulate.color.a = 1.
		%Sprite2D.position = get_viewport().get_mouse_position()

		visible = true
		await create_tween().tween_property(%CanvasModulate, "color:a", 0, 0.15).finished
		visible = false
		noise_texture.noise.seed += 1
