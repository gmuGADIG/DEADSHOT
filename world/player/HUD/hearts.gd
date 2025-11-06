extends PanelContainer

@export var full_tex: Texture2D
@export var half_tex: Texture2D
@export var empty_tex: Texture2D

func set_hearts(value: int) -> void:
	var halves := value * 2
	for heart: TextureRect in get_children():
		if halves >= 2:
			heart.texture = full_tex
		elif halves == 1:
			heart.texture = empty_tex
		else:
			heart.texture = empty_tex
