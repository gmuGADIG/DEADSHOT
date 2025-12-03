extends CanvasLayer

@export var fade_curve : Curve
@export var scene_change_time : float

var transition_time : float = -1
var switched_scenes : bool
var next_scene : String

func in_transition() -> bool:
	return transition_time >= 0

func change_scene_to_file(file_path : String, pause_scene : bool = false) -> void:
	transition_time = 0
	switched_scenes = false
	next_scene = file_path
	$ColorRect.show()
	get_tree().paused = pause_scene

func quit_game() -> void:
	transition_time = 0
	switched_scenes = false
	next_scene = "quit"
	$ColorRect.show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if transition_time >= 0:
		transition_time += delta
		print(fade_curve.sample(transition_time))
		$ColorRect.color.a = fade_curve.sample(clampf(transition_time,fade_curve.min_domain,fade_curve.max_domain))
		if not switched_scenes and transition_time >= scene_change_time:
			if next_scene == "quit":
				get_tree().quit()
			else:
				get_tree().change_scene_to_file(next_scene)
		if transition_time >= fade_curve.max_domain:
			$ColorRect.hide()
			transition_time = -1
