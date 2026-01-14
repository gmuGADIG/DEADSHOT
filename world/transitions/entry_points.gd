class_name EntryPoints extends Node3D

static var current_entry_point: String = ""

static var transition_duration : float = 0.5

static func set_entry_point(entry_point_name: String) -> void:
	current_entry_point = entry_point_name

@onready var fade_panel : ColorRect = ColorRect.new()
@onready var fade_tween : Tween = create_tween()

func _ready() -> void:
	fade_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_panel.set_offsets_preset(Control.PRESET_FULL_RECT)
	fade_panel.color = Color.BLACK
	add_child(fade_panel)
	fade_tween.tween_property(fade_panel, "color", Color(0,0,0,0),
		transition_duration)
	
	var entry_node: EntryPoint = get_node_or_null(current_entry_point)
	if entry_node == null:
		print("entry_points.gd: Entry node `%s` not found." % current_entry_point)
	else:
		print(entry_node.position)
		Player.instance.position = entry_node.global_position
		Player.instance.current_state = Player.PlayerState.TRANSITIONING
		Player.instance.previous_input_direction = entry_node.entry_direction
	current_entry_point = ""
	
	await fade_tween.finished
	Player.instance.current_state = Player.PlayerState.WALKING
	fade_panel.queue_free()
