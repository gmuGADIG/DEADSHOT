extends ColorRect

const MIN_RAD := 1.065
const MAX_RAD := 0.443

@onready var mat := (material as ShaderMaterial)

@onready var radius := MIN_RAD:
	set(v):
		radius = v
		mat.set_shader_parameter("radius", v)

var tween: Tween

func _ready() -> void:
	Player.instance.health_component.damaged.connect(owch)

func owch() -> void:
	# hit stop
	const HITSTOP_T := .2
	Engine.time_scale = 0.
	get_tree().create_timer(HITSTOP_T, true, false, true).timeout.connect(func() -> void: Engine.time_scale = 1.)

	if tween:
		tween.stop()

	tween = create_tween()
	tween.set_ignore_time_scale(true)
	tween.tween_property(self, "radius", max(radius - .2, MAX_RAD), .1)
	tween.tween_interval(.75)
	tween.tween_property(self, "radius", MIN_RAD, 1.5) \
		 .set_trans(Tween.TRANS_QUAD) \
		 .set_ease(Tween.EASE_IN)

# func _process(_delta: float) -> void:
# 	if Input.is_action_just_pressed("interact"):
# 		owch()
