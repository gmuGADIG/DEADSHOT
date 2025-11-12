extends Control

@export var full_tex: Texture2D
@export var half_tex: Texture2D
@export var empty_tex: Texture2D

func set_hearts(hearts: int) -> void:
	var halves := hearts * 2
	for heart: TextureRect in get_children():
		if halves >= 2:
			heart.texture = full_tex
		elif halves == 1:
			heart.texture = half_tex
		else:
			heart.texture = empty_tex
		halves -= 2

func set_max_hearts(max_hearts: int) -> void:
	for i in range(get_child_count()):
		get_child(i).visible = (i < max_hearts)
