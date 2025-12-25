extends TutorialPopup

@export var spacebar_prompt : TutorialPopup
## How close the player needs to be when shooting to trigger the vanish
@export var required_proximity : float = 90

func _ready() -> void:
	$AnimationPlayer.play("dodge_tutorial")

func _process(delta: float) -> void:
	if visible == false:
		return
	if not destroying_tutorial:
		var dist_squared := global_position.distance_squared_to(Player.instance.global_position)
		#print(dist_squared)
		if dist_squared < required_proximity && Input.is_action_just_pressed("roll"):
			destroying_tutorial = true
			spacebar_prompt.destroying_tutorial = true
			$VanishSound.play()
	super._process(delta)


func _on_texture_changed() -> void:
	shader_mat.set_shader_parameter("albedo_texture",texture)


func _on_roll_spacebar_texture_changed() -> void:
	spacebar_prompt.shader_mat.set_shader_parameter("albedo_texture",spacebar_prompt.texture)
