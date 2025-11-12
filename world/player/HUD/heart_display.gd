extends Control

@export var full_tex: Texture2D
@export var half_tex: Texture2D
@export var empty_tex: Texture2D

func _ready() -> void:
	set_hp(Player.instance.health_component.health)
	set_max_hp(Player.instance.health_component.max_health)
	
	Global.player_hp_changed.connect(set_hp)
	Global.player_max_hp_changed.connect(set_max_hp)

func set_hp(hp: int) -> void:
	for heart: TextureRect in get_children():
		if hp >= 2:
			heart.texture = full_tex
		elif hp == 1:
			heart.texture = half_tex
		else:
			heart.texture = empty_tex
		hp -= 2

func set_max_hp(max_hp: int) -> void:
	var hearts := ceili(float(max_hp) / 2)
	for i in range(get_child_count()):
		get_child(i).visible = (i < hearts)
