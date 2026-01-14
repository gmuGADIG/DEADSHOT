@tool
extends CanvasGroup

@export var tex: NoiseTexture2D = preload("credits-noise.tres")

func _process(delta: float) -> void:
	(tex.noise as FastNoiseLite).offset.z += delta * 25.
